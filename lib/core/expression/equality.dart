import "./binary.dart";
import "./expression.dart";

class Equality extends Binary {
  Equality(Expression left, Expression right) : super("=", left, right);

  @override
  Expression simplify() => Equality(left.simplify(), right.simplify());
}
