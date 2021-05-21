@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class CommentCellViewModelTests: TestCase {
  let vm: CommentCellViewModelType = CommentCellViewModel()

  let avatarImageURL = TestObserver<URL?, Never>()
  let body = TestObserver<String, Never>()
  let authorName = TestObserver<String, Never>()
  let postTime = TestObserver<String, Never>()
  let authorBadge = TestObserver<Comment.AuthorBadge, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.avatarImageURL.observe(self.avatarImageURL.observer)
    self.vm.outputs.body.observe(self.body.observer)
    self.vm.outputs.authorName.observe(self.authorName.observer)
    self.vm.outputs.postTime.observe(self.postTime.observer)
    self.vm.outputs.authorBadge.observe(self.authorBadge.observer)
  }

  func testOutputs() {
    let comment = Comment.template
    let viewer = User.template |> \.id .~ 12_345

    self.vm.inputs.configureWith(comment: comment, viewer: viewer)

    self.avatarImageURL.assertValueCount(1, "An avatar is emitted.")
    self.body.assertValues([comment.body], "The comment body is emitted.")
    self.authorName.assertValues([comment.author.name], "The author's name is emitted.")
    self.postTime.assertValueCount(1, "The relative time of the comment is emitted.")
    self.authorBadge.assertValues([comment.authorBadge], "The author's tag for the comment is emitted.")
  }

  func testOutputs_ViewerIs_LoggedOut() {
    let comment = Comment.template

    self.vm.inputs.configureWith(comment: comment, viewer: nil)

    self.avatarImageURL.assertValueCount(1, "An avatar is emitted.")
    self.body.assertValues([comment.body], "The comment body is emitted.")
    self.authorName.assertValues([comment.author.name], "The author's name is emitted.")
    self.postTime.assertValueCount(1, "The relative time of the comment is emitted.")
    self.authorBadge.assertValues([comment.authorBadge], "The author's tag for the comment is emitted.")
  }

  func testPersonalizedLabels_ViewerIs_Creator_Author() {
    let comment = Comment.template
      |> Comment.lens.authorBadges .~ [.creator]

    let viewer = User.template |> \.id .~ 12_345

    self.vm.inputs.configureWith(comment: comment, viewer: viewer)

    self.authorBadge.assertValues([.creator], "The author badge tag is creator.")
  }

  func testPersonalizedLabels_Viewer_Is_You_Author() {
    let author = Comment.Author.template
      |> \.id .~ "12345"

    let comment = Comment.template
      |> \.author .~ author

    let viewer = User.template |> \.id .~ 12_345

    self.vm.inputs.configureWith(comment: comment, viewer: viewer)

    self.authorBadge.assertValues([.you], "The author badge tag is you.")
  }

  func testPersonalizedLabels_ViewerIs_Superbacker_Author() {
    let comment = Comment.template
      |> Comment.lens.authorBadges .~ [.superbacker]

    let viewer = User.template |> \.id .~ 12_345

    self.vm.inputs.configureWith(comment: comment, viewer: viewer)

    self.authorBadge.assertValues([.superbacker], "The author badge tag is superbacker.")
  }

  func testPersonalizedLabels_ViewerIs_Backer_Author() {
    let comment = Comment.template
      |> Comment.lens.authorBadges .~ nil

    let viewer = User.template |> \.id .~ 12_345

    self.vm.inputs.configureWith(comment: comment, viewer: viewer)

    self.authorBadge.assertValues([.backer], "The author badge tag is backer.")
  }
}
