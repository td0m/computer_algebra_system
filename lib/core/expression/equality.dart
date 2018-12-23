import "./binary.dart";
import "./expression.dart";

class Equality extends Binary {
  Equality(Expression left, Expression right) : super("=", left, right);
}
