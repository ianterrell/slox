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
    print("node[fontname=Courier color=gray40]")
    print("edge[color=gray40 arrowhead=none fontcolor=gray fontname=helvetica fontsize=9]")
  }

  func finish() {
    print("}")
  }

  func nodeName(for node: AnyObject) -> String {
    return "n\(abs(ObjectIdentifier(node).hashValue))"
  }

  func visit(_ stmt: ExpressionStmt) {
    print("\(nodeName(for: stmt)) [label=\"expression\" shape=box]")
    print("\(nodeName(for: stmt)) -> \(nodeName(for: stmt.expr))")
    try! stmt.expr.accept(visitor: self)
  }

  func visit(_ stmt: PrintStmt) {
    print("\(nodeName(for: stmt)) [label=\"print\" shape=box]")
    print("\(nodeName(for: stmt)) -> \(nodeName(for: stmt.expr))")
    try! stmt.expr.accept(visitor: self)
  }

  func visit(_ stmt: IfStmt) throws {
    print("\(nodeName(for: stmt)) [label=\"if\" shape=box]")
    print("\(nodeName(for: stmt)) -> \(nodeName(for: stmt.condition)) [label=\"cond\"]")
    try! stmt.condition.accept(visitor: self)

    print("\(nodeName(for: stmt)) -> \(nodeName(for: stmt.thenBranch)) [label=\"then\"]")
    try! stmt.thenBranch.accept(visitor: self)
    if let elseBranch = stmt.elseBranch {
      print("\(nodeName(for: stmt)) -> \(nodeName(for: elseBranch)) [label=\"else\"]")
      try! elseBranch.accept(visitor: self)
    }
  }

  func visit(_ stmt: FunctionStmt) throws {
    let params = stmt.params.map { $0.lexeme }.joined(separator: ", ")
    print("\(nodeName(for: stmt)) [label=\"fun \(stmt.name.lexeme)(\(params))\" shape=box]")
    stmt.body.forEach { bodyStmt in
      print("\(nodeName(for: stmt)) -> \(nodeName(for: bodyStmt))")
      try! bodyStmt.accept(visitor: self)
    }
  }

  func visit(_ stmt: BlockStmt) {
    print("\(nodeName(for: stmt)) [label=\"{ }\" shape=box]")
    stmt.statements.forEach { blockStmt in
      print("\(nodeName(for: stmt)) -> \(nodeName(for: blockStmt))")
      try! blockStmt.accept(visitor: self)
    }
  }

  func visit(_ stmt: ClassStmt) throws {
    print("\(nodeName(for: stmt)) [label=\"class \(stmt.name.lexeme)\" shape=box]")
    if let superclass = stmt.superclass {
      print("\(nodeName(for: stmt)) -> \(nodeName(for: superclass)) [label=\"superclass\"]")
      try! superclass.accept(visitor: self)
    }
    stmt.methods.forEach { method in
      print("\(nodeName(for: stmt)) -> \(nodeName(for: method))")
      try! method.accept(visitor: self)
    }
  }

  func visit(_ stmt: VarStmt) {
    print("\(nodeName(for: stmt)) [label=\"var \(stmt.name.lexeme) =\" shape=box]")
    if let initializer = stmt.initializer {
      print("\(nodeName(for: stmt)) -> \(nodeName(for: initializer))")
      try! initializer.accept(visitor: self)
    } else {
      print("\(nodeName(for: stmt))2 [label=\"nil\"]")
      print("\(nodeName(for: stmt)) -> \(nodeName(for: stmt))2")
    }
  }

  func visit(_ stmt: WhileStmt) {
    print("\(nodeName(for: stmt)) [label=\"while\" shape=box]")
    print("\(nodeName(for: stmt)) -> \(nodeName(for: stmt.condition)) [label=\"cond\"]")
    try! stmt.condition.accept(visitor: self)

    print("\(nodeName(for: stmt)) -> \(nodeName(for: stmt.body)) [label=\"body\"]")
    try! stmt.body.accept(visitor: self)
  }

  func visit(_ stmt: ReturnStmt) throws {
    print("\(nodeName(for: stmt)) [label=\"return\" shape=box]")
    if let value = stmt.value {
      print("\(nodeName(for: stmt)) -> \(nodeName(for: value))")
      try! value.accept(visitor: self)
    }
  }

  func visit(_ expr: AssignExpr) {
    print("\(nodeName(for: expr)) [label=\"\(expr.name.lexeme) =\" shape=box]")
    print("\(nodeName(for: expr)) -> \(nodeName(for: expr.value))")
    try! expr.value.accept(visitor: self)
  }

  func visit(_ expr: BinaryExpr) {
    print("\(nodeName(for: expr)) [label=\"\(expr.op.lexeme)\" shape=circle]")
    print("\(nodeName(for: expr)) -> \(nodeName(for: expr.left))")
    print("\(nodeName(for: expr)) -> \(nodeName(for: expr.right))")
    try! expr.left.accept(visitor: self)
    try! expr.right.accept(visitor: self)
  }

  func visit(_ expr: CallExpr) throws {
    print("\(nodeName(for: expr)) [label=\"call\"]")
    print("\(nodeName(for: expr)) -> \(nodeName(for: expr.callee)) [label=\"callee\"]")
    try! expr.callee.accept(visitor: self)
    expr.arguments.forEach { arg in
      print("\(nodeName(for: expr)) -> \(nodeName(for: arg)) [label=\"arg\"]")
      try! arg.accept(visitor: self)
    }
  }

  func visit(_ expr: GetExpr) throws -> () {
    print("\(nodeName(for: expr)) [label=\".\(expr.name.lexeme)\"]")
    print("\(nodeName(for: expr)) -> \(nodeName(for: expr.object)) [label=\"obj\"]")
    try! expr.object.accept(visitor: self)
  }

  func visit(_ expr: GroupingExpr) {
    print("\(nodeName(for: expr)) [label=\"( )\"]")
    print("\(nodeName(for: expr)) -> \(nodeName(for: expr.expr))")
    try! expr.expr.accept(visitor: self)
  }

  func visit(_ expr: LiteralExpr) {
    let name: String
    if case .string = expr.value {
      name = "\\\"\(expr.value)\\\""
    } else {
      name = "\(expr.value)"
    }
    print("\(nodeName(for: expr)) [label=\"\(name)\"]")
  }

  func visit(_ expr: VariableExpr) {
    print("\(nodeName(for: expr)) [label=\"\(expr.name.lexeme)\"]")
  }

  func visit(_ expr: SuperExpr) {
    print("\(nodeName(for: expr)) [label=\"super.\(expr.method.lexeme)\"]")
  }

  func visit(_ expr: ThisExpr) {
    print("\(nodeName(for: expr)) [label=\"this\"]")
  }

  func visit(_ expr: LogicalExpr) throws {
    print("\(nodeName(for: expr)) [label=\"\(expr.op.lexeme)\" shape=circle]")
    print("\(nodeName(for: expr)) -> \(nodeName(for: expr.left))")
    print("\(nodeName(for: expr)) -> \(nodeName(for: expr.right))")
    try! expr.left.accept(visitor: self)
    try! expr.right.accept(visitor: self)
  }

  func visit(_ expr: SetExpr) throws {
    print("\(nodeName(for: expr)) [label=\".\(expr.name.lexeme) =\"]")
    print("\(nodeName(for: expr)) -> \(nodeName(for: expr.object)) [label=\"obj\"]")
    print("\(nodeName(for: expr)) -> \(nodeName(for: expr.value)) [label=\"val\"]")
    try! expr.object.accept(visitor: self)
    try! expr.value.accept(visitor: self)
  }

  func visit(_ expr: UnaryExpr) {
    print("\(nodeName(for: expr)) [label=\"\(expr.op.lexeme)\" shape=circle]")
    print("\(nodeName(for: expr)) -> \(nodeName(for: expr.right))")
    try! expr.right.accept(visitor: self)
  }
}
