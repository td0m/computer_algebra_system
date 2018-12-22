import 'package:computer_algebra_system/core/lexer/lexer.dart';

void main() {
  final tokens = Lexer().tokenize("6+5");
  print(tokens);
}
