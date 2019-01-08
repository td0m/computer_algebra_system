import "../expression/expression.dart";
import "../expression/sum.dart";
import "../expression/equality.dart";
import "../expression/fraction.dart";
import "../expression/product.dart";
import "../expression/variable.dart";
import "../expression/power.dart";

import "../expression/functions/log.dart";

class Solution {
  final String name;
  final Expression value;
  final bool isSimultaneous;

  Solution(this.name, Expression value, {bool isSimultaneous = false})
      : this.value = value.simplifyAll(),
        this.isSimultaneous = isSimultaneous;

  @override
  toString() => "$name = ${value.toInfix()}";

  operator ==(other) {
    if (other is Solution) return name == other.name && value == other.value;
    return false;
  }
}

List<Solution> solveEquality(Expression e) {
  if (e is Equality) {
    // rearrange numbers to right, unknows to the right
    Sum left = Sum([e.left]);
    Sum right = Sum([e.right]);

    final List<Expression> leftTerms = [];
    final List<Expression> rightTerms = [];

    for (final term in left.factors) {
      if (Expression.isVariable(term)) {
        leftTerms.add(term);
      } else {
        rightTerms.add(Product([Fraction.minusOne, term]).simplifyAll());
      }
    }
    for (final term in right.factors) {
      if (Expression.isVariable(term)) {
        leftTerms.add(Product([Fraction.minusOne, term]).simplifyAll());
      } else {
        rightTerms.add(term);
      }
    }

    left = Sum(leftTerms).simplifySum();
    right = Sum(rightTerms).simplifySum();

    if (left.factors.length == 1) {
      final l = left.factors[0];

      // linear equation
      if (l is Variable) return [Solution(l.name, right)];

      // exponential
      if (l is Power) {
        // a^x = b  ->  x = log_a(b)
        var a = l.left;
        var x = l.right;
        if (a is Fraction && x is Variable) {
          return [Solution(x.name, Log(a, right).simplifyAll())];
        } else if (a is Variable && x is Fraction) {
          return [Solution(a.name, Power(right, x.reciprocal()).simplifyAll())];
        } else {
          return solveEquality(Equality(x, Log(a, right)).simplifyAll());
        }
      }

      if (l is Product) {
        List<Expression> newLeft = [];
        Expression newRight = right;

        for (final term in l.terms) {
          if (term is Fraction) {
            newRight = Product([newRight, Power(term, Fraction.minusOne)])
                .simplifyAll();
          } else {
            newLeft.add(term);
          }
        }
        return solveEquality(
            Equality(Product(newLeft), newRight).simplifyAll());
      }
    } else if (left.factors.length == 2) {
      final l1 = left.factors[0];
      final l2 = left.factors[1];
      if (Expression.isVariable(l1) &&
          Expression.isVariable(l2) &&
          Expression.tryGetVariable(l1).length == 1) {
        if (Expression.tryGetVariable(l1) == Expression.tryGetVariable(l2)) {
          Fraction a = Expression.getFractionalCoefficient(l1);
          Fraction b = Expression.getFractionalCoefficient(l2);

          Fraction p1 = Expression.getPower(l1);
          Fraction p2 = Expression.getPower(l2);

          if (p1 == Fraction.fromInt(2) && p2 == Fraction.fromInt(1)) {
          } else if (p1 == Fraction.fromInt(1) && p2 == Fraction.fromInt(2)) {
            Fraction temp = a;
            a = b;
            b = temp;
          } else {
            throw Exception("invalid powers $p1 and $p2");
          }

          Fraction c = (right.factors.first as Fraction).negate();
          String symbol = Expression.tryGetVariable(l1);

          final solutions = solveQuadratic(a, b, c);
          return solutions.map((result) => Solution(symbol, result)).toList();
        } else {
          return [
            Solution(
              Expression.tryGetVariable(l1),
              Expression.getFractionalCoefficient(l1),
              isSimultaneous: true,
            ),
            Solution(
              Expression.tryGetVariable(l2),
              Expression.getFractionalCoefficient(l2),
              isSimultaneous: true,
            ),
            Solution("_", right, isSimultaneous: true)
          ];
        }
      }
    }
    print("${left.toInfix()} = ${right.toInfix()}");
  }
  throw Exception("equation not supported");
}

List<Expression> solveQuadratic(Fraction a, Fraction b, Fraction c) {
  Fraction discriminant = (b * b) - (Fraction.fromInt(4) * a * c);
  if (discriminant.numerator < BigInt.zero)
    throw Exception(
        "discriminant = $discriminant, which is below zero, therefore no solutions");

  Fraction divident = Fraction.fromInt(2) * a;

  Expression x1 = Product([
    Sum([b.negate(), sqrt(discriminant)]),
    divident.reciprocal()
  ]).simplifyAll();
  if (discriminant == Fraction.zero) return [x1];
  Expression x2 = Product([
    Sum([
      b.negate(),
      Product([Fraction.minusOne, sqrt(discriminant)])
    ]),
    divident.reciprocal()
  ]).simplifyAll();
  return [x1, x2];
}

Expression sqrt(Fraction other) => other ^ Fraction.fromInt(1, 2);

List<Solution> solveSimultaneously(
  List<Solution> first,
  List<Solution> second,
) {
  var map = <String, List<Fraction>>{};
  final solutions = first;
  solutions.addAll(second);

  for (final s in solutions) {
    if (!map.containsKey(s.name)) map[s.name] = [];
    map[s.name].add(s.value);
  }
  List<Fraction> a;
  List<Fraction> b;
  List<Fraction> c;
  String aKey;
  String bKey;
  if (map.keys.length != 3) throw Exception();
  for (final key in map.keys) {
    if (map[key].length != 2) throw Exception("not a simultaneous equation");
    if (key == "_")
      c = map[key];
    else if (a == null) {
      a = map[key];
      aKey = key;
    } else {
      b = map[key];
      bKey = key;
    }
  }
  final aResult =
      ((c[0] * b[1]) - (b[0] * c[1])) / ((b[1] * a[0]) - (a[1] * b[0]));
  final bResult =
      ((c[1] * a[0]) - (a[1] * c[0])) / ((b[1] * a[0]) - (a[1] * b[0]));
  return [
    Solution(aKey, aResult),
    Solution(bKey, bResult),
  ];
}
