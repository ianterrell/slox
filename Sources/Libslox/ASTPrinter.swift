//MARK:- ParenPrinter

class ParenPrinter: ExprVisitor {
  func print(_ expr: Expr) -> String {
    return try! expr.accept(visitor: self)
  }

  func visit(_ expr: Binary) -> String {
    return parenthesize(expr.op.lexeme, expr.left, expr.right)
  }

  func visit(_ expr: Grouping) -> String {
    return parenthesize("group", expr.expr)
  }

  func visit(_ expr: Literal) -> String {
    return "\(expr.value)"
  }

  func visit(_ expr: Unary) -> String {
    return parenthesize(expr.op.lexeme, expr.right)
  }

  private func parenthesize(_ name: String, _ exprs: Expr...) -> String {
    var output = ""
    output += "(\(name)"
    for expr in exprs {
      output += " \(try! expr.accept(visitor: self))"
    }
    output += ")"
    return output
  }
}

// MARK:- DotPrinter
public class DotPrinter {
  public init() {}

  public func print(_ expr: Expr) -> String {
    let printer = DotPrinterVisitor()
    try! expr.accept(visitor: printer)
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
    try! expr.left.accept(visitor: self)
    try! expr.right.accept(visitor: self)
  }

  func visit(_ expr: Grouping) {
    graph += "  \(nodeName(for: expr)) [label=\"( )\"]\n"
    graph += "  \(nodeName(for: expr)) -> \(nodeName(for: expr.expr))\n\n"
    try! expr.expr.accept(visitor: self)
  }

  func visit(_ expr: Literal) {
    graph += "  \(nodeName(for: expr)) [label=\"\(expr.value)\"]\n"
  }

  func visit(_ expr: Unary) {
    graph += "  \(nodeName(for: expr)) [label=\"\(expr.op.lexeme)\"]\n"
    graph += "  \(nodeName(for: expr)) -> \(nodeName(for: expr.right))\n\n"
    try! expr.right.accept(visitor: self)
  }
}
