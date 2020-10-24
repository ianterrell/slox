//
// THIS IS A GENERATED FILE DO NOT EDIT
//

public protocol Expr: class {
  @discardableResult func accept<T: ExprVisitor>(visitor: T) throws -> T.Result
}

public protocol ExprVisitor {
  associatedtype Result

  func visit(_ expr: Binary) throws -> Result
  func visit(_ expr: Grouping) throws -> Result
  func visit(_ expr: Literal) throws -> Result
  func visit(_ expr: Unary) throws -> Result
}

public class Binary: Expr {
  let left: Expr
  let op: Token
  let right: Expr

  public init(left: Expr, op: Token, right: Expr) {
    self.left = left
    self.op = op
    self.right = right
  }

  @discardableResult
  public func accept<T: ExprVisitor>(visitor: T) throws -> T.Result {
    return try visitor.visit(self)
  }
}

public class Grouping: Expr {
  let expr: Expr

  public init(expr: Expr) {
    self.expr = expr
  }

  @discardableResult
  public func accept<T: ExprVisitor>(visitor: T) throws -> T.Result {
    return try visitor.visit(self)
  }
}

public class Literal: Expr {
  let value: Value

  public init(value: Value) {
    self.value = value
  }

  @discardableResult
  public func accept<T: ExprVisitor>(visitor: T) throws -> T.Result {
    return try visitor.visit(self)
  }
}

public class Unary: Expr {
  let op: Token
  let right: Expr

  public init(op: Token, right: Expr) {
    self.op = op
    self.right = right
  }

  @discardableResult
  public func accept<T: ExprVisitor>(visitor: T) throws -> T.Result {
    return try visitor.visit(self)
  }
}
