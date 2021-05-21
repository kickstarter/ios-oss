@testable import Kickstarter_Framework
@testable import KsApi
import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

internal final class CommentCellHeaderStackViewTests: TestCase {
  fileprivate let vm: CommentCellViewModelType = CommentCellViewModel()
  fileprivate let authorBadge = TestObserver<Comment.AuthorBadge, Never>()

  override func setUp() {
    super.setUp()

    AppEnvironment.pushEnvironment(mainBundle: Bundle.framework)
    self.vm.outputs.authorBadge.observe(self.authorBadge.observer)
  }

  override func tearDown() {
    super.tearDown()
    AppEnvironment.popEnvironment()
  }

  func testUserTagState() {
    let commentCellHeaderStackView =
      CommentCellHeaderStackView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 80))

    let authorBadgeStates = [
      "AuthorBadge_Is_Backer": Comment.AuthorBadge.backer,
      "AuthorBadge_Is_Superbacker": Comment.AuthorBadge.superbacker,
      "AuthorBadge_Is_Creator": Comment.AuthorBadge.creator,
      "AuthorBadge_Is_You": Comment.AuthorBadge.you
    ]

    let viewer = User.template |> \.id .~ 12_345

    for (key, authorBadge) in authorBadgeStates {
      self.vm.inputs.configureWith(comment: Comment.template(for: authorBadge), viewer: viewer)
      FBSnapshotVerifyView(commentCellHeaderStackView, identifier: "state_\(key)")
    }
  }
}
