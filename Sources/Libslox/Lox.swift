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

  public func debugPrint(_ script: String) throws {
    let tokens = try Scanner(source: script).scanTokens()
    let program = try Parser(tokens: tokens).parse()
    DotPrinter().print(program)
  }

  public func run(_ script: String) throws {
    let tokens = try Scanner(source: script).scanTokens()
    let program = try Parser(tokens: tokens).parse()
    let interpreter = Interpreter()
    try Resolver(interpreter: interpreter).analyze(program)
    try interpreter.interpret(program)
  }

  public func repl() {
    func prompt() { print(replPrompt, terminator: "") }
    prompt()
    while let line = readLine() {
      do {
        try run(line)
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
