/*Copyright (c) 2023, Nazeer Al-Filfil
All rights reserved.

This source code is licensed under the BSD-style license found in the
LICENSE file in the root directory of this source tree. */

import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

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
  String _displayedExpression = "";
  String _result = "";

  final double _regularFontSize = 25.0;
  final double _focusedFontSize = 35.0;
  double _expressionFontSize = 0;
  double _resultFontSize = 0;

  final int _expressionLimit = 45;

  bool _backspacePressed = false;
  bool _loopActive = false;

  //save when the equal button is pressed
  bool _equalPressed = false;

  ///This function changes the sign of a number
  void _changeSign(String str) {
    //initialize last and second to last characters
    String lastCharacter = "";
    String secondLastCharacter = "";

    //if str is empty, then there are no last or second to last characters
    //if str length is one, then there is no second to last character
    //if str length is two or more, we proceed as normal
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

    //if last character is a number, or the last character is a decimal character, then we call the function recursively until we finish this number.
    if( _isNumeric(lastCharacter) || lastCharacter == ".") {
      _changeSign( str.substring(0, str.length - 1) );

      //if last character is ")", then insert "×(-"
    } else if(lastCharacter == ")") {
      String secondHalf = _expression.substring(str.length, _expression.length);
      _expression = "$str×(-$secondHalf";

      //if last character is not a number neither a "-" sign, then insert "(-"
    } else if(lastCharacter != "-") {
      //insert "(-"
      String secondHalf = _expression.substring(str.length, _expression.length);
      _expression = "$str(-$secondHalf";

      //if the last character is a "-" sign and second to last character is a "(", then there is a "(-" in place, which will be removed
    } else if( secondLastCharacter == "(" ) {
      //remove "(-"
      String secondHalf = _expression.substring(str.length, _expression.length);
      _expression = str.substring(0, str.length - 2) + secondHalf;

      //in case second to last character is empty, it means there is only a "-" in the string, which will be removed
    } else if(secondLastCharacter == "") {
      //remove "-"
      _expression = _expression.substring(1, _expression.length);

      //if the string is empty, we insert "(-"
    } else {
      //insert "(-"
      String secondHalf = _expression.substring(str.length, _expression.length);
      _expression = "$str(-$secondHalf";

    }
  }

  ///This function places the decimal in its correct place while checking if the number does not have any decimals already
  void _placeDecimal(String str) {
    //initialize last character
    String lastCharacter = "";

    //if str is empty, last character will also be empty
    //otherwise, take last character
    if(str.isEmpty) {
      lastCharacter = "";
    } else {
      lastCharacter = str.substring( str.length - 1, str.length );
    }

    //if last character is a number, we check if the whole number already has a decimal or not
    if( _isNumeric(lastCharacter) ) {
      //we loop over all the string, starting from last index
      for(int i = str.length - 1; i >= 0; i--) {
        //if the character is not numeric (meaning we passed the numbed or reached a decimal), or we reach the end of the string
        //we check if it is a decimal (which means the number already has a decimal), otherwise we add a decimal and return
        if( !_isNumeric(str[i]) || i == 0) {
          if(str[i] == ".") {
            break;
          } else {
            _expression += ".";
            break;
          }
        }
      }

      //if the last character is a decimal (meaning the decimal button was pressed twice in a row), just ignore it and do nothing
    } else if(lastCharacter == ".") {
      //Do Nothing

      //if the last character is an end bracket ")", we insert a multiplication sign, followed by "0."
    } else if(lastCharacter == ")") {
      _expression += "×0.";

      //if string is empty, insert "0."
    } else {
      _expression += "0.";
    }
  }

  ///This function handle placing brackets in the correct way
  void _bracketResolution() {
    //initialize start and end brackets counts
    //initialize last character in the expression
    int startBracketCount = 0;
    int endBracketCount = 0;
    String lastCharacter = "";

    //loop over all characters and count start and end bracket numbers
    //if expression length is zero, then ignore
    for(int i = 0; i < _expression.length; i++) {
      String char = _expression[i];

      if(char == "(") {
        startBracketCount++;
      } else if(char == ")") {
        endBracketCount++;
      }
    }

    //if expression is not empty, get last character
    if(_expression.isNotEmpty) {
      lastCharacter = _expression.substring( _expression.length - 1, _expression.length );

    }

    //if last character is a number, and the count of end brackets is less than start brackets (not all brackets were closed), then insert ")"
    //otherwise insert "×(" (meaning all brackets are closed and we are opening a new one)
    if(_isNumeric(lastCharacter)) {
      if(endBracketCount < startBracketCount) {
        _expression += ")";
      } else {
        _expression += "×(";
      }

      //if last character is a start bracket, insert "("
    } else if(lastCharacter == "(") {
      _expression += "(";

      //if last character is an end bracket, and the count of end brackets is less than start brackets (not all brackets were closed), then insert ")"
      //otherwise insert "×(" (meaning all brackets are closed and we are opening a new one)
    } else if(lastCharacter == ")") {
      if(endBracketCount < startBracketCount) {
        _expression += ")";
      } else {
        _expression += "×(";
      }

      //if last character is a decimal (meaning we are dealing with a number), insert "0×("
    } else if(lastCharacter == ".") {
      _expression += "0×(";

      //if expression is empty, insert start bracket "("
    } else {
      _expression += "(";
    }
  }

  ///This function handle the insertion of operators correctly
  void _operatorResolution(String operator) {
    //initialize last and second to last characters
    String lastCharacter = "";
    String secondLastCharacter = "";

    //if expression is not empty, take last character, and if the the length is two or more take the second to last character
    if(_expression.isNotEmpty) {
      lastCharacter = _expression.substring( _expression.length - 1, _expression.length );
      if(_expression.length != 1) {
        secondLastCharacter = _expression.substring( _expression.length - 2, _expression.length - 1 );
      }
    }

    //if equal was pressed, and the result is numeric, make expression equal to result + operator, and set equalPressed to false
    /*if(_equalPressed && _isNumeric(_result)) {
      _expression = "($_result)$operator";
      _equalPressed = false;

      //if last character is a number, or is an end bracket, insert the operator
    } else*/ if(_isNumeric(lastCharacter) || lastCharacter == ")") {
      _expression += operator;

      //if last character is a decimal (means we are dealing with a number), close number with a zero then insert operator
    } else if(lastCharacter == ".") {
      _expression += "0$operator";

      //if last character is a "-" sign, and one of these two conditions are true:
      //1- second to last character is a start bracket (meaning "(-" {button for change sign} was inserted)
      //2- second to last character is empty (meaning only a minus sign was inserted)
      //then we just do nothing :), because we cannot put an operator without any number (with the exception of a minus sign)
    } else if(lastCharacter == "-" && (secondLastCharacter == "(" || secondLastCharacter == "")) {
      //Do Nothing :)

      //if an operator already exist, swap it with the new one
    } else if(lastCharacter == "÷" || lastCharacter == "×" || lastCharacter == "-" || lastCharacter == "+") {
      _expression = _expression.substring(0, _expression.length - 1) + operator;

      //if expression is empty and we choose "-", then insert minus sign
    } else if(operator == "-") {
      _expression += operator;

      //if any other operator than "-" is chosen, pretend to be deaf
    } else {
      //Do Nothing
    }
  }

  ///This function handles the insertion process for numbers
  void _insertNumber(String number) {
    //if the expression is not empty, and last character is a start bracket "(", then insert a multiplication sign "×" followed by the number
    //otherwise, insert the number
    if(_expression.isNotEmpty) {
      if(_expression.substring(_expression.length - 1, _expression.length) == ")") {
        _expression += "×$number";
      } else {
        _expression += number;
      }

      //if the expression is empty, insert the number
    } else {
      _expression += number;
    }
  }

  ///This function take the expression and make it nice to look at and then display it
  ///Please do not use this garbage yet ;-;
  void _displayedExpressionResolution() {
    //make two temporary expressions
    String expression = _expression;
    String concatenatedExpression = "";

    //replace all operators with a "$space $operator $space" (add spaces before and after any operator)
    //exception is minus sign
    expression.replaceAll("×", "  ");
    expression.replaceAll("÷", " ÷ ");
    expression.replaceAll("+", " + ");
    debugPrint(expression);

    //initialize last and second to last characters
    //initialize numberLength
    String lastCharacter = "";
    String secondLastCharacter = "";
    int numberLength = 0;

    //initialize flag numberFound to false
    bool numberFound = false;

    //if expression is not empty, take last character, and if the the length is two or more take the second to last character
    if(expression.isNotEmpty) {
      lastCharacter = expression.substring(expression.length - 1, expression.length);
      if (expression.length != 1) {
        secondLastCharacter = expression.substring(expression.length - 2, expression.length - 1);
      }
    }

    //replace all "-" operator that are not a minus sign, and add "," in their correct placement
    for(int i = 0; i < expression.length; i++) {
      //if last character is a "-", and there is no "(" before it, and it is not the first character in the string, then it is an operator, so we change it
      if(lastCharacter == "-" && secondLastCharacter != "(" && secondLastCharacter != "") {
        concatenatedExpression += " ${expression[i]} ";

        //otherwise we add them to the expression after checking if it is a number or otherwise
      } else {
        if( _isNumeric(expression[i]) && numberFound == false) {
          for(int j = i; j <= expression.length - 1 && _isNumeric(expression[j]); j++) {
            numberLength++;
          }

          //set numberFound to true
          numberFound = true;
        }

        //if a number is found and the length of this number is still more than 1
        if(numberFound && numberLength >= 3) {
          //if the number should have a "," after it, we can know if its position number (least significant digit start with 1) subtracted by one
          //then by taken modules 3, it should be equal to 0, if it is not, just add it to the expression
          if( (numberLength - 1) % 3 == 0) {
            concatenatedExpression += "${expression[i]},";
          } else {
            concatenatedExpression += expression[i];
          }

          numberLength--;
          //otherwise just add it
        } else {
          concatenatedExpression += expression[i];
          numberFound = false;
          numberLength = 0;
        }
      }
    }

    setState(() {
      _displayedExpression = concatenatedExpression;
    });
  }

  ///This function handles the evaluation process for the expression
  void _evaluateExpression() {
    //if the no numbers were inserted, just return and do not bother with doing anything :D (For example: it can be the following expression "((((((((" with no numbers inserted)
    if(_countSignificantDigits(_expression) == 0) {
      return;
    }

    //check if all brackets are present [ "(" number == ")" number], if not, insert ")" until they are at equal number
    _completeBrackets();

    //Save the expression in a new variable so we can modify it freely, then swap all "×" & "÷" characters, with "*" & "/" respectively
    String equation = _expression;
    equation = equation.replaceAll('×', '*');
    equation = equation.replaceAll('÷', '/');

    try {
      //parse our equation (Of type String) into an expression (Of type Expression)
      Parser parser = Parser();
      Expression expression = parser.parse(equation);

      //Evaluate our expression
      ContextModel contextModel = ContextModel();
      String result = '${expression.evaluate(EvaluationType.REAL, contextModel)}';

      //if digits count is equal to or bigger than 15, then just write result in scientific notations to avoid overflow, or rounding shenanigans
      if( _countSignificantDigits(result) >= 15) {
        _result = double.parse(result).toStringAsExponential(8);

      } else {
        //If the result does not contain decimal places, then no need to write any decimal places
        if(double.parse(result) == double.parse(result).toInt()) {
          _result = double.parse(result).truncate().toString();
        } else {

          int decimalCount = _countDecimalPlaces(result);
          int intCount = _countSignificantDigits(result);

          //TODO: correct comments
          // if the decimal count is bigger than 8, round it to 8 decimals, otherwise, write it as it is
          if(decimalCount <= 8 && intCount <= 15 - decimalCount) {
            _result = double.parse(result).toStringAsFixed(decimalCount);
          } else if(8 + intCount <= 15) {
            _result = double.parse(result).toStringAsFixed(8);
          } else {
            _result = double.parse(result).toStringAsExponential(8);
          }
        }
      }
      //set _equalPressed to true
      _equalPressed = true;

      //after changing result, focus on the result (increase font size)
      _expressionFontSize = _regularFontSize;
      _resultFontSize = _focusedFontSize;

      //if anything goes awry, print "Syntax Error" :P
    } catch(error) {
      _result = "Syntax Error";
      debugPrint(error.toString());
    }
  }

  ///This function complete the brackets are left unclosed
  void _completeBrackets() {
    //initialize start and end brackets counts
    int startBracketCount = 0;
    int endBracketCount = 0;

    //loop over all characters and count start and end bracket numbers
    //if expression length is zero, then ignore
    for(int i = 0; i < _expression.length; i++) {
      String char = _expression[i];

      if(char == "(") {
        startBracketCount++;
      } else if(char == ")") {
        endBracketCount++;
      }
    }

    //while the count of start brackets is larger than the count of end brackets, add more end brackets and increment the count
    while(startBracketCount != endBracketCount) {
      _expression += ")";
      endBracketCount++;
    }
  }

  ///This function check if a given string is numeric or not
  bool _isNumeric(String str) {
    if(str.isEmpty) {
      return false;
    }

    return double.tryParse(str) != null;
  }

  ///count the number of significant digits in any given string, this is used to avoid overflow and rounding shenanigans
  int _countSignificantDigits(String str) {
    //initialize significant digits count
    int count = 0;

    //if the string contains a decimal, count everything before the decimal
    if(str.contains(".")) {
      count = str.substring( 0, str.indexOf(".") ).length;

      //if the string does not contain a decimal, and it is not empty (meaning there are no decimals)
    } else if(str.isNotEmpty) {
      for(int i = 0; i < str.length; i++) {
        if( _isNumeric(str[i]) ) {
          count++;
        }

      }
    }

     return count;
  }

  ///count the number of decimal places in any given string, this is used to avoid overflow and rounding shenanigans
  int _countDecimalPlaces(String str) {
    //initialize significant digits count
    int count = 0;

    //if the string contains a decimal, count everything after the decimal
    if(str.contains(".")) {
      count = str.substring( str.indexOf(".") + 1, str.length ).length;


    }
    /*if they are not decimal, you cannot count how many numbers are there after the decimal... yeah*/
    //if the string does not contain a decimal, and it is not empty (meaning there are no decimals)
    /*else if(str.isNotEmpty) {
      for(int i = 0; i < str.length; i++) {
        if( _isNumeric(str[i]) ) {
          count++;
        }

      }
    }*/

    return count;
  }

  ///This function handle the functionality of the backspace button
  void _backSpace() async {
    //ensure only one loop is active
    if(_loopActive) {
      return;
    }

    //set loop active to true
    _loopActive = true;

    //focus on the expression (increase font size)
    _expressionFontSize = _focusedFontSize;
    _resultFontSize = _regularFontSize;

    //while backspace button is pressed, keep deleting with a 0.1s delay (100 milliseconds)
    while(_backspacePressed)  {
      setState(() {
      //Remove last character
        if(_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
          _result = "";
        }
      });

      //wait 0.1s
      await Future.delayed(const Duration(milliseconds: 100));
    }

    //set loop active to false
    _loopActive = false;
  }

  ///This function activate whenever any button is pressed (other than backspace)
  buttonPressed(String buttonText) {
    setState(() {

      //if the button pressed is "=" and the expression is not empty, then evaluate the expression
      if(buttonText == "=") {
        if(_expression.isNotEmpty) {
          _evaluateExpression();
        }

        //if button pressed is backspace
      } else if(buttonText == "backspace") {
        _backSpace();

        //if any other button is pressed we come here :D (so useful)
      } else {
        //if the button pressed is "C", clear the expression and result
        if(buttonText == "C") {
          _expression = "";
          _result = "";

          //if the length of the expression surpasses the limit, do nothing and return
          //TODO: or show a message indicating it
        } else if(_expression.length >= _expressionLimit) {
          //Show message "Max is $_expressionLimit"
          return;

          //if button pressed is brackets
        } else if(buttonText == "( )") {
          _bracketResolution();

          //if button pressed is change sign
        } else if(buttonText == "+/-") {
          _changeSign(_expression);

          //if button pressed is decimal
        } else if(buttonText == ".") {
          _placeDecimal(_expression);

          //if button pressed is division
        } else if(buttonText == "÷") {
          _operatorResolution(buttonText);

          //if button pressed is multiplication
        } else if(buttonText == "×") {
          _operatorResolution(buttonText);

          //if button pressed is subtraction
        } else if(buttonText == "-") {
          _operatorResolution(buttonText);

          //if button pressed is addition
        } else if(buttonText == "+") {
          _operatorResolution(buttonText);

          //if button pressed is a number
        } else {
          _insertNumber(buttonText);
        }
        //make displayed expression nice :D
        //_displayedExpressionResolution();

        //set result to "", and equalPressed to false (just in case)
        _result = "";
        _equalPressed = false;

        //focus on the expression (increase font size)
        _expressionFontSize = _focusedFontSize;
        _resultFontSize = _regularFontSize;
      }
    });
  }

  ///build the buttons
  Widget buildButton(String buttonText, double fontSize, double buttonHeight, Color buttonColor, Color textColor) {
    double edgeInsetsValue = 1;
    return Container(
      margin: EdgeInsets.fromLTRB(edgeInsetsValue, edgeInsetsValue * buttonHeight, edgeInsetsValue, edgeInsetsValue * buttonHeight),
      height: MediaQuery.of(context).size.height * 0.1 * buttonHeight,

      child: ElevatedButton(
        onPressed: () => buttonPressed(buttonText),

        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
        ),

        child: Text(
          buttonText,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.normal,
            color: textColor,
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
                  child: Listener(
                    onPointerDown: (details) {
                      _backspacePressed = true;
                      buttonPressed("backspace");
                    },
                    onPointerUp: (details) {
                      _backspacePressed = false;
                    },
                    child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.backspace_outlined),
                    splashRadius: 25,
                    ),
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
                          buildButton("C", 30.0, 1, Colors.red, Colors.white),
                          buildButton("( )", 30.0, 1, Colors.red, Colors.white),
                          buildButton("÷", 40.0, 1, Colors.red, Colors.white),
                        ],
                      ),

                      TableRow(
                          children: [
                            buildButton("7", 30.0, 1, Colors.red, Colors.white),
                            buildButton("8", 30.0, 1, Colors.red, Colors.white),
                            buildButton("9", 30.0, 1, Colors.red, Colors.white),
                          ],
                      ),

                      TableRow(
                          children: [
                            buildButton("4", 30.0, 1, Colors.red, Colors.white),
                            buildButton("5", 30.0, 1, Colors.red, Colors.white),
                            buildButton("6", 30.0, 1, Colors.red, Colors.white),
                          ],
                      ),

                      TableRow(
                          children: [
                            buildButton("1", 30.0, 1, Colors.red, Colors.white),
                            buildButton("2", 30.0, 1, Colors.red, Colors.white),
                            buildButton("3", 30.0, 1, Colors.red, Colors.white),
                          ],
                      ),

                      TableRow(
                          children: [
                            buildButton("+/-", 30.0, 1, Colors.red, Colors.white),
                            buildButton("0", 30.0, 1, Colors.red, Colors.white),
                            buildButton(".", 30.0, 1, Colors.red, Colors.white),
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
                            buildButton("×", 40.0, 1, Colors.red, Colors.white),
                          ],
                      ),

                      TableRow(
                          children: [
                            buildButton("-", 50.0, 1, Colors.red, Colors.white),
                          ],
                      ),

                      TableRow(
                          children: [
                            buildButton("+", 40.0, 1, Colors.red, Colors.white),
                          ],
                      ),

                      TableRow(
                          children: [
                            buildButton("=", 50.0, 2, Colors.red, Colors.white),
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
