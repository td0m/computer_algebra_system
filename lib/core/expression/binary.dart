import './expression.dart';
import './fraction.dart';
import './sum.dart';
import './product.dart';
import './power.dart';
import './equality.dart';

abstract class Binary extends Expression {
  final String operator;
  final Expression left;
  final Expression right;

  Binary(this.operator, this.left, this.right);

  static Expression create(String op, Expression left, Expression right) {
    if (op == "+") return Sum([left, right]);
    // a-b => a+(-1)(b)
    if (op == "-")
      return Sum([
        left,
        Product([Fraction.minusOne, right])
      ]);
    if (op == "*") return Product([left, right]);
    // a/b => a*b^-1
    if (op == "/")
      return Product([left, Power.create(right, Fraction.minusOne)]);
    if (op == "^") return Power.create(left, right);
    if (op == "=") return Equality(left, right);
    throw Exception("Unsupported binary operator");
  }

  @override
  get terms => [left, right];
  @override
  get atoms => left.atoms..addAll(right.atoms);

  String toString() => operator;
}
