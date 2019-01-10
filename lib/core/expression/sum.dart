import 'package:computer_algebra_system/core/expression/fraction.dart';
import 'package:computer_algebra_system/core/expression/power.dart';
import 'package:computer_algebra_system/core/expression/product.dart';
import 'package:computer_algebra_system/core/expression/variable.dart';
import 'package:computer_algebra_system/core/expression/vector.dart';
import 'package:computer_algebra_system/core/errors.dart';
import 'package:computer_algebra_system/core/lexer/fsm.dart';
import 'package:computer_algebra_system/core/lexer/lexer.dart';
import 'package:computer_algebra_system/core/parser.dart';

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

  /// Reduces the amount of terms in a sum so that they're in the simplest possible form
  ///
  /// e.g. simplifySum(5x+x) -> 6x
  /// e.g. simplifySum(5x+5x+5) -> 10x+5
  Sum simplifySum() {
    Fraction sum = Fraction.zero;
    Vector vector = Vector.empty;
    List<Expression> factors = [];
    Map<String, Map<String, List<Expression>>> map = {};

    for (final factor in this.factors.map((f) => f.simplifyAll())) {
      if (factor is Fraction) {
        sum += factor;
      } else if (factor is Vector) {
        vector = vector + factor;
      } else {
        String vars = Expression.tryGetVariable(factor);
        if (vars == null || vars.length == 0)
          vars = Expression.getBase(factor).toInfix();
        final power = Expression.getPower(factor).toInfix();
        if (!map.containsKey(vars)) map[vars] = {};
        if (!map[vars].containsKey(power)) map[vars][power] = [];
        map[vars][power].add(Expression.getFractionalCoefficient(factor));
      }
    }
    for (final base in map.keys) {
      for (final power in map[base].keys) {
        final coefficients = map[base][power];
        final baseE = Parser().parse(Lexer().tokenize(base));
        final powerE = Parser().parse(Lexer().tokenize(power));
        factors.add(
            Product([Sum(coefficients), Power(baseE, powerE)]).simplifyAll());
      }
    }

    if (sum != Fraction.zero) factors.add(sum);
    if (!vector.isEmpty()) {
      if (factors.isNotEmpty) throw IncompatibleTypesError();
      factors.add(vector);
    }

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
    final sum = simplifySum();
    if (sum.factors.length == 1) return sum.factors.first;
    if (sum.factors.length == 0) return Fraction.zero;
    return sum;
  }

  String toString() => "+";
}
