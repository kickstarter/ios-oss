@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class CommentRepliesViewModelTests: TestCase {
  private let vm: CommentRepliesViewModelType = CommentRepliesViewModel()

  private let configureCommentComposerBecomeFirstResponder = TestObserver<Bool, Never>()
  private let configureCommentComposerViewURL = TestObserver<URL?, Never>()
  private let configureCommentComposerViewCanPostComment = TestObserver<Bool, Never>()
  private let loadCommentIntoDataSourceComment = TestObserver<Comment, Never>()
  private let loadRepliesAndProjectIntoDataSourceProject = TestObserver<Project, Never>()
  private let loadRepliesAndProjectIntoDataSourceReplies = TestObserver<[Comment], Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.configureCommentComposerViewWithData.map(\.becomeFirstResponder)
      .observe(self.configureCommentComposerBecomeFirstResponder.observer)
    self.vm.outputs.configureCommentComposerViewWithData.map(\.avatarURL)
      .observe(self.configureCommentComposerViewURL.observer)
    self.vm.outputs.configureCommentComposerViewWithData.map(\.canPostComment)
      .observe(self.configureCommentComposerViewCanPostComment.observer)
    self.vm.outputs.loadCommentIntoDataSource.observe(self.loadCommentIntoDataSourceComment.observer)
    self.vm.outputs.loadRepliesAndProjectIntoDataSource.map(second)
      .observe(self.loadRepliesAndProjectIntoDataSourceProject.observer)
    self.vm.outputs.loadRepliesAndProjectIntoDataSource.map(first)
      .observe(self.loadRepliesAndProjectIntoDataSourceReplies.observer)
  }

  func testDataSource_WithComment_HasComment() {
    self.loadCommentIntoDataSourceComment.assertDidNotEmitValue()

    let rootComment = Comment.template

    withEnvironment {
      self.vm.inputs.configureWith(
        comment: rootComment,
        project: .template,
        inputAreaBecomeFirstResponder: false
      )

      self.loadCommentIntoDataSourceComment.assertDidNotEmitValue()

      self.vm.inputs.viewDidLoad()

      self.loadCommentIntoDataSourceComment.assertValue(rootComment)
    }
  }

  func testOutput_ConfigureCommentComposerViewWithData_IsLoggedOut_HasNoCommentComposer() {
    self.configureCommentComposerViewURL.assertDidNotEmitValue()
    self.configureCommentComposerViewCanPostComment.assertDidNotEmitValue()
    self.configureCommentComposerBecomeFirstResponder.assertDidNotEmitValue()

    withEnvironment(currentUser: nil) {
      self.vm.inputs
        .configureWith(comment: .template, project: .template, inputAreaBecomeFirstResponder: false)
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.viewDidAppear()

      self.configureCommentComposerViewURL
        .assertValues([nil], "nil is emitted because the user is not logged in.")
      self.configureCommentComposerViewCanPostComment
        .assertValues([false], "false is emitted because the project is not backed.")
      self.configureCommentComposerBecomeFirstResponder.assertValues(
        [false],
        "false is emitted because the user is not logged in."
      )
    }
  }

  func testOutput_ConfigureCommentComposerViewWithData_IsLoggedIn_IsBacking_False_HasBlockedCommentComposer() {
    let user = User.template |> \.id .~ 12_345

    self.configureCommentComposerViewURL.assertDidNotEmitValue()
    self.configureCommentComposerViewCanPostComment.assertDidNotEmitValue()

    withEnvironment(currentUser: user) {
      self.vm.inputs
        .configureWith(comment: .template, project: .template, inputAreaBecomeFirstResponder: false)
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.viewDidAppear()

      self.configureCommentComposerViewURL
        .assertValues(
          [URL(string: "http://www.kickstarter.com/medium.jpg")],
          "An URL is emitted because the user is logged in."
        )
      self.configureCommentComposerViewCanPostComment
        .assertValues([false], "false is emitted because the project is not backed.")
    }
  }

  func testOutput_ConfigureCommentComposerViewWithData_IsLoggedIn_IsBacking_True_HasCommentComposer() {
    let project = Project.template
      |> \.personalization.isBacking .~ true

    let user = User.template |> \.id .~ 12_345

    self.configureCommentComposerViewURL.assertDidNotEmitValue()
    self.configureCommentComposerViewCanPostComment.assertDidNotEmitValue()

    withEnvironment(currentUser: user) {
      self.vm.inputs.configureWith(comment: .template, project: project, inputAreaBecomeFirstResponder: true)
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

  func testOutput_ConfigureCommentComposerViewWithData_IsLoggedIn_IsCreatorOrCollaborator_True_HasCommentComposer() {
    let project = Project.template
      |> \.personalization.isBacking .~ false
      |> Project.lens.memberData.permissions .~ [.post, .viewPledges, .comment]

    self.configureCommentComposerViewURL.assertDidNotEmitValue()
    self.configureCommentComposerViewCanPostComment.assertDidNotEmitValue()

    withEnvironment(currentUser: .template) {
      self.vm.inputs.configureWith(comment: .template, project: project, inputAreaBecomeFirstResponder: true)
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

  func testOutput_ConfigureCommentComposerViewWithData_IsFromReplyComment_HasShownKeyboard() {
    let project = Project.template
      |> \.personalization.isBacking .~ false
      |> Project.lens.memberData.permissions .~ [.post, .viewPledges, .comment]

    self.configureCommentComposerViewURL.assertDidNotEmitValue()
    self.configureCommentComposerViewCanPostComment.assertDidNotEmitValue()

    withEnvironment(currentUser: .template) {
      self.vm.inputs.configureWith(comment: .template, project: project, inputAreaBecomeFirstResponder: true)
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.viewDidAppear()

      self.configureCommentComposerViewURL
        .assertValues(
          [
            URL(string: "http://www.kickstarter.com/medium.jpg"),
            URL(string: "http://www.kickstarter.com/medium.jpg")
          ],
          "An URL is emitted because the user is logged in."
        )
      self.configureCommentComposerBecomeFirstResponder
        .assertValues([false, true], "true is emitted because the user clicked on reply on the root comment")
    }
  }

  func testOutput_ConfigureCommentComposerViewWithData_IsFromViewReplies_HasNotShownKeyboard() {
    let project = Project.template
      |> \.personalization.isBacking .~ false
      |> Project.lens.memberData.permissions .~ [.post, .viewPledges, .comment]

    self.configureCommentComposerViewURL.assertDidNotEmitValue()
    self.configureCommentComposerViewCanPostComment.assertDidNotEmitValue()

    withEnvironment(currentUser: .template) {
      self.vm.inputs.configureWith(comment: .template, project: project, inputAreaBecomeFirstResponder: false)
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.viewDidAppear()

      self.configureCommentComposerViewURL
        .assertValues(
          [URL(string: "http://www.kickstarter.com/medium.jpg")],
          "An URL is emitted because the user is logged in."
        )
      self.configureCommentComposerBecomeFirstResponder
        .assertValues(
          [false],
          "false is emitted because the user clicked on view replies on the root comment"
        )
    }
  }

  func testOutput_loadRepliesAndProjectIntoDataSource() {
    let project = Project.template
    let envelope = CommentRepliesEnvelope.template

    let mockService = MockService(
      fetchCommentRepliesEnvelopeResult: .success(envelope)
    )

    withEnvironment(apiService: mockService) {
      self.vm.inputs.configureWith(
        comment: .template,
        project: project,
        inputAreaBecomeFirstResponder: false
      )

      self.loadRepliesAndProjectIntoDataSourceProject.assertValues([])
      self.loadRepliesAndProjectIntoDataSourceReplies.assertValues([])

      self.vm.inputs.viewDidLoad()

      self.loadRepliesAndProjectIntoDataSourceProject.assertValues([project])
      self.loadRepliesAndProjectIntoDataSourceReplies.assertValues([envelope.replies])
    }
  }
}
