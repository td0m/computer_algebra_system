import 'package:computer_algebra_system/core/expression/fraction.dart';
import 'package:computer_algebra_system/core/expression/product.dart';

import "./expression.dart";
import "./binary.dart";

class Power extends Binary {
  Power(Expression left, Expression right) : super("^", left, right);

  static Expression create(Expression left, Expression right) {
    return Power(left, right);
  }

  @override
  Expression simplify() {
    final left = this.left.simplify();
    final right = this.right.simplify();
    if (right is Fraction && right == Fraction.one) return left;
    if (right is Fraction && right == Fraction.zero) return Fraction.one;
    if (left is Fraction && right is Fraction) return left ^ right;
    if (left is Power)
      return Power(left.left, Product([left.right, right])).simplify();
    if (left is Product) {
      final factors = left.factors.map((f) => Power(f, right));
      return Product(factors.toList()).simplify();
    }
    return Power(left, right);
  }
}
