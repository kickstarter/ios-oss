import XCTest
import Result
import ReactiveCocoa
@testable import KsApi
@testable import KsApi_TestHelpers
@testable import Library
@testable import Models
@testable import Models_TestHelpers
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers
import Prelude

internal final class CommentsViewModelTests: TestCase {
  internal let vm: CommentsViewModelType = CommentsViewModel()

  internal var hasComments = TestObserver<Bool, NoError>()
  internal var commentButtonVisible = TestObserver<Bool, NoError>()
  internal var loggedOutEmptyStateVisible = TestObserver<Bool, NoError>()
  internal var nonBackerEmptyStateVisible = TestObserver<Bool, NoError>()
  internal var backerEmptyStateVisible = TestObserver<Bool, NoError>()
  internal let presentPostCommentDialog = TestObserver<(Project, Update?), NoError>()
  internal let loginToutIsOpen = TestObserver<Bool, NoError>()
  internal let commentsAreLoading = TestObserver<Bool, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.dataSource.map { !$0.0.isEmpty }.observe(self.hasComments.observer)
    self.vm.outputs.commentButtonVisible.observe(self.commentButtonVisible.observer)
    self.vm.outputs.loggedOutEmptyStateVisible.observe(self.loggedOutEmptyStateVisible.observer)
    self.vm.outputs.nonBackerEmptyStateVisible.observe(self.nonBackerEmptyStateVisible.observer)
    self.vm.outputs.backerEmptyStateVisible.observe(self.backerEmptyStateVisible.observer)
    self.vm.outputs.commentsAreLoading.observe(self.commentsAreLoading.observer)
    self.vm.outputs.presentPostCommentDialog.observe(self.presentPostCommentDialog.observer)

    Signal.merge(
      self.vm.outputs.openLoginTout.mapConst(true),
      self.vm.outputs.closeLoginTout.mapConst(false)
    ).observe(self.loginToutIsOpen.observer)
  }

  func testLoggedOutUser_ViewingEmptyState() {
    withEnvironment(apiService: MockService(fetchCommentsResponse: [])) {
      self.hasComments.assertValues([])
      self.loggedOutEmptyStateVisible.assertValues([])
      self.nonBackerEmptyStateVisible.assertValues([])
      self.backerEmptyStateVisible.assertValues([])
      self.commentButtonVisible.assertValues([])

      self.vm.inputs.project(Project.template, update: nil)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.hasComments.assertValues([false], "Empty set of comments emitted.")
      self.loggedOutEmptyStateVisible.assertValues([true], "Logged-out empty state is visible.")
      self.nonBackerEmptyStateVisible.assertValues([false], "Non-backer empty state is not visible.")
      self.backerEmptyStateVisible.assertValues([false], "Backer empty state is not visible.")
      self.commentButtonVisible.assertValues([false], "Comment button is not visible.")

      XCTAssertEqual(["Project Comment View"], trackingClient.events)
    }
  }

  func testLoggedOutUser_ViewingComments() {
    self.hasComments.assertValues([])
    self.loggedOutEmptyStateVisible.assertValues([])
    self.nonBackerEmptyStateVisible.assertValues([])
    self.backerEmptyStateVisible.assertValues([])
    self.commentButtonVisible.assertValues([])

    self.vm.inputs.project(Project.template, update: nil)
    self.vm.inputs.viewDidLoad()
    self.scheduler.advance()

    self.hasComments.assertValues([true], "A set of comments is emitted.")
    self.loggedOutEmptyStateVisible.assertValues([false], "Logged-out empty state is not visible.")
    self.nonBackerEmptyStateVisible.assertValues([false], "Non-backer empty state is not visible.")
    self.backerEmptyStateVisible.assertValues([false], "Backer empty state is not visible.")
    self.commentButtonVisible.assertValues([false], "Comment button is not visible.")
  }

  func testLoggedInNonBacker_ViewingEmptyState() {
    withEnvironment(apiService: MockService(fetchCommentsResponse: [])) {
      AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: User.template))

      self.hasComments.assertValues([])
      self.loggedOutEmptyStateVisible.assertValues([])
      self.nonBackerEmptyStateVisible.assertValues([])
      self.backerEmptyStateVisible.assertValues([])
      self.commentButtonVisible.assertValues([])

      self.vm.inputs.project(Project.template |> Project.lens.personalization.isBacking .~ false, update: nil)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.hasComments.assertValues([false], "Empty set of comments is emitted.")
      self.loggedOutEmptyStateVisible.assertValues([false], "Logged-out empty state is not visible.")
      self.nonBackerEmptyStateVisible.assertValues([true], "Non-backer empty state is visible.")
      self.backerEmptyStateVisible.assertValues([false], "Backer empty state is not visible.")
      self.commentButtonVisible.assertValues([false], "Comment button is not visible.")
    }
  }

  func testLoggedInBacker_ViewingEmptyState() {
    withEnvironment(apiService: MockService(fetchCommentsResponse: [])) {
      AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: User.template))

      self.hasComments.assertValues([])
      self.loggedOutEmptyStateVisible.assertValues([])
      self.nonBackerEmptyStateVisible.assertValues([])
      self.backerEmptyStateVisible.assertValues([])
      self.commentButtonVisible.assertValues([])

      self.vm.inputs.project(Project.template |> Project.lens.personalization.isBacking .~ true, update: nil)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.hasComments.assertValues([false], "Empty set of comments is emitted.")
      self.loggedOutEmptyStateVisible.assertValues([false], "Logged-out empty state is not visible.")
      self.nonBackerEmptyStateVisible.assertValues([false], "Non-backer empty state is not visible.")
      self.backerEmptyStateVisible.assertValues([true], "Backer empty state is visible.")
      self.commentButtonVisible.assertValues([false], "Comment button is visible.")
    }
  }

  func testRefreshing() {
    let comment = Comment.template

    withEnvironment(apiService: MockService(fetchCommentsResponse: [comment])) {
      self.vm.inputs.project(Project.template, update: nil)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.hasComments.assertValues([true], "A set of comments is emitted.")

      withEnvironment(apiService: MockService(fetchCommentsResponse: [comment, comment])) {
        self.vm.inputs.refresh()

        self.hasComments.assertValues([true], "No new comments are emitted.")

        self.scheduler.advance()

        self.hasComments.assertValues([true, true], "Another set of comments are emitted.")
      }
    }
  }

  func testPaginationAndRefresh_Project() {
    withEnvironment(apiService: MockService(fetchCommentsResponse: [Comment.template])) {
      self.vm.inputs.project(Project.template, update: nil)
      self.vm.inputs.viewDidLoad()

      self.commentsAreLoading.assertValues([true])
      XCTAssertEqual(["Project Comment View"], self.trackingClient.events)

      self.scheduler.advance()

      self.hasComments.assertValues([true], "A set of comments is emitted.")
      self.commentsAreLoading.assertValues([true, false])

      let otherComment = Comment.template |> Comment.lens.id .~ 2
      withEnvironment(apiService: MockService(fetchCommentsResponse: [otherComment])) {
        self.vm.inputs.willDisplayRow(3, outOf: 4)

        self.hasComments.assertValues([true], "No new comments are emitted.")
        self.commentsAreLoading.assertValues([true, false, true])

        self.scheduler.advance()

        self.hasComments.assertValues([true, true], "Another set of comments are emitted.")
        self.commentsAreLoading.assertValues([true, false, true, false])
        XCTAssertEqual(["Project Comment View", "Project Comment Load Older"],
                       self.trackingClient.events)

        self.vm.inputs.refresh()
        self.scheduler.advance()

        self.hasComments.assertValues([true, true, true], "Another set of comments are emitted.")
        XCTAssertEqual(["Project Comment View", "Project Comment Load Older", "Project Comment Load New"],
                       self.trackingClient.events)
      }
    }
  }

  func testPaginationAndRefresh_Update() {
    let update = Update.template
    let project = Project.template

    withEnvironment(apiService: MockService(fetchCommentsResponse: [Comment.template])) {
      self.vm.inputs.project(project, update: update)
      self.vm.inputs.viewDidLoad()

      self.commentsAreLoading.assertValues([true])
      XCTAssertEqual(["Update Comment View"], self.trackingClient.events)

      self.scheduler.advance()

      self.hasComments.assertValues([true], "A set of comments is emitted.")
      self.commentsAreLoading.assertValues([true, false])

      let otherComment = Comment.template |> Comment.lens.id .~ 2
      withEnvironment(apiService: MockService(fetchCommentsResponse: [otherComment])) {
        self.vm.inputs.willDisplayRow(3, outOf: 4)

        self.hasComments.assertValues([true], "No new comments are emitted.")
        self.commentsAreLoading.assertValues([true, false, true])

        self.scheduler.advance()

        self.hasComments.assertValues([true, true], "Another set of comments are emitted.")
        self.commentsAreLoading.assertValues([true, false, true, false])
        XCTAssertEqual(["Update Comment View", "Update Comment Load Older"],
                       self.trackingClient.events)

        self.vm.inputs.refresh()
        self.scheduler.advance()

        self.hasComments.assertValues([true, true, true], "Another set of comments are emitted.")
        XCTAssertEqual(["Update Comment View", "Update Comment Load Older", "Update Comment Load New"],
                       self.trackingClient.events)
      }
    }
  }

  func testUpdateComments_NoProjectProvided() {
    let update = Update.template

    withEnvironment(apiService: MockService(fetchCommentsResponse: [Comment.template])) {
      self.vm.inputs.project(nil, update: update)
      self.vm.inputs.viewDidLoad()

      self.commentsAreLoading.assertValues([true])
      XCTAssertEqual(["Update Comment View"], self.trackingClient.events)

      self.scheduler.advance()

      self.hasComments.assertValues([true], "A set of comments is emitted.")
      self.commentsAreLoading.assertValues([true, false])

      let otherComment = Comment.template |> Comment.lens.id .~ 2
      withEnvironment(apiService: MockService(fetchCommentsResponse: [otherComment])) {
        self.vm.inputs.willDisplayRow(3, outOf: 4)

        self.hasComments.assertValues([true], "No new comments are emitted.")
        self.commentsAreLoading.assertValues([true, false, true])

        self.scheduler.advance()

        self.hasComments.assertValues([true, true], "Another set of comments are emitted.")
        self.commentsAreLoading.assertValues([true, false, true, false])
        XCTAssertEqual(["Update Comment View", "Update Comment Load Older"],
                       self.trackingClient.events)

        self.vm.inputs.refresh()
        self.scheduler.advance()

        self.hasComments.assertValues([true, true, true], "Another set of comments are emitted.")
        XCTAssertEqual(["Update Comment View", "Update Comment Load Older", "Update Comment Load New"],
                       self.trackingClient.events)
      }
    }
  }

  // Tests the flow:
  //   * Backer views empty state of comments
  //   * Taps comment button
  //   * Posts a comment
  //   * Empty state goes away and comment shows
  func testLoggedInBacker_Commenting() {
    let project = Project.template |> Project.lens.personalization.isBacking .~ true

    withEnvironment(apiService: MockService(fetchCommentsResponse: [])) {
      AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: User.template))

      self.hasComments.assertValues([])
      self.commentButtonVisible.assertValues([])
      self.backerEmptyStateVisible.assertValues([])

      self.vm.inputs.project(project, update: nil)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.hasComments.assertValues([false], "Empty set of comments is emitted.")
      self.commentButtonVisible.assertValues(
        [false], "Comment button is not visible since there's a button in the empty state.")
      self.backerEmptyStateVisible.assertValues([true], "Backer empty state is visible.")

      self.vm.inputs.commentButtonPressed()

      self.presentPostCommentDialog
        .assertValueCount(1, "Comment dialog presents after pressing comment button.")

      withEnvironment(apiService: MockService(fetchCommentsResponse: [Comment.template])) {
        self.vm.inputs.commentPosted(Comment.template)
        self.scheduler.advance()

        self.hasComments.assertValues([false, true], "Newly posted comment emits after posting.")
        self.backerEmptyStateVisible.assertValues([true, false], "Backer empty state is not visible.")
      }
    }
  }

  // Tests the flow:
  //   * Logged out user views empty state
  //   * Taps login button and logs in
  //   * Empty state changes and comment dialog opens
  func testLoginFlow_Backer() {
    let notBackingProject = Project.template
    let backingProject = notBackingProject |> Project.lens.personalization.isBacking .~ true

    withEnvironment(apiService: MockService(fetchCommentsResponse: [])) {
      self.vm.inputs.project(notBackingProject, update: nil)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.hasComments.assertValues([false], "No comments are emitted.")
      self.loggedOutEmptyStateVisible.assertValues([true], "Logged out empty state is shown.")
      self.commentButtonVisible.assertValues([false], "Comment button is not visible.")

      self.vm.inputs.loginButtonPressed()

      self.loginToutIsOpen.assertValues([true], "Login prompt is opened.")

      withEnvironment(apiService: MockService(fetchProjectResponse: backingProject)) {

        AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: User.template))
        self.vm.inputs.userSessionStarted()

        self.loginToutIsOpen.assertValues([true, false], "Login prompt is closed.")
        self.hasComments.assertValues([false], "Still no comments are emitted.")
        self.loggedOutEmptyStateVisible.assertValues([true, false], "Logged out empty state is hidden.")
        self.backerEmptyStateVisible.assertValues([false, true], "Backer empty state is now shown.")
        self.commentButtonVisible.assertValues(
          [false], "Comment button is not visible since there's a button in the empty state.")
        self.presentPostCommentDialog.assertValueCount(1, "Immediately open the post comment dialog.")
      }
    }
  }

  func testNoProjectOrUpdate() {
    self.vm.inputs.project(nil, update: nil)

    self.hasComments.assertDidNotEmitValue("Nothing emits when no project or update is provided.")
    self.commentButtonVisible.assertDidNotEmitValue("Nothing emits when no project or update is provided.")
    self.backerEmptyStateVisible.assertDidNotEmitValue(
      "Nothing emits when no project or update is provided.")
    self.loggedOutEmptyStateVisible.assertDidNotEmitValue(
      "Nothing emits when no project or update is provided.")
    self.nonBackerEmptyStateVisible.assertDidNotEmitValue(
      "Nothing emits when no project or update is provided.")
  }
}
