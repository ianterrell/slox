import Foundation

public enum SystemError: LoxError {
  case couldNotReadFile(_ path: String)

  public var description: String {
    switch self {
    case .couldNotReadFile(let path): return "Could not read file at \(path)"
    }
  }
}

public class Lox {
  let replPrompt: String

  public init(replPrompt: String = "> ") {
    self.replPrompt = replPrompt
  }

  public func run(_ script: String) throws -> Value {
    let tokens = try Scanner(source: script).scanTokens()
    let expr = try Parser(tokens: tokens).parse()
    let value = try Interpreter().evaluate(expr)
    return value
  }

  public func repl() {
    func prompt() { print(replPrompt, terminator: "") }
    prompt()
    while let line = readLine() {
      do {
        let value = try run(line)
        print(value)
      } catch {
        if let printer = ErrorPrinter(source: line, error: error) {
          printer.printAll()
        } else {
          print(error)
        }
      }
      prompt()
    }
  }
}
