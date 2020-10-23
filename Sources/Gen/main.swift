import Foundation

let libDir = "./Sources/Libslox"
func file(_ name: String) -> URL {
  return URL(fileURLWithPath: "./Sources/Libslox/\(name)")
}

let tokenData = TokenGenerator().genTokens().data(using: .utf8)!
try! tokenData.write(to: file("Token.swift"))
