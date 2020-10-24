class Parser {
  let tokens: [Token]
  var current = 0

  init(tokens: [Token]) {
    self.tokens = tokens
  }

  func parse() throws -> Expr {
    return try expression()
  }

  // MARK:- Helpers

  var isAtEnd: Bool {
    if case .EOF = peek() {
      return true
    }
    return false
  }

  func peek() -> Token {
    return tokens[current]
  }

  func previous() -> Token {
    return tokens[current - 1]
  }

  @discardableResult
  func advance() -> Token {
    if !isAtEnd {
      current += 1
    }
    return previous()
  }

  func check(_ type: Token.`Type`) -> Bool {
    guard !isAtEnd else { return false }
    return peek().type == type
  }

  func match(_ types: Token.`Type`...) -> Bool {
    for t in types {
      if check(t) {
        advance()
        return true
      }
    }

    return false
  }

  func consume(_ type: Token.`Type`) -> Token? {
    if check(type) {
      return advance()
    }
    return nil
  }

  func synchronize() {
    advance()
    while !isAtEnd {
      if previous().type == .SEMICOLON { return }
      switch peek().type {
      case .CLASS, .FUN, .VAR, .FOR, .IF, .WHILE, .PRINT, .RETURN: return
      default: break
      }
      advance()
    }
  }

  // MARK:- Parsing

  func expression() throws -> Expr {
    return try equality()
  }

  func equality() throws -> Expr {
    var expr = try comparison()
    while match(.BANG_EQUAL, .EQUAL_EQUAL) {
      let op = previous()
      let right = try comparison()
      expr = Binary(left: expr, op: op, right: right)
    }
    return expr
  }

  func comparison() throws -> Expr {
    var expr =  try term()
    while match(.GREATER, .GREATER_EQUAL, .LESS, .LESS_EQUAL) {
      let op = previous()
      let right =  try term()
      expr = Binary(left: expr, op: op, right: right)
    }
    return expr
  }

  func term() throws -> Expr {
    var expr =  try factor()
    while match(.MINUS, .PLUS) {
      let op = previous()
      let right =  try factor()
      expr = Binary(left: expr, op: op, right: right)
    }
    return expr
  }

  func factor() throws -> Expr {
    var expr =  try unary()
    while match(.SLASH, .STAR) {
      let op = previous()
      let right =  try unary()
      expr = Binary(left: expr, op: op, right: right)
    }
    return expr
  }

  func unary() throws -> Expr {
    if match(.BANG, .MINUS) {
      let op = previous()
      let right =  try unary()
      return Unary(op: op, right: right)
    }

    return  try primary()
  }

  func primary() throws -> Expr {
    if match(.FALSE) {
      return Literal(value: .boolean(false))
    }
    if match(.TRUE) {
      return Literal(value: .boolean(true))
    }
    if match(.NIL) {
      return Literal(value: .nil)
    }
    if match(.NUMBER), case .NUMBER(_, _, let n) = previous() {
      return Literal(value: .number(n))
    }
    if match(.STRING), case .STRING(_, _, let s) = previous() {
      return Literal(value: .string(s))
    }
    if match(.LEFT_PAREN) {
      let expr =  try expression()
      guard let _ = consume(.RIGHT_PAREN) else {
        throw SyntaxError.missingParen(token: peek())
      }
      return Grouping(expr: expr)
    }
    throw SyntaxError.missingExpression(token: peek())
  }
}
