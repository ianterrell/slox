import Darwin
import Libslox

extension Int32 {
  static let exitUsage: Int32 = 64
  static let exitDataError: Int32 = 65
}

var args = CommandLine.arguments.suffix(from: 1)
guard args.count <= 1 else {
  print("Usage: slox path/to/script.lox")
  exit(.exitUsage)
}

do {
  let interpreter = Interpreter()
  if let path = args.last {
    try interpreter.runFile(at: path)
  } else {
    interpreter.runREPL()
  }
} catch {
  print(error)
  exit(.exitDataError)
}
