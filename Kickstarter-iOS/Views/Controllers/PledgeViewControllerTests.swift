@testable import Kickstarter_Framework
import XCTest

final class PledgeViewControllerTests: XCTestCase {
  func testViewDidLoadAddsChildTableViewController() {
    let vc = PledgeViewController.instantiate()
    _ = vc.view

    XCTAssertTrue(vc.children.first is PledgeTableViewController)
  }
}
