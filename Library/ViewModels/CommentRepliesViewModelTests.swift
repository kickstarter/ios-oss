@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class CommentRepliesViewModelTests: TestCase {
  private let vm: CommentRepliesViewModelType = CommentRepliesViewModel()

  private let loadCommentIntoDataSourceComment = TestObserver<Comment, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.loadCommentIntoDataSource.observe(self.loadCommentIntoDataSourceComment.observer)
  }

  func testDataSource_WithComment_HasComment() {
    self.loadCommentIntoDataSourceComment.assertDidNotEmitValue()

    let rootComment = Comment.template

    withEnvironment {
      self.vm.inputs.configureWith(
        comment: rootComment
      )

      self.loadCommentIntoDataSourceComment.assertDidNotEmitValue()
      
      self.vm.inputs.viewDidLoad()

      self.loadCommentIntoDataSourceComment.assertValue(rootComment)
    }
  }
}
