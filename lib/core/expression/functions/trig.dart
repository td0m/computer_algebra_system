import 'package:computer_algebra_system/core/expression/expression.dart';
import 'package:computer_algebra_system/core/expression/fraction.dart';
import 'package:computer_algebra_system/core/expression/function.dart';
import 'package:computer_algebra_system/core/expression/power.dart';
import 'package:computer_algebra_system/core/expression/product.dart';
import 'package:computer_algebra_system/core/expression/sum.dart';
import 'package:computer_algebra_system/core/lexer/lexer.dart';
import 'package:computer_algebra_system/core/parser.dart';

Map<BigInt, Expression> exactSinValues = {
  BigInt.zero: Fraction.zero,
  BigInt.from(30): Fraction.fromInt(1, 2),
  BigInt.from(45): Parser().parse(Lexer().tokenize("2^(-1/2)")),
  BigInt.from(60): Parser().parse(Lexer().tokenize("3^(1/2)/2")),
  BigInt.from(90): Fraction.one,
};

BigInt simplifySinValue(BigInt value) {
  final multiplier = value ~/ BigInt.from(360);
  return value - (BigInt.from(360) * multiplier);
}

class Sin extends FunctionAtom {
  final Expression value;
  Sin(this.value);

  String toString() => "sin(${value.toInfix()})";

  @override
  Expression simplify() {
    final val = value.simplify();
    if (val is Fraction && val.isInteger) {
      final sinValue = simplifySinValue(val.asInteger);
      final multiplier = sinValue ~/ BigInt.from(180);
      bool isNegative = multiplier % BigInt.two == BigInt.one;
      BigInt key = sinValue - (multiplier * BigInt.from(180));
      if (key > BigInt.from(90)) key = BigInt.from(180) - key;
      if (exactSinValues.containsKey(key))
        return isNegative
            ? Product([Fraction.minusOne, exactSinValues[key]]).simplify()
            : exactSinValues[key].simplify();
    }
    return Sin(val);
  }
}

class Cos extends FunctionAtom {
  final Expression value;
  Cos(this.value);

  String toString() => "cos(${value.toInfix()})";

  @override
  Expression simplify() {
    final value = Sin(Sum([this.value, Fraction.fromInt(90)])).simplify();
    if (value is Sin) return this;
    return value;
  }
}

class Tan extends FunctionAtom {
  final Expression value;
  Tan(this.value);

  String toString() => "tan(${value.toInfix()})";

  @override
  Expression simplify() {
    return Tan(value.simplify());
  }
}
