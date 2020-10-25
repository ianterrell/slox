public protocol LoxError: Error {}

public struct CompositeLoxError: LoxError {
  public let errors: [LoxError]
}

// MARK:- Syntax Errors

public enum SyntaxError: LoxError, SourceFindable, CustomStringConvertible {
  case unexpectedCharacter(location: String.Index)
  case unterminatedString(location: String.Index)
  case notANumber(location: String.Index)
  case missingParen(location: String.Index)
  case missingExpression(location: String.Index)
  case missingSemicolon(location: String.Index)
  case missingIdentifier(location: String.Index)
  case invalidAssignmentTarget(location: String.Index)
  case missingBrace(location: String.Index)

  public var description: String {
    return "Syntax Error: \(subdescription)"
  }

  var subdescription: String {
    switch self {
    case .unexpectedCharacter: return "Unexpected character"
    case .unterminatedString: return "Unterminated string"
    case .notANumber: return "Not a number"
    case .missingParen: return "Expect ')' after expression"
    case .missingExpression: return "Expect expression"
    case .missingSemicolon: return "Expect semicolon after statement"
    case .missingIdentifier: return "Expect identifier"
    case .invalidAssignmentTarget: return "Invalid assignment target"
    case .missingBrace: return "Expect '}' after block"
    }
  }

  public var index: String.Index {
    switch self {
    case .unexpectedCharacter(let i): return i
    case .unterminatedString(let i): return i
    case .notANumber(let i): return i
    case .missingParen(let i): return i
    case .missingExpression(let i): return i
    case .missingSemicolon(let i): return i
    case .missingIdentifier(let i): return i
    case .invalidAssignmentTarget(let i): return i
    case .missingBrace(let i): return i
    }
  }
}

// MARK:- Runtime Errors

public enum RuntimeError: LoxError, SourceFindable, CustomStringConvertible {
  case binaryOperatorRequiresNumeric(op: String, location: String.Index)
  case binaryOperatorRequiresNumericOrString(op: String, location: String.Index)
  case unaryOperatorRequiresNumeric(op: String, location: String.Index)
  case undefinedVariable(name: String, location: String.Index)
  case internalError(location: String.Index, message: String)

  public var description: String {
    return "Runtime Error: \(subdescription)"
  }

  var subdescription: String {
    switch self {
    case .binaryOperatorRequiresNumeric(let op, _): return "Binary operator \(op) requires numeric operands"
    case .binaryOperatorRequiresNumericOrString(let op, _): return "Binary operator \(op) requires both operands to be either numeric or string"
    case .unaryOperatorRequiresNumeric(let op, _): return "Binary operator \(op) requires numeric operand"
    case .undefinedVariable(let name, _): return "Variable '\(name)' is undefined"
    case .internalError(_, let message): return message
    }
  }

  public var index: String.Index {
    switch self {
    case .binaryOperatorRequiresNumeric(_, let i): return i
    case .binaryOperatorRequiresNumericOrString(_, let i): return i
    case .unaryOperatorRequiresNumeric(_, let i): return i
    case .undefinedVariable(_, let i): return i
    case .internalError(let i, _): return i
    }
  }
}

// MARK:- Source Findable

protocol SourceFindable {
  var index: String.Index { get }
}

class SourceFinder {
  let source: String
  let lines: [Substring]

  init?(source: String) {
    guard !source.isEmpty else {
      return nil
    }
    self.source = source
    self.lines = source.split(separator: "\n", omittingEmptySubsequences: false)
  }

  func find(index: String.Index) -> (line: String, lineNumber: Int, columnNumber: Int)? {
    guard index < source.endIndex else {
      return nil
    }

    var i = 0
    while i < lines.count && lines[i].startIndex <= index {
      i += 1
    }

    let lineNumber = i
    let line = lines[i-1]

    var columnNumber = 1
    var current = line.startIndex
    while current < index && current < line.endIndex {
      columnNumber += 1
      current = line.index(after: current)
    }

    return (line: String(line), lineNumber: lineNumber, columnNumber: columnNumber)
  }
}

public class ErrorPrinter {
  let sourceFinder: SourceFinder
  let error: LoxError

  public init?(source: String, error: Error) {
    guard
      let finder = SourceFinder(source: source),
      let error = error as? LoxError
    else {
      return nil
    }
    self.sourceFinder = finder
    self.error = error
  }

  public func printAll(limit: Int = 5) {
    if let errors = (error as? CompositeLoxError)?.errors {
      let count = errors.count
      if count == 0 {
        print("No errors reported!")
      }
      for i in 0..<min(limit, count) {
        printOne(errors[i])
      }
      if limit < count {
        print("...and \(count - limit) more errors")
      }
    } else {
      printOne(error)
    }
  }

  func printOne(_ error: LoxError) {
    if let findable = error as? SourceFindable,
       let location = sourceFinder.find(index: findable.index)
    {
      print("Line \(location.lineNumber): \(error)")
      print("> \(location.line)")
      let ws = String(repeating: " ", count: location.columnNumber - 1)
      print("  \(ws)^\n")
    } else {
      print("\(error)\n")
    }
  }
}
