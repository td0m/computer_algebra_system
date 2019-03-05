import 'package:computer_algebra_system/core/expression/expression.dart';
import 'package:computer_algebra_system/core/expression/fraction.dart';
import 'package:computer_algebra_system/core/expression/function.dart';
import 'package:computer_algebra_system/core/expression/power.dart';
import 'package:computer_algebra_system/core/expression/product.dart';
import 'package:computer_algebra_system/core/expression/sum.dart';
import 'package:computer_algebra_system/core/expression/variable.dart';

class Integrate extends FunctionAtom {
  final Sum value;
  Integrate(this.value);

  String toString() => "dy/dx(${toInfix()})";

  // integrates any term in form of ax^n and returns (a/(n+1))x^(n+1)
  // throws an error if not in the form of ax^n (not supported)
  static Expression integrateTerm(Expression term) {
    if (term is Fraction) return Product([term, Variable("x")]).simplifyAll();
    if (term is Power || term is Product || term is Variable) {
      Fraction a = Expression.getFractionalCoefficient(term);

      if (Expression.onlyContainsX(term)) {
        Fraction n = Expression.getXExponent(term);
        return Product(
            [a / (n + Fraction.one), Power(Variable("x"), n + Fraction.one)]);
      }
    }
    throw Exception("couldnt integrate");
  }

  @override
  Sum simplify() {
    // integrate each term in the sum
    List<Expression> sum =
        value.simplifySum().factors.map((t) => integrateTerm(t)).toList();
    sum.add(Variable("c"));
    return Sum(sum).simplifySum();
  }
}
