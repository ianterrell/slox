class ASTGenerator: BaseGenerator {
  typealias Attribute = (name: String, type: String)
  typealias ASTList = [(typeName: String, attributes: [Attribute])]

  static let expressions: ASTList = [
    ("Binary", [("left", "Expr"), ("op", "Token"), ("right", "Expr")]),
    ("Grouping", [("expr", "Expr")]),
    ("Literal", [("value", "Value")]),
    ("Unary", [("op", "Token"), ("right", "Expr")]),
  ]

  func genExpr() -> String { return genAST(type: "Expr", list: Self.expressions) }
  
  func genAST(type: String, list: ASTList) -> String {
    let types = list.map { genType(type: type, name: $0.typeName, attributes: $0.attributes) }
    let visitFuncs = list.map { "func visit(_ \(type.lowercased()): \($0.typeName)) -> Result" }

    return """
    \(generatedCodeWarning)

    public protocol \(type): class {
      @discardableResult func accept<T: \(type)Visitor>(visitor: T) -> T.Result
    }

    public protocol \(type)Visitor {
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
    public class \(name): \(type) {
    \(indent(2, declarations))

      public init(\(params.joined(separator: ", "))) {
    \(indent(4, assignments))
      }

      @discardableResult 
      public func accept<T: \(type)Visitor>(visitor: T) -> T.Result {
        return visitor.visit(self)
      }
    }
    """
  }
}
