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

  func testViewController_WithComment_HasRootComment() {
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

  func testView_CurrentUser_LoggedOut() {
    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach {
      language, _ in
      withEnvironment(currentUser: nil, language: language) {
        let controller = CommentRepliesViewController.configuredWith(comment: .template, project: .template)
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

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach {
      language, _ in
      withEnvironment(currentUser: .template, language: language) {
        let controller = CommentRepliesViewController.configuredWith(comment: .template, project: project)
        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 1_100

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "Comments - lang_\(language)")
      }
    }
  }

  func testView_CurrentUser_LoggedIn_IsBacking_False() {
    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach {
      language, _ in
      withEnvironment(currentUser: .template, language: language) {
        let controller = CommentRepliesViewController.configuredWith(comment: .template, project: .template)
        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 1_100

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "Comments - lang_\(language)")
      }
    }
  }
}
