public class DotPrinter {
  public init() {}

  public func genDot(_ expr: Expr) -> String {
    let printer = DotPrinterVisitor()
    expr.accept(visitor: printer)
    return printer.finish()
  }
}

class DotPrinterVisitor: ExprVisitor {
  var graph: String

  init() {
    graph = "digraph {\n"
  }

  func finish() -> String {
    graph += "}"
    return graph
  }

  func nodeName(for expr: Expr) -> String {
    return "n\(abs(ObjectIdentifier(expr).hashValue))"
  }

  func visit(_ expr: Binary) {
    graph += "  \(nodeName(for: expr)) [label=\"\(expr.op.lexeme)\"]\n"
    graph += "  \(nodeName(for: expr)) -> \(nodeName(for: expr.left))\n"
    graph += "  \(nodeName(for: expr)) -> \(nodeName(for: expr.right))\n\n"
    expr.left.accept(visitor: self)
    expr.right.accept(visitor: self)
  }

  func visit(_ expr: Grouping) {
    graph += "  \(nodeName(for: expr)) [label=\"( )\"]\n"
    graph += "  \(nodeName(for: expr)) -> \(nodeName(for: expr.expr))\n\n"
    expr.expr.accept(visitor: self)
  }

  func visit(_ expr: Literal) {
    graph += "  \(nodeName(for: expr)) [label=\"\(expr.value)\"]\n"
  }

  func visit(_ expr: Unary) {
    graph += "  \(nodeName(for: expr)) [label=\"\(expr.op.lexeme)\"]\n"
    graph += "  \(nodeName(for: expr)) -> \(nodeName(for: expr.right))\n\n"
    expr.right.accept(visitor: self)
  }
}
