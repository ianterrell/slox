class Environment {
  var values: [String: Value] = [:]

  func define(name: Token, value: Value) {
    values[name.lexeme] = value
  }

  func get(name: Token) throws -> Value {
    guard let value = values[name.lexeme] else {
      throw RuntimeError.undefinedVariable(name: name.lexeme, location: name.location)
    }
    return value
  }
}
