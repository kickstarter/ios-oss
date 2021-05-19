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
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()

    _ = self.rootStackView
      |> rootStackViewStyle

    _ = self.commentLabel
      |> \.attributedText .~ attributedTextCommentRemoved()
      |> \.lineBreakMode .~ .byWordWrapping
      |> \.numberOfLines .~ 0
      |> \.adjustsFontForContentSizeCategory .~ true
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
      |> ksr_constrainViewToMarginsInParent()
  }
}

// MARK: Styles

private let replyButtonStyle: ButtonStyle = { button in
  button
    |> UIButton.lens.title(for: .normal) %~ { _ in "Reply" }
    |> UIButton.lens.titleLabel.font .~ UIFont.ksr_subhead()
    |> UIButton.lens.image(for: .normal) .~ Library.image(named: "reply")
    |> UIButton.lens.titleColor(for: .normal) .~ UIColor.ksr_support_400
    |> UIButton.lens.tintColor .~ UIColor.ksr_support_400
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

// MARK: - Functions

// TODO: - Replace linkURL: "https://kickstarter.com" with actual url

private func attributedTextCommentRemoved() -> NSAttributedString {
  let regularFontAttribute = [
    NSAttributedString.Key.font: UIFont.ksr_callout(),
    NSAttributedString.Key.foregroundColor: UIColor.ksr_support_400
  ]
  let coloredFontAttribute = [
    NSAttributedString.Key.font: UIFont.ksr_callout(),
    NSAttributedString.Key.foregroundColor: UIColor.ksr_create_700
  ]

  let attributedString = NSMutableAttributedString(
    string: localizedString(
      key: "This_comment_has_been_removed_by_Kickstarter",
      defaultValue: "This comment has been removed by Kickstarter. "
    ),
    attributes: regularFontAttribute
  )
  let learnMorAttributedString = NSMutableAttributedString(
    string: localizedString(
      key: "Learn_more_about_comment_guidelines",
      defaultValue: "Learn more about comment guidelines."
    ),
    attributes: coloredFontAttribute
  )
  attributedString.append(learnMorAttributedString)

  return attributedString
}
