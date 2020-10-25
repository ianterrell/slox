class DotPrinter {
  init() {}

  func print(_ program: [Stmt]) {
    let printer = DotPrinterVisitor()
    program.forEach { try! $0.accept(visitor: printer) }
    return printer.finish()
  }

  func print(_ expr: Expr) {
    let printer = DotPrinterVisitor()
    try! expr.accept(visitor: printer)
    return printer.finish()
  }
}

class DotPrinterVisitor: StmtVisitor, ExprVisitor {
  init() {
    print("digraph {")
  }

  func finish() {
    print("}")
  }

  func nodeName(for node: AnyObject) -> String {
    return "n\(abs(ObjectIdentifier(node).hashValue))"
  }

  func visit(_ stmt: ExpressionStmt) throws {
    print("  subgraph cluster_\(nodeName(for: stmt)) {")
    print("    label=\"Expression\"\n")
    try! stmt.expr.accept(visitor: self)
    print("  }")
  }

  func visit(_ stmt: PrintStmt) throws {
    print("  subgraph cluster_\(nodeName(for: stmt)) {")
    print("    label=\"Print\"\n")
    try! stmt.expr.accept(visitor: self)
    print("  }")
  }

  func visit(_ stmt: VarStmt) throws {
    print("  subgraph cluster_\(nodeName(for: stmt)) {")
    print("    label=\"var \(stmt.name.lexeme) =\"\n")
    if let initializer = stmt.initializer {
      try! initializer.accept(visitor: self)
    } else {
      print("    \(nodeName(for: stmt)) [label=\"nil\"]")
    }
    print("  }")
  }

  func visit(_ expr: BinaryExpr) {
    print("    \(nodeName(for: expr)) [label=\"\(expr.op.lexeme)\"]")
    print("    \(nodeName(for: expr)) -> \(nodeName(for: expr.left))")
    print("    \(nodeName(for: expr)) -> \(nodeName(for: expr.right))\n")
    try! expr.left.accept(visitor: self)
    try! expr.right.accept(visitor: self)
  }

  func visit(_ expr: GroupingExpr) {
    print("    \(nodeName(for: expr)) [label=\"( )\"]")
    print("    \(nodeName(for: expr)) -> \(nodeName(for: expr.expr))\n")
    try! expr.expr.accept(visitor: self)
  }

  func visit(_ expr: LiteralExpr) {
    print("    \(nodeName(for: expr)) [label=\"\(expr.value)\"]")
  }

  func visit(_ expr: VariableExpr) {
    print("    \(nodeName(for: expr)) [label=\"\(expr.name.lexeme)\"]")
  }

  func visit(_ expr: UnaryExpr) {
    print("    \(nodeName(for: expr)) [label=\"\(expr.op.lexeme)\"]")
    print("    \(nodeName(for: expr)) -> \(nodeName(for: expr.right))\n")
    try! expr.right.accept(visitor: self)
  }
}
