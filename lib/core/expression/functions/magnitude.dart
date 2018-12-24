import 'package:computer_algebra_system/core/expression/expression.dart';
import 'package:computer_algebra_system/core/expression/fraction.dart';
import 'package:computer_algebra_system/core/expression/function.dart';
import 'package:computer_algebra_system/core/expression/power.dart';
import 'package:computer_algebra_system/core/expression/sum.dart';
import 'package:computer_algebra_system/core/expression/vector.dart';

class Magnitude extends FunctionAtom {
  final Vector vector;
  Magnitude(this.vector);

  String toString() => "magnitude(${vector.toInfix()})";

  @override
  Expression simplify() {
    final termsSquared =
        vector.values.map((v) => Power(v, Fraction.fromInt(2))).toList();
    return Power(Sum(termsSquared), Fraction.fromInt(1, 2)).simplify();
  }
}
