import 'package:computer_algebra_system/core/errors.dart';

import './token.dart';
import './fsm.dart';

class Lexer {
  String _input;
  // Tracks the "current" position of the item in the input and recognises the end of input
  int _position;
  // Tracks how many brackets have been used and detects mismatching brackets
  int _depth;

  /// Converts a raw string input to a list of tokens that can be later parsed as an equation and solved
  ///
  /// Throws [MismatchingBracketsError] when brackets do not match
  List<Token> tokenize(String input) {
    _input = input;
    _position = 0;
    _depth = 0;
    List<Token> tokens = [];

    Token next = _nextToken();
    while (next.type != TokenType.End) {
      // number followed by a string -> number times string
      // ax -> a*x
      if (tokens.length > 0 &&
          (tokens.last.type == TokenType.WholeNumber ||
              tokens.last.type == TokenType.Decimal) &&
          next.type == TokenType.String) {
        tokens.add(Token(TokenType.Multiply, "*"));
      }
      // string followed by a number -> string to the power of the number
      // xa -> x^a
      if (tokens.length > 0 &&
          (next.type == TokenType.WholeNumber ||
              next.type == TokenType.Decimal) &&
          tokens.last.type == TokenType.String) {
        tokens.add(Token(TokenType.Power, "^"));
      }
      tokens.add(next);
      next = _nextToken();
    }
    if (_depth != 0) throw MismatchingBracketsError();
    return tokens;
  }

  /// Determines the content and the type of the next token
  ///
  /// Returns [TokenType.End] token when there are no tokens remaining in the input
  /// Throws [InvalidCharacterError] when invalid token given
  Token _nextToken() {
    // ignore whitespace
    while (_position < _input.length && _input[_position] == " ") {
      _position++;
    }

    // if there is no next token, return ending token
    if (_position >= _input.length) return Token(TokenType.End);

    // process the next token with the finite state machine
    final Fsm result = Fsm.run(_input.substring(_position));

    // cannot process the token
    if (!result.success) throw InvalidCharacterError();
    // commas outside of functions are not allowed
    if (result.type == TokenType.Comma && _depth < 1) throw InvalidCharacterError();

    // get the string that was processed by the fsm
    final String output =
        _input.substring(_position, _position + result.length);

    if (result.type == TokenType.LeftBracket ||
        result.type == TokenType.LeftVectorBracket) {
      _depth++;
    } else if (result.type == TokenType.RightBracket ||
        result.type == TokenType.RightVectorBracket) {
      _depth--;
    }

    // skip the characters that we just processed
    _position += result.length;
    return Token(result.type, output);
  }
}
