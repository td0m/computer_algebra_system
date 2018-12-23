import 'package:computer_algebra_system/core/expression/function.dart';

import "../expression.dart";

class Sin extends FunctionAtom {
  final Expression value;
  Sin(this.value);

  String toString() => "sin(${value.toInfix()})";

  static Expression create(Expression value) {
    return Sin(value);
  }
}

class Cos extends FunctionAtom {
  final Expression value;
  Cos(this.value);

  String toString() => "cos(${value.toInfix()})";

  static Expression create(Expression value) {
    return Cos(value);
  }
}

class Tan extends FunctionAtom {
  final Expression value;
  Tan(this.value);

  String toString() => "tan(${value.toInfix()})";

  static Expression create(Expression value) {
    return Tan(value);
  }
}
