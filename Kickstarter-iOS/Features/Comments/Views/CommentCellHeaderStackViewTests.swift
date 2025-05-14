@testable import Kickstarter_Framework
@testable import KsApi
import Library
import Prelude
import ReactiveExtensions_TestHelpers
import SnapshotTesting
import XCTest

internal final class CommentCellHeaderStackViewTests: TestCase {
  private let vm: CommentCellViewModelType = CommentCellViewModel()
  private let commentCellHeaderStackView =
    CommentCellHeaderStackView(frame: CGRect(
      x: 0,
      y: 0,
      width: UIScreen.main.bounds.width,
      height: Styles.grid(9)
    ))

  override func setUp() {
    super.setUp()
    self.commentCellHeaderStackView.layer.backgroundColor = LegacyColors.ksr_white.uiColor().cgColor
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    UIView.setAnimationsEnabled(true)
    super.tearDown()
  }

  func testAuthorBadge_Backer() {
    self.commentCellHeaderStackView
      .configureWith(comment: Comment.backerTemplate)

    assertSnapshot(
      matching: self.commentCellHeaderStackView,
      as: .image,
      named: "state_AuthorBadge_Is_Backer"
    )
  }

  func testAuthorBadge_Collaborator() {
    self.commentCellHeaderStackView
      .configureWith(comment: Comment.collaboratorTemplate)

    assertSnapshot(
      matching: self.commentCellHeaderStackView,
      as: .image,
      named: "state_AuthorBadge_Is_Colaborator"
    )
  }

  func testAuthorBadge_Creator() {
    self.commentCellHeaderStackView
      .configureWith(comment: Comment.template)

    assertSnapshot(
      matching: self.commentCellHeaderStackView,
      as: .image,
      named: "state_AuthorBadge_Is_Creator"
    )
  }

  func testAuthorBadge_SuperBacker() {
    self.commentCellHeaderStackView
      .configureWith(comment: Comment.superbackerTemplate)

    assertSnapshot(
      matching: self.commentCellHeaderStackView,
      as: .image,
      named: "state_AuthorBadge_Is_Superbacker"
    )
  }

  func testAuthorBadge_You() {
    self.commentCellHeaderStackView
      .configureWith(comment: Comment.failedTemplate)

    assertSnapshot(matching: self.commentCellHeaderStackView, as: .image, named: "state_AuthorBadge_Is_You")
  }
}
