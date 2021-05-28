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

      self.loadCommentsAndProjectIntoDataSourceComments.assertValues([envelope.comments], "New comments are emitted")
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

      self.loadCommentsAndProjectIntoDataSourceComments.assertValues([envelope.comments], "New comments are emitted")
      self.loadCommentsAndProjectIntoDataSourceProject.assertValues([project], "New project is emitted")

      let updatedEnvelope = CommentsEnvelope.multipleCommentTemplate
      
      withEnvironment(apiService: MockService(fetchCommentsEnvelopeResult: .success(updatedEnvelope))) {
        self.vm.inputs.refresh()

        self.loadCommentsAndProjectIntoDataSourceComments.assertValues([envelope.comments], "No new comments are emitted")
        self.loadCommentsAndProjectIntoDataSourceProject.assertValues([project], "No new projects are emitted")

        self.scheduler.advance()

        self.loadCommentsAndProjectIntoDataSourceComments.assertValues([envelope.comments, updatedEnvelope.comments], "New comments are emitted")
        self.loadCommentsAndProjectIntoDataSourceProject.assertValues([project, project], "Same project is emitted again")
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

      self.loadCommentsAndProjectIntoDataSourceComments.assertValues([envelope.comments], "New comments are emitted")
      self.loadCommentsAndProjectIntoDataSourceProject.assertValues([.template], "Same project is emitted again")
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

  // TODO: Empty state not tested yet https://kickstarter.atlassian.net/browse/NT-1942
  // TODO: Post comments can be fully tested after this ticket is merged: https://kickstarter.atlassian.net/browse/NT-1893
}
