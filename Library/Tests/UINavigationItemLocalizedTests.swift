import XCTest
@testable import Library

final class UINavigationItemLocalizedKeyTests: XCTestCase {

  override func setUp() {
    AppEnvironment.pushEnvironment(mainBundle: MockBundle())
  }

  override func tearDown() {
    AppEnvironment.popEnvironment()
  }

  func testTitleLocalizedKey() {
    let item = UINavigationItem()

    withEnvironment(language: .en) {
      item.titleLocalizedKey = "hello"
      XCTAssertEqual(item.title, "world")
      XCTAssertEqual(item.titleLocalizedKey, "")
    }

    withEnvironment(language: .de) {
      item.titleLocalizedKey = "hello"
      XCTAssertEqual(item.title, "de_world")
      XCTAssertEqual(item.titleLocalizedKey, "")
    }
  }

  #if os(iOS)
  func testPromptLocalizedKey() {
    let item = UINavigationItem()

    withEnvironment(language: .en) {
      item.promptLocalizedKey = "hello"
      XCTAssertEqual(item.prompt, "world")
      XCTAssertEqual(item.promptLocalizedKey, "")
    }

    withEnvironment(language: .de) {
      item.promptLocalizedKey = "hello"
      XCTAssertEqual(item.prompt, "de_world")
      XCTAssertEqual(item.promptLocalizedKey, "")
    }
  }
  #endif
}
