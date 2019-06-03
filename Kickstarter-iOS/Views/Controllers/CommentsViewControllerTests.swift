@testable import Kickstarter_Framework
@testable import KsApi
import Library
import Prelude
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

  func testView() {
    let backer = User.brando
      |> \.avatar.large .~ ""
      |> \.avatar.medium .~ ""
      |> \.avatar.small .~ ""

    let author = Author.template
      |> \.id .~ backer.id
      |> \.name .~ backer.name

    let creator = User.template
      |> \.id .~ 808
      |> \.name .~ "Native Squad"

    let project = .template
      |> Project.lens.creator .~ creator

    let defaultComment = .template
      |> Comment.lens.createdAt .~ 1_473_461_640

    let backerComment = .template
      |> Comment.lens.author .~ author
      |> Comment.lens.body .~ "I have never seen such a beautiful project."
      |> Comment.lens.createdAt .~ 1_473_461_640

    let creatorComment = .template
      |> Comment.lens.author .~ (author |> \.id .~ creator.id)
      |> Comment.lens.body .~ "Thank you kindly for your feedback!"
      |> Comment.lens.createdAt .~ 1_473_461_640

    let deletedComment = .template
      |> Comment.lens.author .~ (.template |> \.name .~ "Naughty Blob")
      |> Comment.lens.body .~ "This comment has been deleted by Kickstarter."
      |> Comment.lens.createdAt .~ 1_473_461_640
      |> Comment.lens.deletedAt .~ 1_473_461_640

    let comments = [defaultComment, backerComment, creatorComment, deletedComment]

    AppEnvironment.pushEnvironment(
      apiService: MockService(
        fetchCommentsResponse: comments
      ),
      currentUser: backer,
      mainBundle: Bundle.framework
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
