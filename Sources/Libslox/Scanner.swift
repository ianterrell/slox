//
//  Scanner.swift
//  Libslox
//
//  Created by Ian Terrell on 10/22/20.
//

import Foundation

class Scanner {
  unowned let interpreter: Interpreter

  let source: String
  var tokens: [Token] = []

  var start: String.Index
  var current: String.Index
  var line = 1
  var isAtEnd: Bool { current >= source.endIndex }
  var currentLexeme: String { String(source[start..<current]) }

  static let keywordMap: [String: TokenType] = [
    "and": .AND,
    "class": .CLASS,
    "else": .ELSE,
    "false": .FALSE,
    "for": .FOR,
    "fun": .FUN,
    "if": .IF,
    "nil": .NIL,
    "or": .OR,
    "print": .PRINT,
    "return": .RETURN,
    "super": .SUPER,
    "this": .THIS,
    "true": .TRUE,
    "var": .VAR,
    "while": .WHILE,
  ]

  init(source: String, runningIn interpreter: Interpreter) {
    self.source = source
    self.start = source.startIndex
    self.current = source.startIndex
    self.interpreter = interpreter
  }

  func scanTokens() -> [Token] {
    while !isAtEnd {
      start = current
      scanToken()
    }
    tokens.append(Token(type: .EOF, lexeme: "", line: line))
    return tokens
  }

  func scanToken() {
    let c = advance()
    switch (c) {
    case "(": addToken(.LEFT_PAREN)
    case ")": addToken(.RIGHT_PAREN)
    case "{": addToken(.LEFT_BRACE)
    case "}": addToken(.RIGHT_BRACE)
    case ",": addToken(.COMMA)
    case ".": addToken(.DOT)
    case "-": addToken(.MINUS)
    case "+": addToken(.PLUS)
    case ";": addToken(.SEMICOLON)
    case "*": addToken(.STAR)
    case "!": addToken(match("=") ? .BANG_EQUAL : .BANG)
    case "=": addToken(match("=") ? .EQUAL_EQUAL : .EQUAL)
    case "<": addToken(match("=") ? .LESS_EQUAL : .LESS)
    case ">": addToken(match("=") ? .GREATER_EQUAL : .GREATER)
    case "/":
      if match("/") {
        // A comment goes until the end of the line.
        while peek() != "\n" && !isAtEnd {
          advance()
        }
      } else {
        addToken(.SLASH)
      }
    case "\"": string()

    // Ignore whitespace.
    case " ": fallthrough
    case "\r": fallthrough
    case "\t": break
    case "\n": line += 1

    default:
      if isDigit(c) {
        number()
      } else if isAlpha(c) {
        identifier()
      } else {
        interpreter.reportError(line: line, message: "Unexpected character: \(c)")
      }
    }
  }

  func addToken(_ type: TokenType) {
    tokens.append(Token(type: type, lexeme: currentLexeme, line: line))
  }

  func peek() -> Character {
    guard !isAtEnd else { return "\0" }
    return source[current]
  }

  func peekNext() -> Character {
    let next = source.index(after: current)
    guard next < source.endIndex else { return "\0" }
    return source[next]
  }

  @discardableResult
  func advance() -> Character {
    let c = source[current]
    current = source.index(after: current)
    return c
  }

  func match(_ expected: Character) -> Bool {
    guard
      !isAtEnd,
      source[current] == expected
    else {
      return false
    }
    current = source.index(after: current)
    return true
  }

  func isDigit(_ c: Character) -> Bool {
    return c >= "0" && c <= "9"
  }

  func isAlpha(_ c: Character) -> Bool {
    return (c >= "a" && c <= "z") ||
           (c >= "A" && c <= "Z") ||
            c == "_"
  }

  func isAlphanumeric(_ c: Character) -> Bool {
    return isAlpha(c) || isDigit(c)
  }

  func string() {
    while peek() != "\"" && !isAtEnd {
      if peek() == "\n" { line += 1 }
      advance()
    }

    guard !isAtEnd else {
      interpreter.reportError(line: line, message: "Unterminated string")
      return
    }

    advance() // Consume the closing "
    addToken(.STRING)
  }

  func number() {
    while isDigit(peek()) { advance() }
    // Look for a fractional part.
    if peek() == "." && isDigit(peekNext()) {
      advance() // Consume the "."
      while isDigit(peek()) { advance() }
    }

    addToken(.NUMBER)
  }

  func identifier() {
    while isAlphanumeric(peek()) { advance() }
    if let keyword = Scanner.keywordMap[currentLexeme] {
      addToken(keyword)
    } else {
      addToken(.IDENTIFIER)
    }
  }
}
