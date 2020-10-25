//
// THIS IS A GENERATED FILE DO NOT EDIT
//

protocol Stmt: class {
  @discardableResult func accept<T: StmtVisitor>(visitor: T) throws -> T.StmtResult
}

protocol StmtVisitor {
  associatedtype StmtResult

  func visit(_ stmt: IfStmt) throws -> StmtResult
  func visit(_ stmt: BlockStmt) throws -> StmtResult
  func visit(_ stmt: ExpressionStmt) throws -> StmtResult
  func visit(_ stmt: PrintStmt) throws -> StmtResult
  func visit(_ stmt: VarStmt) throws -> StmtResult
}

class IfStmt: Stmt {
  let condition: Expr
  let thenBranch: Stmt
  let elseBranch: Stmt?

  init(condition: Expr, thenBranch: Stmt, elseBranch: Stmt?) {
    self.condition = condition
    self.thenBranch = thenBranch
    self.elseBranch = elseBranch
  }

  @discardableResult
  func accept<T: StmtVisitor>(visitor: T) throws -> T.StmtResult {
    return try visitor.visit(self)
  }
}

class BlockStmt: Stmt {
  let statements: [Stmt]

  init(statements: [Stmt]) {
    self.statements = statements
  }

  @discardableResult
  func accept<T: StmtVisitor>(visitor: T) throws -> T.StmtResult {
    return try visitor.visit(self)
  }
}

class ExpressionStmt: Stmt {
  let expr: Expr

  init(expr: Expr) {
    self.expr = expr
  }

  @discardableResult
  func accept<T: StmtVisitor>(visitor: T) throws -> T.StmtResult {
    return try visitor.visit(self)
  }
}

class PrintStmt: Stmt {
  let expr: Expr

  init(expr: Expr) {
    self.expr = expr
  }

  @discardableResult
  func accept<T: StmtVisitor>(visitor: T) throws -> T.StmtResult {
    return try visitor.visit(self)
  }
}

class VarStmt: Stmt {
  let name: Token
  let initializer: Expr?

  init(name: Token, initializer: Expr?) {
    self.name = name
    self.initializer = initializer
  }

  @discardableResult
  func accept<T: StmtVisitor>(visitor: T) throws -> T.StmtResult {
    return try visitor.visit(self)
  }
}
