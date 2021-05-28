@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class CommentsViewModelTests: TestCase {
  internal let vm: CommentsViewModelType = CommentsViewModel()

  internal let isCommentsLoading = TestObserver<Bool, Never>()
  internal let loadCommentsAndProjectIntoDataSourceComments = TestObserver<[Comment], Never>()
  internal let loadCommentsAndProjectIntoDataSourceProject = TestObserver<Project, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.loadCommentsAndProjectIntoDataSource.map(first)
      .observe(self.loadCommentsAndProjectIntoDataSourceComments.observer)
    self.vm.outputs.loadCommentsAndProjectIntoDataSource.map(second)
      .observe(self.loadCommentsAndProjectIntoDataSourceProject.observer)
    self.vm.outputs.isCommentsLoading.observe(self.isCommentsLoading.observer)
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

//  func testLoggedInNonBacker_ViewingComments_CanViewComments() {
//    withEnvironment(apiService: MockService(fetchCommentsEnvelopeResult: .success(.singleCommentTemplate))) {
//      AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: User.template))
//
//      self.hasComments.assertDidNotEmitValue()
//
//      self.vm.inputs.configureWith(
//        project: .template |> Project.lens.personalization.isBacking .~ false,
//        update: nil
//      )
//      self.vm.inputs.viewDidLoad()
//      self.scheduler.advance()
//
//      self.hasComments.assertValues([true], "A set of comments is emitted.")
//    }
//  }
//
//  func testLoggedInBacker_ViewingComments_CanViewComments() {
//    withEnvironment(apiService: MockService(fetchCommentsEnvelopeResult: .success(.singleCommentTemplate))) {
//      AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: User.template))
//
//      self.hasComments.assertDidNotEmitValue()
//
//      self.vm.inputs.configureWith(
//        project: .template |> Project.lens.personalization.isBacking .~ true,
//        update: nil
//      )
//      self.vm.inputs.viewDidLoad()
//      self.scheduler.advance()
//
//      self.hasComments.assertValues([true], "A set of comments is emitted.")
//    }
//  }
//
//  func testRefreshing_WhenNewCommentAdded_CanViewUpdatedComments() {
//    withEnvironment(apiService: MockService(fetchCommentsEnvelopeResult: .success(.singleCommentTemplate))) {
//      self.vm.inputs.configureWith(project: Project.template, update: nil)
//      self.vm.inputs.viewDidLoad()
//      self.scheduler.advance()
//
//      self.hasComments.assertValues([true], "A set of comments is emitted.")
//
//      withEnvironment(apiService: MockService(fetchCommentsEnvelopeResult: .success(.multipleCommentTemplate))) {
//        self.vm.inputs.refresh()
//
//        self.hasComments.assertValues([true], "No new comments are emitted.")
//
//        self.scheduler.advance()
//
//        self.hasComments.assertValues([true, true], "Another set of comments are emitted.")
//      }
//    }
//  }
//
//  func testProjectPagination_WhenLimitReached_CanViewUpdatedComments() {
//    withEnvironment(apiService: MockService(fetchCommentsEnvelopeResult: .success(.singleCommentTemplate))) {
//      self.vm.inputs.configureWith(project: Project.template, update: nil)
//      self.vm.inputs.viewDidLoad()
//
//      self.isCommentsLoading.assertValues([true])
//
//      self.scheduler.advance()
//
//      self.hasComments.assertValues([true], "A set of comments is emitted.")
//      self.isCommentsLoading.assertValues([true, false])
//
//      withEnvironment(apiService: MockService(fetchCommentsEnvelopeResult: .success(.multipleCommentTemplate))) {
//        self.vm.inputs.willDisplayRow(3, outOf: 4)
//
//        self.hasComments.assertValues([true], "No new comments are emitted.")
//        self.isCommentsLoading.assertValues([true, false, true])
//
//        self.scheduler.advance()
//
//        self.hasComments.assertValues([true, true], "Another set of comments are emitted.")
//        self.isCommentsLoading.assertValues([true, false, true, false])
//      }
//    }
//  }
//
  func testUpdatePagination_WhenLimitReached_CanViewUpdatedComments() {
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

      let env2 = CommentsEnvelope.multipleCommentTemplate

      withEnvironment(apiService: MockService(fetchCommentsEnvelopeResult: .success(env2))) {
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
          [envelope.comments, envelope.comments + env2.comments],
          "New comments are emitted."
        )
        self.loadCommentsAndProjectIntoDataSourceProject.assertValues([.template, .template])
        self.isCommentsLoading.assertValues([true, false, true, false])
      }
    }
  }

//
//  func testComments_WhenOnlyUpdate_HasUpdatedComments() {
//    withEnvironment(apiService: MockService(fetchCommentsEnvelopeResult: .success(.multipleCommentTemplate))) {
//      self.hasComments.assertDidNotEmitValue("Nothing emits when no project or update is provided.")
//
//      self.vm.inputs.configureWith(
//        project: nil,
//        update: .template
//      )
//
//      self.vm.inputs.viewDidLoad()
//
//      self.isCommentsLoading.assertValues([true])
//
//      self.scheduler.advance()
//
//      self.hasComments.assertValues([true], "A set of comments is emitted.")
//      self.isCommentsLoading.assertValues([true, false])
//    }
//  }
//
//  func testComments_WhenNoProjectOrUpdate_HasNotUpdatedComments() {
//    withEnvironment(apiService: MockService(fetchCommentsEnvelopeResult: .success(.multipleCommentTemplate))) {
//      self.hasComments.assertDidNotEmitValue("Nothing emits when no project or update is provided.")
//
//      self.vm.inputs.configureWith(project: nil, update: nil)
//
//      self.vm.inputs.viewDidLoad()
//
//      self.isCommentsLoading.assertDidNotEmitValue("Nothing emits when no project or update is provided.")
//
//      self.scheduler.advance()
//
//      self.hasComments.assertDidNotEmitValue("Nothing emits when no project or update is provided.")
//      self.isCommentsLoading.assertDidNotEmitValue("Nothing emits when no project or update is provided.")
//    }
//  }

  // TODO: Empty state not tested yet
  // TODO: Post comments can be fully tested after this ticket is merged: NT-1893
}
