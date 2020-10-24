//
// THIS IS A GENERATED FILE DO NOT EDIT
//

protocol Stmt: class {
  @discardableResult func accept<T: StmtVisitor>(visitor: T) throws -> T.Result
}

protocol StmtVisitor {
  associatedtype Result

  func visit(_ stmt: ExpressionStmt) throws -> Result
  func visit(_ stmt: PrintStmt) throws -> Result
}

class ExpressionStmt: Stmt {
  let expr: Expr

  init(expr: Expr) {
    self.expr = expr
  }

  @discardableResult
  func accept<T: StmtVisitor>(visitor: T) throws -> T.Result {
    return try visitor.visit(self)
  }
}

class PrintStmt: Stmt {
  let expr: Expr

  init(expr: Expr) {
    self.expr = expr
  }

  @discardableResult
  func accept<T: StmtVisitor>(visitor: T) throws -> T.Result {
    return try visitor.visit(self)
  }
}
