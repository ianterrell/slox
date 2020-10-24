public enum Value: CustomStringConvertible {
  case string(String)
  case number(Double)
  case boolean(Bool)
  case `nil`

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
