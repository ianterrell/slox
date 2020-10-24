import Foundation
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

let lox = Lox()

if args.isEmpty {
  lox.repl()
  exit(0)
}

func read(fileAt path: String) -> String {
  do {
    return try String(contentsOfFile: path, encoding: .utf8)
  } catch {
    print("Could not read file at \(path)")
    exit(.exitDataError)
  }
}

let path = args.last!
let script = read(fileAt: path)
do {
  try lox.run(script)
} catch let error as LoxError {
  if let printer = ErrorPrinter(source: script, error: error) {
    printer.printAll()
  } else {
    print(error)
  }
  exit(.exitDataError)
}
