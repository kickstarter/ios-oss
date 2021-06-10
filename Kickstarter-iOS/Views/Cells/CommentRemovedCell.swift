import KsApi
import Library
import Prelude
import UIKit

protocol CommentRemovedCellDelegate: AnyObject {
  func commentLabelTapped(
    _ cell: CommentRemovedCell
  )
}

final class CommentRemovedCell: UITableViewCell, ValueCell {
  weak var delegate: CommentRemovedCellDelegate?

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

  private let viewModel = CommentCellViewModel()

  // MARK: - Lifecycle

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.setupConstraints()
    self.bindStyles()
    self.bindViewModel()
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
      |> \.isUserInteractionEnabled .~ true
      |> \.lineBreakMode .~ .byWordWrapping
      |> \.numberOfLines .~ 0
      |> \.adjustsFontForContentSizeCategory .~ true
  }

  // MARK: - View model

  internal override func bindViewModel() {
    self.viewModel.outputs.notifyDelegateLabelTapped
      .observeForUI()
      .observeValues { [weak self] _ in
        guard let self = self else { return }

        self.delegate?.commentLabelTapped(self)
      }
  }

  // MARK: - Configuration

  internal func configureWith(value: Comment) {
    self.commentCellHeaderStackView
      .configureWith(comment: value)
  }

  private func configureViews() {
    self.rowStackView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    _ = ([self.commentCellHeaderStackView, self.rowStackView], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.infoImageView, self.commentLabel], self.rowStackView)
      |> ksr_addArrangedSubviewsToStackView()

    let tapGestureRecognizer = UITapGestureRecognizer(
      target: self,
      action: #selector(CommentRemovedCell.commentLabelTapped)
    )

    self.commentLabel.addGestureRecognizer(tapGestureRecognizer)
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

  // MARK: - Accessors

  @objc private func commentLabelTapped() {
    self.viewModel.inputs.commentLabelTapped()
  }
}

// MARK: Styles

private let rowStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.alignment .~ .top
    |> \.spacing .~ Styles.grid(1)
}

// MARK: - Functions

// TODO: Add logic in here for range of label
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
    string: Strings.This_comment_has_been_removed_by_Kickstarter(),
    attributes: regularFontAttribute
  )

  if var helpCenter = HelpType.helpCenter
    .url(withBaseUrl: AppEnvironment.current.apiService.serverConfig.webBaseUrl) {
    helpCenter.appendPathComponent("community")

    let learnMoreAttributedString = NSMutableAttributedString(
      string: Strings.Learn_more_about_comment_guidelines(community_link: helpCenter.absoluteString),
      attributes: coloredFontAttribute
    )
    attributedString.append(learnMoreAttributedString)
  }

  return attributedString
}
