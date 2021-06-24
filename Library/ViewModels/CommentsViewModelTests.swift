@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class CommentsViewModelTests: TestCase {
  private let vm: CommentsViewModelType = CommentsViewModel()

  private let beginOrEndRefreshing = TestObserver<Bool, Never>()
  private let cellSeparatorHidden = TestObserver<Bool, Never>()
  private let commentComposerViewHidden = TestObserver<Bool, Never>()
  private let configureCommentComposerViewURL = TestObserver<URL?, Never>()
  private let configureCommentComposerViewCanPostComment = TestObserver<Bool, Never>()
  private let configureFooterViewWithState = TestObserver<CommentTableViewFooterViewState, Never>()
  private let goToCommentRepliesComment = TestObserver<Comment, Never>()
  private let loadCommentsAndProjectIntoDataSourceComments = TestObserver<[Comment], Never>()
  private let loadCommentsAndProjectIntoDataSourceProject = TestObserver<Project, Never>()
  private let showHelpWebViewController = TestObserver<HelpType, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.beginOrEndRefreshing.observe(self.beginOrEndRefreshing.observer)
    self.vm.outputs.cellSeparatorHidden.observe(self.cellSeparatorHidden.observer)
    self.vm.outputs.configureCommentComposerViewWithData.map(third)
      .observe(self.commentComposerViewHidden.observer)
    self.vm.outputs.configureCommentComposerViewWithData.map(first)
      .observe(self.configureCommentComposerViewURL.observer)
    self.vm.outputs.configureCommentComposerViewWithData.map(second)
      .observe(self.configureCommentComposerViewCanPostComment.observer)
    self.vm.outputs.configureFooterViewWithState.observe(self.configureFooterViewWithState.observer)
    self.vm.outputs.goToCommentReplies.observe(self.goToCommentRepliesComment.observer)
    self.vm.outputs.loadCommentsAndProjectIntoDataSource.map(first)
      .observe(self.loadCommentsAndProjectIntoDataSourceComments.observer)
    self.vm.outputs.loadCommentsAndProjectIntoDataSource.map(second)
      .observe(self.loadCommentsAndProjectIntoDataSourceProject.observer)
    self.vm.outputs.showHelpWebViewController.observe(self.showHelpWebViewController.observer)
  }

  func testOutput_ConfigureCommentComposerViewWithData_IsLoggedOut() {
    self.configureCommentComposerViewURL.assertDidNotEmitValue()
    self.configureCommentComposerViewCanPostComment.assertDidNotEmitValue()

    withEnvironment(currentUser: nil) {
      self.vm.inputs.configureWith(project: .template, update: nil)
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
      self.vm.inputs.configureWith(project: .template, update: nil)
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
      self.vm.inputs.configureWith(project: project, update: nil)
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
      self.vm.inputs.configureWith(project: project, update: nil)
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

  func testCommentComposerHidden_WhenUserIsLoggedIn() {
    withEnvironment(currentUser: .template) {
      self.vm.inputs.configureWith(project: .template, update: nil)
      self.vm.inputs.viewDidLoad()

      self.commentComposerViewHidden.assertValue(false)
    }
  }

  func testCommentComposerHidden_WhenUserIsNotLoggedIn() {
    withEnvironment(currentUser: nil) {
      self.vm.inputs.configureWith(project: .template, update: nil)
      self.vm.inputs.viewDidLoad()

      self.commentComposerViewHidden.assertValue(true)
    }
  }

  func testOutput_ShowHelpWebViewController() {
    var url = AppEnvironment.current.apiService.serverConfig.webBaseUrl
    url.appendPathComponent("help/community")

    self.showHelpWebViewController.assertDidNotEmitValue()

    withEnvironment {
      self.vm.inputs.configureWith(project: .template, update: nil)
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.showHelpWebViewController.assertDidNotEmitValue()

      self.scheduler.advance()

      self.vm.inputs.commentRemovedCellDidTapURL(url)

      self.showHelpWebViewController
        .assertValue(.community, ".community is emitted after commentRemovedCellDidTapURL is called.")
    }
  }

  func testGoToCommentReplies_CommentHasReplies_GoToEmits() {
    self.goToCommentRepliesComment.assertDidNotEmitValue()

    let project = Project.template
    let comment = Comment.template
      |> \.replyCount .~ 1
      |> \.status .~ .success

    self.vm.inputs.configureWith(project: project, update: nil)
    self.vm.inputs.viewDidLoad()

    self.goToCommentRepliesComment.assertDidNotEmitValue()

    self.vm.inputs.commentCellDidTapViewReplies(comment)

    self.goToCommentRepliesComment
      .assertValues([comment])
  }

  func testGoToCommentReplies_CommentHasReplies_IsDeleted_GoToDoesNotEmit() {
    self.goToCommentRepliesComment.assertDidNotEmitValue()

    let project = Project.template
    let comment = Comment.template
      |> \.replyCount .~ 1
      |> \.isDeleted .~ true

    self.vm.inputs.configureWith(project: project, update: nil)
    self.vm.inputs.viewDidLoad()

    self.goToCommentRepliesComment.assertDidNotEmitValue()

    self.vm.inputs.didSelectComment(comment)

    self.goToCommentRepliesComment.assertDidNotEmitValue()
  }

  func testGoToCommentReplies_CommentHasReplies_IsErrored_GoToDoesNotEmit() {
    self.goToCommentRepliesComment.assertDidNotEmitValue()

    let project = Project.template
    let comment = Comment.template
      |> \.replyCount .~ 1
      |> \.status .~ .failed

    self.vm.inputs.configureWith(project: project, update: nil)
    self.vm.inputs.viewDidLoad()

    self.goToCommentRepliesComment.assertDidNotEmitValue()

    self.vm.inputs.didSelectComment(comment)

    self.goToCommentRepliesComment.assertDidNotEmitValue()
  }

  func testGoToCommentReplies_CommentHasNoReplies_GoToDoesNotEmit() {
    self.goToCommentRepliesComment.assertDidNotEmitValue()

    let project = Project.template
    let comment = Comment.template
      |> \.replyCount .~ 0

    self.vm.inputs.configureWith(project: project, update: nil)
    self.vm.inputs.viewDidLoad()

    self.goToCommentRepliesComment.assertDidNotEmitValue()

    self.vm.inputs.didSelectComment(comment)

    self.goToCommentRepliesComment.assertDidNotEmitValue()
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
    self.beginOrEndRefreshing.assertDidNotEmitValue()
    self.configureFooterViewWithState.assertDidNotEmitValue()

    let envelope = CommentsEnvelope.singleCommentTemplate
    let project = Project.template

    withEnvironment(apiService: MockService(fetchCommentsEnvelopeResult: .success(envelope))) {
      self.vm.inputs.configureWith(project: project, update: nil)
      self.vm.inputs.viewDidLoad()

      self.loadCommentsAndProjectIntoDataSourceComments.assertDidNotEmitValue()
      self.loadCommentsAndProjectIntoDataSourceProject.assertDidNotEmitValue()
      self.beginOrEndRefreshing.assertValues([true])
      self.configureFooterViewWithState.assertValues([.hidden])

      self.scheduler.advance()

      self.loadCommentsAndProjectIntoDataSourceComments.assertValues(
        [envelope.comments],
        "A set of comments is emitted."
      )
      self.loadCommentsAndProjectIntoDataSourceProject.assertValues([.template])
      self.beginOrEndRefreshing.assertValues([true, false])
      self.configureFooterViewWithState.assertValues([.hidden])

      let updatedEnvelope = CommentsEnvelope.multipleCommentTemplate

      withEnvironment(apiService: MockService(fetchCommentsEnvelopeResult: .success(updatedEnvelope))) {
        self.vm.inputs.willDisplayRow(3, outOf: 4)

        self.loadCommentsAndProjectIntoDataSourceComments.assertValues(
          [envelope.comments],
          "No new comments are emitted."
        )
        self.loadCommentsAndProjectIntoDataSourceProject.assertValues([.template])
        self.beginOrEndRefreshing.assertValues([true, false, true])
        self.configureFooterViewWithState.assertValues([.hidden, .activity])

        self.scheduler.advance()

        self.loadCommentsAndProjectIntoDataSourceComments.assertValueCount(2)

        self.loadCommentsAndProjectIntoDataSourceComments.assertValues(
          [envelope.comments, envelope.comments + updatedEnvelope.comments],
          "New comments are emitted."
        )
        self.loadCommentsAndProjectIntoDataSourceProject.assertValues([.template, .template])
        self.beginOrEndRefreshing.assertValues([true, false, true, false])
        self.configureFooterViewWithState.assertValues([.hidden, .activity, .hidden])
      }
    }
  }

  func testUpdatePagination_WhenLimitReached_CommentsAreLoadedIntoDataSource() {
    self.loadCommentsAndProjectIntoDataSourceComments.assertDidNotEmitValue()
    self.loadCommentsAndProjectIntoDataSourceProject.assertDidNotEmitValue()
    self.beginOrEndRefreshing.assertDidNotEmitValue()
    self.configureFooterViewWithState.assertDidNotEmitValue()

    let envelope = CommentsEnvelope.singleCommentTemplate
    let update = Update.template

    withEnvironment(apiService: MockService(fetchCommentsEnvelopeResult: .success(envelope))) {
      self.vm.inputs.configureWith(project: nil, update: update)
      self.vm.inputs.viewDidLoad()

      self.loadCommentsAndProjectIntoDataSourceComments.assertDidNotEmitValue()
      self.loadCommentsAndProjectIntoDataSourceProject.assertDidNotEmitValue()
      self.beginOrEndRefreshing.assertValues([true])
      self.configureFooterViewWithState.assertValues([.hidden])

      self.scheduler.advance()

      self.loadCommentsAndProjectIntoDataSourceComments.assertValues(
        [envelope.comments],
        "A set of comments is emitted."
      )
      self.loadCommentsAndProjectIntoDataSourceProject.assertValues([.template])
      self.beginOrEndRefreshing.assertValues([true, false])
      self.configureFooterViewWithState.assertValues([.hidden])

      let updatedEnvelope = CommentsEnvelope.multipleCommentTemplate

      withEnvironment(apiService: MockService(fetchCommentsEnvelopeResult: .success(updatedEnvelope))) {
        self.vm.inputs.willDisplayRow(3, outOf: 4)

        self.loadCommentsAndProjectIntoDataSourceComments.assertValues(
          [envelope.comments],
          "No new comments are emitted."
        )
        self.loadCommentsAndProjectIntoDataSourceProject.assertValues([.template])
        self.beginOrEndRefreshing.assertValues([true, false, true])
        self.configureFooterViewWithState.assertValues([.hidden, .activity])

        self.scheduler.advance()

        self.loadCommentsAndProjectIntoDataSourceComments.assertValueCount(2)

        self.loadCommentsAndProjectIntoDataSourceComments.assertValues(
          [envelope.comments, envelope.comments + updatedEnvelope.comments],
          "New comments are emitted."
        )
        self.loadCommentsAndProjectIntoDataSourceProject.assertValues([.template, .template])
        self.beginOrEndRefreshing.assertValues([true, false, true, false])
        self.configureFooterViewWithState.assertValues([.hidden, .activity, .hidden])
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
      self.beginOrEndRefreshing.assertValues([true], "loading begins")

      self.scheduler.advance()

      self.loadCommentsAndProjectIntoDataSourceComments
        .assertValues([envelope.comments], "New comments are emitted")
      self.loadCommentsAndProjectIntoDataSourceProject
        .assertValues([.template], "Same project is emitted again")
      self.beginOrEndRefreshing.assertValues([true, false], "loading ends")
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
      self.beginOrEndRefreshing.assertDidNotEmitValue()

      self.scheduler.advance()

      self.loadCommentsAndProjectIntoDataSourceComments.assertDidNotEmitValue()
      self.loadCommentsAndProjectIntoDataSourceProject.assertDidNotEmitValue()
      self.beginOrEndRefreshing.assertDidNotEmitValue()
    }
  }

  func testPostNewCommentFlow_Success() {
    let envelope = CommentsEnvelope.singleCommentTemplate
    let expectedSuccessfulPostResponse = Comment.template

    let mockService = MockService(
      fetchCommentsEnvelopeResult: .success(envelope),
      postCommentResult: .success(expectedSuccessfulPostResponse)
    )

    withEnvironment(apiService: mockService, currentUser: .template) {
      self.vm.inputs.configureWith(project: .template, update: nil)
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.loadCommentsAndProjectIntoDataSourceComments.assertValues([envelope.comments])

      let bodyText = "I just posted a comment."

      self.vm.inputs.commentComposerDidSubmitText(bodyText)

      let expectedFailableComment = Comment.failableComment(
        withId: self.uuidType.init().uuidString,
        date: MockDate().date,
        project: .template,
        user: .template,
        body: bodyText
      )

      XCTAssertEqual(
        self.loadCommentsAndProjectIntoDataSourceComments.values.last?.first,
        expectedFailableComment,
        "Failable temporary comment is emitted first."
      )

      XCTAssertEqual(
        self.loadCommentsAndProjectIntoDataSourceComments.values.last?.count,
        2,
        "The amount of comments in the data source doesn't change."
      )

      self.scheduler.advance()

      XCTAssertEqual(
        self.loadCommentsAndProjectIntoDataSourceComments.values.last?.first,
        expectedSuccessfulPostResponse,
        "After the request the actual comment is inserted, replacing the failable one."
      )

      XCTAssertEqual(
        self.loadCommentsAndProjectIntoDataSourceComments.values.last?.count,
        2,
        "The amount of comments in the data source doesn't change."
      )
    }
  }

  func testPostNewCommentFlow_Error() {
    let envelope = CommentsEnvelope.singleCommentTemplate

    let mockService = MockService(
      fetchCommentsEnvelopeResult: .success(envelope),
      postCommentResult: .failure(.couldNotParseJSON)
    )

    withEnvironment(apiService: mockService, currentUser: .template) {
      self.vm.inputs.configureWith(project: .template, update: nil)
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.loadCommentsAndProjectIntoDataSourceComments.assertValues([envelope.comments])

      let bodyText = "I just posted a comment."

      self.vm.inputs.commentComposerDidSubmitText(bodyText)

      let expectedFailableComment = Comment.failableComment(
        withId: self.uuidType.init().uuidString,
        date: MockDate().date,
        project: .template,
        user: .template,
        body: bodyText
      )

      XCTAssertEqual(
        self.loadCommentsAndProjectIntoDataSourceComments.values.last?.first,
        expectedFailableComment,
        "Failable temporary comment is emitted first."
      )

      self.scheduler.advance()

      let expectedFailedComment = expectedFailableComment
        |> \.status .~ .failed

      XCTAssertEqual(
        self.loadCommentsAndProjectIntoDataSourceComments.values.last?.first,
        expectedFailedComment,
        "If the request fails the failable comment is placed back in the data source with a failed status."
      )

      XCTAssertEqual(
        self.loadCommentsAndProjectIntoDataSourceComments.values.last?.count,
        2,
        "The amount of comments in the data source doesn't change."
      )
    }
  }

  func testRetryCommentFlow_Success() {
    let envelope = CommentsEnvelope.singleCommentTemplate

    let mockService1 = MockService(
      fetchCommentsEnvelopeResult: .success(envelope),
      postCommentResult: .failure(.couldNotParseJSON)
    )

    withEnvironment(apiService: mockService1, currentUser: .template) {
      self.vm.inputs.configureWith(project: .template, update: nil)
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.loadCommentsAndProjectIntoDataSourceComments.assertValues([envelope.comments])

      let bodyText = "I just posted a comment."

      self.vm.inputs.commentComposerDidSubmitText(bodyText)

      let expectedFailableComment = Comment.failableComment(
        withId: self.uuidType.init().uuidString,
        date: MockDate().date,
        project: .template,
        user: .template,
        body: bodyText
      )

      XCTAssertEqual(
        self.loadCommentsAndProjectIntoDataSourceComments.values.last?.first,
        expectedFailableComment,
        "Failable temporary comment is emitted first."
      )

      self.scheduler.advance()

      let expectedFailedComment = expectedFailableComment
        |> \.status .~ .failed

      XCTAssertEqual(
        self.loadCommentsAndProjectIntoDataSourceComments.values.last?.first,
        expectedFailedComment,
        "If the request fails the failable comment is placed back in the data source with a failed status."
      )

      XCTAssertEqual(
        self.loadCommentsAndProjectIntoDataSourceComments.values.last?.count,
        2,
        "The amount of comments in the data source doesn't change."
      )

      let expectedSuccessfulPostedComment = expectedFailableComment
        |> \.status .~ .success

      let mockService2 = MockService(
        fetchCommentsEnvelopeResult: .success(envelope),
        postCommentResult: .success(expectedSuccessfulPostedComment)
      )

      withEnvironment(apiService: mockService2) {
        // Tap on the failed comment to retry
        self.vm.inputs.didSelectComment(expectedFailedComment)

        // Tapping repeatedly is ignored (in the case where retries may be in flight).
        self.vm.inputs.didSelectComment(expectedFailedComment)
        self.vm.inputs.didSelectComment(expectedFailedComment)
        self.vm.inputs.didSelectComment(expectedFailedComment)

        let expectedRetryingComment = expectedFailedComment
          |> \.status .~ .retrying

        XCTAssertEqual(
          self.loadCommentsAndProjectIntoDataSourceComments.values.last?.first,
          expectedRetryingComment,
          "Comment is replaced with one with a retrying status."
        )

        self.scheduler.advance(by: .seconds(1))

        let expectedRetryingSuccessComment = expectedFailedComment
          |> \.body .~ bodyText
          |> \.status .~ .retrySuccess

        XCTAssertEqual(
          self.loadCommentsAndProjectIntoDataSourceComments.values.last?.first,
          expectedRetryingSuccessComment,
          "Comment is replaced with one with a retrySuccess status after elapsed time."
        )

        self.scheduler.advance(by: .seconds(3))

        XCTAssertEqual(
          self.loadCommentsAndProjectIntoDataSourceComments.values.last?.first,
          expectedSuccessfulPostedComment,
          "Comment is replaced with one with a success status after elapsed time."
        )
      }
    }
  }

  func testRetryCommentFlow_Error() {
    let envelope = CommentsEnvelope.singleCommentTemplate

    let mockService1 = MockService(
      fetchCommentsEnvelopeResult: .success(envelope),
      postCommentResult: .failure(.couldNotParseJSON)
    )

    withEnvironment(apiService: mockService1, currentUser: .template) {
      self.vm.inputs.configureWith(project: .template, update: nil)
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.loadCommentsAndProjectIntoDataSourceComments.assertValues([envelope.comments])

      let bodyText = "I just posted a comment."

      self.vm.inputs.commentComposerDidSubmitText(bodyText)

      let expectedFailableComment = Comment.failableComment(
        withId: self.uuidType.init().uuidString,
        date: MockDate().date,
        project: .template,
        user: .template,
        body: bodyText
      )

      XCTAssertEqual(
        self.loadCommentsAndProjectIntoDataSourceComments.values.last?.first,
        expectedFailableComment,
        "Failable temporary comment is emitted first."
      )

      self.scheduler.advance()

      let expectedFailedComment = expectedFailableComment
        |> \.status .~ .failed

      XCTAssertEqual(
        self.loadCommentsAndProjectIntoDataSourceComments.values.last?.first,
        expectedFailedComment,
        "If the request fails the failable comment is placed back in the data source with a failed status."
      )

      XCTAssertEqual(
        self.loadCommentsAndProjectIntoDataSourceComments.values.last?.count,
        2,
        "The amount of comments in the data source doesn't change."
      )

      let mockService2 = MockService(
        fetchCommentsEnvelopeResult: .success(envelope),
        postCommentResult: .failure(.couldNotParseJSON)
      )

      withEnvironment(apiService: mockService2) {
        // Tap on the failed comment to retry
        self.vm.inputs.didSelectComment(expectedFailedComment)

        let expectedRetryingComment = expectedFailedComment
          |> \.status .~ .retrying

        XCTAssertEqual(
          self.loadCommentsAndProjectIntoDataSourceComments.values.last?.first,
          expectedRetryingComment,
          "Comment is replaced with one with a retrying status."
        )

        self.scheduler.advance(by: .seconds(1))

        XCTAssertEqual(
          self.loadCommentsAndProjectIntoDataSourceComments.values.last?.first,
          expectedFailedComment,
          "Comment is replaced with original failed comment."
        )
      }
    }
  }

  func testViewingComments_WithNoComments_ShouldHaveCellSeparator() {
    self.cellSeparatorHidden.assertDidNotEmitValue()
    self.loadCommentsAndProjectIntoDataSourceProject.assertDidNotEmitValue()

    let envelope = CommentsEnvelope.emptyCommentsTemplate
    let project = Project.template
      |> Project.lens.personalization.isBacking .~ false

    withEnvironment(apiService: MockService(fetchCommentsEnvelopeResult: .success(envelope))) {
      self.vm.inputs.configureWith(
        project: project,
        update: nil
      )

      self.vm.inputs.viewDidLoad()

      self.loadCommentsAndProjectIntoDataSourceComments.assertDidNotEmitValue()
      self.cellSeparatorHidden.assertDidNotEmitValue()

      self.scheduler.advance()

      self.loadCommentsAndProjectIntoDataSourceComments.assertValues([envelope.comments])
      self.cellSeparatorHidden.assertValue(true)
    }
  }

  func testViewingComments_WithComments_ShouldHaveCellSeparator() {
    self.cellSeparatorHidden.assertDidNotEmitValue()
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
      self.cellSeparatorHidden.assertDidNotEmitValue()

      self.scheduler.advance()

      self.loadCommentsAndProjectIntoDataSourceComments.assertValues([envelope.comments])
      self.cellSeparatorHidden.assertValue(false)
    }
  }

  func testConfigureFooterViewWithState_HiddenOnViewDidLoad() {
    self.configureFooterViewWithState.assertDidNotEmitValue()

    let envelope = CommentsEnvelope.singleCommentTemplate
    let project = Project.template

    withEnvironment(apiService: MockService(fetchCommentsEnvelopeResult: .success(envelope))) {
      self.vm.inputs.configureWith(project: project, update: nil)
      self.vm.inputs.viewDidLoad()

      self.configureFooterViewWithState.assertValues([.hidden])
    }
  }

  func testConfigureFooterViewWithState_ErrorOnFirstPage() {
    self.configureFooterViewWithState.assertDidNotEmitValue()

    let envelope = CommentsEnvelope.singleCommentTemplate
    let project = Project.template

    withEnvironment(apiService: MockService(fetchCommentsEnvelopeResult: .failure(.couldNotParseJSON))) {
      self.vm.inputs.configureWith(project: project, update: nil)
      self.vm.inputs.viewDidLoad()

      self.configureFooterViewWithState.assertValues([.hidden])

      self.scheduler.advance()

      self.configureFooterViewWithState.assertValues([.hidden, .error], "Emits error state.")

      withEnvironment(apiService: MockService(fetchCommentsEnvelopeResult: .success(envelope))) {
        self.vm.inputs.commentTableViewFooterViewDidTapRetry()

        self.scheduler.advance()

        self.configureFooterViewWithState.assertValues([.hidden, .error, .hidden], "Returns to hidden.")
      }
    }
  }

  func testConfigureFooterViewWithState_ErrorOnNextPage() {
    self.configureFooterViewWithState.assertDidNotEmitValue()

    let envelope = CommentsEnvelope.singleCommentTemplate

    withEnvironment(apiService: MockService(fetchCommentsEnvelopeResult: .success(envelope))) {
      self.vm.inputs.configureWith(project: .template, update: nil)
      self.vm.inputs.viewDidLoad()

      self.configureFooterViewWithState.assertValues([.hidden])

      self.scheduler.advance()

      self.configureFooterViewWithState.assertValues([.hidden])

      let updatedEnvelope = CommentsEnvelope.multipleCommentTemplate

      withEnvironment(apiService: MockService(fetchCommentsEnvelopeResult: .success(updatedEnvelope))) {
        self.vm.inputs.willDisplayRow(3, outOf: 4)

        self.configureFooterViewWithState.assertValues(
          [.hidden, .activity], "Activity is shown during paging."
        )

        self.scheduler.advance()

        self.configureFooterViewWithState.assertValues(
          [.hidden, .activity, .hidden], "Returns to hidden."
        )

        // "Scrolling"
        self.vm.inputs.willDisplayRow(5, outOf: 10)

        withEnvironment(apiService: MockService(fetchCommentsEnvelopeResult: .failure(.couldNotParseJSON))) {
          self.vm.inputs.willDisplayRow(9, outOf: 10)

          self.configureFooterViewWithState.assertValues(
            [.hidden, .activity, .hidden, .activity], "Activity is shown during paging."
          )

          self.scheduler.advance()

          self.configureFooterViewWithState.assertValues(
            [.hidden, .activity, .hidden, .activity, .error], "Emits error state."
          )

          withEnvironment(
            apiService: MockService(fetchCommentsEnvelopeResult: .success(.singleCommentTemplate))
          ) {
            // Retry
            self.vm.inputs.commentTableViewFooterViewDidTapRetry()

            self.configureFooterViewWithState.assertValues(
              [.hidden, .activity, .hidden, .activity, .error, .activity], "Activity is shown during paging."
            )

            self.scheduler.advance()

            self.configureFooterViewWithState.assertValues(
              [.hidden, .activity, .hidden, .activity, .error, .activity, .hidden], "Returns to hidden."
            )
          }
        }
      }
    }
  }

  // TODO: Empty state not tested yet https://kickstarter.atlassian.net/browse/NT-1942
  // TODO: Post comments can be fully tested after this ticket is merged: https://kickstarter.atlassian.net/browse/NT-1893
}
