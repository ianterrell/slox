//MARK:- ParenPrinter

class ParenPrinter: ExprVisitor {
  func print(_ expr: Expr) -> String {
    return try! expr.accept(visitor: self)
  }

  func visit(_ expr: BinaryExpr) -> String {
    return parenthesize(expr.op.lexeme, expr.left, expr.right)
  }

  func visit(_ expr: GroupingExpr) -> String {
    return parenthesize("group", expr.expr)
  }

  func visit(_ expr: LiteralExpr) -> String {
    return "\(expr.value)"
  }

  func visit(_ expr: UnaryExpr) -> String {
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
class DotPrinter {
  init() {}

  func print(_ expr: Expr) -> String {
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

  func visit(_ expr: BinaryExpr) {
    graph += "  \(nodeName(for: expr)) [label=\"\(expr.op.lexeme)\"]\n"
    graph += "  \(nodeName(for: expr)) -> \(nodeName(for: expr.left))\n"
    graph += "  \(nodeName(for: expr)) -> \(nodeName(for: expr.right))\n\n"
    try! expr.left.accept(visitor: self)
    try! expr.right.accept(visitor: self)
  }

  func visit(_ expr: GroupingExpr) {
    graph += "  \(nodeName(for: expr)) [label=\"( )\"]\n"
    graph += "  \(nodeName(for: expr)) -> \(nodeName(for: expr.expr))\n\n"
    try! expr.expr.accept(visitor: self)
  }

  func visit(_ expr: LiteralExpr) {
    graph += "  \(nodeName(for: expr)) [label=\"\(expr.value)\"]\n"
  }

  func visit(_ expr: UnaryExpr) {
    graph += "  \(nodeName(for: expr)) [label=\"\(expr.op.lexeme)\"]\n"
    graph += "  \(nodeName(for: expr)) -> \(nodeName(for: expr.right))\n\n"
    try! expr.right.accept(visitor: self)
  }
}
