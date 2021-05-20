import Library
import Prelude
import UIKit

private enum Layout {
  enum Border {
    static let height: CGFloat = 1.0
  }

  enum Avatar {
    static let diameter: CGFloat = 44.0
  }
}

final class CommentComposerView: UIView {
  // MARK: - Properties

  private let rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private let topBorderView = {
    UIView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var inputContainerView: CommentInputContainerView = {
    CommentInputContainerView()
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  lazy var avatarImageView = {
    CircleAvatarImageView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var onlyBackersLabel: UILabel = {
    UILabel(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private let characterLimit: Int = 9_000
  private let viewModel: CommentComposerViewModelType = CommentComposerViewModel()

  // MARK: - Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.configureViews()
    self.setupConstraints()
    self.bindViewModel()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override var intrinsicContentSize: CGSize {
    return .zero
  }

  // MARK: - Configuration

  public func configure(with data: CommentComposerViewData) {
    self.viewModel.inputs.configure(with: data)
  }

  // MARK: - Views

  private func configureViews() {
    _ = self |> \.autoresizingMask .~ .flexibleHeight
    _ = self |> \.backgroundColor .~ .ksr_white

    _ = self.inputContainerView.inputTextView
      |> \.delegate .~ self

    self.inputContainerView.postButton
      .addTarget(self, action: #selector(self.postButtonPressed), for: .touchUpInside)

    _ = ([self.avatarImageView, self.inputContainerView, self.onlyBackersLabel], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = (self.rootStackView, self)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = (self.topBorderView, self)
      |> ksr_addSubviewToParent()

    _ = (self.onlyBackersLabel, self)
      |> ksr_addSubviewToParent()
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.topBorderView.topAnchor.constraint(equalTo: topAnchor),
      self.topBorderView.leadingAnchor.constraint(equalTo: leadingAnchor),
      self.topBorderView.trailingAnchor.constraint(equalTo: trailingAnchor),
      self.topBorderView.heightAnchor.constraint(equalToConstant: Layout.Border.height),
      self.avatarImageView.heightAnchor.constraint(equalToConstant: Layout.Avatar.diameter),
      self.avatarImageView.widthAnchor.constraint(equalToConstant: Layout.Avatar.diameter),
      self.onlyBackersLabel.leadingAnchor
        .constraint(equalTo: self.avatarImageView.trailingAnchor, constant: Styles.grid(2)),
      self.onlyBackersLabel.trailingAnchor
        .constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -Styles.grid(2)),
      self.onlyBackersLabel.centerYAnchor.constraint(equalTo: self.avatarImageView.centerYAnchor)
    ])
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.rootStackView
      |> rootStackViewStyle

    _ = self.topBorderView
      |> \.backgroundColor .~ .ksr_support_300

    _ = self.avatarImageView
      |> UIImageView.lens.image .~ UIImage(named: "avatar--placeholder")

    _ = self.onlyBackersLabel |> onlyBackersLabelStyle
  }

  // MARK: - ViewModel

  override func bindViewModel() {
    super.bindViewModel()

    self.avatarImageView.rac.ksr_imageUrl = self.viewModel.outputs.avatarURL

    self.viewModel.outputs.inputAreaVisible
      .observeForUI()
      .observeValues { [weak self] isVisible in
        self?.showInputArea(isVisible)
      }

    self.viewModel.outputs.inputEmpty
      .observeForUI()
      .observeValues { [weak self] isEmpty in
        self?.handleInputEmptyState(isEmpty)
      }
  }

  // MARK: - Helpers

  private func showInputArea(_ show: Bool) {
    self.rootStackView.alignment = show ? .bottom : .leading
    _ = self.inputContainerView
      |> \.isHidden .~ !show

    _ = self.onlyBackersLabel
      |> \.isHidden .~ show
  }

  private func handleInputEmptyState(_ isEmpty: Bool) {
    _ = self.inputContainerView.placeholderLabel |> \.isHidden .~ !isEmpty
    _ = self.inputContainerView.postButton |> \.isHidden .~ isEmpty
    _ = self.inputContainerView.backgroundColor = isEmpty ? .ksr_support_100 : .ksr_white
  }

  // MARK: - Actions

  @objc private func postButtonPressed() {
    self.viewModel.inputs.postButtonPressed()
  }
}

// MARK: - UITextViewDelegate

extension CommentComposerView: UITextViewDelegate {
  func textViewDidChange(_ textView: UITextView) {
    self.inputContainerView.inputTextView.invalidateIntrinsicContentSize()
    self.viewModel.inputs.textDidChange(textView.text)
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

private let rootStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ .horizontal
    |> \.distribution .~ .fill
    |> \.spacing .~ Styles.grid(2)
    |> \.layoutMargins .~ .init(all: Styles.grid(3))
    |> \.isLayoutMarginsRelativeArrangement .~ true
}

private let onlyBackersLabelStyle: LabelStyle = { label in
  label
    |> \.textColor .~ .ksr_support_400
    |> \.font .~ UIFont.ksr_body(size: 15.0)
    // TODO: To be replaced with a type-safe string when copy is available.
    |> \.text .~
    localizedString(key: "Only_backers_can_leave_comments", defaultValue: "Only backers can leave comments")
    |> \.adjustsFontForContentSizeCategory .~ true
}
