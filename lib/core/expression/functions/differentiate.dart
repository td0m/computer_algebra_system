import 'package:computer_algebra_system/core/expression/expression.dart';
import 'package:computer_algebra_system/core/expression/fraction.dart';
import 'package:computer_algebra_system/core/expression/function.dart';
import 'package:computer_algebra_system/core/expression/power.dart';
import 'package:computer_algebra_system/core/expression/product.dart';
import 'package:computer_algebra_system/core/expression/sum.dart';
import 'package:computer_algebra_system/core/expression/variable.dart';

class Differentiate extends FunctionAtom {
  final Sum value;
  Differentiate(this.value);

  String toString() => "dy/dx(${toInfix()})";

  // takes a single term in the form of ax^n and returns (an)x^(n-1)
  // throws an error if not in the form of ax^n (not supported)
  static Expression differentiateTerm(Expression term) {
    if (term is Fraction) return Fraction.zero;
    if (term is Power || term is Product || term is Variable) {
      Fraction a = Expression.getFractionalCoefficient(term);

      if (Expression.onlyContainsX(term)) {
        Fraction n = Expression.getXExponent(term);
        return Product([a * n, Power(Variable("x"), n - Fraction.one)]);
      }
    }
    throw Exception("couldnt differentiate");
  }

  @override
  Sum simplify() {
    // differentiate each term
    List<Expression> sum =
        value.simplifySum().factors.map((t) => differentiateTerm(t)).toList();
    return Sum(sum).simplifySum();
  }
}
