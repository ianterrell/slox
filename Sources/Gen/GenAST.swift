class ASTGenerator: BaseGenerator {
  typealias Attribute = (name: String, type: String)
  typealias ASTList = [(typeName: String, attributes: [Attribute])]

  static let statements: ASTList = [
    ("ExpressionStmt", [("expr", "Expr")]),
    ("PrintStmt", [("expr", "Expr")]),
  ]

  static let expressions: ASTList = [
    ("BinaryExpr", [("left", "Expr"), ("op", "Token"), ("right", "Expr")]),
    ("GroupingExpr", [("expr", "Expr")]),
    ("LiteralExpr", [("value", "Value")]),
    ("UnaryExpr", [("op", "Token"), ("right", "Expr")]),
  ]

  func genExpr() -> String { return genAST(type: "Expr", list: Self.expressions) }
  func genStmt() -> String { return genAST(type: "Stmt", list: Self.statements) }

  func genAST(type: String, list: ASTList) -> String {
    let types = list.map { genType(type: type, name: $0.typeName, attributes: $0.attributes) }
    let visitFuncs = list.map { "func visit(_ \(type.lowercased()): \($0.typeName)) throws -> Result" }

    return """
    \(generatedCodeWarning)

    protocol \(type): class {
      @discardableResult func accept<T: \(type)Visitor>(visitor: T) throws -> T.Result
    }

    protocol \(type)Visitor {
      associatedtype Result

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
      func accept<T: \(type)Visitor>(visitor: T) throws -> T.Result {
        return try visitor.visit(self)
      }
    }
    """
  }
}
