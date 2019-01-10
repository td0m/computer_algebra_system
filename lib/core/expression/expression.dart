import 'package:computer_algebra_system/core/expression/power.dart';
import 'package:computer_algebra_system/core/expression/variable.dart';

import './atom.dart';
import './fraction.dart';
import './product.dart';
import './binary.dart';
import './sum.dart';
import '../parser.dart';

abstract class Expression {
  List<Expression> terms = [];
  List<Atom> atoms = [];

  /// defines whether the equation has already been simplified
  /// used to prevent some simplification algorithms from running recursively forever
  bool simplified = false;

  /// only simplifies if the equation isn't already simplified
  Expression simplifyAll() {
    if (simplified) return this;
    return simplify();
  }

  Expression simplify() => this;

  /// Prints the expression tree to console for debugging purposes
  void printTree([int tabs = 0]) {
    print("  " * tabs + "$this");
    for (var term in terms) {
      term.printTree(tabs + 1);
    }
  }

  /// Converts the expression tree to a formatted infix notation
  ///
  /// Throws an [Exception] if the operator has no arguments
  String toInfix([int parentPrecendence = -1]) {
    String out = "$this";
    if (this is Binary || this is Product || this is Sum) {
      int precedence =
          Parser.getPrecedence(Parser.tokenFromSymbol(this.toString()));
      if (terms.length > 0) {
        out = terms.first.toInfix(precedence);
        for (int i = 1; i < terms.length; i++) {
          var t = terms[i];
          if (t is Fraction && t < Fraction.zero && this is Sum)
            out += t.toInfix(precedence);
          else {
            out += "$this" + t.toInfix(precedence);
          }
        }
        if (parentPrecendence > precedence) out = "($out)";
      } else {
        throw Exception("No arguments!");
      }
    }
    return out;
  }

  /// returns true if the expression contains a variable
  static bool isVariable(Expression e) {
    for (final atom in e.atoms) {
      if (atom is Variable) return true;
    }
    return false;
  }

  /// returns the power of an expression
  ///
  /// e.g. f(x^3) -> 3
  static Expression getPower(Expression e) {
    if (e is Atom)
      return Fraction.one;
    else if (e is Power)
      return e.right;
    else if (e is Product) {
      for (final term in e.terms) {
        if (isVariable(term)) return getPower(term);
      }
    }
    return Fraction.one;
  }

  /// gets a fractional coefficient of an expression
  ///
  /// e.g. f(5x^2) -> 5
  static Fraction getFractionalCoefficient(Expression e) {
    if (e is Variable) return Fraction.one;
    if (e is Product) {
      Fraction product = Fraction.one;
      for (final term in e.terms) {
        if (term is Fraction) product = product * term;
      }
      return product;
    }
    return Fraction.one;
  }

  /// gets the string sequence of variables and sorts them
  ///
  /// e.g. f(5xzy) -> xyz
  static String tryGetVariable(Expression e) {
    if (e is Variable) return e.name;
    if (e is Product) {
      List<String> vars = [];
      for (final term in e.terms) {
        if (isVariable(term)) vars.add(tryGetVariable(term));
      }
      vars.sort();
      return vars.join();
    }
    if (e is Power) {
      if (isVariable(e.left)) return tryGetVariable(e.left);
    }
    return null;
  }

  /// gets the exponent of x
  /// throws an exception if not found
  /// used by differentiation and integration
  static Expression getXExponent(Expression e) {
    if (e is Variable && e.name == "x") return Fraction.one;
    if (e is Power && e.left is Variable && (e.left as Variable).name == "x")
      return e.right;
    if (e is Product) {
      for (final term in e.factors) {
        if (term is Variable || term is Power || term is Product)
          return getXExponent(term);
      }
    }
    throw Exception();
  }

  /// returns true if other variables used or if it doesn't contain x
  /// used by differentiation and integration
  static bool onlyContainsX(Expression e) {
    try {
      getXExponent(e);
      return true;
    } catch (err) {
      return false;
    }
  }

  /// returns the base of a power, or the whole expression if it's not a power
  /// e.g.
  ///     f(x^2) -> x
  ///     f(x+2) -> x+2
  static Expression getBase(Expression e) {
    if (e is Power) return e.left;
    return e;
  }
}
