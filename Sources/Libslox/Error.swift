public protocol LoxError: Error {}

public protocol CompositeLoxError {
  var errors: [LoxError] { get }
}

// MARK:- Syntax Errors

public enum SyntaxError: LoxError, SourceFindable, CustomStringConvertible {
  case unexpectedCharacter(location: String.Index)
  case unterminatedString(location: String.Index)
  case notANumber(location: String.Index)
  case missingParen(token: Token)
  case missingExpression(token: Token)

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
    }
  }

  public var index: String.Index {
    switch self {
    case .unexpectedCharacter(let i): return i
    case .unterminatedString(let i): return i
    case .notANumber(let i): return i
    case .missingParen(let t): return t.location
    case .missingExpression(let t): return t.location
    }
  }
}

// MARK:- Runtime Errors

public enum RuntimeError: LoxError, SourceFindable, CustomStringConvertible {
  case binaryOperatorRequiresNumeric(token: Token)
  case binaryOperatorRequiresNumericOrString(token: Token)
  case unaryOperatorRequiresNumeric(token: Token)
  case internalError(token: Token, message: String)

  public var description: String {
    return "Runtime Error: \(subdescription)"
  }

  var subdescription: String {
    switch self {
    case .binaryOperatorRequiresNumeric(let t): return "Binary operator \(t.lexeme) requires numeric operands"
    case .binaryOperatorRequiresNumericOrString(let t): return "Binary operator \(t.lexeme) requires both operands to be either numeric or string"
    case .unaryOperatorRequiresNumeric(let t): return "Binary operator \(t.lexeme) requires numeric operand"
    case .internalError(_, let message): return message
    }
  }

  public var index: String.Index {
    switch self {
    case .binaryOperatorRequiresNumeric(let t): return t.location
    case .binaryOperatorRequiresNumericOrString(let t): return t.location
    case .unaryOperatorRequiresNumeric(let t): return t.location
    case .internalError(let t, _): return t.location
    }
  }
}

// MARK:- Source Findable

public protocol SourceFindable {
  var index: String.Index { get }
}

public class SourceFinder {
  let source: String
  let lines: [Substring]

  public init?(source: String) {
    guard !source.isEmpty else {
      return nil
    }
    self.source = source
    self.lines = source.split(separator: "\n", omittingEmptySubsequences: false)
  }

  public func find(index: String.Index) -> (line: String, lineNumber: Int, columnNumber: Int)? {
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
