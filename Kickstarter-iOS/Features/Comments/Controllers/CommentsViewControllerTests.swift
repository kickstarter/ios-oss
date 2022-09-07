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

  func testView_WithFailedRemovedAndSuccessfulComments_ShouldDisplayAll_Success() {
    let mockService =
      MockService(fetchProjectCommentsEnvelopeResult: .success(CommentsEnvelope
          .failedRemovedSuccessfulCommentsTemplate))

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach {
      language, device in
      withEnvironment(apiService: mockService, currentUser: .template, language: language) {
        let controller = CommentsViewController.configuredWith(project: .template)

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

  func testView_WithSuccessFailedRetryingRetrySuccessComments_ShouldDisplayAll() {
    let mockService =
      MockService(fetchProjectCommentsEnvelopeResult: .success(CommentsEnvelope
          .successFailedRetryingRetrySuccessCommentsTemplate))

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach {
      language, device in
      withEnvironment(apiService: mockService, currentUser: .template, language: language) {
        let controller = CommentsViewController.configuredWith(project: Project.template)

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

  func testView_CurrentUser_LoggedOut() {
    let mockService =
      MockService(fetchProjectCommentsEnvelopeResult: .success(CommentsEnvelope.multipleCommentTemplate))

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach {
      language, device in
      withEnvironment(apiService: mockService, currentUser: nil, language: language) {
        let controller = CommentsViewController.configuredWith(project: .template)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        parent.view.frame.size.height = 1_100

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "Comments - lang_\(language)_device_\(device)")
      }
    }
  }

  func testView_CurrentUser_LoggedIn_IsBacking_True() {
    let mockService =
      MockService(fetchProjectCommentsEnvelopeResult: .success(CommentsEnvelope.multipleCommentTemplate))

    let project = Project.template
      |> \.personalization.isBacking .~ true

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach {
      language, device in
      withEnvironment(apiService: mockService, currentUser: .template, language: language) {
        let controller = CommentsViewController.configuredWith(project: project)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 1_100

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "Comments - lang_\(language)_device_\(device)")
      }
    }
  }

  func testView_CurrentUser_LoggedIn_IsBacking_False() {
    let mockService =
      MockService(fetchProjectCommentsEnvelopeResult: .success(CommentsEnvelope.multipleCommentTemplate))

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach {
      language, device in
      withEnvironment(apiService: mockService, currentUser: .template, language: language) {
        let controller = CommentsViewController.configuredWith(project: .template)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 1_100

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "Comments - lang_\(language)_device_\(device)")
      }
    }
  }

  func testView_CurrentUser_LoggedIn_PagingError() {
    let mockService =
      MockService(fetchProjectCommentsEnvelopeResult: .success(CommentsEnvelope.multipleCommentTemplate))

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach {
      language, device in
      withEnvironment(apiService: mockService, currentUser: .template, language: language) {
        let controller = CommentsViewController.configuredWith(project: .template)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 600

        self.scheduler.advance()

        withEnvironment(apiService: MockService(fetchProjectCommentsEnvelopeResult: .failure(.couldNotParseJSON))) {
          controller.viewModel.inputs.willDisplayRow(3, outOf: 4)

          self.scheduler.advance()

          FBSnapshotVerifyView(parent.view, identifier: "Comments - lang_\(language)_device_\(device)")
        }
      }
    }
  }

  func testView_CurrentUser_LoggedIn_IsBacking_CommentFlaggingEnabledFeatureFlag_True() {
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.features .~ [OptimizelyFeature.commentFlaggingEnabled.rawValue: true]

    let mockService =
      MockService(fetchProjectCommentsEnvelopeResult: .success(CommentsEnvelope.multipleCommentTemplate))

    let project = Project.template
      |> \.personalization.isBacking .~ true

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach {
      language, device in
      withEnvironment(
        apiService: mockService,
        currentUser: .template,
        language: language,
        optimizelyClient: mockOptimizelyClient
      ) {
        let controller = CommentsViewController.configuredWith(project: project)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 1_100

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "Comments - lang_\(language)_device_\(device)")
      }
    }
  }

  func testView_CurrentUser_LoggedIn_IsBacking_CommentFlaggingEnabledFeatureFlag_False() {
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.features .~ [OptimizelyFeature.commentFlaggingEnabled.rawValue: false]

    let mockService =
      MockService(fetchProjectCommentsEnvelopeResult: .success(CommentsEnvelope.multipleCommentTemplate))

    let project = Project.template
      |> \.personalization.isBacking .~ true

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach {
      language, device in
      withEnvironment(
        apiService: mockService,
        currentUser: .template,
        language: language,
        optimizelyClient: mockOptimizelyClient
      ) {
        let controller = CommentsViewController.configuredWith(project: project)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 1_100

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "Comments - lang_\(language)_device_\(device)")
      }
    }
  }

  func testView_NoComments_ShouldShowEmptyState() {
    AppEnvironment.pushEnvironment(
      apiService: MockService(
        fetchProjectCommentsEnvelopeResult: .success(CommentsEnvelope.emptyCommentsTemplate)
      ),
      currentUser: User.template,
      mainBundle: Bundle.framework
    )

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach {
      language, device in
      withEnvironment(currentUser: .template, language: language) {
        let controller = CommentsViewController.configuredWith(project: .template)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 1_100

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "Comments - lang_\(language)_device_\(device)")
      }
    }
  }

  func testView_NoComments_ShouldShowErrorState() {
    AppEnvironment.pushEnvironment(
      apiService: MockService(
        fetchProjectCommentsEnvelopeResult: .failure(.couldNotParseJSON)
      ),
      currentUser: User.template,
      mainBundle: Bundle.framework
    )

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach {
      language, device in
      withEnvironment(currentUser: .template, language: language) {
        let controller = CommentsViewController.configuredWith(project: .template)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "Comments - lang_\(language)_device_\(device)")
      }
    }
  }

  func testCommentsViewControllerCreation_Success() {
    let mockOptimizelyClient = MockOptimizelyClient()
    let mockService = MockService(fetchProjectResult: .success(.template))

    withEnvironment(
      apiService: mockService, optimizelyClient: mockOptimizelyClient
    ) {
      XCTAssert(commentsViewController(for: .template).isKind(of: CommentsViewController.self))
    }
  }
}
