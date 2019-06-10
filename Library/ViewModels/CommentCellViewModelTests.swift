@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class CommentCellViewModelTest: TestCase {
  let vm: CommentCellViewModelType = CommentCellViewModel()

  let avatarUrl = TestObserver<URL?, Never>()
  let body = TestObserver<String, Never>()
  let bodyColor = TestObserver<UIColor, Never>()
  let bodyFont = TestObserver<UIFont, Never>()
  let creatorHidden = TestObserver<Bool, Never>()
  let commenterName = TestObserver<String, Never>()
  let timestamp = TestObserver<String, Never>()
  let youHidden = TestObserver<Bool, Never>()

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
    let project = .template |> Project.lens.creator.id .~ 222
    let viewer = User.template |> \.id .~ 12_345

    self.vm.inputs.comment(comment, project: project, viewer: viewer)

    self.avatarUrl.assertValueCount(1, "An avatar is emitted.")
    self.body.assertValues([comment.body], "The comment body is emitted.")
    self.bodyColor.assertValueCount(1, "A body color is emitted.")
    self.bodyFont.assertValueCount(1, "A body font is emitted.")
    self.creatorHidden.assertValues([true], "The creator tag is hidden.")
    self.commenterName.assertValues([comment.author.name], "The author's name is emitted.")
    self.timestamp.assertValueCount(1, "A timestamp is emitted.")
    self.youHidden.assertValues([true], "The you tag is hidden.")
  }

  func testOutputs_ViewerIs_LoggedOut() {
    let comment = Comment.template
    let project = .template |> Project.lens.creator.id .~ 222

    self.vm.inputs.comment(comment, project: project, viewer: nil)

    self.avatarUrl.assertValueCount(1, "An avatar is emitted.")
    self.body.assertValues([comment.body], "The comment body is emitted.")
    self.bodyColor.assertValueCount(1, "A body color is emitted.")
    self.bodyFont.assertValueCount(1, "A body font is emitted.")
    self.creatorHidden.assertValues([true], "The creator tag is hidden.")
    self.commenterName.assertValues([comment.author.name], "The author's name is emitted.")
    self.timestamp.assertValueCount(1, "A timestamp is emitted.")
    self.youHidden.assertValues([true], "The you tag is hidden.")
  }

  func testPersonalizedLabels_ViewerIs_NotCreator_NotAuthor() {
    let comment = Comment.template
    let project = .template |> Project.lens.creator.id .~ 222
    let viewer = User.template |> \.id .~ 12_345

    self.vm.inputs.comment(comment, project: project, viewer: viewer)

    self.creatorHidden.assertValues([true], "The creator tag is hidden.")
    self.youHidden.assertValues([true], "The you tag is hidden.")
  }

  func testPersonalizedLabels_ViewerIs_NotCreator_Author() {
    let author = Author.template |> \.id .~ 12_345
    let viewer = User.template |> \.id .~ author.id
    let comment = Comment(
      author: author,
      body: "HELLO",
      createdAt: 123_456_789.0,
      deletedAt: nil,
      id: 1
    )
    let project = Project.template

    self.vm.inputs.comment(comment, project: project, viewer: viewer)

    self.creatorHidden.assertValues([true], "The creator tag is hidden.")
    self.youHidden.assertValues([false], "The you tag is shown.")
  }

  func testPersonalizedLabels_ViewerIs_Creator_Author() {
    let project = Project.template
    let author = Author.template
      |> \.id .~ project.creator.id

    let comment = Comment(
      author: author,
      body: "HELLO",
      createdAt: 123_456_789.0,
      deletedAt: nil,
      id: 1
    )
    let viewer = User.template
      |> \.id .~ project.creator.id

    self.vm.inputs.comment(comment, project: project, viewer: viewer)

    self.creatorHidden.assertValues([false], "Creator tag is shown instead of You tag.")
    self.youHidden.assertValues([true], "You tag is hidden.")
  }

  func testPersonalizedLabels_ViewerIs_Creator_NonAuthor() {
    let project = .template |> Project.lens.creator.id .~ 11_111
    let comment = Comment(
      author: Author.template |> \.id .~ 12_345,
      body: "HELLO",
      createdAt: 123_456_789.0,
      deletedAt: nil,
      id: 1
    )
    let viewer = project.creator

    self.vm.inputs.comment(comment, project: project, viewer: viewer)

    self.creatorHidden.assertValues([true], "Creator tag is hidden for non-authored comment.")
    self.youHidden.assertValues([true], "You tag is hidden.")
  }

  func testDeletedComment() {
    let comment = .template |> Comment.lens.deletedAt .~ 123_456_789.0
    let project = .template |> Project.lens.creator.id .~ 11_111
    let viewer = User.template |> \.id .~ 12_345

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
