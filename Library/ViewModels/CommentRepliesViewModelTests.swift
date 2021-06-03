@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class CommentRepliesViewModelTests: TestCase {
  private let vm: CommentRepliesViewModelType = CommentRepliesViewModel()

  private let loadCommentAndProjectIntoDataSourceComment = TestObserver<Comment, Never>()
  private let loadCommentAndProjectIntoDataSourceProject = TestObserver<Project, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.loadCommentAndProjectIntoDataSource.map(first)
      .observe(self.loadCommentAndProjectIntoDataSourceComment.observer)
    self.vm.outputs.loadCommentAndProjectIntoDataSource.map(second)
      .observe(self.loadCommentAndProjectIntoDataSourceProject.observer)
  }

  func testViewingRootComment_WithCommentAndProject_CommentIsLoadedIntoDataSource() {
    self.loadCommentAndProjectIntoDataSourceComment.assertDidNotEmitValue()
    self.loadCommentAndProjectIntoDataSourceProject.assertDidNotEmitValue()

    let rootComment = Comment.template
    let project = Project.template
      |> Project.lens.personalization.isBacking .~ false

    withEnvironment {
      self.vm.inputs.configureWith(
        comment: rootComment,
        project: project
      )

      self.vm.inputs.viewDidLoad()

      self.loadCommentAndProjectIntoDataSourceComment.assertValue(rootComment)
      self.loadCommentAndProjectIntoDataSourceProject.assertValue(project)
    }
  }
}
