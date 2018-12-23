import 'package:computer_algebra_system/core/expression/expression.dart';

import "./atom.dart";

class Vector extends Atom {
  final List<Expression> values;
  Vector(this.values);

  String toString() => "[${values.map((v) => v.toInfix()).join(",")}]";
}
