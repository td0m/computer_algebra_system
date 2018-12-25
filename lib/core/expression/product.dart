import 'package:computer_algebra_system/core/expression/fraction.dart';
import 'package:computer_algebra_system/core/expression/power.dart';
import 'package:computer_algebra_system/core/expression/sum.dart';
import 'package:computer_algebra_system/core/expression/variable.dart';
import 'package:computer_algebra_system/core/expression/vector.dart';

import "./expression.dart";
import "./atom.dart";

class Product extends Expression {
  final List<Expression> factors;
  Product(List<Expression> factors) : this.factors = flatten(factors);

  /// if there is a product inside of a product, it will flatten it and reduce it to only one product
  static List<Expression> flatten(List<Expression> expressions) {
    List<Expression> flattened = [];
    for (final expression in expressions) {
      if (expression is Product) {
        flattened.addAll(flatten(expression.terms));
      } else {
        flattened.add(expression);
      }
    }
    return flattened;
  }

  static Product simplifyProduct(List<Expression> simplifiedFactorList) {
    Fraction product = Fraction.one;
    List<Expression> factors = [];
    Vector vector = Vector.empty;
    Map<String, List<Expression>> map = {};

    for (final factor in simplifiedFactorList) {
      if (factor is Fraction) {
        product *= factor;
      } else if (factor is Vector) {
        vector *= factor;
      } else {
        final vars = Expression.tryGetVariable(factor);
        if (vars != null && vars.length != 0) {
          final power = Expression.getPower(factor);
          if (!map.containsKey(vars)) map[vars] = [];
          map[vars].add(power);
        } else
          factors.add(factor);
      }
    }
    for (final base in map.keys) {
      // need to do basic product simplification here, in order to avoid a stack overflow
      List<Expression> variables =
          base.split("").map((s) => Variable(s)).toList();
      Expression baseE = Product(variables);
      if (variables.length == 1)
        baseE = variables.first;
      else if (variables.length == 0) baseE = Fraction.zero;

      factors.add(Power(baseE, Sum(map[base])).simplify());
    }

    if (factors.length == 0 || product != Fraction.one) factors.add(product);
    if (!vector.isEmpty()) return Product([vector * Product(factors)]);

    return Product(factors);
  }

  @override
  get terms => factors;

  @override
  get atoms {
    List<Atom> atoms = [];
    for (var term in factors) {
      atoms.addAll(term.atoms);
    }
    return atoms;
  }

  @override
  Expression simplify() {
    final product = simplifyProduct(factors.map((f) => f.simplify()).toList());
    if (product.factors.length == 1) return product.factors.first;
    if (product.factors.length == 0) return Fraction.zero;
    return product;
  }

  String toString() => "*";
}
