//
//  Interpreter.swift
//  Libslox
//
//  Created by Ian Terrell on 10/22/20.
//

import Foundation

public class Interpreter {
  let replPrompt: String
  var hadError = false

  public init(replPrompt: String = "> ") {
    self.replPrompt = replPrompt
  }

  public func runFile(at path: String) throws {
    let script: String
    do {
      script = try String(contentsOfFile: path, encoding: .utf8)
    } catch {
      throw LoxError.couldNotReadFile(path)
    }
    run(script)
    guard !hadError else {
      throw LoxError.runtimeError
    }
  }

  public func runREPL() {
    func prompt() { print(replPrompt, terminator: "") }
    prompt()
    while let line = readLine() {
      run(line)
      hadError = false
      prompt()
    }
  }

  public func run(_ script: String) {
    let scanner = Scanner(source: script, runningIn: self)
    let tokens = scanner.scanTokens()
    print(tokens)
  }

  func reportError(line: Int, where: String? = nil, message: String) {
    if let `where` = `where` {
      print("[\(line)] Error \(`where`): \(message)")
    } else {
      print("[\(line)] Error: \(message)")
    }
    hadError = true
  }
}
