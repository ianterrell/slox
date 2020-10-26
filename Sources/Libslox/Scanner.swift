class Scanner {
  let source: String

  var start: String.Index
  var current: String.Index
  var isAtEnd: Bool { current >= source.endIndex }
  var currentLexeme: String { String(source[start..<current]) }

  init(source: String) {
    self.source = source
    self.start = source.startIndex
    self.current = source.startIndex
  }

  func scanTokens() throws -> [Token] {
    var tokens: [Token] = []
    var errors: [SyntaxError] = []
    while !isAtEnd {
      start = current
      do {
        if let token = try scanToken() {
          tokens.append(token)
        }
      } catch let error as SyntaxError {
        errors.append(error)
      } catch {
        fatalError("Unexpected error: \(error)")
      }
    }
    tokens.append(.EOF(location: start, lexeme: ""))
    if errors.isEmpty {
      return tokens
    } else {
      throw CompositeLoxError(errors: errors)
    }
  }

  func scanToken() throws -> Token? {
    let c = advance()
    switch (c) {
    case "(": return .LEFT_PAREN(location: start, lexeme: currentLexeme)
    case ")": return .RIGHT_PAREN(location: start, lexeme: currentLexeme)
    case "{": return .LEFT_BRACE(location: start, lexeme: currentLexeme)
    case "}": return .RIGHT_BRACE(location: start, lexeme: currentLexeme)
    case ",": return .COMMA(location: start, lexeme: currentLexeme)
    case ".": return .DOT(location: start, lexeme: currentLexeme)
    case "-": return .MINUS(location: start, lexeme: currentLexeme)
    case "+": return .PLUS(location: start, lexeme: currentLexeme)
    case ";": return .SEMICOLON(location: start, lexeme: currentLexeme)
    case "*": return .STAR(location: start, lexeme: currentLexeme)
    case "!": return match("=") ? .BANG_EQUAL(location: start, lexeme: currentLexeme) : .BANG(location: start, lexeme: currentLexeme)
    case "=": return match("=") ? .EQUAL_EQUAL(location: start, lexeme: currentLexeme) : .EQUAL(location: start, lexeme: currentLexeme)
    case "<": return match("=") ? .LESS_EQUAL(location: start, lexeme: currentLexeme) : .LESS(location: start, lexeme: currentLexeme)
    case ">": return match("=") ? .GREATER_EQUAL(location: start, lexeme: currentLexeme) : .GREATER(location: start, lexeme: currentLexeme)
    case "/":
      if match("/") {
        // A comment goes until the end of the line.
        while peek() != "\n" && !isAtEnd {
          advance()
        }
      } else {
        return .SLASH(location: start, lexeme: currentLexeme)
      }
    case "\"": return try string()

    // Ignore whitespace.
    case " ": break
    case "\r": break
    case "\t": break
    case "\n": break

    default:
      if isDigit(c) {
        return try number()
      }
      if isAlpha(c) {
        return identifier()
      }
      throw SyntaxError(start, "Unexpected character \(c)")
    }

    return nil // noop on full advancing
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

  func string() throws -> Token {
    while peek() != "\"" && !isAtEnd {
      advance()
    }

    guard !isAtEnd else {
      throw SyntaxError(start, "Unterminated string")
    }

    advance() // Consume the closing "
    let value = String(source[source.index(after: start)..<source.index(before: current)])
    return .STRING(location: start, lexeme: currentLexeme, value: value)
  }

  func number() throws -> Token {
    while isDigit(peek()) { advance() }
    // Look for a fractional part.
    if peek() == "." && isDigit(peekNext()) {
      advance() // Consume the "."
      while isDigit(peek()) { advance() }
    }

    guard let value = Double(currentLexeme) else {
      throw SyntaxError(start, "'\(currentLexeme)' is not a number")
    }
    return .NUMBER(location: start, lexeme: currentLexeme, value: value)
  }

  func identifier() -> Token {
    while isAlphanumeric(peek()) { advance() }
    if let keyword = Token(location: start, lexeme: currentLexeme) {
      return keyword
    } else {
      return .IDENTIFIER(location: start, lexeme: currentLexeme)
    }
  }
}
