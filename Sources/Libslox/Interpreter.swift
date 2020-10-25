class Interpreter: StmtVisitor, ExprVisitor {
  var environment = Environment()

  func interpret(_ program: [Stmt]) throws {
    try program.forEach(execute)
  }

  func executeBlock(_ stmts: [Stmt], env: Environment) throws {
    let previous = environment
    defer { environment = previous }
    environment = env
    try stmts.forEach(execute)
  }

  func execute(_ stmt: Stmt) throws {
    return try stmt.accept(visitor: self)
  }

  func evaluate(_ expr: Expr) throws -> Value {
    return try expr.accept(visitor: self)
  }

  func visit(_ stmt: ExpressionStmt) throws {
    _ = try evaluate(stmt.expr)
  }

  func visit(_ stmt: PrintStmt) throws {
    let value = try evaluate(stmt.expr)
    print(value)
  }

  func visit(_ stmt: IfStmt) throws {
    let value = try evaluate(stmt.condition)
    if isTruthy(value) {
      try stmt.thenBranch.accept(visitor: self)
    } else {
      try stmt.elseBranch?.accept(visitor: self)
    }
  }

  func visit(_ stmt: BlockStmt) throws {
    try executeBlock(stmt.statements, env: Environment(parent: environment))
  }

  func visit(_ stmt: VarStmt) throws {
    let value = try stmt.initializer.flatMap(evaluate) ?? .nil
    environment.define(name: stmt.name, value: value)
  }

  func visit(_ expr: AssignExpr) throws -> Value {
    let value = try evaluate(expr.value)
    try environment.assign(name: expr.name, value: value)
    return value
  }

  func visit(_ expr: BinaryExpr) throws -> Value {
    let left = try evaluate(expr.left)
    let right = try evaluate(expr.right)
    switch (expr.op, left, right) {
    
    // Numeric math & comparison
    case (.PLUS, .number(let lhs), .number(let rhs)): return .number(lhs + rhs)
    case (.MINUS, .number(let lhs), .number(let rhs)): return .number(lhs - rhs)
    case (.SLASH, .number(let lhs), .number(let rhs)): return .number(lhs / rhs)
    case (.STAR, .number(let lhs), .number(let rhs)): return .number(lhs * rhs)
    case (.GREATER, .number(let lhs), .number(let rhs)): return .boolean(lhs > rhs)
    case (.GREATER_EQUAL, .number(let lhs), .number(let rhs)): return .boolean(lhs >= rhs)
    case (.LESS, .number(let lhs), .number(let rhs)): return .boolean(lhs < rhs)
    case (.LESS_EQUAL, .number(let lhs), .number(let rhs)): return .boolean(lhs <= rhs)

    // String concatenation & comparison
    case (.PLUS, .string(let lhs), .string(let rhs)): return .string(lhs + rhs)
    case (.GREATER, .string(let lhs), .string(let rhs)): return .boolean(lhs > rhs)
    case (.GREATER_EQUAL, .string(let lhs), .string(let rhs)): return .boolean(lhs >= rhs)
    case (.LESS, .string(let lhs), .string(let rhs)): return .boolean(lhs < rhs)
    case (.LESS_EQUAL, .string(let lhs), .string(let rhs)): return .boolean(lhs <= rhs)

    // Type mismatches
    case (.MINUS, _, _): fallthrough
    case (.SLASH, _, _): fallthrough
    case (.STAR, _, _): throw RuntimeError.binaryOperatorRequiresNumeric(op: expr.op.lexeme, location: expr.op.location)
    case (.PLUS, _, _): fallthrough
    case (.GREATER, _, _): fallthrough
    case (.GREATER_EQUAL, _, _): fallthrough
    case (.LESS, _, _): fallthrough
    case (.LESS_EQUAL, _, _): throw RuntimeError.binaryOperatorRequiresNumericOrString(op: expr.op.lexeme, location: expr.op.location)

    // Type-agnostic equality
    case (.EQUAL_EQUAL, let lhs, let rhs): return .boolean(lhs == rhs)
    case (.BANG_EQUAL, let lhs, let rhs): return .boolean(lhs != rhs)

    default:
      throw RuntimeError.internalError(location: expr.op.location, message: "Invalid operator for binary expression; should not have parsed")
    }
  }

  func visit(_ expr: GroupingExpr) throws -> Value {
    return try evaluate(expr.expr)
  }

  func visit(_ expr: LiteralExpr) throws -> Value {
    return expr.value
  }

  func visit(_ expr: LogicalExpr) throws -> Value {
    let left = try evaluate(expr.left)
    switch expr.op {
    case .OR: return isTruthy(left) ? left : try evaluate(expr.right)
    case .AND: return !isTruthy(left) ? left : try evaluate(expr.right)
    default:
      throw RuntimeError.internalError(location: expr.op.location, message: "Invalid operator for logical expression; should not have parsed")
    }
  }

  func visit(_ expr: UnaryExpr) throws -> Value {
    let right = try evaluate(expr.right)
    switch (expr.op, right) {
    case (.BANG, let v): return .boolean(!isTruthy(v))
    case (.MINUS, .number(let n)): return .number(-n)
    case (.MINUS, _): throw RuntimeError.unaryOperatorRequiresNumeric(op: expr.op.lexeme, location: expr.op.location)
    default: throw RuntimeError.internalError(location: expr.op.location, message: "Invalid operator for unary expression; should not have parsed")
    }
  }

  func visit(_ expr: VariableExpr) throws -> Value {
    return try environment.get(name: expr.name)
  }

  func isTruthy(_ value: Value) -> Bool {
    switch value {
    case .nil: fallthrough
    case .boolean(false): return false
    default: return true
    }
  }
}
