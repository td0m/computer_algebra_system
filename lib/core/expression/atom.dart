import './expression.dart';

// either numbers, vectors or variables
abstract class Atom extends Expression {
  @override
  get terms => [];
  @override
  get atoms => [this];
}
