import 'package:computer_algebra_system/core/expression/fraction.dart';
import 'package:computer_algebra_system/core/expression/product.dart';
import 'package:computer_algebra_system/core/expression/vector.dart';

import "./expression.dart";
import "./binary.dart";

class Power extends Binary {
  Power(Expression left, Expression right) : super("^", left, right);

  static Expression create(Expression left, Expression right) {
    return Power(left, right);
  }

  @override
  Expression simplify() {
    final left = this.left.simplifyAll();
    final right = this.right.simplifyAll();
    // x^1 = x
    if (right is Fraction && right == Fraction.one) return left;
    // x^0 = 1
    if (right is Fraction && right == Fraction.zero) return Fraction.one;
    // 0^a = 0
    if (left is Fraction && left == Fraction.zero) return Fraction.zero;
    // a^b = simplify(a^b)
    if (left is Fraction && right is Fraction) return left ^ right;
    if (left is Power)
      return Power(left.left, Product([left.right, right])).simplifyAll();
    if (left is Product) {
      final factors = left.factors.map((f) => Power(f, right));
      return Product(factors.toList()).simplifyAll();
    }
    if (left is Vector) {
      return Vector(
          left.values.map((v) => Power(v, right).simplifyAll()).toList());
    }
    return Power(left, right);
  }
}
