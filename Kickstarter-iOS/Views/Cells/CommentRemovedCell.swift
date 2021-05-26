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

  private lazy var infoImageView = {
    UIImageView(frame: .zero)
      |> \.image .~ Library.image(named: "info")
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var commentLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var rowStackView: UIStackView = {
    UIStackView(frame: .zero)
  }()

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
      |> commentCellRootStackViewStyle

    _ = self.rowStackView
      |> rowStackViewStyle

    _ = self.commentLabel
      |> \.attributedText .~ attributedTextCommentRemoved()
      |> \.lineBreakMode .~ .byWordWrapping
      |> \.numberOfLines .~ 0
      |> \.adjustsFontForContentSizeCategory .~ true
  }

  // MARK: - Configuration

  internal func configureWith(value: (comment: Comment, user: User?, project: Project)) {
    self.commentCellHeaderStackView
      .configureWith(comment: value.comment, user: value.user, project: value.project)
  }

  private func configureViews() {
    self.rowStackView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    _ = ([self.commentCellHeaderStackView, self.rowStackView], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.infoImageView, self.commentLabel], self.rowStackView)
      |> ksr_addArrangedSubviewsToStackView()
  }

  private func setupConstraints() {
    _ = (self.rootStackView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    NSLayoutConstraint.activate([
      self.infoImageView.widthAnchor.constraint(equalToConstant: Styles.grid(4)),
      self.infoImageView.heightAnchor.constraint(equalToConstant: Styles.grid(4))
    ])
  }
}

// MARK: Styles

private let rowStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.alignment .~ .top
    |> \.spacing .~ Styles.grid(1)
}

// MARK: - Functions

// TODO/FIXME: Internationalized in the near future.
// Allow "Learn more about comment guidelines." to be tappable and open link in a web browser

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
  let learnMoreAttributedString = NSMutableAttributedString(
    string: localizedString(
      key: "Learn_more_about_comment_guidelines",
      defaultValue: "Learn more about comment guidelines."
    ),
    attributes: coloredFontAttribute
  )
  attributedString.append(learnMoreAttributedString)

  return attributedString
}
