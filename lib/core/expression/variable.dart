import "./atom.dart";

class Variable extends Atom {
  final String name;
  Variable(this.name);

  String toString() => name;
}
