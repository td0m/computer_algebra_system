import 'package:computer_algebra_system/core/expression/fraction.dart';
import 'package:computer_algebra_system/core/expression/power.dart';
import 'package:computer_algebra_system/core/expression/sum.dart';
import 'package:computer_algebra_system/core/expression/vector.dart';
import 'package:computer_algebra_system/core/lexer/lexer.dart';
import 'package:computer_algebra_system/core/parser.dart';

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

  /// Reduces the amount of terms in a product so that they're in the simplest possible form
  ///
  /// e.g. simplifySum(5x+x) -> 6x
  /// e.g. simplifySum(5x+5x+5) -> 10x+5
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
        String vars = Expression.tryGetVariable(factor);
        Expression power = Expression.getPower(factor);
        if (vars == null || vars.length == 0) {
          Expression base = Expression.getBase(factor);
          if (base is Fraction &&
              base != Fraction.one &&
              base.numerator == BigInt.one &&
              base.denominator > BigInt.one) {
            base = (base as Fraction).reciprocal();
            power = Product([power, Fraction.minusOne]).simplifyAll();
          }
          vars = base.toInfix();
        }
        if (!map.containsKey(vars)) map[vars] = [];
        map[vars].add(power);
      }
    }
    for (final base in map.keys) {
      // need to do basic product simplification here in order to avoid an infinite loop
      Expression baseE = Parser().parse(Lexer().tokenize(base));
      if (baseE is Product && baseE.factors.length == 1)
        baseE = (baseE as Product).factors.first;
      else if (baseE is Product && baseE.factors.length == 0)
        baseE = Fraction.zero;
      // prevents the program from going into an infinite loop
      baseE.simplified = true;
      final powerE = Sum(map[base]).simplifyAll();
      factors.add(Power(baseE, powerE).simplifyAll());
    }

    // we still need to return a product even if the answer is 0
    if (product == Fraction.zero) return Product([]);
    // add the fractional product if there are no variable factors or the product isn't one
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
    final product =
        simplifyProduct(flatten(factors.map((f) => f.simplifyAll()).toList()));
    if (product.factors.length == 1) return product.factors.first;
    if (product.factors.length == 0) return Fraction.zero;
    return product;
  }

  String toString() => "*";
}
