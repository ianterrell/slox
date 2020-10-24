public enum Value {
  case string(String)
  case number(Double)
  case boolean(Bool)
  case `nil`

  var typeName: String {
    switch self {
    case .string: return "String"
    case .number: return "Number"
    case .boolean: return "Boolean"
    case .nil: return "nil"
    }
  }
}

extension Value: CustomStringConvertible {
  public var description: String {
    switch self {
    case .string(let s): return s
    case .number(let n):
      let s = "\(n)"
      if s.hasSuffix(".0") { return String(s.dropLast(2)) }
      return s
    case .boolean(let b): return "\(b)"
    case .nil: return "nil"
    }
  }
}

extension Value: Equatable {
  public static func ==(lhs: Value, rhs: Value) -> Bool {
    switch (lhs, rhs) {
    case (.string(let lhs), .string(let rhs)): return lhs == rhs
    case (.number(let lhs), .number(let rhs)): return lhs == rhs
    case (.boolean(let lhs), .boolean(let rhs)): return lhs == rhs
    case (.nil, .nil): return true
    default: return false
    }
  }
}
