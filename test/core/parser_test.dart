import 'package:computer_algebra_system/core/errors.dart';
import 'package:computer_algebra_system/core/lexer/lexer.dart';
import 'package:computer_algebra_system/core/lexer/token.dart';
import 'package:computer_algebra_system/core/expression/expression.dart';
import 'package:computer_algebra_system/core/parser.dart';
import "package:test/test.dart";

/// Convert the output of the `parse` function to a
/// readable string format to make testing easier.
String parse(String input) {
  final List<Token> tokens = Lexer().tokenize(input);
  final Expression parsed = Parser().parse(tokens);
  return parsed.toInfix();
}

final throwsInvalidArgumentsError =
    throwsA(TypeMatcher<InvalidArgumentsError>());

/// This test assumes that the `Lexer` works as expected and passes all its unit tests
void main() {
  /// 3.a tested visually, 3.a and 3.b. assumed to be working as all the following tests are
  /// depending on them and there is no easy way of unit testing them separately
  /// TODO: in testing, prove that 3.a works using the `printTree` function
  /// TODO: in testing, prove that 3.b works using the `toInfix` function

  test("3.c Parser should support whole numbers and decimals", () {
    expect(parse("124"), equals("124"));
    expect(parse("124.5"), equals("(249/2)"));
    expect(parse("0.125"), equals("(1/8)"));
  });
  test("3.d Parser should support variables", () {
    expect(parse("x"), equals("x"));
    expect(parse("y"), equals("y"));
    expect(parse("xyz"), equals("x*y*z"));
  });
  test("3.e Parser should support operators", () {
    expect(parse("1+2*3^4"), equals("1+2*3^4"));
  });
  test("3.f Parser should transform the - operator", () {
    expect(parse("1-2"), equals("1+-1*2"));
    expect(parse("1-x"), equals("1+-1*x"));
  });
  test("3.g Parser should transform the / operator", () {
    expect(parse("5/2"), equals("5*2^-1"));
    expect(parse("5/x"), equals("5*(x)^-1"));
  });
  test("3.h Parser should support brackets", () {
    expect(parse("5*(1+2)"), equals("5*(1+2)"));
    expect(parse("5*(1^2)"), equals("5*1^2"));
    expect(parse("5^(4*(3+2))"), equals("5^(4*(3+2))"));
  });
  test("3.i Parser should support vectors", () {
    expect(parse("[1]"), equals("[1]"));
    expect(parse("[1,2]"), equals("[1,2]"));
    expect(parse("[x,2+3]"), equals("[x,2+3]"));
    expect(parse("[x,y,z]"), equals("[x,y,z]"));
  });
  test("3.j Parser should detect functions", () {
    expect(parse("sin(10)"), equals("sin(10)"));
    expect(parse("cos(10)"), equals("cos(10)"));
    expect(parse("tan(10)"), equals("tan(10)"));
    expect(parse("log(10,100)"), equals("log(10,100)"));
    expect(parse("log(100)"), equals("log(10,100)"));
  });
  test("3.k Parser should validate function arguments", () {
    expect(() => parse("sin(10,10)"), throwsInvalidArgumentsError);
    expect(() => parse("cos(1,2,3)"), throwsInvalidArgumentsError);
    expect(() => parse("log(1,2,3)"), throwsInvalidArgumentsError);
  });
  test("3.l Parser should evaluate in order of precedence", () {
    expect(parse("5*(x+2)"), equals("5*(x+2)"));
    expect(parse("5*(x^2)"), equals("5*(x)^2"));
  });
  test("3.m Parser should Process associativity of operators", () {
    expect(parse("2^(3^4)"), equals("2^3^4"));
  });
  test("3.n Parser should support large numbers", () {
    // 2^100
    final bigNumber = "1267650600228229401496703205376";
    // 2^222
    final veryBigNumber =
        "6739986666787659948666753771754907668409286105635143120275902562304";
    expect(parse(bigNumber), equals(bigNumber));
    expect(parse(veryBigNumber), equals(veryBigNumber));
    expect(parse("-$veryBigNumber"), equals("-$veryBigNumber"));
  });
}
