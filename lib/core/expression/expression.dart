import './atom.dart';
import './fraction.dart';
import './product.dart';
import './binary.dart';
import './sum.dart';
import '../parser.dart';

abstract class Expression {
  List<Expression> terms = [];
  List<Atom> atoms = [];

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
}
