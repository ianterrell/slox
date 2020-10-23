//
//  Token.swift
//  Libslox
//
//  Created by Ian Terrell on 10/22/20.
//

import Foundation

enum TokenType: Equatable {
  // Single-character tokens.
  case LEFT_PAREN, RIGHT_PAREN, LEFT_BRACE, RIGHT_BRACE,
  COMMA, DOT, MINUS, PLUS, SEMICOLON, SLASH, STAR,

  // One or two character tokens.
  BANG, BANG_EQUAL,
  EQUAL, EQUAL_EQUAL,
  GREATER, GREATER_EQUAL,
  LESS, LESS_EQUAL,

  // Literals.
  IDENTIFIER, STRING, NUMBER,

  // Keywords.
  AND, CLASS, ELSE, FALSE, FUN, FOR, IF, NIL, OR,
  PRINT, RETURN, SUPER, THIS, TRUE, VAR, WHILE,

  EOF
}

struct Token: Equatable, CustomStringConvertible {
  let type: TokenType
  let lexeme: String
  let line: Int

  var description: String {
    if lexeme.isEmpty {
      return "\(type)"
    }
    return "\(type) \(lexeme)"
  }

  var stringLiteral: String? {
    guard type == .STRING else { return nil }
    let first = lexeme.index(after: lexeme.startIndex)
    let last = lexeme.index(before: lexeme.endIndex)
    return String(lexeme[first..<last])
  }

  var numberLiteral: Double? {
    guard type == .NUMBER else { return nil }
    return Double(lexeme)
  }
}

