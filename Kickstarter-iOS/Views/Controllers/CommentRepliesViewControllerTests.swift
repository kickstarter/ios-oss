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

  func testViewController_WithRootCommentNoReplies() {
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

  func testViewController_WithRootCommentAndSuccessfulReplies() {
    let mockService = MockService(
      fetchCommentRepliesEnvelopeResult: .success(CommentRepliesEnvelope.successfulRepliesTemplate)
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

  func testViewController_WithRootCommentAndFailingReplies() {
    let mockService = MockService(
      fetchCommentRepliesEnvelopeResult: .success(CommentRepliesEnvelope.failedAndSuccessRepliesTemplate)
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

  func testViewController_WithRootCommentRepliesandViewMoreRepliesFailedCell() {
    let mockService = MockService(
      fetchCommentRepliesEnvelopeResult: .success(CommentRepliesEnvelope.successfulRepliesTemplate))
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

        self.scheduler.advance()

        withEnvironment(apiService: MockService(fetchCommentRepliesEnvelopeResult: .failure(.couldNotParseJSON))) {
          controller.viewModel.inputs.viewMoreRepliesOrViewMoreRepliesFailedCellWasTapped()

          self.scheduler.advance()

          FBSnapshotVerifyView(parent.view, identifier: "Comments - lang_\(language)_device_\(device)")
        }
      }
    }
  }
}
