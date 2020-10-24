class BaseGenerator {
  let generatedCodeWarning = """
  //
  // THIS IS A GENERATED FILE DO NOT EDIT
  //
  """

  func indent<T: StringProtocol>(_ n: Int, _ s: T) -> String {
    return indent(n, s.split(separator: "\n"))
  }

  func indent<T: StringProtocol>(_ n: Int, _ s: [T]) -> String {
    let ws = String(repeating: " ", count: n)
    return s.map{"\(ws)\($0)"}.joined(separator: "\n")
  }
}
