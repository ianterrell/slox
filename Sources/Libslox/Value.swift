public enum Value: CustomStringConvertible {
  case string(String)
  case number(Double)

  public var description: String {
    switch self {
    case .string(let v): return v
    case .number(let v): return "\(v)"
    }
  }
}
