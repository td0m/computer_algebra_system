import '../function.dart';
import "../expression.dart";

class Log extends FunctionAtom {
  final Expression base;
  final Expression value;
  Log(this.base, this.value);

  String toString() => "log(${base.toInfix()},${value.toInfix()})";

  static Expression create(Expression base, Expression value) {
    return Log(base, value);
  }
}
