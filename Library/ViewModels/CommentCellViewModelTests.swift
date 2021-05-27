@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class CommentCellViewModelTests: TestCase {
  let vm: CommentCellViewModelType = CommentCellViewModel()

  private let authorBadge = TestObserver<Comment.AuthorBadge, Never>()
  private let authorImageURL = TestObserver<URL, Never>()
  private let authorName = TestObserver<String, Never>()
  private let body = TestObserver<String, Never>()
  private let postTime = TestObserver<String, Never>()
  private let replyButtonIsHidden = TestObserver<Bool, Never>()
  private let viewRepliesContainerHidden = TestObserver<Bool, Never>()

  override func setUp() {
    super.setUp()
    self.vm.outputs.authorBadge.observe(self.authorBadge.observer)
    self.vm.outputs.authorImageURL.observe(self.authorImageURL.observer)
    self.vm.outputs.authorName.observe(self.authorName.observer)
    self.vm.outputs.body.observe(self.body.observer)
    self.vm.outputs.postTime.observe(self.postTime.observer)
    self.vm.outputs.replyButtonIsHidden.observe(self.replyButtonIsHidden.observer)
    self.vm.outputs.viewRepliesContainerHidden.observe(self.viewRepliesContainerHidden.observer)
  }

  func testOutputs() {
    let author = Comment.Author.template
      |> \.imageUrl .~ "http://www.kickstarter.com/small.jpg"

    let comment = Comment.template
      |> \.author .~ author

    let project = Project.template
      |> \.personalization.isBacking .~ true

    self.vm.inputs.configureWith(comment: comment, project: project)

    self.authorBadge.assertValues([.creator], "The author's badge is emitted.")
    self.authorImageURL.assertValues([URL(string: "http://www.kickstarter.com/small.jpg")!])
    self.authorName.assertValues([comment.author.name], "The author's name is emitted.")
    self.body.assertValues([comment.body], "The comment body is emitted.")
    self.postTime.assertValueCount(1, "The relative time of the comment is emitted.")
  }

  func testOutputs_replyButtonIsHidden_IsBacker_True_IsLoggedIn() {
    let project = Project.template
      |> \.personalization.isBacking .~ true

    let user = User.template |> \.id .~ 12_345

    withEnvironment(currentUser: user) {
      self.vm.inputs.configureWith(comment: .template, project: project)

      self.replyButtonIsHidden
        .assertValue(false, "The replyButton is not hidden because the user is a backer AND logged in.")
    }
  }

  func testOutputs_replyButtonIsHidden_IsBacker_False_IsLoggedOut() {
    withEnvironment(currentUser: nil) {
      self.vm.inputs.configureWith(comment: .template, project: .template)

      self.replyButtonIsHidden
        .assertValue(true, "The replyButton is hidden because the user is not a backer AND not logged in.")
    }
  }

  func testOutputs_replyButtonIsHidden_IsBacker_False_IsLoggedIn() {
    let user = User.template |> \.id .~ 12_345

    withEnvironment(currentUser: user) {
      self.vm.inputs.configureWith(comment: .template, project: .template)

      self.replyButtonIsHidden
        .assertValue(true, "The replyButton is hidden because the user is logged in but not a backer.")
    }
  }

  func testOutputs_UserIs_LoggedOut() {
    let author = Comment.Author.template
      |> \.imageUrl .~ "http://www.kickstarter.com/small.jpg"

    let comment = Comment.template
      |> \.author .~ author

    self.vm.inputs.configureWith(comment: comment, project: .template)

    self.authorBadge.assertValues([.creator], "The author's badge is emitted.")
    self.authorImageURL.assertValues([URL(string: "http://www.kickstarter.com/small.jpg")!])
    self.authorName.assertValues([comment.author.name], "The author's name is emitted.")
    self.body.assertValues([comment.body], "The comment body is emitted.")
    self.postTime.assertValueCount(1, "The relative time of the comment is emitted.")
    self.replyButtonIsHidden.assertValue(true, "User is not logged in.")
  }

  func testPersonalizedLabels_UserIs_Creator_Author() {
    let comment = Comment.template

    self.vm.inputs.configureWith(comment: comment, project: .template)
    self.authorBadge.assertValues([.creator], "The author's badge is emitted.")
  }

  func testPersonalizedLabels_User_Is_You_Author() {
    let author = Comment.Author.template
      |> \.id .~ "12345"

    let comment = Comment.template
      |> \.author .~ author
      |> \.authorBadges .~ [.superbacker]

    let user = User.template |> \.id .~ 12_345

    withEnvironment(currentUser: user) {
      self.vm.inputs.configureWith(comment: comment, project: .template)
      self.authorBadge.assertValues([.you], "The author's badge is emitted.")
    }
  }

  func testPersonalizedLabels_UserIs_Superbacker_Author() {
    let comment = Comment.superbackerTemplate

    self.vm.inputs.configureWith(comment: comment, project: .template)
    self.authorBadge.assertValues([.superbacker], "The author's badge is emitted.")
  }

  func testPersonalizedLabels_UserIs_Backer_Author() {
    let comment = Comment.backerTemplate

    self.vm.inputs.configureWith(comment: comment, project: .template)
    self.authorBadge.assertValues([.backer], "The author's badge is emitted.")
  }

  func testBindStylesEmitsAuthorBadge() {
    self.authorBadge.assertDidNotEmitValue()

    self.vm.inputs.configureWith(comment: .template, project: .template)

    self.authorBadge.assertValues([.creator], "The author's badge is emitted.")

    self.vm.inputs.bindStyles()

    self.authorBadge.assertValues([.creator, .creator], "The author's badge is emitted.")
  }

  func testViewRepliesContainerHidden_IsHiddenWhenNoReplies() {
    self.viewRepliesContainerHidden.assertDidNotEmitValue()

    let comment = Comment.template
      |> \.replyCount .~ 0

    self.vm.inputs.configureWith(comment: comment, user: nil)

    self.viewRepliesContainerHidden.assertValues([true])
  }

  func testViewRepliesContainerHidden_IsNotHiddenWhenCommentHasReplies() {
    self.viewRepliesContainerHidden.assertDidNotEmitValue()

    let comment = Comment.template
      |> \.replyCount .~ 1

    self.vm.inputs.configureWith(comment: comment, user: nil)

    self.viewRepliesContainerHidden.assertValues([false])
  }
}
