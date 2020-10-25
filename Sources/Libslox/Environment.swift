class Environment {
  let parent: Environment?
  var values: [String: Value] = [:]

  init(parent: Environment? = nil) {
    self.parent = parent
  }

  func define(name: Token, value: Value) {
    values[name.lexeme] = value
  }

  func assign(name: Token, value: Value) throws {
    if values[name.lexeme] != nil {
      values[name.lexeme] = value
      return
    }
    if let parent = self.parent {
      try parent.assign(name: name, value: value)
      return
    }

    throw RuntimeError.undefinedVariable(name: name.lexeme, location: name.location)
  }

  func get(name: Token) throws -> Value {
    if let value = values[name.lexeme] {
      return value
    }
    if let parent = self.parent {
      return try parent.get(name: name)
    }
    throw RuntimeError.undefinedVariable(name: name.lexeme, location: name.location)
  }
}
