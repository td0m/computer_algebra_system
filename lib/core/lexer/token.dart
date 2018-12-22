enum TokenType {
  Initial,
  End,

  // operands
  WholeNumber,
  Decimal,
  String,
  IncompleteDecimal, // invalid

  // binary operators
  Equals,
  Add,
  Subtract,
  Multiply,
  Divide,
  Power,

  // unary operators
  Negate,

  // brackets
  LeftBracket,
  RightBracket,

  // vectors
  LeftVectorBracket,
  RightVectorBracket,

  // other
  Comma
}

class Token {
  final TokenType type;
  final String lexeme;

  Token(this.type, [this.lexeme = ""]);

  @override
  String toString() => lexeme;
}
