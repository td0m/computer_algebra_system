import 'package:computer_algebra_system/core/lexer/lexer.dart';
import 'package:computer_algebra_system/core/lexer/token.dart';
import 'package:computer_algebra_system/core/expression/expression.dart';
import 'package:computer_algebra_system/core/parser.dart';
import "package:test/test.dart";

/// Convert the output of the simplified `parse` tree to a
/// readable string format to make testing easier.
String simplify(String input) {
  final List<Token> tokens = Lexer().tokenize(input);
  final Expression parsed = Parser().parse(tokens);
  return parsed.simplify().toInfix();
}

/// This test assumes that the `Lexer` and `Parser` work as expected and pass all their unit tests
void main() {
  test("4.a Simplifier should add fractions", () {
    expect(simplify("2+3+4"), equals("9"));
    expect(simplify("1+4"), equals("5"));
  });
  test("4.b Simplifier should subtract fractions", () {
    expect(simplify("2-2-4"), equals("-4"));
    expect(simplify("9-4"), equals("5"));
    expect(simplify("-2*-4"), equals("8"));
  });
  test("4.c Simplifier should multiply fractions", () {
    expect(simplify("2*-4"), equals("-8"));
    expect(simplify("2*8*100"), equals("1600"));
  });
  test("4.d Simplifier should divide fractions", () {
    expect(simplify("18/3"), equals("6"));
    expect(simplify("2/3"), equals("(2/3)"));
    expect(simplify("12/6"), equals("2"));
    expect(simplify("2/6"), equals("(1/3)"));
  });
  test("4.e Simplifier should calculate integer powers of fractions", () {
    expect(simplify("2^12"), equals("4096"));
    expect(simplify("5^5"), equals("3125"));
    expect(simplify("5^2"), equals("25"));
  });
  test("4.f Simplifier should calculate negative int powers of fractions", () {
    expect(simplify("2^-12"), equals("(1/4096)"));
    expect(simplify("1^-12"), equals("1"));
  });
  test("4.g Simplifier should calculate and simplify fractional powers", () {
    expect(simplify("1^-3/12"), equals("1"));
    expect(simplify("36^0.5"), equals("6"));
    expect(simplify("2^(2/4)"), equals("2^(1/2)"));
    expect(simplify("144^(1/2)"), equals("12"));
    expect(simplify("64^(1/3)"), equals("4"));
    expect(simplify("8^(2/3)"), equals("4"));
    expect(simplify("2^(1/2)"), equals("2^(1/2)"));
  });
  test("4.h Simplifier should add vectors", () {
    // TODO
  });
  test("4.i Simplifier should subtract vectors", () {
    // TODO
  });
  test("4.j Simplifier should multiply vectors", () {
    // TODO
  });
  test("4.k Simplifier should divide vectors", () {
    // TODO
  });
  test(
      "4.l Simplifier should throw error if trying to raise a vector to a power",
      () {
    // TODO
  });
  test(
      "4.m Simplifier should throw error if trying to add or subtract vectors and fractions",
      () {
    // TODO
  });
  test("4.n Simplifier should multiply & divide vectors by a number", () {
    // TODO
  });
}
