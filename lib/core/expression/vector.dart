import 'package:computer_algebra_system/core/expression/expression.dart';
import 'package:computer_algebra_system/core/expression/fraction.dart';
import 'package:computer_algebra_system/core/expression/product.dart';
import 'package:computer_algebra_system/core/expression/sum.dart';
import "dart:math";

import "./atom.dart";

class Vector extends Atom {
  static Vector empty = Vector([]);

  final List<Expression> values;
  Vector(this.values);

  bool isEmpty() => values.length == 0;

  // add two vectors
  Vector operator +(Vector other) {
    List<Expression> summed = [];

    for (int i = 0; i < max(values.length, other.values.length); i++) {
      final a = i < values.length ? values[i] : Fraction.zero;
      final b = i < other.values.length ? other.values[i] : Fraction.zero;

      summed.add(Sum([a, b]).simplifyAll());
    }

    return Vector(summed);
  }

  // dot product / multiplication based on the "multiplier"
  Vector operator *(Expression multiplier) {
    // calculate the dot product
    if (multiplier is Vector) {
      List<Expression> product = [];

      for (int i = 0; i < max(values.length, multiplier.values.length); i++) {
        final a = i < values.length ? values[i] : Fraction.one;
        final b =
            i < multiplier.values.length ? multiplier.values[i] : Fraction.one;

        product.add(Product([a, b]).simplifyAll());
      }

      return Vector(product);
    }
    // multiplies all of the terms in the vector by the multiplier
    return Vector(
        values.map((v) => Product([v, multiplier]).simplifyAll()).toList());
  }

  String toString() => "[${values.map((v) => v.toInfix()).join(",")}]";
}
