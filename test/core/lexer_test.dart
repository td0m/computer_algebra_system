import "package:test/test.dart";
import 'package:computer_algebra_system/core/errors.dart';
import 'package:computer_algebra_system/core/lexer/lexer.dart';
import 'package:computer_algebra_system/core/lexer/token.dart';

/// Convert the output of the `tokenize` function to a
/// readable string format to make testing easier.
String tokenize(String input) {
  final List<Token> tokens = Lexer().tokenize(input);
  return tokens.map((token) => token.lexeme).join(" ");
}

final throwsInvalidCharacterError =
    throwsA(TypeMatcher<InvalidCharacterError>());
final throwsMismatchingBracketsError =
    throwsA(TypeMatcher<MismatchingBracketsError>());

void main() {
  test("2a. Lexer should interpret whole numbers", () {
    expect(tokenize("0"), equals("0"));
    expect(tokenize("55"), equals("55"));
    expect(tokenize("1235476859012"), equals("1235476859012"));
  });
  test("2b. Lexer should interpret decimals", () {
    expect(tokenize("3.141592"), equals("3.141592"));
    expect(tokenize("3.11"), equals("3.11"));
    expect(() => tokenize("3.1.2"), throwsInvalidCharacterError);
    expect(() => tokenize(".1"), throwsInvalidCharacterError);
    expect(() => tokenize("0..1"), throwsInvalidCharacterError);
    expect(() => tokenize("0...1"), throwsInvalidCharacterError);
  });
  test("2c. Lexer should interpret operators", () {
    for (String op in ["+", "-", "*", "/", "^"]) {
      expect(tokenize("1 $op 2"), equals("1 $op 2"));
    }
  });
  test("2d. Lexer should interpret brackets", () {
    expect(tokenize("5*(3)"), equals("5 * ( 3 )"));
    expect(tokenize("5*(x-2)"), equals("5 * ( x - 2 )"));
  });
  test("2e. Lexer should interpret vectors", () {
    expect(tokenize("[1,2]"), equals("[ 1 , 2 ]"));
    expect(tokenize("[1,2,3]"), equals("[ 1 , 2 , 3 ]"));
    expect(tokenize("[1,2,3,4,5,6,7,8,9]"),
        equals("[ 1 , 2 , 3 , 4 , 5 , 6 , 7 , 8 , 9 ]"));
  });
  test("2f. Lexer should interpret variables", () {
    expect(tokenize("5 + x"), equals("5 + x"));
    expect(tokenize("x + x"), equals("x + x"));
    expect(tokenize("2*x + x"), equals("2 * x + x"));
  });
  test("2g. Lexer should ignore spaces", () {
    expect(tokenize("15 +   5"), equals("15 + 5"));
    expect(tokenize("   1 +   2"), equals("1 + 2"));
    expect(tokenize("   "), equals(""));
    expect(tokenize(""), equals(""));
  });
  test("2h. Lexer should handle invalid tokens appropriately", () {
    expect(() => tokenize("£"), throwsInvalidCharacterError);
    expect(() => tokenize("\$"), throwsInvalidCharacterError);
    expect(() => tokenize("%"), throwsInvalidCharacterError);
    expect(() => tokenize("&"), throwsInvalidCharacterError);
    expect(() => tokenize("#"), throwsInvalidCharacterError);
    expect(() => tokenize("\""), throwsInvalidCharacterError);
  });
  test("2i. Lexer should transform ax to a*x", () {
    expect(tokenize("12x"), equals("12 * x"));
    expect(tokenize("-5x"), equals("- 5 * x"));
  });
  test("2j. Lexer should transform xa to x^a", () {
    expect(tokenize("x3"), equals("x ^ 3"));
    expect(tokenize("x12"), equals("x ^ 12"));
    expect(tokenize("xb"), equals("xb"));
  });
  test("2k. Lexer should validate if brackets have been closed", () {
    expect(() => tokenize("(5+x))"), throwsMismatchingBracketsError);
    expect(() => tokenize("(5+x"), throwsMismatchingBracketsError);
    expect(() => tokenize("(5+sin(12+(a+c)"), throwsMismatchingBracketsError);
  });
  test("2l. Lexer should allow functions with multiple arguments", () {
    expect(tokenize("log(12,5)"), equals("log ( 12 , 5 )"));
    expect(tokenize("sin(10)"), equals("sin ( 10 )"));
    expect(tokenize("rand()"), equals("rand ( )"));
  });
  test("2m. Lexer should only allow commas inside functions", () {
    expect(() => tokenize("5,2"), throwsInvalidCharacterError);
  });
}
