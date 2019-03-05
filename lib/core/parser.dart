import 'package:computer_algebra_system/core/expression/function.dart';
import 'package:computer_algebra_system/core/expression/vector.dart';

import './lexer/token.dart';
import './expression/expression.dart';
import './expression/binary.dart';
import './expression/fraction.dart';
import './expression/variable.dart';
import './expression/product.dart';

class Parser {
  List<Token> _tokens;
  int _position;

  Token get _next {
    return _tokens[_position];
  }

  _consume() {
    _position++;
  }

  // implemented based on https://en.wikipedia.org/wiki/Operator-precedence_parser#Precedence_climbing_method
  Expression parse(List<Token> tokens) {
    _tokens = tokens;
    _position = 0;

    final Expression tree = _parseTree(0);
    if (_position < _tokens.length && _next.type != TokenType.End)
      throw "Error parsing the expression";
    return tree;
  }

  Expression _parseTree(int precedence) {
    Expression left = _parseNext();
    bool keepParsing = true;

    while (keepParsing) {
      if (_position < _tokens.length &&
          _isBinaryOperator(_next) &&
          getPrecedence(_next.type) >= precedence) {
        final String symbol = _next.lexeme[0];
        final int newPrecedence =
            getPrecedence(_next.type) + (_isRightAssociative(_next) ? 0 : 1);
        _consume();
        final Expression right = _parseTree(newPrecedence);
        left = Binary.create(symbol, left, right);
      } else {
        keepParsing = false;
      }
    }
    return left;
  }
  
  Expression _parseNext() {
    if (_next.type == TokenType.Add) {
      _consume();
      return _parseNext();
    } else if (_next.type == TokenType.Decimal ||
        _next.type == TokenType.WholeNumber) {
      final Fraction fraction = Fraction.parse(_next.lexeme);
      _consume();
      return fraction;
    } else if (_isUnary(_next)) {
      int precedence = getPrecedence(_toUnary(_next).type);
      _consume();
      final t = _parseTree(precedence);
      if (t is Fraction) return t.negate();
      return Product([Fraction.fromInt(-1), t]);
    } else if (_next.type == TokenType.LeftBracket) {
      _consume();
      final t = _parseTree(0);
      if (_next.type != TokenType.RightBracket)
        throw Exception("Expected ')', given ${_next.lexeme}");
      _consume();
      return t;
    } else if (_next.type == TokenType.String) {
      if (_isFunction(_next)) {
        final functionName = _next.lexeme.toLowerCase();
        _consume();
        final List<Expression> args = [];
        do {
          _consume();
          args.add(_parseTree(0));
        } while (_next.type == TokenType.Comma);
        if (_next.type != TokenType.RightBracket)
          throw Exception("Expected ')', given '${_next.lexeme}'");
        _consume();
        return FunctionAtom.create(functionName, args);
      } else {
        final List<Variable> variables =
            _next.lexeme.split("").map((char) => Variable(char)).toList();
        _consume();
        return Product(variables);
      }
    } else if (_next.type == TokenType.LeftVectorBracket) {
      // _consume();
      final List<Expression> args = [];
      do {
        _consume();
        args.add(_parseTree(0));
      } while (_next.type == TokenType.Comma);
      if (_next.type != TokenType.RightVectorBracket)
        throw Exception("Expected ']', given '${_next.lexeme}'");
      _consume();
      return Vector(args);
    } else {
      throw Exception("Invalid token \"$_next\"");
    }
  }

  // gets the precedence of a token
  static int getPrecedence(TokenType type) {
    switch (type) {
      case TokenType.Equals:
        return 0;
      case TokenType.Add:
      case TokenType.Subtract:
        return 1;
      case TokenType.Negate:
        return 2;
      case TokenType.Multiply:
      case TokenType.Divide:
        return 3;
      case TokenType.Power:
        return 4;
      default:
        throw Exception("Invalid token $type");
    }
  }

  // converts a string symbol to a token type
  static TokenType tokenFromSymbol(String s) {
    switch (s) {
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
      default:
        throw Exception("Cannot get token type from symbol $s");
    }
  }

  // returns true if the given token is a binary operator
  static bool _isBinaryOperator(Token t) {
    switch (t.type) {
      case TokenType.Equals:
      case TokenType.Add:
      case TokenType.Subtract:
      case TokenType.Multiply:
      case TokenType.Divide:
      case TokenType.Power:
        return true;
      default:
        return false;
    }
  }

  // returns true if the token is right associative (only ^ power operator)
  static bool _isRightAssociative(Token t) {
    if (t.type == TokenType.Power) return true;
    return false;
  }

  // in some cases, such as e.g. 5 * (-2), the - is not a binary operator
  // it is what we call a unary operator which only takes in one argument
  static bool _isUnary(Token t) => t.type == TokenType.Subtract;


  // if a token is a "-" token, its negated value will be added
  static Token _toUnary(Token t) {
    TokenType type = t.type;
    if (t.type == TokenType.Subtract) type = TokenType.Negate;
    return Token(type, t.lexeme);
  }

  // returns true if the token is a valid function
  static bool _isFunction(Token t) {
    if (t.type != TokenType.String) return false;
    final name = t.lexeme.toLowerCase();
    switch (name) {
      case "sin":
      case "cos":
      case "tan":
      case "log":
      case "magnitude":
      case "differentiate":
      case "integrate":
        return true;
      default:
        return false;
    }
  }
}
