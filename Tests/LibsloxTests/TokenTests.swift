//
//  TokenTests.swift
//  Libslox
//
//  Created by Ian Terrell on 10/22/20.
//

import XCTest
@testable import Libslox

final class TokenTests: XCTestCase {
  let interpreter = Interpreter()

  func testDescription() {
    let token = Token(type: .EOF, lexeme: "", line: 1)
    XCTAssertEqual("EOF", token.description)
  }

  func testLiteralString() {
    let eof = Token(type: .EOF, lexeme: "WHAT", line: 1)
    XCTAssertNil(eof.stringLiteral)

    let s = Token(type: .STRING, lexeme: "\"hi mom\"", line: 1)
    XCTAssertEqual("hi mom", s.stringLiteral)
  }

  func testLiteralNumber() {
    let eof = Token(type: .EOF, lexeme: "WHAT", line: 1)
    XCTAssertNil(eof.numberLiteral)

    let s = Token(type: .NUMBER, lexeme: "6.28", line: 1)
    XCTAssertEqual(6.28, s.numberLiteral!, accuracy: 0.00001)
  }
}
