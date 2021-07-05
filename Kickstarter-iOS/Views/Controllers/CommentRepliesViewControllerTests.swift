@testable import Kickstarter_Framework
@testable import KsApi
import Library
import Prelude
import XCTest

final class CommentRepliesViewControllerTests: TestCase {
  override func setUp() {
    super.setUp()

    AppEnvironment.pushEnvironment(mainBundle: Bundle.framework)
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    UIView.setAnimationsEnabled(true)
    super.tearDown()
  }

  func testViewController_WithRootComment() {
    let devices = [Device.phone4_7inch, Device.pad]
    combos(Language.allLanguages, devices).forEach { language, device in
      withEnvironment(currentUser: .template, language: language) {
        let controller = CommentRepliesViewController
          .configuredWith(comment: .template, project: .template, inputAreaBecomeFirstResponder: true)

        let (parent, _) = traitControllers(
          device: device,
          orientation: .portrait,
          child: controller
        )

        parent.view.frame.size.height = 1_100

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "Comments - lang_\(language)_device_\(device)")
      }
    }
  }

  func testViewController_WithRootCommentAndReplies() {
    let mockService = MockService(
      fetchCommentRepliesEnvelopeResult: .success(CommentRepliesEnvelope.multipleReplyTemplate)
    )
    let devices = [Device.phone4_7inch, Device.pad]
    combos(Language.allLanguages, devices).forEach { language, device in
      withEnvironment(apiService: mockService, currentUser: .template, language: language) {
        let controller = CommentRepliesViewController
          .configuredWith(comment: .template, project: .template, inputAreaBecomeFirstResponder: true)

        let (parent, _) = traitControllers(
          device: device,
          orientation: .portrait,
          child: controller
        )

        parent.view.frame.size.height = 1_100

        self.scheduler.run()
        FBSnapshotVerifyView(parent.view, identifier: "Comments - lang_\(language)_device_\(device)")
      }
    }
  }

  // TODO: When implementing error state of posting `CommentPostFailedCell` are tested here.
}
