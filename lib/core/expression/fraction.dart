import 'package:computer_algebra_system/core/lexer/fsm.dart';

import "./atom.dart";

class Fraction extends Atom implements Comparable<Fraction> {
  static Fraction zero = Fraction.fromInt(0);
  static Fraction one = Fraction.fromInt(1);
  static Fraction minusOne = Fraction.fromInt(-1);

  BigInt numerator;
  BigInt denominator;

  /// primary constructor
  Fraction(this.numerator, this.denominator, [bool simplified = false]) {
    if (denominator == BigInt.zero)
      throw Exception("Invalid fraction: $numerator/$denominator");

    if (!simplified) {
      final f = Fraction.simplifyFraction(numerator, denominator);
      numerator = f.numerator;
      denominator = f.denominator;
    }
  }

  /// add an int constructor for more readable code
  Fraction.fromInt(int numerator, [int denominator = 1])
      : numerator = BigInt.from(numerator),
        denominator = BigInt.from(denominator);

  /// convert a whole number or decimal string to a fraction
  static Fraction parse(String str) {
    String numbers = "";
    BigInt denominator = BigInt.one;
    bool afterDot = false;
    for (int i = 0; i < str.length; i++) {
      if (isDigit(str[i])) numbers += str[i];
      if (afterDot) denominator *= BigInt.from(10);
      if (str[i] == ".") afterDot = true;
    }
    return Fraction(BigInt.parse(numbers), denominator);
  }

  /// calculate the greatest common denominator of two big integers
  static BigInt gcd(BigInt a, BigInt b) {
    if (b == BigInt.zero)
      return a.abs();
    else
      return gcd(b.abs(), a.abs().remainder(b.abs()));
  }

  /// simplify a fraction
  static Fraction simplifyFraction(BigInt numerator, BigInt denominator) {
    BigInt n = numerator;
    BigInt d = denominator;

    final BigInt gcd = Fraction.gcd(n, d);
    if (gcd > BigInt.one) {
      n = numerator ~/ gcd;
      d = denominator ~/ gcd;
    }
    if (d < BigInt.zero) {
      n = -n;
      d = -d;
    }
    return Fraction(n, d, true);
  }

  reciprocal() => Fraction(denominator, numerator);
  negate() => Fraction(-numerator, denominator);

  /// multiply two fractions
  operator *(Fraction other) =>
      Fraction(numerator * other.numerator, denominator * other.denominator);

  /// divide a fraction
  operator /(Fraction other) => this * other.reciprocal();

  /// add fractions
  operator +(Fraction other) => Fraction(
      numerator * other.denominator + other.numerator * denominator,
      denominator * other.denominator);

  /// subtract a fraction
  operator -(Fraction other) => this + other.negate();

  // TODO: implement the ^ operator

  @override
  int compareTo(Fraction other) {
    final a = numerator * other.denominator;
    final b = denominator * other.numerator;

    return a.compareTo(b);
  }

  operator ==(other) {
    if (other is Fraction) return this.compareTo(other) == 0;
    return false;
  }

  operator <(other) {
    if (other is Fraction) return this.compareTo(other) < 0;
  }

  operator >(other) {
    if (other is Fraction) return this.compareTo(other) > 0;
  }

  // used to make sure that the map of values doesn't contain
  // different values with same powers
  // read more about how hashCode and == are used:
  // https://stackoverflow.com/questions/1894377/understanding-the-workings-of-equals-and-hashcode-in-a-hashmap
  @override
  int get hashCode => 0;

  /// converts fraction to a string format
  ///
  /// e.g.
  ///    1/2 -> 1/2
  ///    2/1 -> 2
  @override
  String toString() {
    if (denominator == BigInt.one) return "$numerator";
    return "($numerator/$denominator)";
  }
}
