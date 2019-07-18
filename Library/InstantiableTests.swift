import Foundation
import XCTest

private class TestViewController: UIViewController {
  var initWithNibNamedCalled = false

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

    self.initWithNibNamedCalled = true
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

final class InstantiableTests: TestCase {
  func testInstantiateCallsInitWithNibName() {
    let testVC = TestViewController.instantiate()

    XCTAssertTrue(testVC.initWithNibNamedCalled)
  }
}
