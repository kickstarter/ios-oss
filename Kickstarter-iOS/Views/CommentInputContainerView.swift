import Library
import Prelude
import UIKit

private enum Layout {
  enum Container {
    // Using the radius of 30 specified in the design won't achieve
    // the corner radius look for the same height of 44 of the container on the iOS App.
    static let radius: CGFloat = 22
  }

  enum Button {
    static let bottomMargin: CGFloat = 12.0
    static let rightMargin: CGFloat = 18.0
    static let height: CGFloat = 20.0
    static let width: CGFloat = 33.0
  }

  enum TextView {
    static let leftMargin: CGFloat = 14.0
    static let rightMargin: CGFloat = 5.0
    static let yMargin: CGFloat = 12.0
  }

  enum Placeholder {
    static let xMargin: CGFloat = 18.0
    static let yMargin: CGFloat = 13.0
  }
}

final class CommentInputContainerView: UIView {
  // MARK: - Properties

  private lazy var inputTextView: CommentInputTextView = {
    CommentInputTextView(frame: .zero)
      |> \.delegate .~ self
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private let placeholderLabel: UILabel = {
    UILabel(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var postButton: UIButton = {
    UIButton(type: .system)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
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
    _ = self |> \.autoresizingMask .~ .flexibleHeight

    _ = self.inputTextView |> \.delegate .~ self

    _ = (self.inputTextView, self)
      |> ksr_addSubviewToParent()

    _ = (self.placeholderLabel, self)
      |> ksr_addSubviewToParent()

    _ = (self.postButton, self)
      |> ksr_addSubviewToParent()
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.postButton.bottomAnchor
        .constraint(equalTo: self.bottomAnchor, constant: -Layout.Button.bottomMargin),
      self.postButton.trailingAnchor
        .constraint(equalTo: self.trailingAnchor, constant: -Layout.Button.rightMargin),
      self.postButton.heightAnchor.constraint(equalToConstant: Layout.Button.height),
      self.postButton.widthAnchor.constraint(equalToConstant: Layout.Button.width),
      self.inputTextView.leadingAnchor
        .constraint(equalTo: self.leadingAnchor, constant: Layout.TextView.leftMargin),
      self.inputTextView.topAnchor.constraint(equalTo: self.topAnchor, constant: Layout.TextView.yMargin),
      self.inputTextView.bottomAnchor
        .constraint(equalTo: self.bottomAnchor, constant: -Layout.TextView.yMargin),
      self.inputTextView.trailingAnchor
        .constraint(equalTo: self.postButton.leadingAnchor, constant: -Layout.TextView.rightMargin),
      self.placeholderLabel.leadingAnchor
        .constraint(equalTo: leadingAnchor, constant: Layout.Placeholder.xMargin),
      self.placeholderLabel.trailingAnchor
        .constraint(equalTo: trailingAnchor, constant: -Layout.Placeholder.xMargin),
      self.placeholderLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
    ])
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self |> \.backgroundColor .~ .ksr_support_100

    _ = self
      |> \.layer.borderColor .~ UIColor.ksr_support_300.cgColor
      |> \.layer.borderWidth .~ 1
      |> \.layer.cornerRadius .~ Layout.Container.radius
      |> \.clipsToBounds .~ true

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

// MARK: - Helper Functions

private let placeholderLabelStyle: LabelStyle = { label in
  label
    |> \.textColor .~ .ksr_support_400
    |> \.font .~ UIFont.ksr_body(size: 15.0)
    // To be replaced with a type-safe string when copy is available.
    |> \.text .~ "Leave a comment..."
    |> \.adjustsFontForContentSizeCategory .~ true
}
