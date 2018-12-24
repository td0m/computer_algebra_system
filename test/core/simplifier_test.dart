import 'package:computer_algebra_system/core/errors.dart';
import 'package:computer_algebra_system/core/lexer/lexer.dart';
import 'package:computer_algebra_system/core/lexer/token.dart';
import 'package:computer_algebra_system/core/expression/expression.dart';
import 'package:computer_algebra_system/core/parser.dart';
import "package:test/test.dart";

final throwsIncompatibleTypesError =
    throwsA(TypeMatcher<IncompatibleTypesError>());

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
    expect(simplify("[1,2]+[2,2]"), equals("[3,4]"));
    expect(simplify("[1,2,3]+[2,2]"), equals("[3,4,3]"));
    expect(simplify("[1,2,3,4]+[4,3,2,1]"), equals("[5,5,5,5]"));
    expect(simplify("[1,x]+[2,0]"), equals("[3,x]"));
  });
  test("4.i Simplifier should subtract vectors", () {
    expect(simplify("[1,2]-[2,2]"), equals("[-1,0]"));
    expect(simplify("[1,2,3]-[2,2]"), equals("[-1,0,3]"));
  });
  test("4.j Simplifier should multiply vectors", () {
    expect(simplify("5*[2,4]"), equals("[10,20]"));
    expect(simplify("0.25*[2,4]"), equals("[(1/2),1]"));
  });
  test("4.k Simplifier should divide vectors", () {
    expect(simplify("[150]/2"), equals("[75]"));
    expect(simplify("[2,4]/2"), equals("[1,2]"));
  });
  test("4.l Simplifier should be able to raise a vector to a power", () {
    expect(simplify("2/[2,4]"), equals("[1,(1/2)]"));
    expect(simplify("[9,16]^(1/2)"), equals("[3,4]"));
  });
  test(
      "4.m Simplifier should throw error if trying to add or subtract vectors and fractions",
      () {
    expect(() => simplify("[2,4]+2"), throwsIncompatibleTypesError);
    expect(() => simplify("[2,4]+x"), throwsIncompatibleTypesError);
  });
  test("4.n Simplifier should multiply & divide vectors by other vectors", () {
    expect(simplify("[1,2]/[3,4]"), equals("[(1/3),(1/2)]"));
    expect(simplify("[1,2]*[3,4]"), equals("[3,8]"));
    expect(simplify("[2]/[3,3]"), equals("[(2/3),(1/3)]"));
  });
  test("4.o Simplifier should use basic index laws", () {
    // x^0 = x
    expect(simplify("x^0"), equals("1"));
    // x^1 = x
    expect(simplify("x^1"), equals("x"));
    // x^a^b = (x^a)^b = x^(a+b)
    expect(simplify("(x^2)^3"), equals("x^6"));
    expect(simplify("(5*x^2)^3"), equals("x^6*125"));
  });
  test("4.p Simplifier should use more complex simplification rules", () {
    // Summing
    // ax^n+bx^n = (a+b)x^n
    expect(simplify("x+0"), equals("x"));
    expect(simplify("x+x"), equals("x*2"));
    expect(simplify("x+x+x"), equals("x*3"));
    expect(simplify("x+x+x+x+x"), equals("x*5"));
    expect(simplify("x+x^2"), equals("x+x^2"));
    expect(simplify("x+x^2+x"), equals("x*2+x^2"));
    expect(simplify("x^2+5x^2+3x*2"), equals("x^2*6+x*6"));
    expect(simplify("5x^2-2x^2+4x"), equals("x^2*3+x*4"));
    expect(simplify("xyz+xzy"), equals("x*y*z*2"));
    expect(simplify("5xy+10yx"), equals("x*y*15"));
    expect(simplify("2^x+2^x"), equals("2^x*2"));
    expect(simplify("2^x+2^y"), equals("2^x+2^y"));

    expect(simplify("2^0.5+16^0.5"), equals("2^(1/2)+4"));
    expect(simplify("2^0.5+16^0.5+2^(1/2)"), equals("2^(1/2)*2+4"));

    // Multiplication
    // x^a*x^b = x^(a+b)
    expect(simplify("x*x"), equals("x^2"));
    expect(simplify("x*x*x"), equals("x^3"));
    expect(simplify("x*x*z"), equals("x^2*z"));
    expect(simplify("x*x*z*x"), equals("x^3*z"));
    expect(simplify("5*x*x*z*x"), equals("x^3*z*5"));
    expect(simplify("x^2*x^5"), equals("x^7"));
    // Expansion of terms not yet supported
    expect(simplify("(x+2)*(x+2)"), equals("(x+2)*(x+2)"));
  });
}
