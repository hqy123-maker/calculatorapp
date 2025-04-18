import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({Key? key}) : super(key: key);

  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String expression = '';
  String result = '0';
  String lastExpression = '';
  bool justCalculated = false;

  void onButtonPressed(String buttonText) {
    setState(() {
      if (buttonText == 'AC') {
        expression = '';
        result = '0';
        lastExpression = '';
        justCalculated = false;
      } else if (buttonText == '+/-') {
        expression = toggleSign(expression);
      } else if (buttonText == '=') {
        if (expression.isNotEmpty) {
          try {
            Parser p = Parser();
            Expression exp = p.parse(processExpression(expression));
            ContextModel cm = ContextModel();
            lastExpression = expression; // Lưu phép toán cũ
            result = '${exp.evaluate(EvaluationType.REAL, cm)}';
            expression = ''; // Reset để bắt đầu phép toán mới
            justCalculated = true;
          } catch (e) {
            result = 'Error';
          }
        }
      } else if (['÷', '×', '-', '+'].contains(buttonText)) {
        if (justCalculated) {
          lastExpression = result;
          expression = result + buttonText;
          justCalculated = false;
        } else {
          expression += buttonText;
        }
      } else {
        if (justCalculated) {
          lastExpression = result;
          expression = buttonText;
          justCalculated = false;
        } else {
          expression += buttonText;
        }
      }
    });
  }

  String toggleSign(String expr) {
    if (expr.isEmpty) return expr;

    if (RegExp(r'^-?\d+(\.\d+)?$').hasMatch(expr)) {
      return expr.startsWith('-') ? expr.substring(1) : '-$expr';
    }

    RegExp lastNumberRegex = RegExp(r'(\d+\.?\d*)$');
    Match? match = lastNumberRegex.firstMatch(expr);

    if (match != null) {
      String lastNumber = match.group(0)!;
      String beforeNumber = expr.substring(0, match.start);

      if (beforeNumber.endsWith('(-')) {
        return beforeNumber.substring(0, beforeNumber.length - 2) + lastNumber;
      } else {
        return beforeNumber + '(-' + lastNumber;
      }
    }
    return expr;
  }

  String processExpression(String expr) {
    expr = expr.replaceAll('×', '*').replaceAll('÷', '/');

    // Đóng ngoặc nếu thiếu
    int openBrackets = '('.allMatches(expr).length;
    int closeBrackets = ')'.allMatches(expr).length;
    expr += ')' * (openBrackets - closeBrackets);

    return expr;
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(lastExpression,
                      style: const TextStyle(fontSize: 24, color: Colors.white70)),
                  Text(expression.isEmpty ? result : expression,
                      style: const TextStyle(
                          fontSize: 48,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: List.generate(
                  buttonLayout.length,
                      (rowIndex) => Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        buttonLayout[rowIndex].length,
                            (colIndex) {
                          String text = buttonLayout[rowIndex][colIndex];
                          bool isEqual = text == "=";
                          return Expanded(
                            flex: isEqual ? 2 : 1,
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: CalculatorButton(
                                text: text,
                                isGreen: greenButtons.contains(text),
                                isBlue: blueButtons.contains(text),
                                isLarge: isEqual,
                                onTap: () => onButtonPressed(text),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Layout các nút
List<List<String>> buttonLayout = [
  ['AC', '+/-', '%', '÷'],
  ['7', '8', '9', '×'],
  ['4', '5', '6', '-'],
  ['1', '2', '3', '+'],
  ['0', '.', '='],
];

// Các nút màu xanh lá
List<String> greenButtons = ['AC', '+/-', '%', '÷', '×', '-', '+', '='];

// Các nút màu xanh dương
List<String> blueButtons = [];

class CalculatorButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool isGreen;
  final bool isBlue;
  final bool isLarge;

  const CalculatorButton({
    Key? key,
    required this.text,
    required this.onTap,
    this.isGreen = false,
    this.isBlue = false,
    this.isLarge = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: isGreen ? Colors.greenAccent : (isBlue ? Colors.blue : Colors.white),
          shape: isLarge ? BoxShape.rectangle : BoxShape.circle,
          borderRadius: isLarge ? BorderRadius.circular(20) : null,
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: isBlue || isGreen ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
