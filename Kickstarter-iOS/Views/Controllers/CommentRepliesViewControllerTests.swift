@testable import Kickstarter_Framework
@testable import KsApi
import Library
import Prelude
import XCTest

internal final class CommentRepliesViewControllerTests: TestCase {
  override func setUp() {
    super.setUp()

    AppEnvironment.pushEnvironment(mainBundle: Bundle.framework)
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    UIView.setAnimationsEnabled(true)
    super.tearDown()
  }

  func testView_WithRootComment_ShouldDisplayRootComment() {
    Language.allLanguages.forEach { language in
      withEnvironment(currentUser: .template, language: language) {
        let controller = CommentRepliesViewController.configuredWith(comment: .template, project: .template)

        let (parent, _) = traitControllers(
          device: .phone4_7inch,
          orientation: .portrait,
          child: controller
        )

        parent.view.frame.size.height = 1_100

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "Comments - lang_\(language)")
      }
    }
  }
}
