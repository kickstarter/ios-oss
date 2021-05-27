@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class CommentsViewModelTests: TestCase {
  internal let vm: CommentsViewModelType = CommentsViewModel()

  private let goToCommentRepliesComment = TestObserver<Comment, Never>()
  private let goToCommentRepliesProject = TestObserver<Project, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.goToCommentReplies.map(first).observe(self.goToCommentRepliesComment.observer)
    self.vm.outputs.goToCommentReplies.map(second).observe(self.goToCommentRepliesProject.observer)
  }

  func testGoToCommentReplies_CommentHasReplies_GoToEmits() {
    self.goToCommentRepliesComment.assertDidNotEmitValue()
    self.goToCommentRepliesProject.assertDidNotEmitValue()

    let project = Project.template
    let comment = Comment.template
      |> \.replyCount .~ 1

    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()

    self.goToCommentRepliesComment.assertDidNotEmitValue()
    self.goToCommentRepliesProject.assertDidNotEmitValue()

    self.vm.inputs.didSelectComment(comment)

    self.goToCommentRepliesComment.assertValues([comment])
    self.goToCommentRepliesProject.assertValues([project])
  }

  func testGoToCommentReplies_CommentHasReplies_IsDeleted_GoToDoesNotEmit() {
    self.goToCommentRepliesComment.assertDidNotEmitValue()
    self.goToCommentRepliesProject.assertDidNotEmitValue()

    let project = Project.template
    let comment = Comment.template
      |> \.replyCount .~ 1
      |> \.isDeleted .~ true

    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()

    self.goToCommentRepliesComment.assertDidNotEmitValue()
    self.goToCommentRepliesProject.assertDidNotEmitValue()

    self.vm.inputs.didSelectComment(comment)

    self.goToCommentRepliesComment.assertDidNotEmitValue()
    self.goToCommentRepliesProject.assertDidNotEmitValue()
  }

  func testGoToCommentReplies_CommentHasReplies_IsErrored_GoToDoesNotEmit() {
    self.goToCommentRepliesComment.assertDidNotEmitValue()
    self.goToCommentRepliesProject.assertDidNotEmitValue()

    let project = Project.template
    let comment = Comment.template
      |> \.replyCount .~ 1
      |> \.isFailed .~ true

    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()

    self.goToCommentRepliesComment.assertDidNotEmitValue()
    self.goToCommentRepliesProject.assertDidNotEmitValue()

    self.vm.inputs.didSelectComment(comment)

    self.goToCommentRepliesComment.assertDidNotEmitValue()
    self.goToCommentRepliesProject.assertDidNotEmitValue()
  }

  func testGoToCommentReplies_CommentHasNoReplies_GoToDoesNotEmit() {
    self.goToCommentRepliesComment.assertDidNotEmitValue()
    self.goToCommentRepliesProject.assertDidNotEmitValue()

    let project = Project.template
    let comment = Comment.template
      |> \.replyCount .~ 0

    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()

    self.goToCommentRepliesComment.assertDidNotEmitValue()
    self.goToCommentRepliesProject.assertDidNotEmitValue()

    self.vm.inputs.didSelectComment(comment)

    self.goToCommentRepliesComment.assertDidNotEmitValue()
    self.goToCommentRepliesProject.assertDidNotEmitValue()
  }
}
