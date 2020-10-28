import Foundation

public protocol LoxCallable: class {
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
  struct Return: Error {
    let value: Value
  }

  let declaration: FunctionStmt
  let closure: Environment

  var arity: Int { return declaration.params.count }
  var description: String { return "<fn \(declaration.name.lexeme)>" }

  init(declaration: FunctionStmt, closure: Environment) {
    self.declaration = declaration
    self.closure = closure
  }

  func call(interpreter: Interpreter, arguments: [Value]) throws -> Value {
    let environment = Environment(parent: closure)
    for (p, v) in zip(declaration.params, arguments) {
      environment.define(name: p.lexeme, value: v)
    }
    do {
      try interpreter.executeBlock(declaration.body, env: environment)
    } catch let e as Return {
      return e.value
    }
    return .nil
  }
}

public class LoxClass: LoxCallable, CustomStringConvertible {
  let name: String

  public var arity: Int { return 0 }
  public var description: String { return "<class \(name)>" }

  init(name: String) {
    self.name = name
  }

  public func call(interpreter: Interpreter, arguments: [Value]) throws -> Value {
    return .instance(LoxInstance(cls: self))
  }
}

public class LoxInstance: CustomStringConvertible {
  let cls: LoxClass

  public var description: String { return "<instance of \(cls.name)>" }

  init(cls: LoxClass) {
    self.cls = cls
  }
}
