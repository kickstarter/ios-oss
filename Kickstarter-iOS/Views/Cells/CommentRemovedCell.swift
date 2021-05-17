import KsApi
import Library
import Prelude
import UIKit

final class CommentRemovedCell: UITableViewCell, ValueCell {
  // MARK: - Properties

  private lazy var rootStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var separatorView: UIView = { UIView(frame: .zero)
    |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var commentLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var commentCellHeaderStackView: CommentCellHeaderStackView = {
    CommentCellHeaderStackView(frame: .zero)
  }()

  // MARK: - Lifecycle

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.setupConstraints()
    self.bindStyles()
    self.configureViews()
    self.bindViewModel()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> \.selectionStyle .~ .none

    _ = self.rootStackView
      |> rootStackViewStyle

    _ = self.commentLabel
      |> \.attributedText .~ attributedCommentRemoved()
      |> \.lineBreakMode .~ .byWordWrapping
      |> \.numberOfLines .~ 0
      |> \.adjustsFontForContentSizeCategory .~ true

    _ = self.separatorView
      |> \.backgroundColor .~ UIColor.hex(0xF0F0F0)
      |> \.accessibilityElementsHidden .~ true
  }

  // MARK: - Configuration

  internal func configureWith(value: DemoComment) {
    self.commentCellHeaderStackView.configureWith(comment: value)
  }

  private func configureViews() {
    _ = ([self.commentCellHeaderStackView, self.commentLabel], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()
  }

  private func setupConstraints() {
    _ = (self.rootStackView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent(priority: .defaultHigh)

    _ = (self.separatorView, self.contentView)
      |> ksr_addSubviewToParent()

    NSLayoutConstraint.activate([
      self.rootStackView.bottomAnchor.constraint(equalTo: self.separatorView.topAnchor, constant: 1),
      self.separatorView.heightAnchor.constraint(equalToConstant: 1),
      self.separatorView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
      self.separatorView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
      self.separatorView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor)
    ])
  }
}

// MARK: Styles

private let rootStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ .vertical
    |> \.layoutMargins .~ .init(all: Styles.grid(3))
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.insetsLayoutMarginsFromSafeArea .~ false
    |> \.spacing .~ Styles.grid(3)
}

private let replyButtonStyle: ButtonStyle = { button in
  button
    |> UIButton.lens.title(for: .normal) %~ { _ in "Reply" }
    |> UIButton.lens.titleLabel.font .~ UIFont.ksr_subhead()
    |> UIButton.lens.image(for: .normal) .~ Library.image(named: "reply")
    |> UIButton.lens.titleColor(for: .normal) .~ UIColor.hex(0x656969)
    |> UIButton.lens.tintColor .~ UIColor.hex(0x656969)
    |> UIButton.lens.titleEdgeInsets .~ UIEdgeInsets(left: 7.17)
    |> UIButton.lens.contentHorizontalAlignment .~ .left
}

private let tapRetryPostButtonStyle: ButtonStyle = { button in
  button
    |> UIButton.lens.title(for: .normal) %~ { _ in "Failed to post. Tap to retry" }
    |> UIButton.lens.titleLabel.font .~ UIFont.ksr_subhead()
    |> UIButton.lens.image(for: .normal) .~ Library.image(named: "circle-back")
    |> UIButton.lens.titleColor(for: .normal) .~ UIColor.ksr_celebrate_700
    |> UIButton.lens.tintColor .~ UIColor.ksr_celebrate_700
    |> UIButton.lens.titleEdgeInsets .~ UIEdgeInsets(left: 7.17)
    |> UIButton.lens.contentHorizontalAlignment .~ .left
}

private func attributedCommentRemoved() -> NSAttributedString {
  let regularFontAttribute = [
    NSAttributedString.Key.font: UIFont.ksr_callout(),
    NSAttributedString.Key.foregroundColor: UIColor.hex(0x656969)
  ]
  let coloredFontAttribute = [
    NSAttributedString.Key.font: UIFont.ksr_callout(),
    NSAttributedString.Key.foregroundColor: UIColor.ksr_create_700
  ]

  let attributedString = NSMutableAttributedString(
    string: "This comment has been removed by Kickstarter. ",
    attributes: regularFontAttribute
  )
  let attributedString2 = NSMutableAttributedString(
    string: "Learn more about comment guidelines",
    attributes: coloredFontAttribute
  )
  attributedString.append(attributedString2)

  return attributedString
}
