@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class CommentsViewModelTests: TestCase {
  private let vm: CommentsViewModelType = CommentsViewModel()

  private let configureCommentComposerViewURL = TestObserver<URL?, Never>()
  private let configureCommentComposerViewIsBacking = TestObserver<Bool, Never>()
  private let goToCommentRepliesComment = TestObserver<Comment, Never>()
  private let goToCommentRepliesProject = TestObserver<Project, Never>()
  private let isCommentComposerHidden = TestObserver<Bool, Never>()
  private let isCommentsLoading = TestObserver<Bool, Never>()
  private let loadCommentsAndProjectIntoDataSourceComments = TestObserver<[Comment], Never>()
  private let loadCommentsAndProjectIntoDataSourceProject = TestObserver<Project, Never>()
  private let postCommentSuccessful = TestObserver<Comment, Never>()
  private let postCommentSubmitted = TestObserver<(), Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.configureCommentComposerViewWithData.map(first)
      .observe(self.configureCommentComposerViewURL.observer)
    self.vm.outputs.configureCommentComposerViewWithData.map(second)
      .observe(self.configureCommentComposerViewIsBacking.observer)
    self.vm.outputs.commentComposerViewHidden.observe(self.isCommentComposerHidden.observer)
    self.vm.outputs.goToCommentReplies.map(first).observe(self.goToCommentRepliesComment.observer)
    self.vm.outputs.goToCommentReplies.map(second).observe(self.goToCommentRepliesProject.observer)
    self.vm.outputs.loadCommentsAndProjectIntoDataSource.map(first)
      .observe(self.loadCommentsAndProjectIntoDataSourceComments.observer)
    self.vm.outputs.loadCommentsAndProjectIntoDataSource.map(second)
      .observe(self.loadCommentsAndProjectIntoDataSourceProject.observer)
    self.vm.outputs.isCommentsLoading.observe(self.isCommentsLoading.observer)
    self.vm.outputs.postCommentSuccessful.observe(self.postCommentSuccessful.observer)
    self.vm.outputs.postCommentSubmitted.observe(self.postCommentSubmitted.observer)
  }

  func testOutput_ConfigureCommentComposerViewWithData_IsLoggedOut() {
    self.configureCommentComposerViewURL.assertDidNotEmitValue()
    self.configureCommentComposerViewIsBacking.assertDidNotEmitValue()

    withEnvironment(currentUser: nil) {
      self.vm.inputs.configureWith(project: .template, update: nil)
      self.vm.inputs.viewDidLoad()

      self.configureCommentComposerViewURL
        .assertValues([nil], "nil is emitted because the user is not logged in.")
      self.configureCommentComposerViewIsBacking
        .assertValues([false], "false is emitted because the project is not backed.")
    }
  }

  func testOutput_ConfigureCommentComposerViewWithData_IsLoggedIn_IsBacking_False() {
    let user = User.template |> \.id .~ 12_345

    self.configureCommentComposerViewURL.assertDidNotEmitValue()
    self.configureCommentComposerViewIsBacking.assertDidNotEmitValue()

    withEnvironment(currentUser: user) {
      self.vm.inputs.configureWith(project: .template, update: nil)
      self.vm.inputs.viewDidLoad()

      self.configureCommentComposerViewURL
        .assertValues(
          [URL(string: "http://www.kickstarter.com/medium.jpg")],
          "An URL is emitted because the user is logged in."
        )
      self.configureCommentComposerViewIsBacking
        .assertValues([false], "false is emitted because the project is not backed.")
    }
  }

  func testOutput_ConfigureCommentComposerViewWithData_IsLoggedIn_IsBacking_True() {
    let project = Project.template
      |> \.personalization.isBacking .~ true

    let user = User.template |> \.id .~ 12_345

    self.configureCommentComposerViewURL.assertDidNotEmitValue()
    self.configureCommentComposerViewIsBacking.assertDidNotEmitValue()

    withEnvironment(currentUser: user) {
      self.vm.inputs.configureWith(project: project, update: nil)
      self.vm.inputs.viewDidLoad()

      self.configureCommentComposerViewURL
        .assertValues(
          [URL(string: "http://www.kickstarter.com/medium.jpg")],
          "An URL is emitted because the user is logged in."
        )
      self.configureCommentComposerViewIsBacking
        .assertValues([true], "true is emitted because the project is backed.")
    }
  }

  func testOutput_IsCommentComposerHidden_False() {
    let user = User.template |> \.id .~ 12_345

    withEnvironment(currentUser: user) {
      self.vm.inputs.configureWith(project: .template, update: nil)
      self.vm.inputs.viewDidLoad()

      self.isCommentComposerHidden.assertValue(false)
    }
  }

  func testOutput_IsCommentComposerHidden_True() {
    withEnvironment(currentUser: nil) {
      self.vm.inputs.configureWith(project: .template, update: nil)
      self.vm.inputs.viewDidLoad()

      self.isCommentComposerHidden.assertValue(true)
    }
  }

  func testGoToCommentReplies_CommentHasReplies_GoToEmits() {
    self.goToCommentRepliesComment.assertDidNotEmitValue()
    self.goToCommentRepliesProject.assertDidNotEmitValue()

    let project = Project.template
    let comment = Comment.template
      |> \.replyCount .~ 1

    self.vm.inputs.configureWith(project: project, update: nil)
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

    self.vm.inputs.configureWith(project: project, update: nil)
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

    self.vm.inputs.configureWith(project: project, update: nil)
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

    self.vm.inputs.configureWith(project: project, update: nil)
    self.vm.inputs.viewDidLoad()

    self.goToCommentRepliesComment.assertDidNotEmitValue()
    self.goToCommentRepliesProject.assertDidNotEmitValue()

    self.vm.inputs.didSelectComment(comment)

    self.goToCommentRepliesComment.assertDidNotEmitValue()
    self.goToCommentRepliesProject.assertDidNotEmitValue()
  }

  func testLoggedOut_ViewingComments_CommentsAreLoadedIntoDataSource() {
    self.loadCommentsAndProjectIntoDataSourceComments.assertDidNotEmitValue()
    self.loadCommentsAndProjectIntoDataSourceProject.assertDidNotEmitValue()

    let envelope = CommentsEnvelope.singleCommentTemplate
    let project = Project.template
      |> Project.lens.personalization.isBacking .~ false

    withEnvironment(apiService: MockService(fetchCommentsEnvelopeResult: .success(envelope))) {
      self.vm.inputs.configureWith(
        project: project,
        update: nil
      )

      self.vm.inputs.viewDidLoad()

      self.loadCommentsAndProjectIntoDataSourceComments.assertDidNotEmitValue()
      self.loadCommentsAndProjectIntoDataSourceProject.assertDidNotEmitValue()

      self.scheduler.advance()

      self.loadCommentsAndProjectIntoDataSourceComments.assertValues([envelope.comments])
      self.loadCommentsAndProjectIntoDataSourceProject.assertValues([project])
    }
  }

  func testLoggedInNonBacker_ViewingComments_CommentsAreLoadedIntoDataSource() {
    self.loadCommentsAndProjectIntoDataSourceComments.assertDidNotEmitValue()
    self.loadCommentsAndProjectIntoDataSourceProject.assertDidNotEmitValue()

    let user = User.template
    let accessToken = AccessTokenEnvelope(accessToken: "deadbeef", user: user)
    let envelope = CommentsEnvelope.singleCommentTemplate
    let project = Project.template
      |> Project.lens.personalization.isBacking .~ false

    withEnvironment(apiService: MockService(fetchCommentsEnvelopeResult: .success(.singleCommentTemplate))) {
      AppEnvironment.login(accessToken)

      self.vm.inputs.configureWith(
        project: project,
        update: nil
      )
      self.vm.inputs.viewDidLoad()

      self.loadCommentsAndProjectIntoDataSourceComments.assertDidNotEmitValue()
      self.loadCommentsAndProjectIntoDataSourceProject.assertDidNotEmitValue()

      self.scheduler.advance()

      self.loadCommentsAndProjectIntoDataSourceComments.assertValues([envelope.comments])
      self.loadCommentsAndProjectIntoDataSourceProject.assertValues([project])
    }
  }

  func testLoggedInBacker_ViewingComments_CommentsAreLoadedIntoDataSource() {
    self.loadCommentsAndProjectIntoDataSourceComments.assertDidNotEmitValue()
    self.loadCommentsAndProjectIntoDataSourceProject.assertDidNotEmitValue()

    let user = User.template
    let accessToken = AccessTokenEnvelope(accessToken: "deadbeef", user: user)
    let envelope = CommentsEnvelope.singleCommentTemplate
    let project = Project.template
      |> Project.lens.personalization.isBacking .~ true

    withEnvironment(apiService: MockService(fetchCommentsEnvelopeResult: .success(envelope))) {
      AppEnvironment.login(accessToken)

      self.vm.inputs.configureWith(
        project: project,
        update: nil
      )
      self.vm.inputs.viewDidLoad()

      self.loadCommentsAndProjectIntoDataSourceComments.assertDidNotEmitValue()
      self.loadCommentsAndProjectIntoDataSourceProject.assertDidNotEmitValue()

      self.scheduler.advance()

      self.loadCommentsAndProjectIntoDataSourceComments
        .assertValues([envelope.comments], "New comments are emitted")
      self.loadCommentsAndProjectIntoDataSourceProject.assertValues([project], "New project is emitted")
    }
  }

  func testRefreshing_WhenNewCommentAdded_CommentsAreUpdatedInDataSource() {
    self.loadCommentsAndProjectIntoDataSourceComments.assertDidNotEmitValue()
    self.loadCommentsAndProjectIntoDataSourceProject.assertDidNotEmitValue()

    let project = Project.template
    let envelope = CommentsEnvelope.singleCommentTemplate

    withEnvironment(apiService: MockService(fetchCommentsEnvelopeResult: .success(envelope))) {
      self.vm.inputs.configureWith(project: project, update: nil)
      self.vm.inputs.viewDidLoad()

      self.loadCommentsAndProjectIntoDataSourceComments.assertDidNotEmitValue()
      self.loadCommentsAndProjectIntoDataSourceProject.assertDidNotEmitValue()

      self.scheduler.advance()

      self.loadCommentsAndProjectIntoDataSourceComments
        .assertValues([envelope.comments], "New comments are emitted")
      self.loadCommentsAndProjectIntoDataSourceProject.assertValues([project], "New project is emitted")

      let updatedEnvelope = CommentsEnvelope.multipleCommentTemplate

      withEnvironment(apiService: MockService(fetchCommentsEnvelopeResult: .success(updatedEnvelope))) {
        self.vm.inputs.refresh()

        self.loadCommentsAndProjectIntoDataSourceComments
          .assertValues([envelope.comments], "No new comments are emitted")
        self.loadCommentsAndProjectIntoDataSourceProject
          .assertValues([project], "No new projects are emitted")

        self.scheduler.advance()

        self.loadCommentsAndProjectIntoDataSourceComments
          .assertValues([envelope.comments, updatedEnvelope.comments], "New comments are emitted")
        self.loadCommentsAndProjectIntoDataSourceProject
          .assertValues([project, project], "Same project is emitted again")
      }
    }
  }

  func testProjectPagination_WhenLimitReached_CommentsAreUpdatedInDataSource() {
    self.loadCommentsAndProjectIntoDataSourceComments.assertDidNotEmitValue()
    self.loadCommentsAndProjectIntoDataSourceProject.assertDidNotEmitValue()

    let envelope = CommentsEnvelope.singleCommentTemplate
    let project = Project.template

    withEnvironment(apiService: MockService(fetchCommentsEnvelopeResult: .success(envelope))) {
      self.vm.inputs.configureWith(project: project, update: nil)
      self.vm.inputs.viewDidLoad()

      self.loadCommentsAndProjectIntoDataSourceComments.assertDidNotEmitValue()
      self.loadCommentsAndProjectIntoDataSourceProject.assertDidNotEmitValue()
      self.isCommentsLoading.assertValues([true])

      self.scheduler.advance()

      self.loadCommentsAndProjectIntoDataSourceComments.assertValues(
        [envelope.comments],
        "A set of comments is emitted."
      )
      self.loadCommentsAndProjectIntoDataSourceProject.assertValues([.template])
      self.isCommentsLoading.assertValues([true, false])

      let updatedEnvelope = CommentsEnvelope.multipleCommentTemplate

      withEnvironment(apiService: MockService(fetchCommentsEnvelopeResult: .success(updatedEnvelope))) {
        self.vm.inputs.willDisplayRow(3, outOf: 4)

        self.loadCommentsAndProjectIntoDataSourceComments.assertValues(
          [envelope.comments],
          "No new comments are emitted."
        )
        self.loadCommentsAndProjectIntoDataSourceProject.assertValues([.template])
        self.isCommentsLoading.assertValues([true, false, true])

        self.scheduler.advance()

        self.loadCommentsAndProjectIntoDataSourceComments.assertValueCount(2)

        self.loadCommentsAndProjectIntoDataSourceComments.assertValues(
          [envelope.comments, envelope.comments + updatedEnvelope.comments],
          "New comments are emitted."
        )
        self.loadCommentsAndProjectIntoDataSourceProject.assertValues([.template, .template])
        self.isCommentsLoading.assertValues([true, false, true, false])
      }
    }
  }

  func testUpdatePagination_WhenLimitReached_CommentsAreLoadedIntoDataSource() {
    self.loadCommentsAndProjectIntoDataSourceComments.assertDidNotEmitValue()
    self.loadCommentsAndProjectIntoDataSourceProject.assertDidNotEmitValue()

    let envelope = CommentsEnvelope.singleCommentTemplate
    let update = Update.template

    withEnvironment(apiService: MockService(fetchCommentsEnvelopeResult: .success(envelope))) {
      self.vm.inputs.configureWith(project: nil, update: update)
      self.vm.inputs.viewDidLoad()

      self.loadCommentsAndProjectIntoDataSourceComments.assertDidNotEmitValue()
      self.loadCommentsAndProjectIntoDataSourceProject.assertDidNotEmitValue()
      self.isCommentsLoading.assertValues([true])

      self.scheduler.advance()

      self.loadCommentsAndProjectIntoDataSourceComments.assertValues(
        [envelope.comments],
        "A set of comments is emitted."
      )
      self.loadCommentsAndProjectIntoDataSourceProject.assertValues([.template])
      self.isCommentsLoading.assertValues([true, false])

      let updatedEnvelope = CommentsEnvelope.multipleCommentTemplate

      withEnvironment(apiService: MockService(fetchCommentsEnvelopeResult: .success(updatedEnvelope))) {
        self.vm.inputs.willDisplayRow(3, outOf: 4)

        self.loadCommentsAndProjectIntoDataSourceComments.assertValues(
          [envelope.comments],
          "No new comments are emitted."
        )
        self.loadCommentsAndProjectIntoDataSourceProject.assertValues([.template])
        self.isCommentsLoading.assertValues([true, false, true])

        self.scheduler.advance()

        self.loadCommentsAndProjectIntoDataSourceComments.assertValueCount(2)

        self.loadCommentsAndProjectIntoDataSourceComments.assertValues(
          [envelope.comments, envelope.comments + updatedEnvelope.comments],
          "New comments are emitted."
        )
        self.loadCommentsAndProjectIntoDataSourceProject.assertValues([.template, .template])
        self.isCommentsLoading.assertValues([true, false, true, false])
      }
    }
  }

  func testComments_WhenOnlyUpdate_CommentsAreUpdatedInDataSource() {
    self.loadCommentsAndProjectIntoDataSourceComments.assertDidNotEmitValue()
    self.loadCommentsAndProjectIntoDataSourceProject.assertDidNotEmitValue()

    let envelope = CommentsEnvelope.singleCommentTemplate
    let update = Update.template

    withEnvironment(apiService: MockService(fetchCommentsEnvelopeResult: .success(envelope))) {
      self.vm.inputs.configureWith(
        project: nil,
        update: update
      )
      self.vm.inputs.viewDidLoad()

      self.loadCommentsAndProjectIntoDataSourceComments.assertDidNotEmitValue()
      self.loadCommentsAndProjectIntoDataSourceProject.assertDidNotEmitValue()
      self.isCommentsLoading.assertValues([true], "loading begins")

      self.scheduler.advance()

      self.loadCommentsAndProjectIntoDataSourceComments
        .assertValues([envelope.comments], "New comments are emitted")
      self.loadCommentsAndProjectIntoDataSourceProject
        .assertValues([.template], "Same project is emitted again")
      self.isCommentsLoading.assertValues([true, false], "loading ends")
    }
  }

  func testComments_WhenNoProjectOrUpdate_CommentsAreNotUpdatedInDataSource() {
    self.loadCommentsAndProjectIntoDataSourceComments.assertDidNotEmitValue()
    self.loadCommentsAndProjectIntoDataSourceProject.assertDidNotEmitValue()

    let envelope = CommentsEnvelope.singleCommentTemplate

    withEnvironment(apiService: MockService(fetchCommentsEnvelopeResult: .success(envelope))) {
      self.vm.inputs.configureWith(
        project: nil,
        update: nil
      )
      self.vm.inputs.viewDidLoad()

      self.loadCommentsAndProjectIntoDataSourceComments.assertDidNotEmitValue()
      self.loadCommentsAndProjectIntoDataSourceProject.assertDidNotEmitValue()
      self.isCommentsLoading.assertDidNotEmitValue()

      self.scheduler.advance()

      self.loadCommentsAndProjectIntoDataSourceComments.assertDidNotEmitValue()
      self.loadCommentsAndProjectIntoDataSourceProject.assertDidNotEmitValue()
      self.isCommentsLoading.assertDidNotEmitValue()
    }
  }

  func testDataSourceContainsFailableComment() {
    self.vm.inputs.configureWith(project: .template, update: nil)

    let envelope = CommentsEnvelope.singleCommentTemplate

    withEnvironment(
      apiService: MockService(fetchCommentsEnvelopeResult: .success(envelope)),
      currentUser: .template
    ) {
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      let bodyText = "I just posted a comment."

      self.vm.inputs.commentComposerDidSubmitText(bodyText)

      let optimisticComment = Comment
        .createFailableComment(project: .template, user: .template, body: bodyText)

      self.postCommentSubmitted.assertDidEmitValue()

      XCTAssertEqual(
        self.loadCommentsAndProjectIntoDataSourceComments.values.last?.first?.body,
        optimisticComment.body
      )
    }
  }

  func testPostCommentSuccessful() {
    self.vm.inputs.configureWith(project: .template, update: nil)
    self.vm.inputs.viewDidLoad()

    withEnvironment(currentUser: .template) {
      let bodyText = "Posting another comment."

      self.vm.inputs.commentComposerDidSubmitText(bodyText)

      self.postCommentSuccessful.assertValueCount(1, "Comment posted successfully")
    }
  }

  // TODO: Empty state not tested yet https://kickstarter.atlassian.net/browse/NT-1942
  // TODO: Post comments can be fully tested after this ticket is merged: https://kickstarter.atlassian.net/browse/NT-1893
}
