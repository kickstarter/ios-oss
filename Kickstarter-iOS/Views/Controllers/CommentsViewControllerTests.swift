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

  func testView_WithFailedRemovedAndSuccessfulComments_ShouldDisplayAll_CommentThreadingRepliesEnabledFeatureFlag_False() {
    let mockService =
      MockService(fetchCommentsEnvelopeResult: .success(CommentsEnvelope
          .failedRemovedSuccessfulCommentsTemplate))

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach {
      language, _ in
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

  func testView_WithFailedRemovedAndSuccessfulComments_ShouldDisplayAll_CommentThreadingRepliesEnabledFeatureFlag_True() {
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.features .~ [OptimizelyFeature.Key.commentThreadingRepliesEnabled.rawValue: true]

    let mockService =
      MockService(fetchCommentsEnvelopeResult: .success(CommentsEnvelope
          .failedRemovedSuccessfulCommentsTemplate))

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach {
      language, _ in
      withEnvironment(
        apiService: mockService,
        currentUser: .template,
        language: language,
        optimizelyClient: mockOptimizelyClient
      ) {
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

  func testView_WithSuccessFailedRetryingRetrySuccessComments_ShouldDisplayAll() {
    let mockService =
      MockService(fetchCommentsEnvelopeResult: .success(CommentsEnvelope
          .successFailedRetryingRetrySuccessCommentsTemplate))

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach {
      language, _ in
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

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach {
      language, _ in
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

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach {
      language, _ in
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

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach {
      language, _ in
      withEnvironment(apiService: mockService, currentUser: .template, language: language) {
        let controller = CommentsViewController.configuredWith(project: .template)
        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 1_100

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "Comments - lang_\(language)")
      }
    }
  }

  func testView_CurrentUser_LoggedIn_PagingError() {
    let mockService =
      MockService(fetchCommentsEnvelopeResult: .success(CommentsEnvelope.multipleCommentTemplate))

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach {
      language, _ in
      withEnvironment(apiService: mockService, currentUser: .template, language: language) {
        let controller = CommentsViewController.configuredWith(project: .template)
        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 600

        self.scheduler.advance()

        withEnvironment(apiService: MockService(fetchCommentsEnvelopeResult: .failure(.couldNotParseJSON))) {
          controller.viewModel.inputs.willDisplayRow(3, outOf: 4)

          self.scheduler.advance()

          FBSnapshotVerifyView(parent.view, identifier: "Comments - lang_\(language)")
        }
      }
    }
  }

  func testView_CurrentUser_LoggedIn_IsBacking_CommentFlaggingEnabledFeatureFlag_True() {
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.features .~ [OptimizelyFeature.Key.commentFlaggingEnabled.rawValue: true]

    let mockService =
      MockService(fetchCommentsEnvelopeResult: .success(CommentsEnvelope.multipleCommentTemplate))

    let project = Project.template
      |> \.personalization.isBacking .~ true

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach {
      language, _ in
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

  func testView_CurrentUser_LoggedIn_IsBacking_CommentThreadingRepliesEnabledFeatureFlag_True() {
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.features .~ [OptimizelyFeature.Key.commentThreadingRepliesEnabled.rawValue: true]

    let mockService =
      MockService(fetchCommentsEnvelopeResult: .success(CommentsEnvelope.multipleCommentTemplate))

    let project = Project.template
      |> \.personalization.isBacking .~ true

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach {
      language, _ in
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

  func testView_CurrentUser_LoggedIn_IsBacking_CommentFlaggingEnabledFeatureFlag_False() {
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.features .~ [OptimizelyFeature.Key.commentFlaggingEnabled.rawValue: false]

    let mockService =
      MockService(fetchCommentsEnvelopeResult: .success(CommentsEnvelope.multipleCommentTemplate))

    let project = Project.template
      |> \.personalization.isBacking .~ true

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach {
      language, _ in
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

  func testView_CurrentUser_LoggedIn_IsBacking_CommentThreadingRepliesEnabledFeatureFlag_False() {
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.features .~ [OptimizelyFeature.Key.commentThreadingRepliesEnabled.rawValue: false]

    let mockService =
      MockService(fetchCommentsEnvelopeResult: .success(CommentsEnvelope.multipleCommentTemplate))

    let project = Project.template
      |> \.personalization.isBacking .~ true

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach {
      language, _ in
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

  func testView_CurrentUser_LoggedOut_CommentFlaggingEnabledFeatureFlag_True() {
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.features .~ [OptimizelyFeature.Key.commentFlaggingEnabled.rawValue: true]

    let mockService =
      MockService(fetchCommentsEnvelopeResult: .success(CommentsEnvelope.multipleCommentTemplate))

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach {
      language, _ in
      withEnvironment(apiService: mockService, language: language, optimizelyClient: mockOptimizelyClient) {
        let controller = CommentsViewController.configuredWith(project: .template)
        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 1_100

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "Comments - lang_\(language)")
      }
    }
  }

  func testView_CurrentUser_LoggedOut_CommentThreadingRepliesEnabledFeatureFlag_True() {
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.features .~ [OptimizelyFeature.Key.commentThreadingRepliesEnabled.rawValue: true]

    let mockService =
      MockService(fetchCommentsEnvelopeResult: .success(CommentsEnvelope.multipleCommentTemplate))

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach {
      language, _ in
      withEnvironment(apiService: mockService, language: language, optimizelyClient: mockOptimizelyClient) {}
    }
  }

  func testView_NoComments_ShouldShowEmptyState() {
    AppEnvironment.pushEnvironment(
      apiService: MockService(
        fetchCommentsEnvelopeResult: .success(CommentsEnvelope.emptyCommentsTemplate)
      ),
      currentUser: User.template,
      mainBundle: Bundle.framework
    )

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach {
      language, _ in
      withEnvironment(currentUser: .template, language: language) {
        let controller = CommentsViewController.configuredWith(project: .template)
        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 1_100

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "Comments - lang_\(language)")
      }
    }
  }

  func testView_NoComments_ShouldShowErrorState() {
    AppEnvironment.pushEnvironment(
      apiService: MockService(
        fetchCommentsEnvelopeResult: .failure(.couldNotParseJSON)
      ),
      currentUser: User.template,
      mainBundle: Bundle.framework
    )

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach {
      language, _ in
      withEnvironment(currentUser: .template, language: language) {
        let controller = CommentsViewController.configuredWith(project: .template)
        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 1_100

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "Comments - lang_\(language)")
      }
    }
  }

  func testCommentsViewController_Optimizely_FeatureFlag_True() {
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.features .~ [OptimizelyFeature.Key.commentThreading.rawValue: true]

    let mockService = MockService(fetchProjectResponse: .template)

    withEnvironment(
      apiService: mockService, optimizelyClient: mockOptimizelyClient
    ) {
      XCTAssert(commentsViewController(for: .template).isKind(of: CommentsViewController.self))
    }
  }

  func testCommentsViewController_Optimizely_FeatureFlag_False() {
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.features .~ [OptimizelyFeature.Key.commentThreading.rawValue: false]

    let mockService = MockService(fetchProjectResponse: .template)

    withEnvironment(
      apiService: mockService, optimizelyClient: mockOptimizelyClient
    ) {
      XCTAssert(commentsViewController(for: .template).isKind(of: DeprecatedCommentsViewController.self))
    }
  }
}
