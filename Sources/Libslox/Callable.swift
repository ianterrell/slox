import Foundation

public protocol LoxCallable {
  var arity: Int { get }
  func call(interpreter: Interpreter, arguments: [Value]) throws -> Value
}

typealias LoxCallableFn = (Interpreter, [Value]) throws -> Value

class Builtin: LoxCallable, CustomStringConvertible {
  let name: String
  let arity: Int
  let callable: LoxCallableFn

  var description: String { return "<builtin \(name)>" }

  init(name: String, arity: Int, callable: @escaping LoxCallableFn) {
    self.name = name
    self.arity = arity
    self.callable = callable
  }

  func call(interpreter: Interpreter, arguments: [Value]) throws -> Value {
    return try callable(interpreter, arguments)
  }
}

extension Builtin {
  static func register(in env: Environment) {
    for fn in all {
      env.define(name: fn.name, value: .function(fn))
    }
  }

  static let all = [
    clock,
  ]
  
  static let clock = Builtin(name: "clock", arity: 0) { _, _ in
    return .number(Date().timeIntervalSince1970)
  }
}

class LoxFunction: LoxCallable, CustomStringConvertible {
  let declaration: FunctionStmt
  let arity: Int

  var description: String { return "<fn \(declaration.name.lexeme)>" }

  init(declaration: FunctionStmt) {
    self.declaration = declaration
    self.arity = declaration.params.count
  }

  func call(interpreter: Interpreter, arguments: [Value]) throws -> Value {
    let environment = Environment(parent: interpreter.globals)
    for (p, v) in zip(declaration.params, arguments) {
      environment.define(name: p.lexeme, value: v)
    }
    try interpreter.executeBlock(declaration.body, env: environment)
    return .nil
  }
}
