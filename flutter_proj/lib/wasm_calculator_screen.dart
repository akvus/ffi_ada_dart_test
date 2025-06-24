import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'ada_wasm_bridge.dart';

/// Calculator screen that uses Ada WASM functions via WebView
class WasmCalculatorScreen extends StatefulWidget {
  const WasmCalculatorScreen({super.key});

  @override
  State<WasmCalculatorScreen> createState() => _WasmCalculatorScreenState();
}

class _WasmCalculatorScreenState extends State<WasmCalculatorScreen> {
  late WebViewController _webViewController;
  late AdaWasmBridge _adaBridge;
  
  bool _isLoading = true;
  String _status = 'Initializing Ada WASM bridge...';
  
  final TextEditingController _input1Controller = TextEditingController();
  final TextEditingController _input2Controller = TextEditingController();
  final TextEditingController _resultController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeWasm();
  }

  Future<void> _initializeWasm() async {
    try {
      _webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (String url) {
              debugPrint('WebView page finished loading: $url');
            },
          ),
        );

      // Initialize Ada bridge
      _adaBridge = AdaWasmBridge();
      await _adaBridge.initialize(_webViewController);

      setState(() {
        _isLoading = false;
        _status = 'Ada WASM bridge ready!';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = 'Error initializing WASM: $e';
      });
    }
  }

  /// Execute a math operation
  Future<void> _executeOperation(String operation) async {
    if (_isLoading || !_adaBridge.isReady) {
      _showSnackBar('WASM bridge not ready');
      return;
    }

    final input1Text = _input1Controller.text.trim();
    final input2Text = _input2Controller.text.trim();

    if (input1Text.isEmpty) {
      _showSnackBar('Please enter the first number');
      return;
    }

    final double? a = double.tryParse(input1Text);
    if (a == null) {
      _showSnackBar('Invalid first number');
      return;
    }

    double? b;
    if (['add', 'subtract', 'multiply', 'divide', 'power', 'max', 'min'].contains(operation)) {
      if (input2Text.isEmpty) {
        _showSnackBar('Please enter the second number');
        return;
      }
      b = double.tryParse(input2Text);
      if (b == null) {
        _showSnackBar('Invalid second number');
        return;
      }
    }

    try {
      double result;
      String operationText;

      switch (operation) {
        case 'add':
          result = await _adaBridge.add(a, b!);
          operationText = '$a + $b';
          break;
        case 'subtract':
          result = await _adaBridge.subtract(a, b!);
          operationText = '$a - $b';
          break;
        case 'multiply':
          result = await _adaBridge.multiply(a, b!);
          operationText = '$a × $b';
          break;
        case 'divide':
          result = await _adaBridge.divide(a, b!);
          operationText = '$a ÷ $b';
          break;
        case 'sqrt':
          result = await _adaBridge.sqrt(a);
          operationText = '√$a';
          break;
        case 'power':
          result = await _adaBridge.power(a, b!);
          operationText = '$a ^ $b';
          break;
        case 'abs':
          result = await _adaBridge.abs(a);
          operationText = '|$a|';
          break;
        case 'max':
          result = await _adaBridge.max(a, b!);
          operationText = 'max($a, $b)';
          break;
        case 'min':
          result = await _adaBridge.min(a, b!);
          operationText = 'min($a, $b)';
          break;
        default:
          throw Exception('Unknown operation: $operation');
      }

      _resultController.text = result.toString();
      _showSnackBar('$operationText = $result', isSuccess: true);

    } catch (e) {
      _showSnackBar('Error: $e');
      _resultController.text = 'Error';
    }
  }

  /// Show snackbar with message
  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Build operation button
  Widget _buildOperationButton(String operation, String label, {bool requiresTwoInputs = true}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          onPressed: _isLoading ? null : () => _executeOperation(operation),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ada WASM Calculator'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status indicator
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isLoading 
                  ? Colors.orange.shade100 
                  : (_adaBridge.isReady ? Colors.green.shade100 : Colors.red.shade100),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _isLoading 
                    ? Colors.orange 
                    : (_adaBridge.isReady ? Colors.green : Colors.red),
                ),
              ),
              child: Text(
                _status,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _isLoading 
                    ? Colors.orange.shade800 
                    : (_adaBridge.isReady ? Colors.green.shade800 : Colors.red.shade800),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Input fields
            TextField(
              controller: _input1Controller,
              decoration: const InputDecoration(
                labelText: 'First Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            
            const SizedBox(height: 12),
            
            TextField(
              controller: _input2Controller,
              decoration: const InputDecoration(
                labelText: 'Second Number (when needed)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            
            const SizedBox(height: 20),
            
            // Operation buttons
            const Text(
              'Operations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            // Basic operations
            Row(
              children: [
                _buildOperationButton('add', '+'),
                _buildOperationButton('subtract', '−'),
                _buildOperationButton('multiply', '×'),
                _buildOperationButton('divide', '÷'),
              ],
            ),
            
            // Advanced operations
            Row(
              children: [
                _buildOperationButton('sqrt', '√', requiresTwoInputs: false),
                _buildOperationButton('power', '^'),
                _buildOperationButton('abs', '|x|', requiresTwoInputs: false),
                const Expanded(child: SizedBox()), // Empty space
              ],
            ),
            
            // Min/Max operations
            Row(
              children: [
                _buildOperationButton('max', 'max'),
                _buildOperationButton('min', 'min'),
                const Expanded(child: SizedBox()), // Empty space
                const Expanded(child: SizedBox()), // Empty space
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Result field
            TextField(
              controller: _resultController,
              decoration: const InputDecoration(
                labelText: 'Result',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Clear button
            ElevatedButton(
              onPressed: () {
                _input1Controller.clear();
                _input2Controller.clear();
                _resultController.clear();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Clear All'),
            ),
            
            // Hidden WebView (for WASM bridge)
            if (_isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else
              SizedBox(
                height: 0,
                child: WebViewWidget(controller: _webViewController),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _input1Controller.dispose();
    _input2Controller.dispose();
    _resultController.dispose();
    _adaBridge.dispose();
    super.dispose();
  }
}
