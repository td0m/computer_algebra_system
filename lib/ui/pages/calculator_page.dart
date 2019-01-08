import 'package:flutter/material.dart';
import '../../core/lexer/lexer.dart';
import '../../core/parser.dart';
import '../../core/expression/equality.dart';
import '../../core/solver/solve.dart';

InputDecoration outlinedTextField = InputDecoration(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    labelText: 'Equation / Expression',
    hintText: "Type a math problem");

class CalculatorPage extends StatefulWidget {
  @override
  _CalculatorPageState createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _output = "";
  String _input = "";

  _onInputChanged(String input) {
    setState(() {
      _input = input;
      if (input.length == 0) {
        _output = "";
      } else {
        try {
          final tokens = Lexer().tokenize(input);
          final parsed = Parser().parse(tokens);
          if (parsed is Equality) {
            final solutions = solveEquality(parsed);
            _output = solutions.join(", ");
          } else {
            _output = parsed.simplify().toInfix();
          }
        } catch (error) {
          _output = "$error";
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      child: Column(children: [
        TextField(
          onChanged: _onInputChanged,
          keyboardType: TextInputType.multiline,
          maxLines: 4,
          autocorrect: false,
          decoration: outlinedTextField,
        ),
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
