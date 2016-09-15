import XCTest
import Result
import ReactiveCocoa
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers
import Prelude

internal final class CommentsViewModelTests: TestCase {
  internal let vm: CommentsViewModelType = CommentsViewModel()

  internal let hasComments = TestObserver<Bool, NoError>()
  internal let commentBarButtonVisible = TestObserver<Bool, NoError>()
  internal let emptyStateVisible = TestObserver<Void, NoError>()
  internal let presentPostCommentDialog = TestObserver<(Project, Update?), NoError>()
  internal let loginToutIsOpen = TestObserver<Bool, NoError>()
  internal let commentsAreLoading = TestObserver<Bool, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.dataSource.map { !$0.0.isEmpty }.observe(self.hasComments.observer)
    self.vm.outputs.commentBarButtonVisible.observe(self.commentBarButtonVisible.observer)
    self.vm.outputs.commentsAreLoading.observe(self.commentsAreLoading.observer)
    self.vm.outputs.emptyStateVisible.ignoreValues().observe(self.emptyStateVisible.observer)
    self.vm.outputs.presentPostCommentDialog.observe(self.presentPostCommentDialog.observer)

    Signal.merge(
      self.vm.outputs.openLoginTout.mapConst(true),
      self.vm.outputs.closeLoginTout.mapConst(false)
    ).observe(self.loginToutIsOpen.observer)
  }

  func testLoggedOutUser_ViewingEmptyState() {
    withEnvironment(apiService: MockService(fetchCommentsResponse: [])) {
      self.hasComments.assertValues([])
      self.emptyStateVisible.assertValueCount(0)
      self.commentBarButtonVisible.assertValues([])

      self.vm.inputs.configureWith(project: Project.template, update: nil)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.hasComments.assertValues([false], "Empty set of comments emitted.")
      self.emptyStateVisible.assertValueCount(1, "Empty state emitted.")
      self.commentBarButtonVisible.assertValues([false], "Comment button is not visible.")

      XCTAssertEqual(["Project Comment View", "Viewed Project Comments"], trackingClient.events)
      XCTAssertEqual([true, nil],
                     self.trackingClient.properties(forKey: Koala.DeprecatedKey, as: Bool.self))
    }
  }

  func testLoggedOutUser_ViewingComments() {
    self.hasComments.assertValues([])
    self.emptyStateVisible.assertValueCount(0)
    self.commentBarButtonVisible.assertValues([])

    self.vm.inputs.configureWith(project: Project.template, update: nil)
    self.vm.inputs.viewDidLoad()
    self.scheduler.advance()

    self.hasComments.assertValues([true], "A set of comments is emitted.")
    self.emptyStateVisible.assertValueCount(0)
    self.commentBarButtonVisible.assertValues([false], "Comment button is not visible.")
  }

  func testLoggedInNonBacker_ViewingEmptyState() {
    withEnvironment(apiService: MockService(fetchCommentsResponse: [])) {
      AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: User.template))

      self.hasComments.assertValues([])
      self.emptyStateVisible.assertValueCount(0)
      self.commentBarButtonVisible.assertValues([])

      self.vm.inputs.configureWith(project: .template |> Project.lens.personalization.isBacking .~ false,
                                   update: nil)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.hasComments.assertValues([false], "Empty set of comments is emitted.")
      self.emptyStateVisible.assertValueCount(1, "Empty state emitted.")
      self.commentBarButtonVisible.assertValues([false], "Comment button is not visible.")
    }
  }

  func testLoggedInBacker_ViewingEmptyState() {
    withEnvironment(apiService: MockService(fetchCommentsResponse: [])) {
      AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: User.template))

      self.hasComments.assertValues([])
      self.emptyStateVisible.assertValueCount(0)
      self.commentBarButtonVisible.assertValues([])

      self.vm.inputs.configureWith(project: .template |> Project.lens.personalization.isBacking .~ true,
                                   update: nil)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.hasComments.assertValues([false], "Empty set of comments is emitted.")
      self.emptyStateVisible.assertValueCount(1, "Empty state emitted.")
      self.commentBarButtonVisible.assertValues([false], "Comment button is visible.")
    }
  }

  func testRefreshing() {
    let comment = Comment.template

    withEnvironment(apiService: MockService(fetchCommentsResponse: [comment])) {
      self.vm.inputs.configureWith(project: Project.template, update: nil)
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
      self.vm.inputs.configureWith(project: Project.template, update: nil)
      self.vm.inputs.viewDidLoad()

      self.commentsAreLoading.assertValues([true])
      XCTAssertEqual(["Project Comment View", "Viewed Project Comments"], self.trackingClient.events)
      XCTAssertEqual([true, nil],
                     self.trackingClient.properties(forKey: Koala.DeprecatedKey, as: Bool.self))

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
        XCTAssertEqual(
          [
            "Project Comment View", "Viewed Project Comments", "Project Comment Load Older",
            "Loaded Older Project Comments"
          ],
          self.trackingClient.events)
        XCTAssertEqual([true, nil, true, nil],
                       self.trackingClient.properties(forKey: Koala.DeprecatedKey, as: Bool.self))

        self.vm.inputs.refresh()
        self.scheduler.advance()

        self.hasComments.assertValues([true, true, true], "Another set of comments are emitted.")
        XCTAssertEqual(
          [
            "Project Comment View", "Viewed Project Comments", "Project Comment Load Older",
            "Loaded Older Project Comments", "Project Comment Load New", "Loaded Newer Project Comments"
          ],
          self.trackingClient.events)
        XCTAssertEqual([true, nil, true, nil, true, nil],
                       self.trackingClient.properties(forKey: Koala.DeprecatedKey, as: Bool.self))
      }
    }
  }

  func testPaginationAndRefresh_Update() {
    let update = Update.template
    let project = Project.template

    withEnvironment(apiService: MockService(fetchCommentsResponse: [Comment.template])) {
      self.vm.inputs.configureWith(project: project, update: update)
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
      self.vm.inputs.configureWith(project: nil, update: update)
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
      self.commentBarButtonVisible.assertValues([])
      self.emptyStateVisible.assertValueCount(0)

      self.vm.inputs.configureWith(project: project, update: nil)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.hasComments.assertValues([false], "Empty set of comments is emitted.")
      self.commentBarButtonVisible.assertValues(
        [false], "Comment button is not visible since there's a button in the empty state.")
      self.emptyStateVisible.assertValueCount(1, "Empty state visible.")

      self.vm.inputs.commentButtonPressed()

      self.presentPostCommentDialog
        .assertValueCount(1, "Comment dialog presents after pressing comment button.")

      withEnvironment(apiService: MockService(fetchCommentsResponse: [Comment.template])) {
        self.vm.inputs.commentPosted(Comment.template)
        self.scheduler.advance()

        self.hasComments.assertValues([false, true], "Newly posted comment emits after posting.")
        self.emptyStateVisible.assertValueCount(1, "Empty state not visible again.")
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
      self.vm.inputs.configureWith(project: notBackingProject, update: nil)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.hasComments.assertValues([false], "No comments are emitted.")
      self.emptyStateVisible.assertValueCount(1, "Empty state emitted.")
      self.commentBarButtonVisible.assertValues([false], "Comment button is not visible.")

      self.vm.inputs.loginButtonPressed()

      self.loginToutIsOpen.assertValues([true], "Login prompt is opened.")

      withEnvironment(apiService: MockService(fetchProjectResponse: backingProject)) {

        AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: User.template))
        self.vm.inputs.userSessionStarted()

        self.loginToutIsOpen.assertValues([true, false], "Login prompt is closed.")
        self.hasComments.assertValues([false], "Still no comments are emitted.")
        self.emptyStateVisible.assertValueCount(2, "Empty state for backer shown.")
        self.commentBarButtonVisible.assertValues(
          [false], "Comment button is not visible since there's a button in the empty state.")
        self.presentPostCommentDialog.assertValueCount(1, "Immediately open the post comment dialog.")
      }
    }
  }

  func testNoProjectOrUpdate() {
    self.vm.inputs.configureWith(project: nil, update: nil)

    self.hasComments.assertDidNotEmitValue("Nothing emits when no project or update is provided.")
    self.commentBarButtonVisible.assertDidNotEmitValue("Nothing emits when no project or update is provided.")
    self.emptyStateVisible.assertDidNotEmitValue("Nothing emits when no project or update is provided.")
  }
}
