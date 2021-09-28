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
          .configuredWith(
            comment: .template,
            project: .template,
            update: nil,
            inputAreaBecomeFirstResponder: true,
            replyId: nil
          )

        let (parent, _) = traitControllers(
          device: device,
          orientation: .portrait,
          child: controller
        )

        parent.view.frame.size.height = 1_100

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "CommentReplies - lang_\(language)_device_\(device)")
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
          .configuredWith(
            comment: .template,
            project: .template,
            update: nil,
            inputAreaBecomeFirstResponder: true,
            replyId: nil
          )

        let (parent, _) = traitControllers(
          device: device,
          orientation: .portrait,
          child: controller
        )

        parent.view.frame.size.height = 1_100

        self.scheduler.run()
        FBSnapshotVerifyView(parent.view, identifier: "CommentReplies - lang_\(language)_device_\(device)")
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
          .configuredWith(
            comment: .template,
            project: .template,
            update: nil,
            inputAreaBecomeFirstResponder: true,
            replyId: nil
          )

        let (parent, _) = traitControllers(
          device: device,
          orientation: .portrait,
          child: controller
        )

        parent.view.frame.size.height = 1_100

        self.scheduler.run()
        FBSnapshotVerifyView(parent.view, identifier: "CommentReplies - lang_\(language)_device_\(device)")
      }
    }
  }

  func testViewController_WithRootCommentAndSuccessFailedRetryingRetrySuccessComments_ShouldDisplayAll() {
    let mockService =
      MockService(fetchCommentRepliesEnvelopeResult: .success(CommentRepliesEnvelope
          .successFailedRetryingRetrySuccessRepliesTemplate))

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach {
      language, device in
      withEnvironment(apiService: mockService, currentUser: .template, language: language) {
        let controller = CommentRepliesViewController
          .configuredWith(
            comment: .template,
            project: .template,
            update: nil,
            inputAreaBecomeFirstResponder: true,
            replyId: nil
          )

        let (parent, _) = traitControllers(
          device: device,
          orientation: .portrait,
          child: controller
        )

        parent.view.frame.size.height = 1_100

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "CommentReplies - lang_\(language)_device_\(device)")
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
          .configuredWith(
            comment: .template,
            project: .template,
            update: nil,
            inputAreaBecomeFirstResponder: true,
            replyId: nil
          )

        let (parent, _) = traitControllers(
          device: device,
          orientation: .portrait,
          child: controller
        )
        parent.view.frame.size.height = 1_100

        self.scheduler.advance()

        withEnvironment(apiService: MockService(fetchCommentRepliesEnvelopeResult: .failure(.couldNotParseJSON))) {
          controller.viewModel.inputs.paginateOrErrorCellWasTapped()

          self.scheduler.advance()

          FBSnapshotVerifyView(parent.view, identifier: "CommentReplies - lang_\(language)_device_\(device)")
        }
      }
    }
  }

  func testViewController_WithRootCommentAndFailureToRequestFirstPage() {
    let mockService = MockService(
      fetchCommentRepliesEnvelopeResult: .failure(.couldNotParseJSON))
    let devices = [Device.phone4_7inch, Device.pad]
    combos(Language.allLanguages, devices).forEach { language, device in
      withEnvironment(apiService: mockService, currentUser: .template, language: language) {
        let controller = CommentRepliesViewController
          .configuredWith(
            comment: .template,
            project: .template,
            update: nil,
            inputAreaBecomeFirstResponder: true,
            replyId: nil
          )

        let (parent, _) = traitControllers(
          device: device,
          orientation: .portrait,
          child: controller
        )
        parent.view.frame.size.height = 1_100

        self.scheduler.advance()

        FBSnapshotVerifyView(parent.view, identifier: "CommentReplies - lang_\(language)_device_\(device)")
      }
    }
  }

  func testInsert_NewComment_ShouldScroll() {
    let (insert, scroll) = commentRepliesRowBehaviour(for: .template, newComment: true)

    XCTAssertTrue(insert)
    XCTAssertTrue(scroll)
  }

  func testReplace_ExistingCommentWithSuccessfulComment_ShouldNotScroll() {
    let (insert, scroll) = commentRepliesRowBehaviour(for: .template, newComment: false)

    XCTAssertFalse(insert)
    XCTAssertFalse(scroll)
  }

  func testReplace_ExistingCommentWithFailedComment_ShouldScroll() {
    let (insert, scroll) = commentRepliesRowBehaviour(for: .replyFailedTemplate, newComment: false)

    XCTAssertFalse(insert)
    XCTAssertTrue(scroll)
  }
}
