import Library
import Prelude
import UIKit

private enum Layout {
  enum Border {
    static let height: CGFloat = 1.0
  }

  enum Avatar {
    static let diameter: CGFloat = 44.0
    static let margin: CGFloat = 18.0
  }
}

final class CommentComposerView: UIView {
  // MARK: - Properties

  private let rootStackView: UIStackView = { UIStackView(frame: .zero) }()

  private let topBorderView = {
    UIView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private let inputContainerView: CommentInputContainerView = {
    CommentInputContainerView()
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var avatarImageView = {
    CircleAvatarImageView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private let onlyBackersLabel: UILabel = {
    UILabel(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  // This will be replaced with a ViewModel ouput binding
  private let isBacker = false

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
    _ = self |> \.backgroundColor .~ .ksr_white

    _ = self.inputContainerView
      |> \.isHidden .~ !self.isBacker

    _ = self.onlyBackersLabel
      |> \.isHidden .~ self.isBacker

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

  override func bindStyles() {
    super.bindStyles()

    _ = self.rootStackView
      |> rootStackViewStyle

    self.rootStackView.alignment = self.isBacker ? .bottom : .leading

    _ = self.topBorderView
      |> \.backgroundColor .~ .ksr_support_300

    _ = self.avatarImageView
      |> \.backgroundColor .~ .ksr_create_700
      |> UIImageView.lens.image .~ UIImage(named: "avatar--placeholder")

    _ = self.onlyBackersLabel |> onlyBackersLabelStyle
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
    // To be replaced with a type-safe string when copy is available.
    |> \.text .~ "Only backers can leave comments"
    |> \.adjustsFontForContentSizeCategory .~ true
}
