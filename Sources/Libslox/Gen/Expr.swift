//
// THIS IS A GENERATED FILE DO NOT EDIT
//

protocol Expr: class {
  @discardableResult func accept<T: ExprVisitor>(visitor: T) throws -> T.ExprResult
}

protocol ExprVisitor {
  associatedtype ExprResult

  func visit(_ expr: AssignExpr) throws -> ExprResult
  func visit(_ expr: BinaryExpr) throws -> ExprResult
  func visit(_ expr: CallExpr) throws -> ExprResult
  func visit(_ expr: GroupingExpr) throws -> ExprResult
  func visit(_ expr: LiteralExpr) throws -> ExprResult
  func visit(_ expr: LogicalExpr) throws -> ExprResult
  func visit(_ expr: UnaryExpr) throws -> ExprResult
  func visit(_ expr: VariableExpr) throws -> ExprResult
}

class AssignExpr: Expr {
  let name: Token
  let value: Expr

  init(name: Token, value: Expr) {
    self.name = name
    self.value = value
  }

  @discardableResult
  func accept<T: ExprVisitor>(visitor: T) throws -> T.ExprResult {
    return try visitor.visit(self)
  }
}

class BinaryExpr: Expr {
  let left: Expr
  let op: Token
  let right: Expr

  init(left: Expr, op: Token, right: Expr) {
    self.left = left
    self.op = op
    self.right = right
  }

  @discardableResult
  func accept<T: ExprVisitor>(visitor: T) throws -> T.ExprResult {
    return try visitor.visit(self)
  }
}

class CallExpr: Expr {
  let callee: Expr
  let paren: Token
  let arguments: [Expr]

  init(callee: Expr, paren: Token, arguments: [Expr]) {
    self.callee = callee
    self.paren = paren
    self.arguments = arguments
  }

  @discardableResult
  func accept<T: ExprVisitor>(visitor: T) throws -> T.ExprResult {
    return try visitor.visit(self)
  }
}

class GroupingExpr: Expr {
  let expr: Expr

  init(expr: Expr) {
    self.expr = expr
  }

  @discardableResult
  func accept<T: ExprVisitor>(visitor: T) throws -> T.ExprResult {
    return try visitor.visit(self)
  }
}

class LiteralExpr: Expr {
  let value: Value

  init(value: Value) {
    self.value = value
  }

  @discardableResult
  func accept<T: ExprVisitor>(visitor: T) throws -> T.ExprResult {
    return try visitor.visit(self)
  }
}

class LogicalExpr: Expr {
  let left: Expr
  let op: Token
  let right: Expr

  init(left: Expr, op: Token, right: Expr) {
    self.left = left
    self.op = op
    self.right = right
  }

  @discardableResult
  func accept<T: ExprVisitor>(visitor: T) throws -> T.ExprResult {
    return try visitor.visit(self)
  }
}

class UnaryExpr: Expr {
  let op: Token
  let right: Expr

  init(op: Token, right: Expr) {
    self.op = op
    self.right = right
  }

  @discardableResult
  func accept<T: ExprVisitor>(visitor: T) throws -> T.ExprResult {
    return try visitor.visit(self)
  }
}

class VariableExpr: Expr {
  let name: Token

  init(name: Token) {
    self.name = name
  }

  @discardableResult
  func accept<T: ExprVisitor>(visitor: T) throws -> T.ExprResult {
    return try visitor.visit(self)
  }
}
