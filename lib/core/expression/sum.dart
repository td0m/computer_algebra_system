import 'package:computer_algebra_system/core/expression/fraction.dart';

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

  Sum simplifySum() {
    Fraction sum = Fraction.zero;
    List<Expression> factors = [];

    for (final factor in this.factors.map((f) => f.simplify())) {
      if (factor is Fraction) {
        sum += factor;
      } else {
        factors.add(factor);
      }
    }

    if (sum != Fraction.zero) factors.add(sum);

    return Sum(factors);
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
    final sum = this.simplifySum();
    if (sum.factors.length == 1) return sum.factors.first;
    if (sum.factors.length == 0) return Fraction.zero;
    return sum;
  }

  String toString() => "+";
}
