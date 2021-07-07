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
  private let loadFailableReplyIntoDataSource = TestObserver<Comment, Never>()
  private let loadFailableCommentIDIntoDataSource = TestObserver<String, Never>()
  private let loadFailableProjectIntoDataSource = TestObserver<Project, Never>()
  private let loadRepliesAndProjectIntoDataSourceProject = TestObserver<Project, Never>()
  private let loadRepliesAndProjectIntoDataSourceReplies = TestObserver<[Comment], Never>()
  private let loadRepliesAndProjectIntoDataSourceTotalCount = TestObserver<Int, Never>()
  private let resetCommentComposer = TestObserver<(), Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.configureCommentComposerViewWithData.map(\.becomeFirstResponder)
      .observe(self.configureCommentComposerBecomeFirstResponder.observer)
    self.vm.outputs.configureCommentComposerViewWithData.map(\.avatarURL)
      .observe(self.configureCommentComposerViewURL.observer)
    self.vm.outputs.configureCommentComposerViewWithData.map(\.canPostComment)
      .observe(self.configureCommentComposerViewCanPostComment.observer)
    self.vm.outputs.loadCommentIntoDataSource.observe(self.loadCommentIntoDataSourceComment.observer)
    self.vm.outputs.loadFailableReplyIntoDataSource.map(first)
      .observe(self.loadFailableReplyIntoDataSource.observer)
    self.vm.outputs.loadFailableReplyIntoDataSource.map(second)
      .observe(self.loadFailableCommentIDIntoDataSource.observer)
    self.vm.outputs.loadFailableReplyIntoDataSource.map(third)
      .observe(self.loadFailableProjectIntoDataSource.observer)
    self.vm.outputs.loadRepliesAndProjectIntoDataSource.map(second)
      .observe(self.loadRepliesAndProjectIntoDataSourceProject.observer)
    self.vm.outputs.loadRepliesAndProjectIntoDataSource
      .map(first)
      .map { replies, _ in replies }
      .observe(self.loadRepliesAndProjectIntoDataSourceReplies.observer)
    self.vm.outputs.loadRepliesAndProjectIntoDataSource
      .map(first)
      .map { _, totalCount in totalCount }
      .observe(self.loadRepliesAndProjectIntoDataSourceTotalCount.observer)
    self.vm.outputs.resetCommentComposer.observe(self.resetCommentComposer.observer)
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

  func testOutput_LoadRepliesProjectAndTotalCountIntoDataSource_PaginationSuccessful() {
    let project = Project.template
    let envelope = CommentRepliesEnvelope.successfulRepliesTemplate
    let updatedEnvelope = CommentRepliesEnvelope(
      comment: .template,
      cursor: "nextCursor",
      hasPreviousPage: false,
      replies: [
        .collaboratorTemplate,
        .collaboratorTemplate,
        .collaboratorTemplate,
        .collaboratorTemplate,
        .collaboratorTemplate,
        .collaboratorTemplate,
        .collaboratorTemplate
      ],
      totalCount: 14
    )

    withEnvironment(apiService: MockService(fetchCommentRepliesEnvelopeResult: .success(envelope))) {
      self.vm.inputs.configureWith(
        comment: .template,
        project: project,
        inputAreaBecomeFirstResponder: false
      )

      self.vm.inputs.viewDidLoad()

      self.loadRepliesAndProjectIntoDataSourceProject.assertValues([])
      self.loadRepliesAndProjectIntoDataSourceReplies.assertValues([])
      self.loadRepliesAndProjectIntoDataSourceTotalCount.assertValues([])

      self.scheduler.advance()

      self.loadRepliesAndProjectIntoDataSourceProject.assertValues([project])
      self.loadRepliesAndProjectIntoDataSourceReplies.assertValues([envelope.replies])
      self.loadRepliesAndProjectIntoDataSourceTotalCount.assertValues([envelope.totalCount])

      withEnvironment(apiService: MockService(fetchCommentRepliesEnvelopeResult: .success(updatedEnvelope))) {
        self.vm.inputs.viewMoreRepliesCellWasTapped()

        self.scheduler.advance()

        self.loadRepliesAndProjectIntoDataSourceProject.assertValues([project, project])
        self.loadRepliesAndProjectIntoDataSourceReplies
          .assertValues([envelope.replies, updatedEnvelope.replies])
        self.loadRepliesAndProjectIntoDataSourceTotalCount
          .assertValues([updatedEnvelope.totalCount, updatedEnvelope.totalCount])
      }
    }
  }

  func testOutput_SubmitText_FromCommentComposer_ResetsCommentComposerTextInput() {
    let project = Project.template
      |> \.personalization.isBacking .~ false
      |> Project.lens.memberData.permissions .~ [.post, .viewPledges, .comment]

    self.resetCommentComposer.assertDidNotEmitValue()

    withEnvironment(currentUser: .template) {
      self.vm.inputs.configureWith(comment: .template, project: project, inputAreaBecomeFirstResponder: true)
      self.vm.inputs.viewDidLoad()

      self.resetCommentComposer.assertDidNotEmitValue()

      self.vm.inputs.commentComposerDidSubmitText("Text")

      self.resetCommentComposer.assertDidEmitValue()
    }
  }

  func testOutput_SubmitText_FromCommentComposer_ReturnsFailableCommentAndSuccessfulComment() {
    let project = Project.template
      |> \.personalization.isBacking .~ false
      |> Project.lens.memberData.permissions .~ [.post, .viewPledges, .comment]

    let mockService = MockService(
      postCommentResult: .success(.replyTemplate)
    )

    self.loadFailableReplyIntoDataSource.assertDidNotEmitValue()
    self.loadFailableProjectIntoDataSource.assertDidNotEmitValue()
    self.loadFailableCommentIDIntoDataSource.assertDidNotEmitValue()

    withEnvironment(apiService: mockService, currentUser: .template) {
      self.vm.inputs.configureWith(
        comment: .replyRootCommentTemplate,
        project: project,
        inputAreaBecomeFirstResponder: true
      )
      self.vm.inputs.viewDidLoad()

      self.loadFailableReplyIntoDataSource.assertDidNotEmitValue()
      self.loadFailableProjectIntoDataSource.assertDidNotEmitValue()
      self.loadFailableCommentIDIntoDataSource.assertDidNotEmitValue()

      self.vm.inputs.commentComposerDidSubmitText("Text")

      self.loadFailableReplyIntoDataSource.assertValueCount(1)
      self.loadFailableProjectIntoDataSource.assertLastValue(project)
      self.loadFailableCommentIDIntoDataSource.assertLastValue(MockUUID().uuidString)

      XCTAssertEqual(self.loadFailableReplyIntoDataSource.lastValue!.body, "Text")
      XCTAssertEqual(self.loadFailableReplyIntoDataSource.lastValue!.author.id, "\(User.template.id)")
      XCTAssertEqual(
        self.loadFailableReplyIntoDataSource.lastValue!.parentId!,
        Comment.replyRootCommentTemplate.id
      )

      self.scheduler.advance(by: .seconds(1))

      self.loadFailableReplyIntoDataSource.assertValueCount(2)
      self.loadFailableReplyIntoDataSource.assertLastValue(.replyTemplate)
      self.loadFailableProjectIntoDataSource.assertLastValue(project)
      self.loadFailableCommentIDIntoDataSource.assertLastValue(MockUUID().uuidString)
    }
  }
}
