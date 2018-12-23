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

  String toString() => "*";
}
