import 'package:computer_algebra_system/core/expression/fraction.dart';
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

  Product simplifyProduct() {
    Fraction product = Fraction.one;
    List<Expression> factors = [];
    Vector vector = Vector.empty;

    for (final factor in this.factors.map((f) => f.simplify())) {
      if (factor is Fraction) {
        product *= factor;
      } else if (factor is Vector) {
        vector *= factor;
      } else {
        factors.add(factor);
      }
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
    final product = this.simplifyProduct();
    if (product.factors.length == 1) return product.factors.first;
    if (product.factors.length == 0) return Fraction.zero;
    return product;
  }

  String toString() => "*";
}
