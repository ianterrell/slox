import XCTest
@testable import Libslox

final class ScannerTests: XCTestCase {
  func testEOF() {
    let src = ""
    guard case .EOF(location: src.startIndex, lexeme: "") = firstToken(in: src) else {
      return XCTFail("Unexpected token!")
    }
  }

  func testStar() {
    let src = "*z"
    guard case .STAR(location: src.startIndex, lexeme: "*") = firstToken(in: src) else {
      return XCTFail("Unexpected token!")
    }
  }

  func testBang() {
    let src = "!a"
    guard case .BANG(location: src.startIndex, lexeme: "!") = firstToken(in: src) else {
      return XCTFail("Unexpected token!")
    }
  }

  func testBangEqual() {
    let src = "!= b"
    guard case .BANG_EQUAL(location: src.startIndex, lexeme: "!=") = firstToken(in: src) else {
      return XCTFail("Unexpected token!")
    }
  }

  func testComment() {
    let src = "// This is a comment"
    guard case .EOF(location: _, lexeme: "") = firstToken(in: src) else {
      return XCTFail("Unexpected token!")
    }
  }

  func testWhitespace() {
    let src = "   \t\t"
    guard case .EOF(location: _, lexeme: "") = firstToken(in: src) else {
      return XCTFail("Unexpected token!")
    }
  }

  func testString() {
    let src = "\"hi mom\" !"
    guard case .STRING(location: src.startIndex, lexeme: "\"hi mom\"", value: "hi mom") = firstToken(in: src) else {
      return XCTFail("Unexpected token!")
    }
  }

  func testNumber() {
    let src = "6.28 is tau"
    guard case .NUMBER(location: src.startIndex, lexeme: "6.28", value: 6.28) = firstToken(in: src) else {
      return XCTFail("Unexpected token!")
    }
  }

  func testElse() {
    let src = "else foo"
    guard case .ELSE(location: src.startIndex, lexeme: "else") = firstToken(in: src) else {
      return XCTFail("Unexpected token!")
    }
  }

  func testIdentifier() {
    let src = "foo bar"
    guard case .IDENTIFIER(location: src.startIndex, lexeme: "foo") = firstToken(in: src) else {
      return XCTFail("Unexpected token!")
    }
  }

  func firstToken(in source: String) -> Token? {
    let scanner = Scanner(source: source)
    return try? scanner.scanTokens().first
  }
}
