@testable import Kickstarter_Framework
@testable import KsApi
import Library
import Prelude
import SnapshotTesting
import XCTest

internal final class CommentsViewControllerTests: TestCase {
  override func setUp() {
    super.setUp()
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    UIView.setAnimationsEnabled(true)
    super.tearDown()
  }

  func testView_WithFailedRemovedAndSuccessfulComments_ShouldDisplayAll_Success() {
    let mockService =
      MockService(fetchProjectCommentsEnvelopeResult: .success(
        CommentsEnvelope
          .failedRemovedSuccessfulCommentsTemplate
      ))

    orthogonalCombos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach {
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

        assertSnapshot(
          matching: parent.view,
          as: .image(perceptualPrecision: 0.99),
          named: "Comments - lang_\(language)_device_\(device)"
        )
      }
    }
  }

  func testView_WithSuccessFailedRetryingRetrySuccessComments_ShouldDisplayAll() {
    let mockService =
      MockService(fetchProjectCommentsEnvelopeResult: .success(
        CommentsEnvelope
          .successFailedRetryingRetrySuccessCommentsTemplate
      ))

    orthogonalCombos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach {
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

        assertSnapshot(
          matching: parent.view,
          as: .image(perceptualPrecision: 0.99),
          named: "Comments - lang_\(language)_device_\(device)"
        )
      }
    }
  }

  func testView_CurrentUser_LoggedOut() {
    let mockService =
      MockService(fetchProjectCommentsEnvelopeResult: .success(CommentsEnvelope.multipleCommentTemplate))

    orthogonalCombos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach {
      language, device in
      withEnvironment(apiService: mockService, currentUser: nil, language: language) {
        let controller = CommentsViewController.configuredWith(project: .template)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        parent.view.frame.size.height = 1_100

        self.scheduler.run()

        assertSnapshot(
          matching: parent.view,
          as: .image(perceptualPrecision: 0.99),
          named: "Comments - lang_\(language)_device_\(device)"
        )
      }
    }
  }

  func testView_CurrentUser_LoggedIn_IsBacking_True() {
    let mockService =
      MockService(fetchProjectCommentsEnvelopeResult: .success(CommentsEnvelope.multipleCommentTemplate))

    let project = Project.template
      |> \.personalization.isBacking .~ true

    orthogonalCombos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach {
      language, device in
      withEnvironment(apiService: mockService, currentUser: .template, language: language) {
        let controller = CommentsViewController.configuredWith(project: project)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 1_100

        self.scheduler.run()

        assertSnapshot(
          matching: parent.view,
          as: .image(perceptualPrecision: 0.99),
          named: "Comments - lang_\(language)_device_\(device)"
        )
      }
    }
  }

  func testView_CurrentUser_LoggedIn_IsBacking_False() {
    let mockService =
      MockService(fetchProjectCommentsEnvelopeResult: .success(CommentsEnvelope.multipleCommentTemplate))

    orthogonalCombos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach {
      language, device in
      withEnvironment(apiService: mockService, currentUser: .template, language: language) {
        let controller = CommentsViewController.configuredWith(project: .template)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 1_100

        self.scheduler.run()

        assertSnapshot(
          matching: parent.view,
          as: .image(perceptualPrecision: 0.99),
          named: "Comments - lang_\(language)_device_\(device)"
        )
      }
    }
  }

  func testView_CurrentUser_LoggedIn_PagingError() {
    let mockService =
      MockService(fetchProjectCommentsEnvelopeResult: .success(CommentsEnvelope.multipleCommentTemplate))

    orthogonalCombos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach {
      language, device in
      withEnvironment(apiService: mockService, currentUser: .template, language: language) {
        let controller = CommentsViewController.configuredWith(project: .template)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 600

        self.scheduler.advance()

        withEnvironment(
          apiService: MockService(fetchProjectCommentsEnvelopeResult: .failure(.couldNotParseJSON))
        ) {
          controller.viewModel.inputs.willDisplayRow(3, outOf: 4)

          self.scheduler.advance()

          assertSnapshot(
            matching: parent.view,
            as: .image(perceptualPrecision: 0.99),
            named: "Comments - lang_\(language)_device_\(device)"
          )
        }
      }
    }
  }

  func testView_NoComments_ShouldShowEmptyState() {
    AppEnvironment.pushEnvironment(
      apiService: MockService(
        fetchProjectCommentsEnvelopeResult: .success(CommentsEnvelope.emptyCommentsTemplate)
      ),
      currentUser: User.template
    )

    orthogonalCombos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach {
      language, device in
      withEnvironment(currentUser: .template, language: language) {
        let controller = CommentsViewController.configuredWith(project: .template)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 1_100

        self.scheduler.run()

        assertSnapshot(
          matching: parent.view,
          as: .image(perceptualPrecision: 0.99),
          named: "Comments - lang_\(language)_device_\(device)"
        )
      }
    }
  }

  func testView_NoComments_ShouldShowErrorState() {
    AppEnvironment.pushEnvironment(
      apiService: MockService(
        fetchProjectCommentsEnvelopeResult: .failure(.couldNotParseJSON)
      ),
      currentUser: User.template
    )

    orthogonalCombos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach {
      language, device in
      withEnvironment(currentUser: .template, language: language) {
        let controller = CommentsViewController.configuredWith(project: .template)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        self.scheduler.run()

        assertSnapshot(
          matching: parent.view,
          as: .image(perceptualPrecision: 0.99),
          named: "Comments - lang_\(language)_device_\(device)"
        )
      }
    }
  }

  func testCommentsViewControllerCreation_Success() {
    let mockService = MockService(fetchProjectResult: .success(.template))

    withEnvironment(
      apiService: mockService
    ) {
      XCTAssert(commentsViewController(for: .template).isKind(of: CommentsViewController.self))
    }
  }

  func testView_WithFlaggedComments() {
    let mockService =
      MockService(fetchProjectCommentsEnvelopeResult: .success(
        CommentsEnvelope
          .flaggedCommentsTemplate
      ))

    orthogonalCombos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach {
      language, device in
      withEnvironment(apiService: mockService, currentUser: .template, language: language) {
        let controller = CommentsViewController.configuredWith(project: .template)

        let (parent, _) = traitControllers(
          device: device,
          orientation: .portrait,
          child: controller
        )

        self.scheduler.run()

        assertSnapshot(
          matching: parent.view,
          as: .image(perceptualPrecision: 0.99),
          named: "Comments - lang_\(language)_device_\(device)"
        )
      }
    }
  }
}
