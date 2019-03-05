import 'package:computer_algebra_system/core/solver/solve.dart';
import 'package:computer_algebra_system/ui/pages/calculator_page.dart';

void main() {
  print(
    Solver.solveSimultaneously(
        CalculatorPage.solve("5y+x=17"), CalculatorPage.solve("2x+3y=13")),
  );
}
