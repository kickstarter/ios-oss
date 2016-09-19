import Library
import Prelude
import Result
import XCTest
@testable import Kickstarter_Framework
@testable import KsApi

internal final class CommentsViewControllerTests: TestCase {

  override func setUp() {
    super.setUp()
    UIView.setAnimationsEnabled(false)
  }

  func testView() {
    let backer = User.brando
      |> User.lens.avatar.large .~ ""
      |> User.lens.avatar.medium .~ ""
      |> User.lens.avatar.small .~ ""

    let creator = .template
      |> User.lens.id .~ 808
      |> User.lens.name .~ "Native Squad"

    let project = .template
      |> Project.lens.creator .~ creator

    let defaultComment = .template
      |> Comment.lens.createdAt .~ 1473461640

    let backerComment = .template
      |> Comment.lens.author .~ backer
      |> Comment.lens.body .~ "I have never seen such a beautiful project."
      |> Comment.lens.createdAt .~ 1473461640

    let creatorComment = .template
      |> Comment.lens.author .~ creator
      |> Comment.lens.body .~ "Thank you kindly for your feedback!"
      |> Comment.lens.createdAt .~ 1473461640

    let deletedComment = .template
      |> Comment.lens.author .~ (.template |> User.lens.name .~ "Naughty Blob")
      |> Comment.lens.body .~ "This comment has been deleted by Kickstarter."
      |> Comment.lens.createdAt .~ 1473461640
      |> Comment.lens.deletedAt .~ 1473461640

    let comments = [defaultComment, backerComment, creatorComment, deletedComment]

    AppEnvironment.pushEnvironment(
      apiService: MockService(
        fetchCommentsResponse: comments
      ),
      currentUser: backer,
      mainBundle: NSBundle.framework
    )

    Language.allLanguages.forEach { language in
      withEnvironment(language: language) {
        let controller = CommentsViewController.configuredWith(project: project)
        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 600

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "Comments - lang_\(language)")
      }
    }

    AppEnvironment.popEnvironment()
  }
}
