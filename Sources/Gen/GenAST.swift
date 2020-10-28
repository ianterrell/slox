class ASTGenerator: BaseGenerator {
  typealias Attribute = (name: String, type: String)
  typealias ASTList = [(typeName: String, attributes: [Attribute])]

  static let statements: ASTList = [
    ("IfStmt", [("condition", "Expr"), ("thenBranch", "Stmt"), ("elseBranch", "Stmt?")]),
    ("BlockStmt", [("statements", "[Stmt]")]),
    ("ClassStmt", [("name", "Token"), ("methods", "[Stmt]")]),
    ("ExpressionStmt", [("expr", "Expr")]),
    ("FunctionStmt", [("name", "Token"), ("params", "[Token]"), ("body", "[Stmt]")]),
    ("PrintStmt", [("expr", "Expr")]),
    ("ReturnStmt", [("keyword", "Token"), ("value", "Expr?")]),
    ("VarStmt", [("name", "Token"), ("initializer", "Expr?")]),
    ("WhileStmt", [("condition", "Expr"), ("body", "Stmt")]),
  ]

  static let expressions: ASTList = [
    ("AssignExpr", [("name", "Token"), ("value", "Expr")]),
    ("BinaryExpr", [("left", "Expr"), ("op", "Token"), ("right", "Expr")]),
    ("CallExpr", [("callee", "Expr"), ("paren", "Token"), ("arguments", "[Expr]")]),
    ("GetExpr", [("object", "Expr"), ("name", "Token")]),
    ("GroupingExpr", [("expr", "Expr")]),
    ("LiteralExpr", [("value", "Value")]),
    ("LogicalExpr", [("left", "Expr"), ("op", "Token"), ("right", "Expr")]),
    ("SetExpr", [("object", "Expr"), ("name", "Token"), ("value", "Expr")]),
    ("ThisExpr", [("keyword", "Token")]),
    ("UnaryExpr", [("op", "Token"), ("right", "Expr")]),
    ("VariableExpr", [("name", "Token")]),
  ]

  func genExpr() -> String { return genAST(type: "Expr", list: Self.expressions) }
  func genStmt() -> String { return genAST(type: "Stmt", list: Self.statements) }

  func genAST(type: String, list: ASTList) -> String {
    let types = list.map { genType(type: type, name: $0.typeName, attributes: $0.attributes) }
    let visitFuncs = list.map { "func visit(_ \(type.lowercased()): \($0.typeName)) throws -> \(type)Result" }

    return """
    \(generatedCodeWarning)

    protocol \(type): class {
      @discardableResult func accept<T: \(type)Visitor>(visitor: T) throws -> T.\(type)Result
    }

    protocol \(type)Visitor {
      associatedtype \(type)Result

    \(indent(2, visitFuncs))
    }

    \(types.joined(separator: "\n\n"))

    """
  }

  func genType(type: String, name: String, attributes: [Attribute]) -> String {
    let params = attributes.map { "\($0.name): \($0.type)" }
    let declarations = params.map { "let \($0)" }
    let assignments = attributes.map { "self.\($0.name) = \($0.name)" }

    return """
    class \(name): \(type) {
    \(indent(2, declarations))

      init(\(params.joined(separator: ", "))) {
    \(indent(4, assignments))
      }

      @discardableResult
      func accept<T: \(type)Visitor>(visitor: T) throws -> T.\(type)Result {
        return try visitor.visit(self)
      }
    }
    """
  }
}
