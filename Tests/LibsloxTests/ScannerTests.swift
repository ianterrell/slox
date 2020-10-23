import XCTest
@testable import Libslox

final class ScannerTests: XCTestCase {
  func testEOF() {
    let expected = Token(type: .EOF, lexeme: "", line: 1)
    assertFirstToken(in: "", is: expected)
  }

  func testStar() {
    let expected = Token(type: .STAR, lexeme: "*", line: 1)
    assertFirstToken(in: "*z", is: expected)
  }

  func testBang() {
    let expected = Token(type: .BANG, lexeme: "!", line: 1)
    assertFirstToken(in: "!a", is: expected)
  }

  func testBangEqual() {
    let expected = Token(type: .BANG_EQUAL, lexeme: "!=", line: 1)
    assertFirstToken(in: "!= b", is: expected)
  }

  func testComment() {
    let expected = Token(type: .EOF, lexeme: "", line: 1)
    assertFirstToken(in: "// This is a comment", is: expected)
  }

  func testWhitespace() {
    let expected = Token(type: .EOF, lexeme: "", line: 1)
    assertFirstToken(in: "   \t\t", is: expected)
  }

  func testNewlines() {
    let expected = Token(type: .EOF, lexeme: "", line: 3)
    assertFirstToken(in: "   \n\n", is: expected)
  }

  func testString() {
    let expected = Token(type: .STRING, lexeme: "\"hi mom\"", line: 1)
    assertFirstToken(in: "\"hi mom\" !", is: expected)
  }

  func testElse() {
    let expected = Token(type: .ELSE, lexeme: "else", line: 1)
    assertFirstToken(in: "else foo", is: expected)
  }

  func testIdentifier() {
    let expected = Token(type: .IDENTIFIER, lexeme: "foo", line: 1)
    assertFirstToken(in: "foo bar", is: expected)
  }

  func assertFirstToken(in source: String, is expected: Token) {
    let interpreter = Interpreter()
    let scanner = Scanner(source: source, runningIn: interpreter)
    XCTAssertEqual(expected, scanner.scanTokens().first)
    XCTAssertFalse(interpreter.hadError)
  }
}
