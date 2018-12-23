import "./expression.dart";
import "./binary.dart";

class Power extends Binary {
  Power(Expression left, Expression right) : super("^", left, right);

  static Expression create(Expression left, Expression right) {
    return Power(left, right);
  }
}
