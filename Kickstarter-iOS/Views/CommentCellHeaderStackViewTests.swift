@testable import Kickstarter_Framework
@testable import KsApi
import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

internal final class CommentCellHeaderStackViewTests: TestCase {
  fileprivate let vm: CommentCellViewModelType = CommentCellViewModel()
  fileprivate let userTag = TestObserver<DemoComment.UserTagEnum, Never>()

  override func setUp() {
    super.setUp()

    AppEnvironment.pushEnvironment(mainBundle: Bundle.framework)
    self.vm.outputs.userTag.observe(self.userTag.observer)
  }

  override func tearDown() {
    super.tearDown()
    AppEnvironment.popEnvironment()
  }

  func testUserTagState() {
    let commentCellHeaderStackView =
      CommentCellHeaderStackView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 45))

    let userTagStates = [
      "Tag_Is_Backer": DemoComment.UserTagEnum.backer,
      "Tag_Is_Superbacker": DemoComment.UserTagEnum.superbacker,
      "Tag_Is_Creator": DemoComment.UserTagEnum.creator,
      "Tag_Is_You": DemoComment.UserTagEnum.you
    ]

    for (key, tag) in userTagStates {
      self.vm.inputs.configureWith(comment: DemoComment.template(for: tag))
      FBSnapshotVerifyView(commentCellHeaderStackView, identifier: "state_\(key)")
    }
  }
}
