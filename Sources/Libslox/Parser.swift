class Parser {
  let tokens: [Token]
  var current = 0

  init(tokens: [Token]) {
    self.tokens = tokens
  }

  func parse() throws -> [Stmt] {
    var statements: [Stmt] = []
    var errors: [LoxError] = []
    while !isAtEnd {
      do {
        statements.append(try declaration())
      } catch let error as SyntaxError {
        errors.append(error)
        synchronize()
      } catch {
        fatalError("Unexpected error: \(error)")
      }
    }
    guard errors.isEmpty else {
      throw CompositeLoxError(errors: errors)
    }
    return statements
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

  func consume(_ type: Token.`Type`) -> Bool {
    if check(type) {
      advance()
      return true
    }
    return false
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

  // MARK:- Parsing Statements

  func declaration() throws -> Stmt {
    if match(.VAR) {
      return try varDeclaration()
    }
    return try statement()
  }

  func varDeclaration() throws -> Stmt {
    guard consume(.IDENTIFIER) else {
      throw SyntaxError.missingIdentifier(location: peek().location)
    }
    let name = previous()
    let initializer = match(.EQUAL) ? try expression() : nil
    guard consume(.SEMICOLON) else {
      throw SyntaxError.missingSemicolon(location: peek().location)
    }
    return VarStmt(name: name, initializer: initializer)
  }

  func statement() throws -> Stmt {
    if match(.PRINT) {
      return try printStatement()
    }
    return try expressionStatement()
  }

  func printStatement() throws -> Stmt {
    let expr = try expression()
    guard consume(.SEMICOLON) else {
      throw SyntaxError.missingSemicolon(location: peek().location)
    }
    return PrintStmt(expr: expr)
  }

  func expressionStatement() throws -> Stmt {
    let expr = try expression()
    guard consume(.SEMICOLON) else {
      throw SyntaxError.missingSemicolon(location: peek().location)
    }
    return ExpressionStmt(expr: expr)
  }

  // MARK:- Parsing Expressions

  func expression() throws -> Expr {
    return try equality()
  }

  func equality() throws -> Expr {
    var expr = try comparison()
    while match(.BANG_EQUAL, .EQUAL_EQUAL) {
      let op = previous()
      let right = try comparison()
      expr = BinaryExpr(left: expr, op: op, right: right)
    }
    return expr
  }

  func comparison() throws -> Expr {
    var expr =  try term()
    while match(.GREATER, .GREATER_EQUAL, .LESS, .LESS_EQUAL) {
      let op = previous()
      let right =  try term()
      expr = BinaryExpr(left: expr, op: op, right: right)
    }
    return expr
  }

  func term() throws -> Expr {
    var expr =  try factor()
    while match(.MINUS, .PLUS) {
      let op = previous()
      let right =  try factor()
      expr = BinaryExpr(left: expr, op: op, right: right)
    }
    return expr
  }

  func factor() throws -> Expr {
    var expr =  try unary()
    while match(.SLASH, .STAR) {
      let op = previous()
      let right =  try unary()
      expr = BinaryExpr(left: expr, op: op, right: right)
    }
    return expr
  }

  func unary() throws -> Expr {
    if match(.BANG, .MINUS) {
      let op = previous()
      let right =  try unary()
      return UnaryExpr(op: op, right: right)
    }

    return  try primary()
  }

  func primary() throws -> Expr {
    if match(.FALSE) {
      return LiteralExpr(value: .boolean(false))
    }
    if match(.TRUE) {
      return LiteralExpr(value: .boolean(true))
    }
    if match(.NIL) {
      return LiteralExpr(value: .nil)
    }
    if match(.NUMBER), case .NUMBER(_, _, let n) = previous() {
      return LiteralExpr(value: .number(n))
    }
    if match(.STRING), case .STRING(_, _, let s) = previous() {
      return LiteralExpr(value: .string(s))
    }
    if match(.IDENTIFIER) {
      return VariableExpr(name: previous())
    }
    if match(.LEFT_PAREN) {
      let expr =  try expression()
      guard consume(.RIGHT_PAREN) else {
        throw SyntaxError.missingParen(location: peek().location)
      }
      return GroupingExpr(expr: expr)
    }
    throw SyntaxError.missingExpression(location: peek().location)
  }
}
