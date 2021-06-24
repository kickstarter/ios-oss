import Library
import Prelude
import UIKit

private enum Layout {
  enum Avatar {
    static let diameter: CGFloat = 44.0
  }

  enum Border {
    static let height: CGFloat = 1.0
  }
}

protocol CommentComposerViewDelegate: AnyObject {
  func commentComposerView(_ view: CommentComposerView, didSubmitText text: String)
}

final class CommentComposerView: UIView {
  // MARK: - Properties

  lazy var avatarImageView = {
    CircleAvatarImageView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var inputContainerView: CommentInputContainerView = {
    CommentInputContainerView()
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var onlyBackersLabel: UILabel = {
    UILabel(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private let rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private let topBorderView = {
    UIView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  weak var delegate: CommentComposerViewDelegate?
  private var inputAreaHeightConstraint: NSLayoutConstraint?
  private let viewModel: CommentComposerViewModelType = CommentComposerViewModel()

  // MARK: - Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.configureViews()
    self.bindViewModel()
    self.setupConstraints()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override var intrinsicContentSize: CGSize {
    return .zero
  }

  // MARK: - Configuration

  /**
   Sets up the interface for the CommentComposerView, including the avatar and conditional rendering of the text view

   - parameter with: `CommentComposerViewData` object that determines.the avatarURL and if the user is a backer
   */
  public func configure(with data: CommentComposerViewData) {
    self.viewModel.inputs.configure(with: data)
  }

  public func resetInput() {
    self.viewModel.inputs.resetInput()
  }

  // MARK: - Views

  private func configureViews() {
    self.inputAreaHeightConstraint = self.rootStackView.heightAnchor.constraint(equalToConstant: 0)

    _ = self.inputAreaHeightConstraint
      ?|> \.isActive .~ true

    _ = self
      |> \.autoresizingMask .~ .flexibleHeight
      |> \.backgroundColor .~ .ksr_white
      |> \.clipsToBounds .~ true

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
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.topBorderView.topAnchor.constraint(equalTo: topAnchor),
      self.topBorderView.leadingAnchor.constraint(equalTo: leadingAnchor),
      self.topBorderView.trailingAnchor.constraint(equalTo: trailingAnchor),
      self.topBorderView.heightAnchor.constraint(equalToConstant: Layout.Border.height),
      self.avatarImageView.heightAnchor.constraint(equalToConstant: Layout.Avatar.diameter),
      self.avatarImageView.widthAnchor.constraint(equalToConstant: Layout.Avatar.diameter)
    ])
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.rootStackView
      |> rootStackViewStyle

    _ = self.topBorderView
      |> \.backgroundColor .~ .ksr_support_200

    _ = self.avatarImageView
      |> \.backgroundColor .~ .ksr_support_100

    _ = self.onlyBackersLabel |> onlyBackersLabelStyle
  }

  // MARK: - ViewModel

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.clearInputTextView
      .observeForUI()
      .observeValues { [weak self] _ in
        self?.inputContainerView.inputTextView.text = nil
      }

    self.viewModel.outputs.inputTextViewDidBecomeFirstResponder
      .observeForControllerAction()
      .observeValues { [weak self] becomeFirstResponder in
        guard let self = self else { return }
        _ = becomeFirstResponder
          ? self.inputContainerView.inputTextView.becomeFirstResponder()
          : self.inputContainerView.inputTextView.resignFirstResponder()
      }

    self.viewModel.outputs.updateTextViewHeight
      .observeForUI()
      .observeValues { [weak self] _ in
        self?.inputContainerView.inputTextView.invalidateIntrinsicContentSize()
      }

    self.inputContainerView.placeholderLabel.rac.hidden = self.viewModel.outputs.placeholderHidden
    self.inputContainerView.postButton.rac.hidden = self.viewModel.outputs.postButtonHidden

    self.viewModel.outputs.avatarURL
      .observeForUI()
      .on(event: { [weak self] _ in
        self?.avatarImageView.af.cancelImageRequest()
        self?.avatarImageView.image = nil
      })
      .skipNil()
      .observeValues { [weak self] url in
        self?.avatarImageView.ksr_setRoundedImageWith(url)
      }

    self.viewModel.outputs.notifyDelegateDidSubmitText
      .observeForUI()
      .observeValues { [weak self] text in
        guard let self = self else { return }
        self.delegate?.commentComposerView(self, didSubmitText: text)
      }

    self.viewModel.outputs.inputAreaHidden
      .observeForUI()
      .observeValues { [weak self] isHidden in
        self?.hideInputArea(isHidden)
      }

    self.viewModel.outputs.commentComposerHidden
      .observeForUI()
      .observeValues { [weak self] isHidden in
        self?.inputAreaHeightConstraint?.isActive = isHidden
      }
  }

  // MARK: - Helpers

  private func hideInputArea(_ hide: Bool) {
    self.rootStackView.alignment = hide ? .center : .bottom
    _ = self.inputContainerView
      |> \.isHidden .~ hide

    _ = self.onlyBackersLabel
      |> \.isHidden .~ !hide
  }

  // MARK: - Actions

  @objc private func postButtonPressed() {
    self.viewModel.inputs.postButtonPressed()
  }
}

// MARK: - UITextViewDelegate

extension CommentComposerView: UITextViewDelegate {
  func textViewDidChange(_ textView: UITextView) {
    self.viewModel.inputs.bodyTextDidChange(textView.text)
  }

  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange,
                replacementText text: String) -> Bool {
    return self.viewModel.inputs.textViewShouldChange(text: textView.text, in: range, replacementText: text)
  }
}

// MARK: - Styles

private let onlyBackersLabelStyle: LabelStyle = { label in
  label
    |> \.textColor .~ .ksr_support_400
    |> \.font .~ UIFont.ksr_body(size: 15.0)
    |> \.text .~ Strings.Only_backers_can_post_comments()
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.numberOfLines .~ 0
}

private let rootStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ .horizontal
    |> \.distribution .~ .fill
    |> \.spacing .~ Styles.grid(2)
    |> \.layoutMargins .~ .init(all: Styles.grid(3))
    |> \.isLayoutMarginsRelativeArrangement .~ true
}
