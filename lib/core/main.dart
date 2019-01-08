import 'package:computer_algebra_system/core/expression/equality.dart';
import 'package:computer_algebra_system/core/expression/expression.dart';
import 'package:computer_algebra_system/core/expression/fraction.dart';
import 'package:computer_algebra_system/core/lexer/lexer.dart';
import 'package:computer_algebra_system/core/lexer/token.dart';
import 'package:computer_algebra_system/core/parser.dart';
import 'package:computer_algebra_system/core/solver/solve.dart';

List<Solution> solve(String input) {
  final List<Token> tokens = Lexer().tokenize(input);
  final Expression parsed = Parser().parse(tokens);
  return solveEquality(parsed.simplifyAll());
}

void main() {
  print(solveSimultaneously(solve("5y+x=17"), solve("2x+3y=13")));
}
