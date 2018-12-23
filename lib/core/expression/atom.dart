import './expression.dart';

abstract class Atom extends Expression {
  @override
  get terms => [];
  @override
  get atoms => [this];
}
