@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class RootCommentCellViewModelTests: TestCase {
  let vm: RootCommentCellViewModelType = RootCommentCellViewModel()

  private let authorBadge = TestObserver<Comment.AuthorBadge, Never>()
  private let authorImageURL = TestObserver<URL, Never>()
  private let authorName = TestObserver<String, Never>()
  private let body = TestObserver<String, Never>()
  private let postTime = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()
    self.vm.outputs.authorBadge.observe(self.authorBadge.observer)
    self.vm.outputs.authorImageURL.observe(self.authorImageURL.observer)
    self.vm.outputs.authorName.observe(self.authorName.observer)
    self.vm.outputs.body.observe(self.body.observer)
    self.vm.outputs.postTime.observe(self.postTime.observer)
  }

  func testAllOutputs_WhenEmitted_HasEmitAllOutputs() {
    let author = Comment.Author.template
      |> \.imageUrl .~ "http://www.kickstarter.com/small.jpg"

    let comment = Comment.template
      |> \.author .~ author

    self.vm.inputs.configureWith(comment: comment)

    self.authorBadge.assertValues([.creator], "The author's badge is emitted.")
    self.authorImageURL.assertValues([URL(string: "http://www.kickstarter.com/small.jpg")!])
    self.authorName.assertValues([comment.author.name], "The author's name is emitted.")
    self.body.assertValues([comment.body], "The comment body is emitted.")
    self.postTime.assertValueCount(1, "The relative time of the comment is emitted.")
  }

  func testPersonalizedLabels_CommentIsFromCreator_HasCreatorAuthorBadge() {
    let comment = Comment.template

    self.vm.inputs.configureWith(comment: comment)
    self.authorBadge.assertValues([.creator], "The author's badge is emitted.")
  }

  func testPersonalizedLabels_CommentIsFromYou_HasYouAuthorBadge() {
    let author = Comment.Author.template
      |> \.id .~ "12345"

    let comment = Comment.template
      |> \.author .~ author
      |> \.authorBadges .~ [.superbacker]

    let user = User.template |> \.id .~ 12_345

    withEnvironment(currentUser: user) {
      self.vm.inputs.configureWith(comment: comment)
      self.authorBadge.assertValues([.you], "The author's badge is emitted.")
    }
  }

  func testPersonalizedLabels_CommentIsFromSuperbacker_HasSuperbackerAuthorBadge() {
    let comment = Comment.superbackerTemplate

    self.vm.inputs.configureWith(comment: comment)
    self.authorBadge.assertValues([.superbacker], "The author's badge is emitted.")
  }

  func testPersonalizedLabels_CommentIsFromBacker_HasBackerAuthorBadge() {
    let comment = Comment.backerTemplate

    self.vm.inputs.configureWith(comment: comment)
    self.authorBadge.assertValues([.backer], "The author's badge is emitted.")
  }

  func testEmitAuthorBadge_HasBindStyles_EmitsAuthorBadge() {
    self.authorBadge.assertDidNotEmitValue()

    self.vm.inputs.configureWith(comment: .template)

    self.authorBadge.assertValues([.creator], "The author's badge is emitted.")

    self.vm.inputs.bindStyles()

    self.authorBadge.assertValues([.creator, .creator], "The author's badge is emitted.")
  }
}
