@testable import Kickstarter_Framework
@testable import KsApi
import Library
import Prelude
import XCTest

internal final class CommentsViewControllerTests: TestCase {
  override func setUp() {
    super.setUp()
    AppEnvironment.pushEnvironment(mainBundle: Bundle.framework)
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    UIView.setAnimationsEnabled(true)
    super.tearDown()
  }

  func testView_WithFailedRemovedAndSuccessfulComments_ShouldDisplayAll() {
    let mockService =
      MockService(fetchCommentsEnvelopeResult: .success(CommentsEnvelope
          .failedRemovedSuccessfulCommentsTemplate))

    Language.allLanguages.forEach { language in
      withEnvironment(apiService: mockService, currentUser: .template, language: language) {
        let controller = CommentsViewController.configuredWith(project: Project.template)

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

  func testView_CurrentUser_LoggedOut() {
    let mockService =
      MockService(fetchCommentsEnvelopeResult: .success(CommentsEnvelope.multipleCommentTemplate))

    Language.allLanguages.forEach { language in
      withEnvironment(apiService: mockService, currentUser: nil, language: language) {
        let controller = CommentsViewController.configuredWith(project: .template)
        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: controller)

        parent.view.frame.size.height = 1_100

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "Comments - lang_\(language)")
      }
    }
  }

  func testView_CurrentUser_LoggedIn_IsBacking_True() {
    let mockService =
      MockService(fetchCommentsEnvelopeResult: .success(CommentsEnvelope.multipleCommentTemplate))

    let project = Project.template
      |> \.personalization.isBacking .~ true

    Language.allLanguages.forEach { language in
      withEnvironment(apiService: mockService, currentUser: .template, language: language) {
        let controller = CommentsViewController.configuredWith(project: project)
        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 1_100

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "Comments - lang_\(language)")
      }
    }
  }

  func testView_CurrentUser_LoggedIn_IsBacking_False() {
    let mockService =
      MockService(fetchCommentsEnvelopeResult: .success(CommentsEnvelope.multipleCommentTemplate))

    Language.allLanguages.forEach { language in
      withEnvironment(apiService: mockService, currentUser: .template, language: language) {
        let controller = CommentsViewController.configuredWith(project: .template)
        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 1_100

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "Comments - lang_\(language)")
      }
    }
  }

  func testView_CurrentUser_LoggedIn_IsBacking_FeatureFlag_True() {
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.features .~ [OptimizelyFeature.Key.commentFlaggingDisabled.rawValue: true]

    let mockService =
      MockService(fetchCommentsEnvelopeResult: .success(CommentsEnvelope.multipleCommentTemplate))

    let project = Project.template
      |> \.personalization.isBacking .~ true

    Language.allLanguages.forEach { language in
      withEnvironment(
        apiService: mockService,
        currentUser: .template,
        language: language,
        optimizelyClient: mockOptimizelyClient
      ) {
        let controller = CommentsViewController.configuredWith(project: project)
        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 1_100

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "Comments - lang_\(language)")
      }
    }
  }

  func testView_CurrentUser_LoggedIn_IsBacking_FeatureFlag_False() {
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.features .~ [OptimizelyFeature.Key.commentFlaggingDisabled.rawValue: false]

    let mockService =
      MockService(fetchCommentsEnvelopeResult: .success(CommentsEnvelope.multipleCommentTemplate))

    let project = Project.template
      |> \.personalization.isBacking .~ true

    Language.allLanguages.forEach { language in
      withEnvironment(
        apiService: mockService,
        currentUser: .template,
        language: language,
        optimizelyClient: mockOptimizelyClient
      ) {
        let controller = CommentsViewController.configuredWith(project: project)
        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 1_100

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "Comments - lang_\(language)")
      }
    }
  }

  func testView_CurrentUser_LoggedOut_FeatureFlag_True() {
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.features .~ [OptimizelyFeature.Key.commentFlaggingDisabled.rawValue: true]

    let mockService =
      MockService(fetchCommentsEnvelopeResult: .success(CommentsEnvelope.multipleCommentTemplate))

    Language.allLanguages.forEach { language in
      withEnvironment(apiService: mockService, language: language, optimizelyClient: mockOptimizelyClient) {
        let controller = CommentsViewController.configuredWith(project: .template)
        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 1_100

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "Comments - lang_\(language)")
      }
    }
  }
}
