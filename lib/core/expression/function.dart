import 'package:computer_algebra_system/core/errors.dart';
import 'package:computer_algebra_system/core/expression/atom.dart';
import 'package:computer_algebra_system/core/expression/expression.dart';
import 'package:computer_algebra_system/core/expression/fraction.dart';
import 'package:computer_algebra_system/core/expression/functions/log.dart';
import 'package:computer_algebra_system/core/expression/functions/magnitude.dart';
import 'package:computer_algebra_system/core/expression/functions/trig.dart';
import 'package:computer_algebra_system/core/expression/vector.dart';

abstract class FunctionAtom extends Atom {
  static FunctionAtom create(String name, List<Expression> args) {
    // trigonometric functions
    if (name == "sin" && args.length == 1) return Sin.create(args.first);
    if (name == "cos" && args.length == 1)
      return Cos.create(args.first);
    else if (name == "tan" && args.length == 1) return Tan.create(args.first);

    // logarithms
    if (name == "log" && args.length == 1)
      return Log.create(Fraction.fromInt(10), args[0]);
    if (name == "log" && args.length == 2) return Log.create(args[0], args[1]);
    if (name == "magnitude" && args.length == 1 && args.first is Vector)
      return Magnitude(args.first as Vector);
    throw InvalidArgumentsError();
  }
}
