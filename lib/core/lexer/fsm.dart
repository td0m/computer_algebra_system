import './token.dart';

// check if a string is a digit
bool isDigit(String char) {
  RegExp digitRe = RegExp("[0-9]");
  return digitRe.hasMatch(char);
}

// check if a string is a letter
bool isLetter(String char) {
  RegExp letterRe = RegExp("[a-z]", caseSensitive: false);
  return letterRe.hasMatch(char);
}

class Fsm {
  final TokenType type;
  final bool success;
  final int length;

  Fsm(this.type, this.success, this.length);

  static Fsm run(String input) {
    TokenType currentState = TokenType.Initial;

    for (var i = 0; i < input.length; i++) {
      String char = input[i];
      TokenType nextTokenType = getNextTokenType(currentState, char);
      if (nextTokenType == TokenType.End) {
        return Fsm(currentState, isSuccess(currentState), i);
      }
      currentState = nextTokenType;
    }

    return Fsm(currentState, isSuccess(currentState), input.length);
  }

  // returns true if the input isnt empty (initial) and if it hasn't ended yet (end)
  static bool isSuccess(TokenType currentState) {
    if (currentState == TokenType.End || currentState == TokenType.Initial)
      return false;
    return true;
  }

  // the finite state machine core logic
  static TokenType getNextTokenType(TokenType currentToken, String char) {
    switch (currentToken) {
      case TokenType.Initial:
        {
          if (isDigit(char)) return TokenType.WholeNumber;
          if (isLetter(char)) return TokenType.String;
          switch (char) {
            case "=":
              return TokenType.Equals;
            case "+":
              return TokenType.Add;
            case "-":
              return TokenType.Subtract;
            case "*":
              return TokenType.Multiply;
            case "/":
              return TokenType.Divide;
            case "^":
              return TokenType.Power;
            case ",":
              return TokenType.Comma;
            case "(":
              return TokenType.LeftBracket;
            case ")":
              return TokenType.RightBracket;
            case "[":
              return TokenType.LeftVectorBracket;
            case "]":
              return TokenType.RightVectorBracket;
          }
          break;
        }
      case TokenType.String:
        {
          if (isLetter(char)) return TokenType.String;
          break;
        }
      case TokenType.WholeNumber:
        {
          if (isDigit(char)) return TokenType.WholeNumber;
          if (char == ".") return TokenType.IncompleteDecimal;
          break;
        }
      case TokenType.IncompleteDecimal:
        {
          if (isDigit(char)) return TokenType.Decimal;
          break;
        }
      case TokenType.Decimal:
        {
          if (isDigit(char)) return TokenType.Decimal;
          break;
        }
      default:
        return TokenType.End;
    }
    return TokenType.End;
  }
}
