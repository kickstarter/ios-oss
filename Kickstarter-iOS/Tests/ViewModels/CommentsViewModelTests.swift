import XCTest
import Result
import ReactiveCocoa
@testable import Kickstarter_iOS
@testable import KsApi
@testable import KsApi_TestHelpers
@testable import Library
@testable import Models
@testable import Models_TestHelpers
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers

internal final class CommentsViewModelTests: TestCase {
  internal let vm: CommentsViewModelType = CommentsViewModel()

  internal var hasComments = TestObserver<Bool, NoError>()
  internal var commentButtonVisible = TestObserver<Bool, NoError>()
  internal var loggedOutEmptyStateVisible = TestObserver<Bool, NoError>()
  internal var nonBackerEmptyStateVisible = TestObserver<Bool, NoError>()
  internal var backerEmptyStateVisible = TestObserver<Bool, NoError>()
  internal var postCommentDialogPresented = TestObserver<Bool, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.comments.map { !$0.isEmpty }.observe(self.hasComments.observer)
    self.vm.outputs.commentButtonVisible.observe(self.commentButtonVisible.observer)
    self.vm.outputs.loggedOutEmptyStateVisible.observe(self.loggedOutEmptyStateVisible.observer)
    self.vm.outputs.nonBackerEmptyStateVisible.observe(self.nonBackerEmptyStateVisible.observer)
    self.vm.outputs.backerEmptyStateVisible.observe(self.backerEmptyStateVisible.observer)
    self.vm.outputs.postCommentDialogPresented.observe(self.postCommentDialogPresented.observer)
  }

  func testLoggedOutUser_ViewingEmptyState() {
    withEnvironment(apiService: MockService(fetchCommentsResponse: [])) {
      self.hasComments.assertValues([])
      self.loggedOutEmptyStateVisible.assertValues([])
      self.nonBackerEmptyStateVisible.assertValues([])
      self.backerEmptyStateVisible.assertValues([])
      self.commentButtonVisible.assertValues([])

      self.vm.inputs.project(ProjectFactory.live())
      self.vm.inputs.viewWillAppear()

      self.hasComments.assertValues([false], "Empty set of comments emitted.")
      self.loggedOutEmptyStateVisible.assertValues([true], "Logged-out empty state is visible.")
      self.nonBackerEmptyStateVisible.assertValues([], "Non-backer empty state is not visible.")
      self.backerEmptyStateVisible.assertValues([], "Backer empty state is not visible.")
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

    self.vm.inputs.project(ProjectFactory.live())
    self.vm.inputs.viewWillAppear()

    self.hasComments.assertValues([true], "A set of comments is emitted.")
    self.loggedOutEmptyStateVisible.assertValues([], "Logged-out empty state is not visible.")
    self.nonBackerEmptyStateVisible.assertValues([], "Non-backer empty state is not visible.")
    self.backerEmptyStateVisible.assertValues([], "Backer empty state is not visible.")
    self.commentButtonVisible.assertValues([false], "Comment button is not visible.")
  }

  func testLoggedInNonBacker_ViewingEmptyState() {
    withEnvironment(apiService: MockService(fetchCommentsResponse: [])) {
      AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: UserFactory.user))

      self.hasComments.assertValues([])
      self.loggedOutEmptyStateVisible.assertValues([])
      self.nonBackerEmptyStateVisible.assertValues([])
      self.backerEmptyStateVisible.assertValues([])
      self.commentButtonVisible.assertValues([])

      self.vm.inputs.project(ProjectFactory.notBacking)
      self.vm.inputs.viewWillAppear()

      self.hasComments.assertValues([false], "Empty set of comments is emitted.")
      self.loggedOutEmptyStateVisible.assertValues([], "Logged-out empty state is not visible.")
      self.nonBackerEmptyStateVisible.assertValues([true], "Non-backer empty state is visible.")
      self.backerEmptyStateVisible.assertValues([], "Backer empty state is not visible.")
      self.commentButtonVisible.assertValues([false], "Comment button is not visible.")
    }
  }

  func testLoggedInBacker_ViewingEmptyState() {
    withEnvironment(apiService: MockService(fetchCommentsResponse: [])) {
      AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: UserFactory.user))

      self.hasComments.assertValues([])
      self.loggedOutEmptyStateVisible.assertValues([])
      self.nonBackerEmptyStateVisible.assertValues([])
      self.backerEmptyStateVisible.assertValues([])
      self.commentButtonVisible.assertValues([])

      self.vm.inputs.project(ProjectFactory.backing)
      self.vm.inputs.viewWillAppear()

      self.hasComments.assertValues([false], "Empty set of comments is emitted.")
      self.loggedOutEmptyStateVisible.assertValues([], "Logged-out empty state is not visible.")
      self.nonBackerEmptyStateVisible.assertValues([], "Non-backer empty state is not visible.")
      self.backerEmptyStateVisible.assertValues([true], "Backer empty state is visible.")
      self.commentButtonVisible.assertValues([true], "Comment button is visible.")
    }
  }

  func testLoggedInBacker_Commenting() {
    withEnvironment(apiService: MockService(fetchCommentsResponse: [])) {
      AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: UserFactory.user))

      self.hasComments.assertValues([])
      self.commentButtonVisible.assertValues([])
      self.backerEmptyStateVisible.assertValues([])

      self.vm.inputs.project(ProjectFactory.backing)
      self.vm.inputs.viewWillAppear()

      self.hasComments.assertValues([false], "Empty set of comments is emitted.")
      self.commentButtonVisible.assertValues([true], "Comment button is visible.")
      self.backerEmptyStateVisible.assertValues([true], "Backer empty state is visible.")

      self.vm.inputs.commentButtonPressed()

      self.postCommentDialogPresented.assertValues([true],
                                                   "Comment dialog presents after pressing comment button.")

      self.vm.inputs.cancelCommentButtonPressed()

      self.postCommentDialogPresented.assertValues([true, false],
                                                   "Comment dialog dismisses after pressing cancel button.")

      self.vm.inputs.commentButtonPressed()

      self.postCommentDialogPresented.assertValues([true, false, true],
                                                   "Comment dialog re-appears after pressing comment button.")

      withEnvironment(apiService: MockService(fetchCommentsResponse: [CommentFactory.comment()])) {
        self.vm.inputs.commentPosted()

        self.postCommentDialogPresented.assertValues([true, false, true, false],
                                                     "Comment dialog dismisses after posting comment.")
        self.hasComments.assertValues([false, true], "Newly posted comment emits after posting.")
        self.backerEmptyStateVisible.assertValues([true, false], "Backer empty state is not visible.")
      }
    }
  }
}
