import Foundation

let dir = "./Sources/Libslox/Gen"
func file(_ name: String) -> URL {
  return URL(fileURLWithPath: "\(dir)/\(name)")
}

func write(_ contents: String, to name: String) {
  print("Writing \(name)...")
  let data = contents.data(using: .utf8)!
  try! data.write(to: file(name))
}

write(TokenGenerator().genTokens(), to: "Token.swift")
write(ASTGenerator().genStmt(), to: "Stmt.swift")
write(ASTGenerator().genExpr(), to: "Expr.swift")
print("Done!")
