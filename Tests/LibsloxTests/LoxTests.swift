import XCTest
@testable import Libslox

final class LoxTests: XCTestCase {
  let lox = Lox()

  func testMath() {
    XCTAssertEqual(.number(2), try! lox.run("1 + 1"))
    XCTAssertEqual(.number(0), try! lox.run("1 - 1"))
    XCTAssertEqual(.number(0.5), try! lox.run("1 / 2"))
    XCTAssertEqual(.number(4), try! lox.run("2 * 2"))
  }

  func testComparison() {
    XCTAssertEqual(.boolean(true), try! lox.run("2 > 1"))
    XCTAssertEqual(.boolean(true), try! lox.run("1 >= 1"))
    XCTAssertEqual(.boolean(false), try! lox.run("2 < 2"))
    XCTAssertEqual(.boolean(false), try! lox.run("2 <= 1"))
  }
}
