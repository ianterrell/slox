public class Interpreter: StmtVisitor, ExprVisitor {
  let globals: Environment
  var environment: Environment

  var locals: [ObjectIdentifier: Int] = [:]

  init() {
    self.globals = Environment()
    self.environment = globals

    Builtin.register(in: globals)
  }

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

  // MARK:- Variables

  func resolve(_ expr: Expr, _ depth: Int) {
    locals[ObjectIdentifier(expr)] = depth
  }

  func lookupDistance(_ expr: Expr) -> Int? {
    return locals[ObjectIdentifier(expr)]
  }

  func lookUpVariable(_ expr: Expr, _ name: Token) throws -> Value {
    guard let distance = lookupDistance(expr) else {
      return try globals.get(name: name)
    }
    return try environment.get(name: name, distance: distance)
  }

  // MARK:- Traversal

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
      try execute(stmt.thenBranch)
    } else {
      try stmt.elseBranch.flatMap(execute)
    }
  }

  func visit(_ stmt: FunctionStmt) throws {
    let function = LoxFunction(declaration: stmt, closure: environment, isInitializer: false)
    environment.define(name: stmt.name, value: .function(function))
  }

  func visit(_ stmt: ReturnStmt) throws {
    throw LoxFunction.Return.value(try stmt.value.flatMap(evaluate))
  }

  func visit(_ stmt: BlockStmt) throws {
    try executeBlock(stmt.statements, env: Environment(parent: environment))
  }

  func visit(_ stmt: ClassStmt) throws {
    var superclass: LoxClass?
    if let superclassVar = stmt.superclass {
      guard case .class(let stmtSuperclass) = try evaluate(superclassVar) else {
        throw RuntimeError(superclassVar.name.location, "Superclass must be a class")
      }
      superclass = stmtSuperclass
    }

    environment.define(name: stmt.name.lexeme, value: .nil)

    if let superclass = superclass {
      environment = Environment(parent: environment)
      environment.define(name: "super", value: .class(superclass))
    }

    var methods: [String: LoxFunction] = [:]
    for method in stmt.methods {
      guard let method = method as? FunctionStmt else { continue }
      let isInit = method.name.lexeme == "init"
      methods[method.name.lexeme] = LoxFunction(declaration: method, closure: environment, isInitializer: isInit)
    }
    let cls = LoxClass(name: stmt.name.lexeme, superclass: superclass, methods: methods)

    if superclass != nil {
      environment = environment.parent!
    }

    environment.define(name: stmt.name.lexeme, value: .class(cls))
  }

  func visit(_ stmt: VarStmt) throws {
    let value = try stmt.initializer.flatMap(evaluate) ?? .nil
    environment.define(name: stmt.name, value: value)
  }

  func visit(_ stmt: WhileStmt) throws {
    while isTruthy(try evaluate(stmt.condition)) {
      try execute(stmt.body)
    }
  }

  func visit(_ expr: AssignExpr) throws -> Value {
    let value = try evaluate(expr.value)
    guard let distance = locals[ObjectIdentifier(expr)] else {
      try globals.assign(name: expr.name, value: value)
      return value
    }
    try environment.assign(name: expr.name, value: value, distance: distance)
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
    case (.STAR, _, _): throw RuntimeError(expr.op.location, "Binary operator '\(expr.op.lexeme)' requires numeric operands")
    case (.PLUS, _, _): fallthrough
    case (.GREATER, _, _): fallthrough
    case (.GREATER_EQUAL, _, _): fallthrough
    case (.LESS, _, _): fallthrough
    case (.LESS_EQUAL, _, _): throw RuntimeError(expr.op.location, "Binary operator '\(expr.op.lexeme)' requires both operands to be either numeric or string")

    // Type-agnostic equality
    case (.EQUAL_EQUAL, let lhs, let rhs): return .boolean(lhs == rhs)
    case (.BANG_EQUAL, let lhs, let rhs): return .boolean(lhs != rhs)

    default:
      throw RuntimeError(expr.op.location, "Invalid operator for binary expression; should not have parsed")
    }
  }

  func visit(_ expr: CallExpr) throws -> Value {
    guard let callee  = try evaluate(expr.callee).callable else {
      throw RuntimeError(expr.paren.location, "Expression is not a function or callable type")
    }
    let arguments = try expr.arguments.map(evaluate)
    return try callee.call(interpreter: self, arguments: arguments)
  }

  func visit(_ expr: GetExpr) throws -> Value {
    guard case .instance(let instance) = try evaluate(expr.object) else {
      throw RuntimeError(expr.name.location, "Only instances have properties")
    }
    return try instance.get(expr.name)
  }

  func visit(_ expr: SetExpr) throws -> Value {
    guard case .instance(let instance) = try evaluate(expr.object) else {
      throw RuntimeError(expr.name.location, "Only instances have fields")
    }
    let value = try evaluate(expr.value)
    instance.set(expr.name, value: value)
    return value
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
      throw RuntimeError(expr.op.location, "Invalid operator for logical expression; should not have parsed")
    }
  }

  func visit(_ expr: UnaryExpr) throws -> Value {
    let right = try evaluate(expr.right)
    switch (expr.op, right) {
    case (.BANG, let v): return .boolean(!isTruthy(v))
    case (.MINUS, .number(let n)): return .number(-n)
    case (.MINUS, _): throw RuntimeError(expr.op.location, "Unary operator '\(expr.op.lexeme)' requires numeric operand")
    default: throw RuntimeError(expr.op.location, "Invalid operator for unary expression; should not have parsed")
    }
  }

  func visit(_ expr: VariableExpr) throws -> Value {
    return try lookUpVariable(expr, expr.name)
  }

  func visit(_ expr: SuperExpr) throws -> Value {
    guard
      let distance = lookupDistance(expr),
      case .class(let superclass) = try environment.get(unsafe: "super", distance: distance),
      case .instance(let this) = try environment.get(unsafe: "this", distance: distance - 1),
      let method = superclass.find(method: expr.method)
    else {
      throw RuntimeError(expr.method.location, "Undefined property '\(expr.method.lexeme)'")
    }
    return .function(method.bind(this: this))
  }

  func visit(_ expr: ThisExpr) throws -> Value {
    return try lookUpVariable(expr, expr.keyword)
  }

  func isTruthy(_ value: Value) -> Bool {
    switch value {
    case .nil: fallthrough
    case .boolean(false): return false
    default: return true
    }
  }
}
