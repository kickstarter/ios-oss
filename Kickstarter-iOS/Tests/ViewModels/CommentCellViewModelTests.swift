import XCTest
@testable import Library
@testable import Kickstarter_iOS
@testable import ReactiveExtensions_TestHelpers
@testable import Models
@testable import Models_TestHelpers
import ReactiveCocoa
import Result
import Prelude

final class CommentCellViewModelTest: TestCase {
  let vm: CommentCellViewModelType = CommentCellViewModel()

  let avatarUrl = TestObserver<NSURL?, NoError>()
  let body = TestObserver<String, NoError>()
  let bodyColor = TestObserver<UIColor, NoError>()
  let bodyFont = TestObserver<UIFont, NoError>()
  let creatorHidden = TestObserver<Bool, NoError>()
  let commenterName = TestObserver<String, NoError>()
  let timestamp = TestObserver<String, NoError>()
  let youHidden = TestObserver<Bool, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.avatarUrl.observe(self.avatarUrl.observer)
    self.vm.outputs.body.observe(self.body.observer)
    self.vm.outputs.bodyColor.observe(self.bodyColor.observer)
    self.vm.outputs.bodyFont.observe(self.bodyFont.observer)
    self.vm.outputs.creatorHidden.observe(self.creatorHidden.observer)
    self.vm.outputs.name.observe(self.commenterName.observer)
    self.vm.outputs.timestamp.observe(self.timestamp.observer)
    self.vm.outputs.youHidden.observe(self.youHidden.observer)
  }

  func testOutputs() {
    let comment = Comment.template
    let project = Project.template
    let viewer = User.template |> User.lens.id *~ 12345

    self.vm.inputs.comment(comment, project: project, viewer: viewer)

    self.avatarUrl.assertValueCount(1, "An avatar is emitted.")
    self.body.assertValues([comment.body], "The comment body is emitted.")
    self.bodyColor.assertValueCount(1, "A body color is emitted.")
    self.bodyFont.assertValueCount(1, "A body font is emitted.")
    self.creatorHidden.assertValues([true], "The creator tag is hidden.")
    self.commenterName.assertValues([comment.author.name], "The author's name is emitted.")
    self.timestamp.assertValueCount(1, "A timestamp is emitted.")
    self.youHidden.assertValues([true], "The you tab is hidden.")
  }

  func testOutputs_ViewerIs_LoggedOut() {
    let comment = Comment.template
    let project = Project.template

    self.vm.inputs.comment(comment, project: project, viewer: nil)

    self.avatarUrl.assertValueCount(1, "An avatar is emitted.")
    self.body.assertValues([comment.body], "The comment body is emitted.")
    self.bodyColor.assertValueCount(1, "A body color is emitted.")
    self.bodyFont.assertValueCount(1, "A body font is emitted.")
    self.creatorHidden.assertValues([true], "The creator tag is hidden.")
    self.commenterName.assertValues([comment.author.name], "The author's name is emitted.")
    self.timestamp.assertValueCount(1, "A timestamp is emitted.")
    self.youHidden.assertValues([true], "The you tab is hidden.")
  }

  func testPersonalizedLabels_ViewerIs_NotCreator_NotAuthor() {
    let comment = Comment.template
    let project = Project.template
    let viewer = User.template |> User.lens.id *~ 12345

    self.vm.inputs.comment(comment, project: project, viewer: viewer)

    self.creatorHidden.assertValues([true], "The creator tag is hidden.")
    self.youHidden.assertValues([true], "The you tag is hidden.")
  }

  func testPersonalizedLabels_ViewerIs_NotCreator_Author() {
    let comment = Comment(author: User.template |> User.lens.id *~ 12345,
                          body: "HELLO",
                          createdAt: 123456789.0,
                          deletedAt: nil,
                          id: 1)
    let project = Project.template
    let viewer = comment.author

    self.vm.inputs.comment(comment, project: project, viewer: viewer)

    self.creatorHidden.assertValues([true], "The creator tag is hidden.")
    self.youHidden.assertValues([false], "The you tag is shown.")
  }

  func testPersonalizedLabels_ViewerIs_Creator_Author() {
    let project = Project.template
    let comment = Comment(author: project.creator,
                          body: "HELLO",
                          createdAt: 123456789.0,
                          deletedAt: nil,
                          id: 1)
    let viewer = comment.author

    self.vm.inputs.comment(comment, project: project, viewer: viewer)

    self.creatorHidden.assertValues([true], "Creator tag is hidden.")
    self.youHidden.assertValues([false], "You tag is shown instead of creator tag.")
  }

  func testPersonalizedLabels_ViewerIs_Creator_NonAuthor() {
    let project = Project.template
    let comment = Comment(author: User.template |> User.lens.id *~ 12345,
                          body: "HELLO",
                          createdAt: 123456789.0,
                          deletedAt: nil,
                          id: 1)
    let viewer = project.creator

    self.vm.inputs.comment(comment, project: project, viewer: viewer)

    self.creatorHidden.assertValues([false], "Creator take is shown.")
    self.youHidden.assertValues([true], "You tag is hidden.")
  }

  func testDeletedComment() {
    let comment = Comment.template |> Comment.lens.deletedAt *~ 123456789.0
    let project = Project.template
    let viewer = User.template |> User.lens.id *~ 12345

    self.vm.inputs.comment(comment, project: project, viewer: viewer)

    self.avatarUrl.assertValueCount(1)
    self.body.assertValues([comment.body])
    self.bodyColor.assertValueCount(1)
    self.bodyFont.assertValueCount(1)
    self.creatorHidden.assertValues([true])
    self.commenterName.assertValues([comment.author.name])
    self.timestamp.assertValueCount(1)
    self.youHidden.assertValues([true])
  }
}
