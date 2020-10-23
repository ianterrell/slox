//
//  Error.swift
//  Libslox
//
//  Created by Ian Terrell on 10/23/20.
//

import Foundation

public protocol LoxError: Error {}

public protocol CompositeLoxError {
  var errors: [LoxError] { get }
}

public protocol SourceFindable {
  var index: String.Index { get }
}

public class SourceFinder {
  let source: String
  let lines: [Substring]

  public init?(source: String) {
    guard !source.isEmpty else {
      return nil
    }
    self.source = source
    self.lines = source.split(separator: "\n", omittingEmptySubsequences: false)
  }

  public func find(index: String.Index) -> (line: String, lineNumber: Int, columnNumber: Int)? {
    guard index < source.endIndex else {
      return nil
    }

    var i = 0
    while i < lines.count && lines[i].startIndex <= index {
      i += 1
    }

    let lineNumber = i
    let line = lines[i-1]

    var columnNumber = 1
    var current = line.startIndex
    while current < index && current < line.endIndex {
      columnNumber += 1
      current = line.index(after: current)
    }

    return (line: String(line), lineNumber: lineNumber, columnNumber: columnNumber)
  }
}

public class ErrorPrinter {
  let sourceFinder: SourceFinder
  let error: LoxError

  public init?(source: String, error: Error) {
    guard
      let finder = SourceFinder(source: source),
      let error = error as? LoxError
    else {
      return nil
    }
    self.sourceFinder = finder
    self.error = error
  }

  public func printAll(limit: Int = 5) {
    if let errors = (error as? CompositeLoxError)?.errors {
      let count = errors.count
      if count == 0 {
        print("No errors reported!")
      }
      for i in 0..<min(limit, count) {
        printOne(errors[i])
      }
      if limit < count {
        print("...and \(count - limit) more errors")
      }
    } else {
      printOne(error)
    }
  }

  func printOne(_ error: LoxError) {
    if let findable = error as? SourceFindable,
       let location = sourceFinder.find(index: findable.index)
    {
      print("Line \(location.lineNumber): \(error)")
      print("> \(location.line)")
      let ws = String(repeating: " ", count: location.columnNumber - 1)
      print("  \(ws)^\n")
    } else {
      print("\(error)\n")
    }
  }
}
