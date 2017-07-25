// swiftlint:disable force_unwrapping
import XCTest
import Result
import ReactiveSwift
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers
import Prelude

internal final class CommentsViewModelTests: TestCase {
  internal let vm: CommentsViewModelType = CommentsViewModel()

  internal let emptyStateVisible = TestObserver<Bool, NoError>()
  internal let hasComments = TestObserver<Bool, NoError>()
  internal let commentBarButtonVisible = TestObserver<Bool, NoError>()
  internal let presentPostCommentDialog = TestObserver<(Project, Update?), NoError>()
  internal let loginToutIsOpen = TestObserver<Bool, NoError>()
  internal let commentsAreLoading = TestObserver<Bool, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.dataSource.map { _, _, _, _, visible in visible }.observe(self.emptyStateVisible.observer)
    self.vm.outputs.dataSource.map { comments, _, _, _, _ in !comments.isEmpty }
        .observe(self.hasComments.observer)
    self.vm.outputs.commentBarButtonVisible.observe(self.commentBarButtonVisible.observer)
    self.vm.outputs.commentsAreLoading.observe(self.commentsAreLoading.observer)
    self.vm.outputs.presentPostCommentDialog.observe(self.presentPostCommentDialog.observer)

    Signal.merge(
      self.vm.outputs.openLoginTout.mapConst(true),
      self.vm.outputs.closeLoginTout.mapConst(false)
    ).observe(self.loginToutIsOpen.observer)
  }

  func testLoggedOutUser_ViewingEmptyState() {
    withEnvironment(apiService: MockService(fetchCommentsResponse: [])) {
      self.hasComments.assertDidNotEmitValue()
      self.emptyStateVisible.assertDidNotEmitValue()
      self.commentBarButtonVisible.assertDidNotEmitValue()

      self.vm.inputs.configureWith(project: Project.template, update: nil)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.hasComments.assertValues([false], "Empty set of comments emitted.")
      self.emptyStateVisible.assertValues([true], "Empty state emitted.")
      self.commentBarButtonVisible.assertValues([false], "Comment button is not visible.")

      XCTAssertEqual(["Project Comment View", "Viewed Comments"], self.trackingClient.events)
      XCTAssertEqual("project", self.trackingClient.properties.last!["context"] as? String)
      XCTAssertEqual([true, nil],
                     self.trackingClient.properties(forKey: Koala.DeprecatedKey, as: Bool.self))
    }
  }

  func testLoggedOutUser_ViewingComments() {
    self.hasComments.assertDidNotEmitValue()
    self.emptyStateVisible.assertDidNotEmitValue()
    self.commentBarButtonVisible.assertDidNotEmitValue()

    self.vm.inputs.configureWith(project: Project.template, update: nil)
    self.vm.inputs.viewDidLoad()
    self.scheduler.advance()

    self.hasComments.assertValues([true], "A set of comments is emitted.")
    self.emptyStateVisible.assertValues([false], "Empty state is hidden.")
    self.commentBarButtonVisible.assertValues([false], "Comment button is not visible.")
  }

  func testLoggedInNonBacker_ViewingEmptyState() {
    withEnvironment(apiService: MockService(fetchCommentsResponse: [])) {
      AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: User.template))

      self.hasComments.assertDidNotEmitValue()
      self.emptyStateVisible.assertDidNotEmitValue()
      self.commentBarButtonVisible.assertDidNotEmitValue()

      self.vm.inputs.configureWith(project: .template |> Project.lens.personalization.isBacking .~ false,
                                   update: nil)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.hasComments.assertValues([false], "Empty set of comments is emitted.")
      self.emptyStateVisible.assertValues([true], "Empty state emitted.")
      self.commentBarButtonVisible.assertValues([false], "Comment button is not visible.")
    }
  }

  func testLoggedInBacker_ViewingEmptyState() {
    withEnvironment(apiService: MockService(fetchCommentsResponse: [])) {
      AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: User.template))

      self.hasComments.assertDidNotEmitValue()
      self.emptyStateVisible.assertDidNotEmitValue()
      self.commentBarButtonVisible.assertDidNotEmitValue()

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
      XCTAssertEqual(["Project Comment View", "Viewed Comments"], self.trackingClient.events)
      XCTAssertEqual("project", self.trackingClient.properties.last!["context"] as? String)
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
          ["Project Comment View", "Viewed Comments", "Project Comment Load Older", "Loaded Older Comments"],
          self.trackingClient.events)
        XCTAssertEqual([true, nil, true, nil],
                       self.trackingClient.properties(forKey: Koala.DeprecatedKey, as: Bool.self))
        XCTAssertEqual("project", self.trackingClient.properties.last!["context"] as? String)

        self.vm.inputs.refresh()
        self.scheduler.advance()

        self.hasComments.assertValues([true, true, true], "Another set of comments are emitted.")
        XCTAssertEqual(
          [
            "Project Comment View", "Viewed Comments", "Project Comment Load Older", "Loaded Older Comments",
            "Project Comment Load New", "Loaded Newer Comments"
          ],
          self.trackingClient.events)
        XCTAssertEqual("project", self.trackingClient.properties.last!["context"] as? String)
        XCTAssertEqual([true, nil, true, nil, true, nil],
                       self.trackingClient.properties(forKey: Koala.DeprecatedKey, as: Bool.self))
      }
    }
  }

  func testPaginationAndRefresh_Update() {
    let update = Update.template

    withEnvironment(apiService: MockService(fetchUpdateCommentsResponse: Result(.template))) {
      self.vm.inputs.configureWith(project: nil, update: update)
      self.vm.inputs.viewDidLoad()

      self.commentsAreLoading.assertValues([true])
      XCTAssertEqual(["Update Comment View", "Viewed Comments"], self.trackingClient.events)
      XCTAssertEqual("update", self.trackingClient.properties.last!["context"] as? String)

      self.scheduler.advance()

      self.hasComments.assertValues([true], "A set of comments is emitted.")
      self.commentsAreLoading.assertValues([true, false])

      withEnvironment(apiService: MockService(fetchUpdateCommentsResponse: Result(.template))) {
        self.vm.inputs.willDisplayRow(3, outOf: 4)

        self.hasComments.assertValues([true], "No new comments are emitted.")
        self.commentsAreLoading.assertValues([true, false, true])

        self.scheduler.advance()

        self.hasComments.assertValues([true, true], "Another set of comments are emitted.")
        self.commentsAreLoading.assertValues([true, false, true, false])
        XCTAssertEqual(
          ["Update Comment View", "Viewed Comments", "Update Comment Load Older", "Loaded Older Comments"],
          self.trackingClient.events
        )
        XCTAssertEqual("update", self.trackingClient.properties.last!["context"] as? String)

        self.vm.inputs.refresh()
        self.scheduler.advance()

        self.hasComments.assertValues([true, true, true], "Another set of comments are emitted.")
        XCTAssertEqual(
          ["Update Comment View", "Viewed Comments", "Update Comment Load Older", "Loaded Older Comments",
           "Update Comment Load New", "Loaded Newer Comments"],
          self.trackingClient.events
        )
        XCTAssertEqual("update", self.trackingClient.properties.last!["context"] as? String)
      }
    }
  }

  func testUpdateComments_NoProjectProvided() {
    let update = Update.template

    withEnvironment(apiService: MockService(fetchUpdateCommentsResponse: Result(.template))) {
      self.vm.inputs.configureWith(project: nil, update: update)
      self.vm.inputs.viewDidLoad()

      self.commentsAreLoading.assertValues([true])
      XCTAssertEqual(["Update Comment View", "Viewed Comments"], self.trackingClient.events)
      XCTAssertEqual("update", self.trackingClient.properties.last!["context"] as? String)

      self.scheduler.advance()

      self.hasComments.assertValues([true], "A set of comments is emitted.")
      self.commentsAreLoading.assertValues([true, false])

      withEnvironment(apiService: MockService(fetchUpdateCommentsResponse: Result(.template))) {
        self.vm.inputs.willDisplayRow(3, outOf: 4)

        self.hasComments.assertValues([true], "No new comments are emitted.")
        self.commentsAreLoading.assertValues([true, false, true])

        self.scheduler.advance()

        self.hasComments.assertValues([true, true], "Another set of comments are emitted.")
        self.commentsAreLoading.assertValues([true, false, true, false])
        XCTAssertEqual(
          ["Update Comment View", "Viewed Comments", "Update Comment Load Older", "Loaded Older Comments"],
          self.trackingClient.events
        )
        XCTAssertEqual("update", self.trackingClient.properties.last!["context"] as? String)

        self.vm.inputs.refresh()
        self.scheduler.advance()

        self.hasComments.assertValues([true, true, true], "Another set of comments are emitted.")
        XCTAssertEqual(
          ["Update Comment View", "Viewed Comments", "Update Comment Load Older", "Loaded Older Comments",
           "Update Comment Load New", "Loaded Newer Comments"],
          self.trackingClient.events
        )
        XCTAssertEqual("update", self.trackingClient.properties.last!["context"] as? String)
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

      self.hasComments.assertDidNotEmitValue()
      self.commentBarButtonVisible.assertDidNotEmitValue()
      self.emptyStateVisible.assertDidNotEmitValue()

      self.vm.inputs.configureWith(project: project, update: nil)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.hasComments.assertValues([false], "Empty set of comments is emitted.")
      self.emptyStateVisible.assertValues([true])
      self.commentBarButtonVisible.assertValues(
        [false], "Comment button is not visible since there's a button in the empty state.")

      self.vm.inputs.commentButtonPressed()

      self.presentPostCommentDialog
        .assertValueCount(1, "Comment dialog presents after pressing comment button.")

      withEnvironment(apiService: MockService(fetchCommentsResponse: [Comment.template])) {
        self.vm.inputs.commentPosted(Comment.template)
        self.scheduler.advance()

        self.hasComments.assertValues([false, false, true], "Newly posted comment emits after posting.")
        self.emptyStateVisible.assertValues([true, false, false], "Empty state not visible again.")
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
      self.emptyStateVisible.assertValues([true], "Empty state emitted.")
      self.commentBarButtonVisible.assertValues([false], "Comment button is not visible.")

      self.vm.inputs.loginButtonPressed()

      self.loginToutIsOpen.assertValues([true], "Login prompt is opened.")

      withEnvironment(apiService: MockService(fetchProjectResponse: backingProject)) {

        AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: User.template))
        self.vm.inputs.userSessionStarted()

        self.loginToutIsOpen.assertValues([true, false], "Login prompt is closed.")
        self.hasComments.assertValues([false, false, false], "Still no comments are emitted.")
        self.emptyStateVisible.assertValues([true, true, true], "Empty state for backer shown.")
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
