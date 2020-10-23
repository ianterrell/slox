//
//  Errors.swift
//  Libslox
//
//  Created by Ian Terrell on 10/22/20.
//

import Foundation

public enum LoxError: Error, CustomStringConvertible {
  case couldNotReadFile(_ path: String)
  case runtimeError

  public var description: String {
    switch self {
    case .couldNotReadFile(let path): return "Could not read file at \(path)"
    case .runtimeError: return "A runtime error occurred"
    }
  }
}

