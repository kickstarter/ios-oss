@testable import Kickstarter_Framework
@testable import LibraryTestHelpers
import XCTest

final class SceneDelegateViewModelTests: TestCase {
  var vm: SceneDelegateViewModelType!

  override func setUp() {
    super.setUp()

    self.vm = SceneDelegateViewModel()
  }

  func testInitialization() {
    XCTAssertNotNil(self.vm)
  }
}
