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
  enum Return: Error {
    case value(Value?)
  }

  let declaration: FunctionStmt
  let closure: Environment
  let isInitializer: Bool

  var arity: Int { return declaration.params.count }
  var description: String { return "<fn \(declaration.name.lexeme)>" }

  init(declaration: FunctionStmt, closure: Environment, isInitializer: Bool) {
    self.declaration = declaration
    self.closure = closure
    self.isInitializer = isInitializer
  }

  func bind(this instance: LoxInstance) -> LoxFunction {
    let environment = Environment(parent: closure)
    environment.define(name: "this", value: .instance(instance))
    return LoxFunction(declaration: declaration, closure: environment, isInitializer: isInitializer)
  }

  func call(interpreter: Interpreter, arguments: [Value]) throws -> Value {
    let environment = Environment(parent: closure)
    for (p, v) in zip(declaration.params, arguments) {
      environment.define(name: p.lexeme, value: v)
    }
    do {
      try interpreter.executeBlock(declaration.body, env: environment)
    } catch Return.value(let value?) {
      return value
    } catch {}
    if isInitializer {
      return try closure.get(unsafe: "this")
    }
    return .nil
  }
}

public class LoxClass: LoxCallable, CustomStringConvertible {
  let name: String
  let superclass: LoxClass?
  let methods: [String: LoxFunction]

  public var arity: Int { return methods["init"]?.arity ?? 0 }
  public var description: String { return "<class \(name)>" }

  init(name: String, superclass: LoxClass?, methods: [String: LoxFunction]) {
    self.name = name
    self.superclass = superclass
    self.methods = methods
  }

  func find(method: Token) -> LoxFunction? {
    if let thisMethod = methods[method.lexeme] {
      return thisMethod
    }
    return superclass?.find(method: method)
  }

  public func call(interpreter: Interpreter, arguments: [Value]) throws -> Value {
    let instance = LoxInstance(cls: self)
    if let initializer = methods["init"] {
      _ = try initializer.bind(this: instance).call(interpreter: interpreter, arguments: arguments)
    }
    return .instance(instance)
  }
}

public class LoxInstance: CustomStringConvertible {
  let cls: LoxClass
  var properties: [String: Value] = [:]

  public var description: String { return "<instance of \(cls.name)>" }

  init(cls: LoxClass) {
    self.cls = cls
  }

  func set(_ field: Token, value: Value) {
    properties[field.lexeme] = value
  }

  func get(_ field: Token) throws -> Value {
    if let value = properties[field.lexeme] {
      return value
    }
    if let method = cls.find(method: field) {
      return .function(method.bind(this: self))
    }
    throw RuntimeError(field.location, "Undefined field '\(field.lexeme)'")
  }
}
