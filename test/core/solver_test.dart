import 'package:computer_algebra_system/core/lexer/lexer.dart';
import 'package:computer_algebra_system/core/lexer/token.dart';
import 'package:computer_algebra_system/core/expression/expression.dart';
import 'package:computer_algebra_system/core/parser.dart';
import 'package:computer_algebra_system/core/solver/solve.dart';
import "package:test/test.dart";

String simplify(String input) {
  final List<Token> tokens = Lexer().tokenize(input);
  final Expression parsed = Parser().parse(tokens);
  return parsed.simplifyAll().toInfix();
}

List<Solution> solve(String input) {
  final List<Token> tokens = Lexer().tokenize(input);
  final Expression parsed = Parser().parse(tokens).simplifyAll();
  return Solver.solveEquality(parsed);
}

Solution solution(String variable, String value) {
  final List<Token> tokens = Lexer().tokenize(value);
  final Expression parsed = Parser().parse(tokens).simplifyAll();
  return Solution(variable, parsed);
}

/// This test assumes that the `Lexer` and `Parser` work as expected and pass all their unit tests
void main() {
  test("5.a Solver should solve linear equations", () {
    expect(solve("x+5=0"), equals([solution("x", "-5")]));
    expect(solve("x-5=0"), equals([solution("x", "5")]));
    expect(solve("2x+5=0"), equals([solution("x", "-5/2")]));
    expect(solve("2x+5=1"), equals([solution("x", "-2")]));
    expect(solve("x=5"), equals([solution("x", "5")]));
    expect(solve("x+0.5+2.5=5"), equals([solution("x", "2")]));
    expect(solve("x+x+2x-8=16"), equals([solution("x", "6")]));
    expect(solve("x+2x^((1+1)/2)-8=16-x"), equals([solution("x", "6")]));
  });
  test("5.b Solver should solve quadratic equations", () {
    expect(solve("x^2+5x+6=0"),
        equals([solution("x", "-2"), solution("x", "-3")]));
    expect(solve("x^2+2x+1=0"), equals([solution("x", "-1")]));
    expect(solve("2x^2+5x-12=0"),
        equals([solution("x", "3/2"), solution("x", "-4")]));
  });
  test("5.d Solver should differentiate an expanded sum of atoms", () {
    expect(simplify("differentiate(5x+5)"), equals("5"));
    expect(simplify("differentiate(5x^2)"), equals("x*10"));
    expect(simplify("differentiate(5x^3+2x)"), equals("x^2*15+2"));
    expect(simplify("differentiate(x^3+2x+2x)"), equals("x^2*3+4"));
  });
  test("5.d Solver should integrate an expanded sum of atoms", () {
    expect(simplify("integrate(5)"), equals("x*5+c"));
    expect(simplify("integrate(5x)"), equals("x^2*(5/2)+c"));
    expect(simplify("integrate(6x+5)"), equals("x^2*3+x*5+c"));
  });
  test("5.f Solver should solve exponential equations", () {
    expect(solve("5^x=25"), equals([solution("x", "2")]));
    expect(solve("5^x=125"), equals([solution("x", "3")]));
    expect(solve("5^x^2=625"), equals([solution("x", "2")]));
    expect(solve("5^(2x+5)-5=120"), equals([solution("x", "-1")]));
  });
}
