import "./expression.dart";
import "./atom.dart";

class Sum extends Expression {
  final List<Expression> factors;
  Sum([List<Expression> factors = const []]) : this.factors = flatten(factors);

  /// if there is a sum inside of a sum, it will flatten it and reduce it to only one sum
  static List<Expression> flatten(List<Expression> expressions) {
    List<Expression> flattened = [];
    for (final expresison in expressions) {
      if (expresison is Sum) {
        flattened.addAll(flatten(expresison.terms));
      } else {
        flattened.add(expresison);
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

  String toString() => "+";
}
