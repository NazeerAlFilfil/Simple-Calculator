import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vimto Calculator',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const MyHomePage(title: 'Vimto Calculator'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _expression = "";
  String _result = "";

  final double _regularFontSize = 25.0;
  final double _focusedFontSize = 35.0;
  double _expressionFontSize = 0;
  double _resultFontSize = 0;

  final int _expressionLimit = 45;

  void _changeSign(String str) {
    String lastCharacter = "";
    String secondLastCharacter = "";

    if(str.isEmpty) {
      lastCharacter = "";
      secondLastCharacter = "";
    } else if(str.length == 1) {
      lastCharacter = str.substring( str.length - 1, str.length );
      secondLastCharacter = "";
    } else {
      lastCharacter = str.substring( str.length - 1, str.length );
      secondLastCharacter = str.substring( str.length - 2, str.length - 1 );
    }

    if( isNumeric(lastCharacter) || lastCharacter == ".") {
      _changeSign( str.substring(0, str.length - 1) );

    } else if(lastCharacter != "-") {
      //insert "(-"
      String secondHalf = _expression.substring(str.length, _expression.length);
      _expression = "$str(-$secondHalf";

    } else if( secondLastCharacter == "(" ) {
      //remove "(-"
      String secondHalf = _expression.substring(str.length, _expression.length);
      _expression = str.substring(0, str.length - 2) + secondHalf;

    } else if(secondLastCharacter == "") {
      //remove "-"
      _expression = _expression.substring(1, _expression.length);

    } else {
      //insert "(-"
      String secondHalf = _expression.substring(str.length, _expression.length);
      _expression = "$str(-$secondHalf";

    }
  }

  void _placeDecimal(String str) {
    String lastCharacter = "";

    if(str.isEmpty) {
      lastCharacter = "";
    } else {
      lastCharacter = str.substring( str.length - 1, str.length );
    }

    if( isNumeric(lastCharacter) ) {
      for(int i = _expression.length - 1; i >= 0; i--) {
        if( !isNumeric(_expression[i]) || i == 0) {
          if(_expression[i] == ".") {
            break;
          } else {
            _expression += ".";
            break;
          }
        }
      }
      //_placeDecimal( str.substring(0, str.length - 1) );

    } else if(lastCharacter == ".") {
      //Do Nothing

    } else if(lastCharacter == ")") {
      /*String secondHalf = _expression.substring(str.length, _expression.length);
      _expression = "$str×0.$secondHalf";*/
      _expression += "×0.";

    } else {
      /*String secondHalf = _expression.substring(str.length, _expression.length);
      _expression = "${str}0.$secondHalf";*/
      _expression += "0.";
    }
  }

  void _bracketResolution() {
    int startBracketCount = 0;
    int endBracketCount = 0;
    String lastCharacter = "";

    for(int i = 0; i < _expression.length; i++) {
      String char = _expression[i];

      if(char == "(") {
        startBracketCount++;
      } else if(char == ")") {
        endBracketCount++;
      }
    }


    if(_expression.isNotEmpty) {
      lastCharacter = _expression.substring( _expression.length - 1, _expression.length );

    }

    if(isNumeric(lastCharacter)) {
      if(endBracketCount < startBracketCount) {
        _expression += ")";
      } else {
        _expression += "×(";
      }

    } else if(lastCharacter == "(") {
      _expression += "(";

    } else if(lastCharacter == ")") {
      if(endBracketCount < startBracketCount) {
        _expression += ")";
      } else {
        _expression += "×(";
      }

    } else if(lastCharacter == ".") {
      _expression += "0×(";
    } else {
      _expression += "(";
    }
  }

  void _operatorResolution(String operator) {
    String lastCharacter = "";
    String secondLastCharacter = "";
    
    if(_expression.isNotEmpty) {
      lastCharacter = _expression.substring( _expression.length - 1, _expression.length );
      if(_expression.length != 1) {
        secondLastCharacter = _expression.substring( _expression.length - 2, _expression.length - 1 );
      }
    }

    if(isNumeric(lastCharacter) || lastCharacter == ")") {
      _expression += operator;

    } else if(lastCharacter == ".") {
      _expression += "0$operator";

    } else if(lastCharacter == "-" && (secondLastCharacter == "(" || secondLastCharacter == "")) {
      //Do Nothing :)
    } else if(lastCharacter == "÷" || lastCharacter == "×" || lastCharacter == "-" || lastCharacter == "+") {
        _expression = _expression.substring(0, _expression.length - 1) + operator;

    } else if(operator == "-") {
      _expression += operator;
      
    } else {
      //Do Nothing
    }
  }

  void _evaluateExpression() {
    String equation = _expression;
    equation = equation.replaceAll('×', '*');
    equation = equation.replaceAll('÷', '/');

    try {
      Parser parser = Parser();
      Expression expression = parser.parse(equation);

      ContextModel contextModel = ContextModel();
      String result = '${expression.evaluate(EvaluationType.REAL, contextModel)}';

      if(double.parse(result) == double.parse(result).toInt()) {
        _result = double.parse(result).toInt().toString();
      } else {
        _result = double.parse(result).toStringAsPrecision(10);
      }
    } catch(error) {
      _result = "Syntax Error";
      debugPrint(error.toString());
    }
  }

  bool isNumeric(String str) {
    if(str.isEmpty) {
      return false;
    }

    return double.tryParse(str) != null;
  }

  void _backSpace() {
    setState(() {
      //Remove last character
      if(_expression.isNotEmpty) {
        _expression = _expression.substring(0, _expression.length - 1);
        _result = "";
      }

      _expressionFontSize = _focusedFontSize;
      _resultFontSize = _regularFontSize;
    });
  }

  buttonPressed(String buttonText) {
    setState(() {
      if(buttonText == "=") {
        if(_expression.isNotEmpty) {
          _evaluateExpression();
        }

        _expressionFontSize = _regularFontSize;
        _resultFontSize = _focusedFontSize;
      } else {
        if(buttonText == "C") {
          _expression = "";
          _result = "";
        } else if(_expression.length >= _expressionLimit) {
          //Show message "Max is $_expressionLimit"
          return;
        } else if(buttonText == "( )") {
          _bracketResolution();
        } else if(buttonText == "+/-") {
          _changeSign(_expression);
        } else if(buttonText == ".") {
          _placeDecimal(_expression);
        } else if(buttonText == "÷") {
          _operatorResolution(buttonText);
        } else if(buttonText == "×") {
          _operatorResolution(buttonText);
        } else if(buttonText == "-") {
          _operatorResolution(buttonText);
        } else if(buttonText == "+") {
          _operatorResolution(buttonText);
        } else {
          _expression += buttonText;
        }

        _expressionFontSize = _focusedFontSize;
        _resultFontSize = _regularFontSize;
      }
    });
  }

  Widget buildButton(String buttonText, double buttonHeight, Color buttonColor) {
    double edgeInsetsValue = 1;
    return Container(
      margin: EdgeInsets.fromLTRB(edgeInsetsValue, edgeInsetsValue * buttonHeight, edgeInsetsValue, edgeInsetsValue * buttonHeight),
      height: MediaQuery.of(context).size.height * 0.1 * buttonHeight,
      color: Colors.red,
      child: ElevatedButton(
        onPressed: () => buttonPressed(buttonText),

        child: Text(
          buttonText,
          style: TextStyle(
            fontSize: 30.0,
            fontWeight: FontWeight.normal,
            color: buttonColor,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.fromLTRB(10, 10, 0, 0),
              width: width,
              child: AnimatedSize(
                curve: Curves.easeInOut,
                duration: const Duration(milliseconds: 350),
                child: Text(
                  _expression,
                  style: TextStyle(
                  fontSize: _expressionFontSize,
                  ),
                ),
              ),
            ),

            const Expanded(
              child: Divider(
                color: Colors.transparent,
              ),
            ),

            Row(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                  width: width * 0.8,
                  child: AnimatedSize(
                    curve: Curves.easeInOut,
                    duration: const Duration(milliseconds: 350),
                    child: Text(
                      _result,
                      style: TextStyle(
                        fontSize: _resultFontSize,
                      ),
                    ),
                  ),
                ),
                
                const Expanded(
                  child: Divider(color: Colors.transparent,),
                ),

                Container(
                  alignment: Alignment.centerRight,
                  margin: const EdgeInsets.fromLTRB(0, 10, 8, 10),
                  width: width * 0.15,
                  child: IconButton(
                    onPressed: _backSpace,
                    icon: const Icon(Icons.backspace_outlined),
                    splashRadius: 25,
                  ),
                ),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: width * 0.75,
                  child: Table(
                    border: TableBorder.symmetric(
                      inside: BorderSide.none,
                    ),
                    children: [
                      TableRow(
                        children: [
                          buildButton("C", 1, Colors.white),
                          buildButton("( )", 1, Colors.white),
                          buildButton("÷", 1, Colors.white),
                        ],
                      ),

                      TableRow(
                          children: [
                            buildButton("7", 1, Colors.white),
                            buildButton("8", 1, Colors.white),
                            buildButton("9", 1, Colors.white),
                          ],
                      ),

                      TableRow(
                          children: [
                            buildButton("4", 1, Colors.white),
                            buildButton("5", 1, Colors.white),
                            buildButton("6", 1, Colors.white),
                          ],
                      ),

                      TableRow(
                          children: [
                            buildButton("1", 1, Colors.white),
                            buildButton("2", 1, Colors.white),
                            buildButton("3", 1, Colors.white),
                          ],
                      ),

                      TableRow(
                          children: [
                            buildButton("+/-", 1, Colors.white),
                            buildButton("0", 1, Colors.white),
                            buildButton(".", 1, Colors.white),
                          ],
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  width: width * 0.25,
                  child: Table(
                    children: [
                      TableRow(
                          children: [
                            buildButton("×", 1, Colors.white),
                          ],
                      ),

                      TableRow(
                          children: [
                            buildButton("-", 1, Colors.white),
                          ],
                      ),

                      TableRow(
                          children: [
                            buildButton("+", 1, Colors.white),
                          ],
                      ),

                      TableRow(
                          children: [
                            buildButton("=", 2, Colors.white),
                          ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
