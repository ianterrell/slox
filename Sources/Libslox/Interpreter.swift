public class Interpreter: ExprVisitor {
  public func evaluate(_ expr: Expr) throws -> Value {
    return try expr.accept(visitor: self)
  }

  public func visit(_ expr: Binary) throws -> Value {
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
    case (.STAR, _, _): throw RuntimeError.binaryOperatorRequiresNumeric(token: expr.op)
    case (.PLUS, _, _): fallthrough
    case (.GREATER, _, _): fallthrough
    case (.GREATER_EQUAL, _, _): fallthrough
    case (.LESS, _, _): fallthrough
    case (.LESS_EQUAL, _, _): throw RuntimeError.binaryOperatorRequiresNumericOrString(token: expr.op)

    // Type-agnostic equality
    case (.EQUAL_EQUAL, let lhs, let rhs): return .boolean(lhs == rhs)
    case (.BANG_EQUAL, let lhs, let rhs): return .boolean(lhs != rhs)

    default:
      throw RuntimeError.internalError(token: expr.op, message: "Invalid operator for binary expression; should not have parsed")
    }
  }

  public func visit(_ expr: Grouping) throws -> Value {
    return try evaluate(expr)
  }

  public func visit(_ expr: Literal) throws -> Value {
    return expr.value
  }

  public func visit(_ expr: Unary) throws -> Value {
    let right = try evaluate(expr.right)
    switch (expr.op, right) {
    case (.BANG, let v): return .boolean(!isTruthy(v))
    case (.MINUS, .number(let n)): return .number(-n)
    case (.MINUS, _): throw RuntimeError.unaryOperatorRequiresNumeric(token: expr.op)
    default: throw RuntimeError.internalError(token: expr.op, message: "Invalid operator for unary expression; should not have parsed")
    }
  }

  func isTruthy(_ value: Value) -> Bool {
    switch value {
    case .nil: fallthrough
    case .boolean(false): return false
    default: return true
    }
  }
}
