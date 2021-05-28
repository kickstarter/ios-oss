@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class CommentsViewModelTests: TestCase {
  internal let vm: CommentsViewModelType = CommentsViewModel()
  internal let commentsAreLoading = TestObserver<Bool, Never>()
  internal let hasComments = TestObserver<Bool, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.dataSource.map { comments, _ in !comments.isEmpty }
      .observe(self.hasComments.observer)
    self.vm.outputs.commentsAreLoading.observe(self.commentsAreLoading.observer)
  }

  func testLoggedOut_ViewingComments_CanViewComments() {
    withEnvironment(apiService: MockService(fetchCommentsEnvelopeResult: .success(.singleCommentTemplate))) {
      self.hasComments.assertDidNotEmitValue()

      self.vm.inputs.configureWith(
        project: .template |> Project.lens.personalization.isBacking .~ false,
        update: nil
      )
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.hasComments.assertValues([true], "A set of comments is emitted.")
    }
  }

  func testLoggedInNonBacker_ViewingComments_CanViewComments() {
    withEnvironment(apiService: MockService(fetchCommentsEnvelopeResult: .success(.singleCommentTemplate))) {
      AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: User.template))

      self.hasComments.assertDidNotEmitValue()

      self.vm.inputs.configureWith(
        project: .template |> Project.lens.personalization.isBacking .~ false,
        update: nil
      )
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.hasComments.assertValues([true], "A set of comments is emitted.")
    }
  }

  func testLoggedInBacker_ViewingComments_CanViewComments() {
    withEnvironment(apiService: MockService(fetchCommentsEnvelopeResult: .success(.singleCommentTemplate))) {
      AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: User.template))

      self.hasComments.assertDidNotEmitValue()

      self.vm.inputs.configureWith(
        project: .template |> Project.lens.personalization.isBacking .~ true,
        update: nil
      )
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.hasComments.assertValues([true], "A set of comments is emitted.")
    }
  }

  func testRefreshing_WhenNewCommentAdded_CanViewUpdatedComments() {
    withEnvironment(apiService: MockService(fetchCommentsEnvelopeResult: .success(.singleCommentTemplate))) {
      self.vm.inputs.configureWith(project: Project.template, update: nil)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.hasComments.assertValues([true], "A set of comments is emitted.")

      withEnvironment(apiService: MockService(fetchCommentsEnvelopeResult: .success(.multipleCommentTemplate))) {
        self.vm.inputs.refresh()

        self.hasComments.assertValues([true], "No new comments are emitted.")

        self.scheduler.advance()

        self.hasComments.assertValues([true, true], "Another set of comments are emitted.")
      }
    }
  }

  func testProjectPagination_WhenLimitReached_CanViewUpdatedComments() {
    withEnvironment(apiService: MockService(fetchCommentsEnvelopeResult: .success(.singleCommentTemplate))) {
      self.vm.inputs.configureWith(project: Project.template, update: nil)
      self.vm.inputs.viewDidLoad()

      self.commentsAreLoading.assertValues([true])

      self.scheduler.advance()

      self.hasComments.assertValues([true], "A set of comments is emitted.")
      self.commentsAreLoading.assertValues([true, false])

      withEnvironment(apiService: MockService(fetchCommentsEnvelopeResult: .success(.multipleCommentTemplate))) {
        self.vm.inputs.willDisplayRow(3, outOf: 4)

        self.hasComments.assertValues([true], "No new comments are emitted.")
        self.commentsAreLoading.assertValues([true, false, true])

        self.scheduler.advance()

        self.hasComments.assertValues([true, true], "Another set of comments are emitted.")
        self.commentsAreLoading.assertValues([true, false, true, false])
      }
    }
  }

  func testUpdatePagination_WhenLimitReached_CanViewUpdatedComments() {
    withEnvironment(apiService: MockService(fetchCommentsEnvelopeResult: .success(.singleCommentTemplate))) {
      self.vm.inputs.configureWith(project: nil, update: .template)
      self.vm.inputs.viewDidLoad()

      self.commentsAreLoading.assertValues([true])

      self.scheduler.advance()

      self.hasComments.assertValues([true], "A set of comments is emitted.")
      self.commentsAreLoading.assertValues([true, false])

      withEnvironment(apiService: MockService(fetchCommentsEnvelopeResult: .success(.multipleCommentTemplate))) {
        self.vm.inputs.willDisplayRow(3, outOf: 4)

        self.hasComments.assertValues([true], "No new comments are emitted.")
        self.commentsAreLoading.assertValues([true, false, true])

        self.scheduler.advance()

        self.hasComments.assertValues([true, true], "Another set of comments are emitted.")
        self.commentsAreLoading.assertValues([true, false, true, false])
      }
    }
  }

  func testComments_WhenOnlyUpdate_HasUpdatedComments() {
    withEnvironment(apiService: MockService(fetchCommentsEnvelopeResult: .success(.multipleCommentTemplate))) {
      self.hasComments.assertDidNotEmitValue("Nothing emits when no project or update is provided.")

      self.vm.inputs.configureWith(
        project: nil,
        update: .template
      )

      self.vm.inputs.viewDidLoad()

      self.commentsAreLoading.assertValues([true])

      self.scheduler.advance()

      self.hasComments.assertValues([true], "A set of comments is emitted.")
      self.commentsAreLoading.assertValues([true, false])
    }
  }

  func testComments_WhenNoProjectOrUpdate_HasNotUpdatedComments() {
    withEnvironment(apiService: MockService(fetchCommentsEnvelopeResult: .success(.multipleCommentTemplate))) {
      self.hasComments.assertDidNotEmitValue("Nothing emits when no project or update is provided.")

      self.vm.inputs.configureWith(project: nil, update: nil)

      self.vm.inputs.viewDidLoad()

      self.commentsAreLoading.assertDidNotEmitValue("Nothing emits when no project or update is provided.")

      self.scheduler.advance()

      self.hasComments.assertDidNotEmitValue("Nothing emits when no project or update is provided.")
      self.commentsAreLoading.assertDidNotEmitValue("Nothing emits when no project or update is provided.")
    }
  }

  // TODO: Empty state not tested yet
  // TODO: Post comments can be fully tested after this ticket is merged: NT-1893
}
