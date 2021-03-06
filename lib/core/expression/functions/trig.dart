import 'package:computer_algebra_system/core/errors.dart';
import 'package:computer_algebra_system/core/expression/expression.dart';
import 'package:computer_algebra_system/core/expression/fraction.dart';
import 'package:computer_algebra_system/core/expression/function.dart';
import 'package:computer_algebra_system/core/expression/product.dart';
import 'package:computer_algebra_system/core/expression/sum.dart';
import 'package:computer_algebra_system/core/lexer/lexer.dart';
import 'package:computer_algebra_system/core/parser.dart';

// this map stores exact sin values
Map<BigInt, Expression> exactSinValues = {
  BigInt.zero: Fraction.zero,
  BigInt.from(30): Fraction.fromInt(1, 2),
  BigInt.from(45): Parser().parse(Lexer().tokenize("2^(-1/2)")),
  BigInt.from(60): Parser().parse(Lexer().tokenize("3^(1/2)/2")),
  BigInt.from(90): Fraction.one,
};

// converts a larger sin value to a standard sin value
// based on the sin function repeating itself (period) every 360 degrees.
BigInt simplifySinValue(BigInt value) {
  final multiplier = value ~/ BigInt.from(360);
  return value - (BigInt.from(360) * multiplier);
}

class Sin extends FunctionAtom {
  final Expression value;
  Sin(this.value);

  String toString() => "sin(${value.toInfix()})";

  // adds support for other sin values not included in the standard values
  // operates based on knowing that the sin value is a reflection of itself for 180 degrees every 180 degrees
  @override
  Expression simplify() {
    final val = value.simplifyAll();
    if (val is Fraction && val.isInteger) {
      final sinValue = simplifySinValue(val.asInteger);
      final multiplier = sinValue ~/ BigInt.from(180);
      bool isNegative = multiplier % BigInt.two == BigInt.one;
      BigInt key = sinValue - (multiplier * BigInt.from(180));
      if (key > BigInt.from(90)) key = BigInt.from(180) - key;
      if (exactSinValues.containsKey(key))
        return isNegative
            ? Product([Fraction.minusOne, exactSinValues[key]]).simplifyAll()
            : exactSinValues[key].simplifyAll();
    }
    return Sin(val);
  }
}

class Cos extends FunctionAtom {
  final Expression value;
  Cos(this.value);

  String toString() => "cos(${value.toInfix()})";

  // converting cos to sin and simplifying the sin function
  @override
  Expression simplify() {
    final value = Sin(Sum([this.value, Fraction.fromInt(90)])).simplifyAll();
    if (value is Sin) return Cos(this.value.simplifyAll());
    return value;
  }
}

class Tan extends FunctionAtom {
  final Expression value;
  Tan(this.value);

  String toString() => "tan(${value.toInfix()})";

  // converts tan to sin/cos and simplifies both sin and cos
  @override
  Expression simplify() {
    final val = value.simplifyAll();
    if (val is Fraction &&
        val.isInteger &&
        (val.asInteger - BigInt.from(90)) % BigInt.from(180) == BigInt.zero)
      throw InvalidArgumentsError();
    final s =
        Parser().parse(Lexer().tokenize("sin($val)/cos($val)")).simplifyAll();
    if (Sin(this.value).simplifyAll() is Sin) return Tan(val);
    return s;
  }
}
