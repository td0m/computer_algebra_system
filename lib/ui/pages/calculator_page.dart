import 'package:computer_algebra_system/core/expression/expression.dart';
import 'package:computer_algebra_system/core/lexer/token.dart';
import 'package:flutter/material.dart';
import '../../core/lexer/lexer.dart';
import '../../core/parser.dart';
import '../../core/expression/equality.dart';
import '../../core/solver/solve.dart';

// define the style for the input text field
InputDecoration outlinedTextField = InputDecoration(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    labelText: 'Input equation / expression here',
    hintText: "Type a math problem");

class CalculatorPage extends StatefulWidget {
  @override
  _CalculatorPageState createState() => _CalculatorPageState();

  // utility to solve a string equality with one function
  static List<Solution> solve(String input) {
    final List<Token> tokens = Lexer().tokenize(input);
    final Expression parsed = Parser().parse(tokens);
    return Solver.solveEquality(parsed.simplifyAll());
  }
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _output = "";
  String _input = "";

  // triggered when the user inputs a new character
  // solves and prints out the result of the expression
  // handles and prints out errors to the user
  _onInputChanged(String input) {
    setState(() {
      _input = input;
      if (input.length == 0) {
        _output = "";
      } else {
        try {
          if (input.contains("\n")) {
            final equations = input.split("\n");
            final solutions = Solver.solveSimultaneously(
                CalculatorPage.solve(equations[0]),
                CalculatorPage.solve(equations[1]));
            _output = solutions.join(", ");
          } else {
            final tokens = Lexer().tokenize(input);
            final parsed = Parser().parse(tokens);
            if (parsed is Equality) {
              final solutions = Solver.solveEquality(parsed);
              _output = solutions.join(", ");
            } else {
              _output = parsed.simplify().toInfix();
            }
          }
        } catch (error) {
          _output = error.toString().split("'")[1];
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      child: Column(children: [
        // create an input text field
        TextField(
          onChanged: _onInputChanged,
          keyboardType: TextInputType.multiline,
          maxLines: 4,
          autocorrect: false,
          decoration: outlinedTextField,
        ),
        // if the user has inputted something, show the result card
        _input.length > 0
            ? Card(
                margin: EdgeInsets.only(top: 10),
                elevation: 5,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: Theme.of(context).primaryColor),
                  child: Text(_output,
                      style: Theme.of(context).primaryTextTheme.subhead),
                ),
              )
            : Container(),
      ]),
    );
  }
}
