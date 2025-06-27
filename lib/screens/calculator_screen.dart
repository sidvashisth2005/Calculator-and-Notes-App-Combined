// lib/screens/calculator_screen.dart
import 'package:flutter/material.dart';
import '../utils/button_values.dart'; // <--- UPDATED IMPORT PATH relative to screens folder

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

// This is a simple calculator screen that allows users to perform basic arithmetic operations.
class _CalculatorScreenState extends State<CalculatorScreen> {
  String number1 = "";
  String operand = "";
  String number2 = "";

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Output display
            Expanded(
              child: SingleChildScrollView(
                reverse: true,
                child: Container(
                  alignment: Alignment.bottomRight,
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    "$number1$operand$number2".isEmpty ? "0" : "$number1$operand$number2",
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ),
            ),
            // Buttons
            Wrap(
              children: Btn.buttonValues
                  .map(
                    (value) => SizedBox(
                      width: value == Btn.n0 ? screenSize.width / 2 : screenSize.width / 4,
                      height: screenSize.height / 8, // fixed height
                      child: buildButton(value),
                    ),
                  ).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildButton(String value) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Material(
        color: getBtnColor(value),
        clipBehavior: Clip.hardEdge,
        shape: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white24),
          borderRadius: BorderRadius.circular(100),
        ),
        child: InkWell(
          onTap: () => onBtnTap(value),
          child: Center(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  void onBtnTap(String value) {
    if (value == Btn.del) {
      delete();
    } else if (value == Btn.clear) {
      clearAll();
    } else if (value == Btn.percent) {
      convertToPercentage();
    } else if (value == Btn.equal) {
      equal();
    } else {
      appendValue(value);
    }
  }

  void equal() {
    if (number1.isEmpty || operand.isEmpty || number2.isEmpty) return;
    double num1 = double.parse(number1);
    double num2 = double.parse(number2);
    double result = 0.0;
    switch (operand) {
      case Btn.add:
        result = num1 + num2;
        break;
      case Btn.sub:
        result = num1 - num2;
        break;
      case Btn.multiply:
        result = num1 * num2;
        break;
      case Btn.div:
        if (num2 != 0) {
          result = num1 / num2;
        } else {
          number1 = "Error"; // Handle division by zero
          operand = "";
          number2 = "";
          setState(() {});
          return;
        }
        break;
    }

    setState(() {
      number1 = result.toString();
      if (number1.endsWith(".0")) {
        number1 = number1.substring(0, number1.length - 2);
      }
      operand = "";
      number2 = "";
    });
  }

  void convertToPercentage() {
    // Only convert if number1 is available and no operand/number2 are set
    if (number1.isEmpty || operand.isNotEmpty || number2.isNotEmpty) return;
    final number = double.parse(number1);
    setState(() {
      number1 = (number / 100).toString();
      if (number1.endsWith(".0")) {
        number1 = number1.substring(0, number1.length - 2);
      }
    });
  }

  void clearAll() {
    setState(() {
      number1 = "";
      operand = "";
      number2 = "";
    });
  }

  void delete() {
    setState(() {
      if (number2.isNotEmpty) {
        number2 = number2.substring(0, number2.length - 1);
      } else if (operand.isNotEmpty) {
        operand = "";
      } else if (number1.isNotEmpty) {
        number1 = number1.substring(0, number1.length - 1);
      }
    });
  }

  void appendValue(String value) {
    setState(() {
      // Handle operand input
      if (value != Btn.dot && double.tryParse(value) == null) {
        // Operand button
        if (number1.isEmpty || operand.isNotEmpty) return; // Don't allow operand if number1 is empty or operand is already set
        operand = value;
        return;
      }

      // Handle number and dot input
      if (operand.isEmpty) {
        // Building number1
        if (value == Btn.dot && number1.contains(Btn.dot)) return; // Prevent multiple dots
        if (value == Btn.dot && number1.isEmpty) value = "0."; // Prepend 0 if dot is first
        number1 += value;
      } else {
        // Building number2
        if (value == Btn.dot && number2.contains(Btn.dot)) return; // Prevent multiple dots
        if (value == Btn.dot && number2.isEmpty) value = "0."; // Prepend 0 if dot is first
        number2 += value;
      }
    });
  }

  Color getBtnColor(String value) {
    if ([Btn.del, Btn.clear].contains(value)) {
      return Colors.blueGrey;
    } else if ([Btn.percent, Btn.multiply, Btn.add, Btn.sub, Btn.div, Btn.equal]
        .contains(value)) {
      return Colors.orange;
    } else {
      return Colors.black87;
    }
  }
}