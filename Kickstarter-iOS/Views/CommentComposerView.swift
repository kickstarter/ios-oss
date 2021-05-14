import Library
import Prelude
import UIKit

private enum Layout {
  enum Border {
    static let margin: CGFloat = 15.0
    static let height: CGFloat = 1.0
  }

  enum Avatar {
    static let height: CGFloat = 44.0
    static let margin: CGFloat = 18.0
  }

  enum InputContainer {
    static let spacing: CGFloat = 12.0
    static let margin: CGFloat = 18.0
  }
}

final class CommentComposerView: UIView {
  // MARK: - Properties

  private let topBorderView = {
    UIView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private let inputContainerView: CommentInputContainerView = {
    CommentInputContainerView()
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private let onlyBackersLabel: UILabel = {
    UILabel(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
      |> \.isHidden .~ true
  }()

  private lazy var avatarImageView = {
    CircleAvatarImageView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

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

    _ = (self.topBorderView, self)
      |> ksr_addSubviewToParent()

    _ = (self.avatarImageView, self)
      |> ksr_addSubviewToParent()

    _ = (self.inputContainerView, self)
      |> ksr_addSubviewToParent()

    _ = (self.onlyBackersLabel, self)
      |> ksr_addSubviewToParent()
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.topBorderView.topAnchor.constraint(equalTo: topAnchor),
      self.topBorderView.leadingAnchor.constraint(equalTo: leadingAnchor),
      self.topBorderView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: Layout.Border.margin),
      self.topBorderView.heightAnchor.constraint(equalToConstant: Layout.Border.height),
      self.avatarImageView.leadingAnchor
        .constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: Layout.Avatar.margin),
      self.avatarImageView.bottomAnchor
        .constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -Layout.Avatar.margin),
      self.avatarImageView.heightAnchor.constraint(equalToConstant: Layout.Avatar.height),
      self.avatarImageView.widthAnchor.constraint(equalToConstant: Layout.Avatar.height),
      self.inputContainerView.leadingAnchor
        .constraint(equalTo: self.avatarImageView.trailingAnchor, constant: Layout.InputContainer.spacing),
      self.inputContainerView.trailingAnchor
        .constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -Layout.InputContainer.margin),
      self.inputContainerView.bottomAnchor
        .constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -Layout.InputContainer.margin),
      self.inputContainerView.topAnchor
        .constraint(equalTo: topAnchor, constant: Layout.InputContainer.margin),
      self.onlyBackersLabel.leadingAnchor
        .constraint(equalTo: self.avatarImageView.trailingAnchor, constant: Layout.InputContainer.margin),
      self.onlyBackersLabel.trailingAnchor
        .constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -Layout.InputContainer.margin),
      self.onlyBackersLabel.centerYAnchor.constraint(equalTo: self.avatarImageView.centerYAnchor)
    ])
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self.topBorderView
      |> \.backgroundColor .~ .ksr_support_300

    _ = self.avatarImageView
      |> \.backgroundColor .~ .ksr_create_700
      |> UIImageView.lens.image .~ UIImage(named: "avatar--placeholder")

    _ = self.onlyBackersLabel |> onlyBackersLabelStyle
  }
}

private let onlyBackersLabelStyle: LabelStyle = { label in
  label
    |> \.textColor .~ .ksr_support_400
    |> \.font .~ UIFont.ksr_body(size: 15.0)
    // To be replaced with a type-safe string when copy is available.
    |> \.text .~ "Only backers can leave comments"
    |> \.adjustsFontForContentSizeCategory .~ true
}
