@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class CommentCellViewModelTests: TestCase {
  let vm: CommentCellViewModelType = CommentCellViewModel()

  private let authorBadgeStyle = TestObserver<PaddingLabelStyle, Never>()
  private let authorImageURL = TestObserver<URL, Never>()
  private let body = TestObserver<String, Never>()
  private let authorName = TestObserver<String, Never>()
  private let postTime = TestObserver<String, Never>()
  private let stackViewAligment = TestObserver<UIStackView.Alignment, Never>()
  private let testLabel = { PaddingLabel(frame: .zero) }()

  override func setUp() {
    super.setUp()
    self.vm.outputs.authorBadgeStyleStackViewAlignment.map(first).observe(self.authorBadgeStyle.observer)
    self.vm.outputs.authorImageURL.observe(self.authorImageURL.observer)
    self.vm.outputs.body.observe(self.body.observer)
    self.vm.outputs.authorName.observe(self.authorName.observer)
    self.vm.outputs.postTime.observe(self.postTime.observer)
    self.vm.outputs.authorBadgeStyleStackViewAlignment.map(second).observe(self.stackViewAligment.observer)
  }

  func testOutputs() {
    let author = Comment.Author.template
      |> \.imageUrl .~ "http://www.kickstarter.com/small.jpg"

    let comment = Comment.template
      |> \.author .~ author

    let viewer = User.template |> \.id .~ 12_345

    self.vm.inputs.configureWith(comment: comment, viewer: viewer)

    self.authorImageURL.assertValues([URL(string: "http://www.kickstarter.com/small.jpg")!])
    self.body.assertValues([comment.body], "The comment body is emitted.")
    self.authorName.assertValues([comment.author.name], "The author's name is emitted.")
    self.postTime.assertValueCount(1, "The relative time of the comment is emitted.")

    self.stackViewAligment
      .assertValues([.center], "The stack view alignment of name and author's badge is emitted.")

    _ = self.testLabel
      |> self.authorBadgeStyle.lastValue!

    XCTAssertEqual(self.testLabel.text, "Creator")
  }

  func testOutputs_ViewerIs_LoggedOut() {
    let author = Comment.Author.template
      |> \.imageUrl .~ "http://www.kickstarter.com/small.jpg"

    let comment = Comment.template
      |> \.author .~ author

    self.vm.inputs.configureWith(comment: comment, viewer: nil)

    self.authorImageURL.assertValues([URL(string: "http://www.kickstarter.com/small.jpg")!])
    self.body.assertValues([comment.body], "The comment body is emitted.")
    self.authorName.assertValues([comment.author.name], "The author's name is emitted.")
    self.postTime.assertValueCount(1, "The relative time of the comment is emitted.")

    self.stackViewAligment
      .assertValues([.center], "The stack view alignment of name and author's badge is emitted.")

    _ = self.testLabel
      |> self.authorBadgeStyle.lastValue!

    XCTAssertEqual(self.testLabel.text, "Creator")
  }

  func testPersonalizedLabels_ViewerIs_Creator_Author() {
    let comment = Comment.template

    let viewer = User.template |> \.id .~ 12_345

    self.vm.inputs.configureWith(comment: comment, viewer: viewer)

    self.stackViewAligment
      .assertValues([.center], "The stack view alignment of name and author's badge is emitted.")

    _ = self.testLabel
      |> self.authorBadgeStyle.lastValue!

    XCTAssertEqual(self.testLabel.text, "Creator")
    XCTAssertEqual(self.testLabel.textColor, UIColor.ksr_create_700)
    XCTAssertEqual(self.testLabel.backgroundColor, UIColor.ksr_create_700.withAlphaComponent(0.06))
    XCTAssertEqual(self.testLabel.insets, .init(all: Styles.grid(1)))
  }

  func testPersonalizedLabels_Viewer_Is_You_Author() {
    let author = Comment.Author.template
      |> \.id .~ "12345"

    let comment = Comment.template
      |> \.author .~ author
      |> \.authorBadges .~ [.superbacker]

    let viewer = User.template |> \.id .~ 12_345

    self.vm.inputs.configureWith(comment: comment, viewer: viewer)

    self.stackViewAligment
      .assertValues([.center], "The stack view alignment of name and author's badge is emitted.")

    _ = self.testLabel
      |> self.authorBadgeStyle.lastValue!

    XCTAssertEqual(self.testLabel.text, "You")
    XCTAssertEqual(self.testLabel.textColor, UIColor.ksr_trust_700)
    XCTAssertEqual(self.testLabel.backgroundColor, UIColor.ksr_trust_100)
    XCTAssertEqual(self.testLabel.insets, .init(all: Styles.grid(1)))
  }

  func testPersonalizedLabels_ViewerIs_Superbacker_Author() {
    let comment = Comment.superbackerTemplate

    let viewer = User.template |> \.id .~ 12_345

    self.vm.inputs.configureWith(comment: comment, viewer: viewer)

    self.stackViewAligment
      .assertValues([.top], "The stack view alignment of name and author's badge is emiited.")

    _ = self.testLabel
      |> self.authorBadgeStyle.lastValue!

    XCTAssertEqual(self.testLabel.text, "SUPERBACKER")
    XCTAssertEqual(self.testLabel.font, UIFont.ksr_headline(size: 10))
    XCTAssertEqual(self.testLabel.textColor, UIColor.ksr_celebrate_500)
    XCTAssertEqual(self.testLabel.backgroundColor, .clear)
    XCTAssertEqual(self.testLabel.insets, .zero)
  }

  func testPersonalizedLabels_ViewerIs_Backer_Author() {
    let comment = Comment.backerTemplate

    let viewer = User.template |> \.id .~ 12_345

    self.vm.inputs.configureWith(comment: comment, viewer: viewer)

    self.stackViewAligment
      .assertValues([.center], "The stack view alignment of name and author's badge is emitted.")

    _ = self.testLabel
      |> self.authorBadgeStyle.lastValue!

    XCTAssertNil(self.testLabel.text)
  }
}
