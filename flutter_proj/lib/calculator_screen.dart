import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> with TickerProviderStateMixin {
  String _display = '0';
  String _firstOperand = '';
  String _secondOperand = '';
  String _operation = '';
  bool _waitingForOperand = false;
  bool _shouldResetDisplay = false;
  
  late AnimationController _displayController;
  late Animation<double> _displayAnimation;

  @override
  void initState() {
    super.initState();
    _displayController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _displayAnimation = CurvedAnimation(
      parent: _displayController,
      curve: Curves.easeOutCubic,
    );
    _displayController.forward();
  }

  @override
  void dispose() {
    _displayController.dispose();
    super.dispose();
  }

  void _inputDigit(String digit) {
    HapticFeedback.lightImpact();
    if (_shouldResetDisplay) {
      _display = '0';
      _shouldResetDisplay = false;
    }

    setState(() {
      if (_display == '0' && digit != '.') {
        _display = digit;
      } else if (digit == '.' && !_display.contains('.')) {
        _display += digit;
      } else if (digit != '.') {
        _display += digit;
      }
    });
    _displayController.forward(from: 0.8);
  }

  void _clear() {
    HapticFeedback.mediumImpact();
    setState(() {
      _display = '0';
      _firstOperand = '';
      _secondOperand = '';
      _operation = '';
      _waitingForOperand = false;
      _shouldResetDisplay = false;
    });
    _displayController.forward(from: 0.5);
  }

  void _setOperation(String op) {
    HapticFeedback.lightImpact();
    if (_firstOperand.isEmpty) {
      _firstOperand = _display;
    } else if (_operation.isNotEmpty && !_waitingForOperand) {
      _calculate();
      _firstOperand = _display;
    }

    setState(() {
      _operation = op;
      _waitingForOperand = true;
      _shouldResetDisplay = true;
    });
  }

  void _calculate() {
    HapticFeedback.mediumImpact();
    if (_operation.isEmpty || _firstOperand.isEmpty) return;

    double first = double.parse(_firstOperand);
    double second = _waitingForOperand ? first : double.parse(_display);
    double result = 0;

    try {
      switch (_operation) {
        case '+':
          result = _add(first, second);
          break;
        case '-':
          result = _subtract(first, second);
          break;
        case '×':
          result = _multiply(first, second);
          break;
        case '÷':
          result = _divide(first, second);
          break;
        case '^':
          result = _power(first, second);
          break;
        case 'max':
          result = _maximum(first, second);
          break;
        case 'min':
          result = _minimum(first, second);
          break;
      }

      setState(() {
        _display = _formatResult(result);
        _operation = '';
        _firstOperand = '';
        _waitingForOperand = false;
        _shouldResetDisplay = true;
      });
      _displayController.forward(from: 0.7);
    } catch (e) {
      setState(() {
        _display = 'Error';
        _shouldResetDisplay = true;
      });
    }
  }

  void _performUnaryOperation(String op) {
    HapticFeedback.lightImpact();
    double value = double.parse(_display);
    double result = 0;

    try {
      switch (op) {
        case '√':
          result = _squareRoot(value);
          break;
        case '|x|':
          result = _absoluteValue(value);
          break;
      }

      setState(() {
        _display = _formatResult(result);
        _shouldResetDisplay = true;
      });
      _displayController.forward(from: 0.8);
    } catch (e) {
      setState(() {
        _display = 'Error';
        _shouldResetDisplay = true;
      });
    }
  }

  String _formatResult(double result) {
    if (result == result.roundToDouble()) {
      return result.toInt().toString();
    }
    return result.toStringAsFixed(6).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  // Math operations
  double _add(double a, double b) => a + b;
  double _subtract(double a, double b) => a - b;
  double _multiply(double a, double b) => a * b;
  double _divide(double a, double b) {
    if (b == 0) throw Exception('Division by zero');
    return a / b;
  }
  double _squareRoot(double x) {
    if (x < 0) throw Exception('Square root of negative number');
    return math.sqrt(x);
  }
  double _power(double base, double exponent) => math.pow(base, exponent).toDouble();
  double _absoluteValue(double x) => x.abs();
  double _maximum(double a, double b) => math.max(a, b);
  double _minimum(double a, double b) => math.min(a, b);

  Widget _buildButton(
    String text, {
    Color? backgroundColor,
    Color? textColor,
    VoidCallback? onPressed,
    double? flex,
    bool isSpecial = false,
  }) {
    return Expanded(
      flex: flex?.toInt() ?? 1,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Material(
          elevation: isSpecial ? 8 : 4,
          shadowColor: backgroundColor?.withOpacity(0.4) ?? Colors.black26,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: onPressed ?? () {
              if (RegExp(r'[0-9.]').hasMatch(text)) {
                _inputDigit(text);
              }
            },
            borderRadius: BorderRadius.circular(20),
            splashColor: Colors.white.withOpacity(0.3),
            highlightColor: Colors.white.withOpacity(0.1),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: backgroundColor != null
                      ? [
                          backgroundColor.withOpacity(0.9),
                          backgroundColor,
                        ]
                      : [
                          const Color(0xFF2A2D3A),
                          const Color(0xFF212332),
                        ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: isSpecial ? 24 : 22,
                    fontWeight: FontWeight.w600,
                    color: textColor ?? Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1B26),
      body: SafeArea(
        child: Column(
          children: [
            // Display Section
            Container(
              height: MediaQuery.of(context).size.height * 0.35,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF2D3142),
                    const Color(0xFF1A1B26),
                  ],
                ),
              ),
              child: Column(
                children: [
                  // Top Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Calculator',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Standard',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Operation Display
                  if (_operation.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '$_firstOperand $_operation',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white.withOpacity(0.5),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  const Spacer(),
                  // Main Display
                  AnimatedBuilder(
                    animation: _displayAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _displayAnimation.value,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                _display,
                                style: const TextStyle(
                                  fontSize: 72,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white,
                                  letterSpacing: -2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Buttons Section
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Row 1: Clear and special operations
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton(
                            'C',
                            backgroundColor: const Color(0xFFEF476F),
                            onPressed: _clear,
                            flex: 2,
                            isSpecial: true,
                          ),
                          _buildButton(
                            '√',
                            backgroundColor: const Color(0xFF06FFA5),
                            textColor: const Color(0xFF1A1B26),
                            onPressed: () => _performUnaryOperation('√'),
                          ),
                          _buildButton(
                            '^',
                            backgroundColor: const Color(0xFF06FFA5),
                            textColor: const Color(0xFF1A1B26),
                            onPressed: () => _setOperation('^'),
                          ),
                        ],
                      ),
                    ),
                    // Row 2: 7, 8, 9, ÷
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton('7'),
                          _buildButton('8'),
                          _buildButton('9'),
                          _buildButton(
                            '÷',
                            backgroundColor: const Color(0xFF4361EE),
                            onPressed: () => _setOperation('÷'),
                            isSpecial: true,
                          ),
                        ],
                      ),
                    ),
                    // Row 3: 4, 5, 6, ×
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton('4'),
                          _buildButton('5'),
                          _buildButton('6'),
                          _buildButton(
                            '×',
                            backgroundColor: const Color(0xFF4361EE),
                            onPressed: () => _setOperation('×'),
                            isSpecial: true,
                          ),
                        ],
                      ),
                    ),
                    // Row 4: 1, 2, 3, -
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton('1'),
                          _buildButton('2'),
                          _buildButton('3'),
                          _buildButton(
                            '-',
                            backgroundColor: const Color(0xFF4361EE),
                            onPressed: () => _setOperation('-'),
                            isSpecial: true,
                          ),
                        ],
                      ),
                    ),
                    // Row 5: 0, ., =, +
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton('0', flex: 2),
                          _buildButton('.'),
                          _buildButton(
                            '+',
                            backgroundColor: const Color(0xFF4361EE),
                            onPressed: () => _setOperation('+'),
                            isSpecial: true,
                          ),
                        ],
                      ),
                    ),
                    // Row 6: |x|, max, min, =
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton(
                            '|x|',
                            backgroundColor: const Color(0xFF7209B7),
                            onPressed: () => _performUnaryOperation('|x|'),
                          ),
                          _buildButton(
                            'max',
                            backgroundColor: const Color(0xFF7209B7),
                            onPressed: () => _setOperation('max'),
                          ),
                          _buildButton(
                            'min',
                            backgroundColor: const Color(0xFF7209B7),
                            onPressed: () => _setOperation('min'),
                          ),
                          _buildButton(
                            '=',
                            backgroundColor: const Color(0xFFFF006E),
                            onPressed: _calculate,
                            isSpecial: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}