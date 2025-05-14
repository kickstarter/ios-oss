import Library
import Prelude
import UIKit

private enum Layout {
  enum Button {
    static let height: CGFloat = 20.0
  }

  enum Container {
    static let radius: CGFloat = 22
  }
}

final class CommentInputContainerView: UIView {
  // MARK: - Properties

  lazy var inputTextView: CommentInputTextView = {
    CommentInputTextView(frame: .zero)
  }()

  let placeholderLabel: UILabel = { UILabel(frame: .zero) }()

  lazy var postButton: UIButton = {
    UIButton(type: .system)
      |> \.isHidden .~ true
  }()

  private let rootStackView: UIStackView = { UIStackView(frame: .zero) }()

  // MARK: - Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.configureViews()
    self.setupConstraints()
  }

  @available(*, unavailable)
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
      |> \.layoutMargins .~ .init(left: Styles.grid(3))

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
      self.postButton.heightAnchor.constraint(equalToConstant: Layout.Button.height)
    ])

    self.postButton.setContentCompressionResistancePriority(.required, for: .horizontal)
    self.postButton.setContentHuggingPriority(.required, for: .horizontal)
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
      |> UIButton.lens.titleLabel.font .~ .ksr_headline(size: 15)
      |> UIButton.lens.titleLabel.numberOfLines .~ 0
      |> UIButton.lens.titleColor(for: .normal) %~ { _ in LegacyColors.ksr_create_700.uiColor() }
      |> UIButton.lens.title(for: .normal) %~ { _ in Strings.Post() }
      |> UIButton.lens.titleLabel.textAlignment .~ .center
  }

  override func traitCollectionDidChange(_: UITraitCollection?) {
    self.inputTextView.invalidateIntrinsicContentSize()
  }
}

// MARK: - Styles

private let containerStyle: ViewStyle = { view in
  view
    |> \.backgroundColor .~ LegacyColors.ksr_white.uiColor()
    |> \.layer.borderColor .~ LegacyColors.ksr_support_200.uiColor().cgColor
    |> \.layer.borderWidth .~ 1
    |> \.layer.cornerRadius .~ Layout.Container.radius
    |> \.clipsToBounds .~ true
}

private let placeholderLabelStyle: LabelStyle = { label in
  label
    |> \.textColor .~ LegacyColors.ksr_support_400.uiColor()
    |> \.font .~ UIFont.ksr_body(size: 15.0)
    |> \.text .~ Strings.Write_a_comment()
    |> \.adjustsFontForContentSizeCategory .~ true
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
