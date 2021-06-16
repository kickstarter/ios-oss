@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class CommentRepliesViewModelTests: TestCase {
  private let vm: CommentRepliesViewModelType = CommentRepliesViewModel()

  private let configureCommentComposerViewURL = TestObserver<URL?, Never>()
  private let configureCommentComposerViewCanPostComment = TestObserver<Bool, Never>()
  private let loadCommentIntoDataSourceComment = TestObserver<Comment, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.configureCommentComposerViewWithData.map(first)
      .observe(self.configureCommentComposerViewURL.observer)
    self.vm.outputs.configureCommentComposerViewWithData.map(second)
      .observe(self.configureCommentComposerViewCanPostComment.observer)
    self.vm.outputs.loadCommentIntoDataSource.observe(self.loadCommentIntoDataSourceComment.observer)
  }

  func testDataSource_WithComment_HasComment() {
    self.loadCommentIntoDataSourceComment.assertDidNotEmitValue()

    let rootComment = Comment.template

    withEnvironment {
      self.vm.inputs.configureWith(
        comment: rootComment,
        project: .template
      )

      self.loadCommentIntoDataSourceComment.assertDidNotEmitValue()

      self.vm.inputs.viewDidLoad()

      self.loadCommentIntoDataSourceComment.assertValue(rootComment)
    }
  }

  func testOutput_ConfigureCommentComposerViewWithData_IsLoggedOut() {
    self.configureCommentComposerViewURL.assertDidNotEmitValue()
    self.configureCommentComposerViewCanPostComment.assertDidNotEmitValue()

    withEnvironment(currentUser: nil) {
      self.vm.inputs.configureWith(comment: .template, project: .template)
      self.vm.inputs.viewDidLoad()

      self.configureCommentComposerViewURL
        .assertValues([nil], "nil is emitted because the user is not logged in.")
      self.configureCommentComposerViewCanPostComment
        .assertValues([false], "false is emitted because the project is not backed.")
    }
  }

  func testOutput_ConfigureCommentComposerViewWithData_IsLoggedIn_IsBacking_False() {
    let user = User.template |> \.id .~ 12_345

    self.configureCommentComposerViewURL.assertDidNotEmitValue()
    self.configureCommentComposerViewCanPostComment.assertDidNotEmitValue()

    withEnvironment(currentUser: user) {
      self.vm.inputs.configureWith(comment: .template, project: .template)
      self.vm.inputs.viewDidLoad()

      self.configureCommentComposerViewURL
        .assertValues(
          [URL(string: "http://www.kickstarter.com/medium.jpg")],
          "An URL is emitted because the user is logged in."
        )
      self.configureCommentComposerViewCanPostComment
        .assertValues([false], "false is emitted because the project is not backed.")
    }
  }

  func testOutput_ConfigureCommentComposerViewWithData_IsLoggedIn_IsBacking_True() {
    let project = Project.template
      |> \.personalization.isBacking .~ true

    let user = User.template |> \.id .~ 12_345

    self.configureCommentComposerViewURL.assertDidNotEmitValue()
    self.configureCommentComposerViewCanPostComment.assertDidNotEmitValue()

    withEnvironment(currentUser: user) {
      self.vm.inputs.configureWith(comment: .template, project: project)
      self.vm.inputs.viewDidLoad()

      self.configureCommentComposerViewURL
        .assertValues(
          [URL(string: "http://www.kickstarter.com/medium.jpg")],
          "An URL is emitted because the user is logged in."
        )
      self.configureCommentComposerViewCanPostComment
        .assertValues([true], "true is emitted because the project is backed.")
    }
  }

  func testOutput_ConfigureCommentComposerViewWithData_IsLoggedIn_IsCreatorOrCollaborator_True() {
    let project = Project.template
      |> \.personalization.isBacking .~ false
      |> Project.lens.memberData.permissions .~ [.post, .viewPledges, .comment]

    self.configureCommentComposerViewURL.assertDidNotEmitValue()
    self.configureCommentComposerViewCanPostComment.assertDidNotEmitValue()

    withEnvironment(currentUser: .template) {
      self.vm.inputs.configureWith(comment: .template, project: project)
      self.vm.inputs.viewDidLoad()

      self.configureCommentComposerViewURL
        .assertValues(
          [URL(string: "http://www.kickstarter.com/medium.jpg")],
          "An URL is emitted because the user is logged in."
        )
      self.configureCommentComposerViewCanPostComment
        .assertValues([true], "true is emitted because current user is creator or collaborator.")
    }
  }
}
