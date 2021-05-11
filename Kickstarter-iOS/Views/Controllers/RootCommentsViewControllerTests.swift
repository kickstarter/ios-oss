@testable import Kickstarter_Framework
@testable import KsApi
import Library
import Prelude
import XCTest

internal final class RootCommentsViewControllerTests: TestCase {
  override func setUp() {
    super.setUp()
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    UIView.setAnimationsEnabled(true)
    super.tearDown()
  }

  func testView() {
    Language.allLanguages.forEach { language in
      withEnvironment(language: language) {
        let controller = RootCommentsViewController()
        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 600

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "RootComments - lang_\(language)")
      }
    }
  }
}
