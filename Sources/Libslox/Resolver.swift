class Resolver: StmtVisitor, ExprVisitor {
  enum VariableStatus {
    case declared
    case defined
  }

  enum FunctionType {
    case function
    case method
    case initializer
  }

  enum ClassType {
    case `class`
    case subclass
  }

  typealias VariableMap = [String: VariableStatus]

  let interpreter: Interpreter
  var scopes: [VariableMap] = [[:]]
  var currentFunction: FunctionType?
  var currentClass: ClassType?
  var errors: [LoxError] = []

  init(interpreter: Interpreter) {
    self.interpreter = interpreter
  }

  func analyze(_ stmts: [Stmt]) throws {
    resolve(stmts)
    guard errors.isEmpty else {
      throw CompositeLoxError(errors: errors)
    }
  }

  func resolve(_ stmts: [Stmt]) {
    stmts.forEach(resolve)
  }

  func resolve(_ stmt: Stmt) {
    try! stmt.accept(visitor: self)
  }

  func resolve(_ expr: Expr) {
    try! expr.accept(visitor: self)
  }

  func resolveLocal(_ expr: Expr, _ name: Token) {
    for i in (0...currentScope).reversed() {
      if scopes[i][name.lexeme] != nil {
        interpreter.resolve(expr, currentScope - i)
      }
    }
  }

  func resolveFunction(_ stmt: FunctionStmt, _ type: FunctionType) {
    let enclosingFunction = currentFunction
    currentFunction = type
    beginScope()
    stmt.params.forEach(declareAndDefine)
    resolve(stmt.body)
    endScope()
    currentFunction = enclosingFunction
  }

  func beginScope() {
    scopes.append([:])
  }

  func endScope() {
    _ = scopes.popLast()
  }

  var currentScope: Int { return scopes.count - 1 }

  func declare(_ name: Token) {
    guard scopes[currentScope][name.lexeme] == nil else {
      errors.append(SemanticError(name.location, "\(name.lexeme) is already defined in the scope"))
      return
    }
    scopes[currentScope][name.lexeme] = .declared
  }

  func define(_ name: Token) {
    define(name.lexeme)
  }

  func define(_ name: String) {
    scopes[currentScope][name] = .defined
  }

  func declareAndDefine(_ name: Token) {
    declare(name)
    define(name)
  }

  // MARK:- Visit Statements

  func visit(_ stmt: IfStmt) {
    resolve(stmt.condition)
    resolve(stmt.thenBranch)
    stmt.elseBranch.flatMap(resolve)
  }

  func visit(_ stmt: BlockStmt) {
    beginScope()
    resolve(stmt.statements)
    endScope()
  }

  func visit(_ stmt: ClassStmt) {
    let enclosingClass = currentClass
    currentClass = .class
    declareAndDefine(stmt.name)
    if let superclass = stmt.superclass {
      currentClass = .subclass

      if stmt.name.lexeme == superclass.name.lexeme {
        errors.append(SemanticError(superclass.name.location, "A class cannot inherit from itself"))
      }
      resolve(superclass)

      beginScope()
      define("super")
    }
    beginScope()
    define("this")
    for method in stmt.methods {
      guard let method = method as? FunctionStmt else { continue }
      let declaration: FunctionType = (method.name.lexeme == "init") ? .initializer : .method
      resolveFunction(method, declaration)
    }
    endScope()

    if stmt.superclass != nil {
      endScope()
    }

    currentClass = enclosingClass
  }

  func visit(_ stmt: ExpressionStmt) {
    resolve(stmt.expr)
  }

  func visit(_ stmt: FunctionStmt) {
    declareAndDefine(stmt.name)
    resolveFunction(stmt, .function)
  }

  func visit(_ stmt: PrintStmt) {
    resolve(stmt.expr)
  }

  func visit(_ stmt: ReturnStmt) {
    if currentFunction == nil {
      errors.append(SemanticError(stmt.keyword.location, "Cannot return from top level code"))
    }
    if currentFunction == .initializer && stmt.value != nil {
      errors.append(SemanticError(stmt.keyword.location, "Cannot return value from initializer"))
    }
    stmt.value.flatMap(resolve)
  }

  func visit(_ stmt: VarStmt) {
    declare(stmt.name)
    stmt.initializer.flatMap(resolve)
    define(stmt.name)
  }

  func visit(_ stmt: WhileStmt) {
    resolve(stmt.condition)
    resolve(stmt.body)
  }

  // MARK:- Visit Expressions

  func visit(_ expr: AssignExpr) {
    resolve(expr.value)
    resolveLocal(expr, expr.name)
  }

  func visit(_ expr: BinaryExpr) {
    resolve(expr.left)
    resolve(expr.right)
  }

  func visit(_ expr: CallExpr) {
    resolve(expr.callee)
    expr.arguments.forEach(resolve)
  }

  func visit(_ expr: GetExpr) {
    resolve(expr.object)
  }

  func visit(_ expr: GroupingExpr) {
    resolve(expr.expr)
  }

  func visit(_ expr: LiteralExpr) {
    // noop
  }

  func visit(_ expr: LogicalExpr) {
    resolve(expr.left)
    resolve(expr.right)
  }

  func visit(_ expr: SetExpr) {
    resolve(expr.object)
    resolve(expr.value)
  }

  func visit(_ expr: UnaryExpr) {
    resolve(expr.right)
  }

  func visit(_ expr: VariableExpr) {
    if case .declared? = scopes[currentScope][expr.name.lexeme] {
      errors.append(SemanticError(expr.name.location, "Can't read local variable in its own declaration."))
    }
    resolveLocal(expr, expr.name)
  }

  func visit(_ expr: SuperExpr) {
    switch currentClass {
    case .none:
      errors.append(SemanticError(expr.keyword.location, "Can't use 'super' outside of a class"))
    case .class?:
      errors.append(SemanticError(expr.keyword.location, "Can't use 'super' in a class without a superclass"))
    default:
      break
    }
    resolveLocal(expr, expr.keyword)
  }

  func visit(_ expr: ThisExpr) {
    if currentClass == nil {
      errors.append(SemanticError(expr.keyword.location, "Can't use 'this' outside of a class"))
    }
    resolveLocal(expr, expr.keyword)
  }
}
