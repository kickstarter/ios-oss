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
    AppEnvironment.pushEnvironment(
      apiService: MockService(
        fetchCommentsEnvelopeResult: .success(CommentsEnvelope.failedRemovedSuccessfulCommentsTemplate)
      ),
      currentUser: User.template,
      mainBundle: Bundle.framework
    )

    Language.allLanguages.forEach { language in
      withEnvironment(language: language) {
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
    Language.allLanguages.forEach { language in
      withEnvironment(currentUser: nil, language: language) {
        let controller = CommentsViewController.configuredWith(project: .template)
        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: controller)

        parent.view.frame.size.height = 1_100

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "Comments - lang_\(language)")
      }
    }
  }

  func testView_CurrentUser_LoggedIn_IsBacking_True() {
    let project = Project.template
      |> \.personalization.isBacking .~ true

    Language.allLanguages.forEach { language in
      withEnvironment(currentUser: .template, language: language) {
        let controller = CommentsViewController.configuredWith(project: project)
        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 1_100

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "Comments - lang_\(language)")
      }
    }
  }

  func testView_CurrentUser_LoggedIn_IsBacking_False() {
    Language.allLanguages.forEach { language in
      withEnvironment(currentUser: .template, language: language) {
        let controller = CommentsViewController.configuredWith(project: .template)
        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 1_100

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "Comments - lang_\(language)")
      }
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
    
    Language.allLanguages.forEach { language in
      withEnvironment(currentUser: .template, language: language) {
        let controller = CommentsViewController.configuredWith(project: .template)
        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 1_100

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "Comments - lang_\(language)")
      }
    }
  }
}
