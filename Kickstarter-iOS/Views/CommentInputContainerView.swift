import Library
import Prelude
import UIKit

private enum Layout {
  enum Container {
    static let radius: CGFloat = 22
  }

  enum Button {
    static let height: CGFloat = 20.0
    static let width: CGFloat = 33.0
  }
}

final class CommentInputContainerView: UIView {
  // MARK: - Properties

  private let rootStackView: UIStackView = { UIStackView(frame: .zero) }()

  private lazy var inputTextView: CommentInputTextView = {
    CommentInputTextView(frame: .zero)
      |> \.delegate .~ self
  }()

  private let placeholderLabel: UILabel = { UILabel(frame: .zero) }()

  private lazy var postButton: UIButton = {
    UIButton(type: .system)
      |> \.isHidden .~ true
  }()

  private let characterLimit: Int = 9_000

  // MARK: - Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.configureViews()
    self.setupConstraints()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override var intrinsicContentSize: CGSize {
    return .zero
  }

  // MARK: - Views

  private func configureViews() {
    _ = self
      |> \.autoresizingMask .~ .flexibleHeight
      |> \.layoutMargins .~ .init(left: 18)

    _ = self.inputTextView |> \.delegate .~ self

    _ = ([self.inputTextView, self.postButton], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = (self.rootStackView, self)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = (self.placeholderLabel, self)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.postButton.heightAnchor.constraint(equalToConstant: Layout.Button.height),
      self.postButton.widthAnchor.constraint(equalToConstant: Layout.Button.width)
    ])
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self |> containerStyle

    _ = self.rootStackView
      |> rootStackViewStyle

    _ = self.placeholderLabel
      |> placeholderLabelStyle

    _ = self.postButton
      |> UIButton.lens.titleLabel.font %~ { _ in UIFont.ksr_body(size: 15).weighted(.semibold) }
      |> UIButton.lens.titleColor(for: .normal) %~ { _ in .ksr_create_700 }
      // To be replaced with a type-safe string when copy is available.
      |> UIButton.lens.title(for: .normal) %~ { _ in "Post" }
  }

  override func traitCollectionDidChange(_: UITraitCollection?) {
    self.inputTextView.invalidateIntrinsicContentSize()
  }
}

// MARK: - UITextViewDelegate

extension CommentInputContainerView: UITextViewDelegate {
  func textViewDidChange(_ textView: UITextView) {
    self.inputTextView.invalidateIntrinsicContentSize()
    self.handleEmptyState(textView.text.isEmpty)
  }

  private func handleEmptyState(_ isEmpty: Bool) {
    _ = self.placeholderLabel |> \.isHidden .~ !isEmpty
    _ = self.postButton |> \.isHidden .~ isEmpty
    _ = self.backgroundColor = isEmpty ? .ksr_support_100 : .ksr_white
  }

  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange,
                replacementText text: String) -> Bool {
    let currentText = textView.text ?? ""
    guard let stringRange = Range(range, in: currentText) else { return false }
    let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
    return updatedText.count <= self.characterLimit
  }
}

// MARK: - Styles

private let containerStyle: ViewStyle = { view in
  view
    |> \.backgroundColor .~ .ksr_support_100
    |> \.layer.borderColor .~ UIColor.ksr_support_300.cgColor
    |> \.layer.borderWidth .~ 1
    |> \.layer.cornerRadius .~ Layout.Container.radius
    |> \.clipsToBounds .~ true
}

private let rootStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ .horizontal
    |> \.distribution .~ .fill
    |> \.alignment .~ .bottom
    |> \.spacing .~ Styles.grid(1)
    |> \.layoutMargins .~ .init(topBottom: Styles.grid(2), leftRight: Styles.grid(3))
    |> \.isLayoutMarginsRelativeArrangement .~ true
}

private let placeholderLabelStyle: LabelStyle = { label in
  label
    |> \.textColor .~ .ksr_support_400
    |> \.font .~ UIFont.ksr_body(size: 15.0)
    // To be replaced with a type-safe string when copy is available.
    |> \.text .~ "Leave a comment..."
    |> \.adjustsFontForContentSizeCategory .~ true
}
