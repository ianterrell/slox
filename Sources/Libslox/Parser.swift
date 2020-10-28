class Parser {
  let tokens: [Token]
  var statements: [Stmt] = []
  var errors: [LoxError] = []
  var current = 0

  init(tokens: [Token]) {
    self.tokens = tokens
  }

  func parse() throws -> [Stmt] {
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

  func consume(_ type: Token.`Type`) -> Token? {
    if check(type) {
      advance()
      return previous()
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

  // MARK:- Parsing Statements

  func program() throws -> Stmt {
    return try declaration()
  }

  func declaration() throws -> Stmt {
    if match(.FUN) { return try function("function") }
    if match(.VAR) { return try varDeclaration() }
    if match(.CLASS) { return try classDeclaration() }
    return try statement()
  }

  func function(_ kind: String) throws -> Stmt {
    guard let name = consume(.IDENTIFIER) else {
      throw SyntaxError(peek().location, "Expect \(kind) name")
    }
    guard let _ = consume(.LEFT_PAREN) else {
      throw SyntaxError(previous().location, "Expect '(' after \(kind) name")
    }
    var parameters: [Token] = []
    if !check(.RIGHT_PAREN) {
      repeat {
        guard let param = consume(.IDENTIFIER) else {
          throw SyntaxError(peek().location, "Expect parameter name")
        }
        parameters.append(param)
        if parameters.count > Constant.maxFunctionArguments {
          errors.append(SyntaxError(peek().location, "Can't have more than \(Constant.maxFunctionArguments) parameters"))
        }
      } while match(.COMMA)
    }
    guard let _ = consume(.RIGHT_PAREN) else {
      throw SyntaxError(previous().location, "Expect ')' after \(kind) parameters")
    }
    guard let _ = consume(.LEFT_BRACE) else {
      throw SyntaxError(previous().location, "Expect '{' before \(kind) body")
    }
    let body = try block()
    return FunctionStmt(name: name, params: parameters, body: body)
  }

  func varDeclaration() throws -> Stmt {
    guard let name = consume(.IDENTIFIER) else {
      throw SyntaxError(peek().location, "Expect variable name")
    }
    let initializer = match(.EQUAL) ? try expression() : nil
    guard let _ = consume(.SEMICOLON) else {
      throw SyntaxError(previous().location, "Expect ';' after declaration")
    }
    return VarStmt(name: name, initializer: initializer)
  }

  func classDeclaration() throws -> Stmt {
    guard let name = consume(.IDENTIFIER) else {
      throw SyntaxError(peek().location, "Expect class name")
    }
    guard let _ = consume(.LEFT_BRACE) else {
      throw SyntaxError(peek().location, "Expect '{' before class body")
    }
    var methods: [Stmt] = []
    while !check(.RIGHT_BRACE) && !isAtEnd {
      methods.append(try function("method"))
    }
    guard let _ = consume(.RIGHT_BRACE) else {
      throw SyntaxError(peek().location, "Expect '}' after class body")
    }
    return ClassStmt(name: name, methods: methods)
  }

  func statement() throws -> Stmt {
    if match(.IF) { return try ifStatement() }
    if match(.PRINT) { return try printStatement() }
    if match(.WHILE) { return try whileStatement() }
    if match(.FOR) { return try forStatement() }
    if match(.RETURN) { return try returnStatement() }
    if match(.LEFT_BRACE) { return try blockStatement() }
    return try expressionStatement()
  }

  func ifStatement() throws -> Stmt {
    guard let _ = consume(.LEFT_PAREN) else {
      throw SyntaxError(previous().location, "Expect '(' after if")
    }
    let condition = try expression()
    guard let _ = consume(.RIGHT_PAREN) else {
      throw SyntaxError(previous().location, "Expect ')' after conditional")
    }
    let thenBranch = try statement()
    let elseBranch = match(.ELSE) ? try statement() : nil
    return IfStmt(condition: condition, thenBranch: thenBranch, elseBranch: elseBranch)
  }

  func printStatement() throws -> Stmt {
    let expr = try expression()
    guard let _ = consume(.SEMICOLON) else {
      throw SyntaxError(previous().location, "Expect ';' after value")
    }
    return PrintStmt(expr: expr)
  }

  func whileStatement() throws -> Stmt {
    guard let _ = consume(.LEFT_PAREN) else {
      throw SyntaxError(previous().location, "Expect '(' after while")
    }
    let condition = try expression()
    guard let _ = consume(.RIGHT_PAREN) else {
      throw SyntaxError(previous().location, "Expect ')' after condition")
    }
    let body = try statement()
    return WhileStmt(condition: condition, body: body)
  }

  func forStatement() throws -> Stmt {
    guard let _ = consume(.LEFT_PAREN) else {
      throw SyntaxError(previous().location, "Expect ')' after for")
    }

    var initializer: Stmt?
    if !match(.SEMICOLON) {
      initializer = match(.VAR) ? try varDeclaration() : try expressionStatement()
    }

    var condition: Expr = LiteralExpr(value: .boolean(true))
    if !match(.SEMICOLON) {
      condition = try expression()
      guard let _ = consume(.SEMICOLON) else {
        throw SyntaxError(previous().location, "Expect ';' in for")
      }
    }

    var increment: Expr?
    if !check(.RIGHT_PAREN) {
      increment = try expression()
    }

    guard let _ = consume(.RIGHT_PAREN) else {
      throw SyntaxError(previous().location, "Expect ')' after for statements")
    }

    var body = try statement()
    if let increment = increment {
      body = BlockStmt(statements: [body, ExpressionStmt(expr: increment)])
    }
    var stmt: Stmt = WhileStmt(condition: condition, body: body)
    if let initializer = initializer {
      stmt = BlockStmt(statements: [initializer, stmt])
    }
    return stmt
  }

  func returnStatement() throws -> Stmt {
    let keyword = previous()
    var value: Expr?
    if !check(.SEMICOLON) {
      value = try expression()
    }
    guard let _ = consume(.SEMICOLON) else {
      throw SyntaxError(previous().location, "Expect ';' after return")
    }
    return ReturnStmt(keyword: keyword, value: value ?? LiteralExpr(value: .nil))
  }

  func blockStatement() throws -> Stmt {
    return BlockStmt(statements: try block())
  }

  func block() throws -> [Stmt] {
    var statements: [Stmt] = []
    while !check(.RIGHT_BRACE) && !isAtEnd {
      statements.append(try declaration())
    }
    guard let _ = consume(.RIGHT_BRACE) else {
      throw SyntaxError(previous().location, "Expect '}' to end block")
    }
    return statements
  }

  func expressionStatement() throws -> Stmt {
    let expr = try expression()
    guard let _ = consume(.SEMICOLON) else {
      throw SyntaxError(previous().location, "Expect ';' after expression")
    }
    return ExpressionStmt(expr: expr)
  }

  // MARK:- Parsing Expressions

  func expression() throws -> Expr {
    return try assignment()
  }

  func assignment() throws -> Expr {
    let expr = try logicalOr()
    if match(.EQUAL) {
      let equals = previous()
      let value = try assignment()
      if let varExpr = expr as? VariableExpr {
        return AssignExpr(name: varExpr.name, value: value)
      }
      throw SyntaxError(equals.location, "Invalid assignment target")
    }
    return expr
  }

  func logicalOr() throws -> Expr {
    var expr = try logicalAnd()
    while match(.OR) {
      let op = previous()
      let right = try logicalAnd()
      expr = LogicalExpr(left: expr, op: op, right: right)
    }
    return expr
  }

  func logicalAnd() throws -> Expr {
    var expr = try equality()
    while match(.AND) {
      let op = previous()
      let right = try equality()
      expr = LogicalExpr(left: expr, op: op, right: right)
    }
    return expr
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
    var expr = try term()
    while match(.GREATER, .GREATER_EQUAL, .LESS, .LESS_EQUAL) {
      let op = previous()
      let right = try term()
      expr = BinaryExpr(left: expr, op: op, right: right)
    }
    return expr
  }

  func term() throws -> Expr {
    var expr = try factor()
    while match(.MINUS, .PLUS) {
      let op = previous()
      let right = try factor()
      expr = BinaryExpr(left: expr, op: op, right: right)
    }
    return expr
  }

  func factor() throws -> Expr {
    var expr = try unary()
    while match(.SLASH, .STAR) {
      let op = previous()
      let right = try unary()
      expr = BinaryExpr(left: expr, op: op, right: right)
    }
    return expr
  }

  func unary() throws -> Expr {
    if match(.BANG, .MINUS) {
      let op = previous()
      let right = try unary()
      return UnaryExpr(op: op, right: right)
    }

    return try call()
  }

  func call() throws -> Expr {
    var expr = try primary()
    while true {
      if match(.LEFT_PAREN) {
        expr = try finishCall(expr)
      } else {
        break
      }
    }
    return expr
  }

  func finishCall(_ expr: Expr) throws -> Expr {
    var arguments: [Expr] = []
    if !check(.RIGHT_PAREN) {
      repeat {
        arguments.append(try expression())
      } while match(.COMMA)
    }
    guard let _ = consume(.RIGHT_PAREN) else {
      throw SyntaxError(previous().location, "Expect ')' after arguments")
    }
    let paren = previous()
    if arguments.count > Constant.maxFunctionArguments {
      errors.append(SyntaxError(paren.location, "Can't have more than \(Constant.maxFunctionArguments) arguments"))
    }
    return CallExpr(callee: expr, paren: paren, arguments: arguments)
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
      let expr = try expression()
      guard let _ = consume(.RIGHT_PAREN) else {
        throw SyntaxError(peek().location, "Missing ')'")
      }
      return GroupingExpr(expr: expr)
    }
    throw SyntaxError(peek().location, "Expect expression")
  }
}
