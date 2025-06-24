import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Ada WASM Bridge - Provides Dart interface to Ada math functions via WebView
class AdaWasmBridge {
  static const String _htmlAssetPath = 'assets/html/wasm_bridge.html';
  
  late WebViewController _controller;
  bool _isReady = false;
  int _requestIdCounter = 0;
  final Map<int, Completer<double>> _pendingRequests = {};

  /// Initialize the WASM bridge with a WebView controller
  Future<void> initialize(WebViewController controller) async {
    _controller = controller;
    
    // Set up JavaScript channels for communication
    await _controller.addJavaScriptChannel(
      'FlutterChannel',
      onMessageReceived: _handleJavaScriptMessage,
    );

    // Load the HTML bridge page
    await _controller.loadFlutterAsset(_htmlAssetPath);
    
    // Wait for WASM to be ready
    await _waitForWasmReady();
  }

  Future<void> _waitForWasmReady() async {
    final completer = Completer<void>();
    Timer? periodicTimer;
    Timer? timeoutTimer;
    
    // Poll for WASM readiness
    periodicTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) async {
      try {
        final result = await _controller.runJavaScriptReturningResult(
          'window.AdaMath && window.AdaMath.isReady()'
        );
        
        if (result == true) {
          _isReady = true;
          timer.cancel();
          timeoutTimer?.cancel();
          completer.complete();
        }
      } catch (e) {
        // Continue polling
      }
    });
    
    // Timeout after 10 seconds
    timeoutTimer = Timer(const Duration(seconds: 10), () {
      if (!completer.isCompleted) {
        periodicTimer?.cancel();
        completer.completeError('WASM initialization timeout');
      }
    });
    
    return completer.future;
  }

  /// Handle messages from JavaScript
  void _handleJavaScriptMessage(JavaScriptMessage message) {
    try {
      final data = jsonDecode(message.message);
      final String type = data['type'];
      
      switch (type) {
        case 'result':
          _handleResult(data);
          break;
        case 'error':
          _handleError(data);
          break;
        case 'wasm_ready':
          _isReady = true;
          break;
        case 'wasm_error':
          _isReady = false;
          break;
      }
    } catch (e) {
      debugPrint('Error handling JavaScript message: $e');
    }
  }

  /// Handle successful result from JavaScript
  void _handleResult(Map<String, dynamic> data) {
    final int requestId = data['requestId'];
    final double result = (data['result'] as num).toDouble();
    
    final completer = _pendingRequests.remove(requestId);
    completer?.complete(result);
  }

  /// Handle error from JavaScript
  void _handleError(Map<String, dynamic> data) {
    final int requestId = data['requestId'];
    final String error = data['error'];
    
    final completer = _pendingRequests.remove(requestId);
    completer?.completeError(AdaWasmException(error));
  }

  /// Execute a math operation and return the result
  Future<double> _executeOperation(String action, Map<String, dynamic> params) async {
    if (!_isReady) {
      throw AdaWasmException('WASM module not ready');
    }

    final requestId = ++_requestIdCounter;
    final completer = Completer<double>();
    _pendingRequests[requestId] = completer;

    final request = {
      'action': action,
      'params': params,
      'requestId': requestId,
    };

    // Send request to JavaScript
    await _controller.runJavaScript('''
      window.postMessage(${jsonEncode(request)}, '*');
    ''');

    // Set timeout for the request
    Timer(const Duration(seconds: 5), () {
      final pendingCompleter = _pendingRequests.remove(requestId);
      if (pendingCompleter != null && !pendingCompleter.isCompleted) {
        pendingCompleter.completeError(AdaWasmException('Request timeout'));
      }
    });

    return completer.future;
  }

  /// Add two numbers using Ada WASM
  Future<double> add(double a, double b) async {
    return _executeOperation('add', {'a': a, 'b': b});
  }

  /// Subtract two numbers using Ada WASM
  Future<double> subtract(double a, double b) async {
    return _executeOperation('subtract', {'a': a, 'b': b});
  }

  /// Multiply two numbers using Ada WASM
  Future<double> multiply(double a, double b) async {
    return _executeOperation('multiply', {'a': a, 'b': b});
  }

  /// Divide two numbers using Ada WASM
  Future<double> divide(double a, double b) async {
    return _executeOperation('divide', {'a': a, 'b': b});
  }

  /// Calculate square root using Ada WASM
  Future<double> sqrt(double x) async {
    return _executeOperation('sqrt', {'x': x});
  }

  /// Calculate power using Ada WASM
  Future<double> power(double base, double exp) async {
    return _executeOperation('power', {'base': base, 'exp': exp});
  }

  /// Calculate absolute value using Ada WASM
  Future<double> abs(double x) async {
    return _executeOperation('abs', {'x': x});
  }

  /// Find maximum of two numbers using Ada WASM
  Future<double> max(double a, double b) async {
    return _executeOperation('max', {'a': a, 'b': b});
  }

  /// Find minimum of two numbers using Ada WASM
  Future<double> min(double a, double b) async {
    return _executeOperation('min', {'a': a, 'b': b});
  }

  /// Check if WASM bridge is ready
  bool get isReady => _isReady;

  /// Dispose of resources
  void dispose() {
    // Complete any pending requests with errors
    for (final completer in _pendingRequests.values) {
      if (!completer.isCompleted) {
        completer.completeError(AdaWasmException('Bridge disposed'));
      }
    }
    _pendingRequests.clear();
  }
}

/// Exception thrown by Ada WASM operations
class AdaWasmException implements Exception {
  final String message;
  
  const AdaWasmException(this.message);
  
  @override
  String toString() => 'AdaWasmException: $message';
}
