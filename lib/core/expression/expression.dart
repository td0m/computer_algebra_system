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

  static bool isVariable(Expression e) {
    for (final atom in e.atoms) {
      if (atom is Variable) return true;
    }
    return false;
  }

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

  static Expression getBase(Expression e) {
    if (e is Power) return e.left;
    return e;
  }
}
