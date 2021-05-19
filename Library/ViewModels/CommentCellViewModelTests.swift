@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class CommentCellViewModelTests: TestCase {
  let vm: CommentCellViewModelType = CommentCellViewModel()

  let avatarImageURL = TestObserver<URL?, Never>()
  let body = TestObserver<String, Never>()
  let authorName = TestObserver<String, Never>()
  let postTime = TestObserver<String, Never>()
  let userTag = TestObserver<DemoComment.UserTagEnum, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.avatarImageURL.observe(self.avatarImageURL.observer)
    self.vm.outputs.body.observe(self.body.observer)
    self.vm.outputs.authorName.observe(self.authorName.observer)
    self.vm.outputs.postTime.observe(self.postTime.observer)
    self.vm.outputs.userTag.observe(self.userTag.observer)
  }

  func testOutputs() {
    let comment = DemoComment.template

    self.vm.inputs.configureWith(comment: comment)

    self.avatarImageURL.assertValueCount(1, "An avatar is emitted.")
    self.body.assertValues([comment.body], "The comment body is emitted.")
    self.authorName.assertValues([comment.authorName], "The author's name is emitted.")
    self.postTime.assertValues([comment.postTime], "The relative time of the comment is emitted.")
    self.userTag.assertValues([comment.userTag], "The author's tag for the comment is emitted.")
  }
}
