import KsApi
import Library
import Prelude
import UIKit

final class CommentPostFailedCell: UITableViewCell, ValueCell {
  // MARK: - Properties

  private let viewModel = CommentCellViewModel()

  private lazy var bodyTextView: UITextView = { UITextView(frame: .zero) }()
  private lazy var commentCellHeaderStackView: CommentCellHeaderStackView = {
    CommentCellHeaderStackView(frame: .zero)
  }()

  private lazy var rootStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var retryButton = { UIButton(frame: .zero) }()

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
      |> baseTableViewCellStyle()

    _ = self.rootStackView
      |> commentCellRootStackViewStyle

    _ = self.bodyTextView
      |> commentBodyTextViewStyle
      |> \.textColor .~ .ksr_support_400

    _ = self.retryButton
      |> retryButtonStyle
  }

  // MARK: - Configuration

  internal func configureWith(value: (comment: Comment, user: User?)) {
    self.commentCellHeaderStackView.configureWith(comment: value.comment, user: value.user)
    self.viewModel.inputs.configureWith(comment: value.comment, user: value.user)
  }

  private func configureViews() {
    _ = ([self.commentCellHeaderStackView, self.bodyTextView, self.retryButton], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()
  }

  private func setupConstraints() {
    _ = (self.rootStackView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()
  }

  // MARK: - View model

  internal override func bindViewModel() {
    self.bodyTextView.rac.text = self.viewModel.outputs.body
  }
}

// MARK: Styles

// TODO: Internationalized in the near future.

private let retryButtonStyle: ButtonStyle = { button in
  button
    |> UIButton.lens
    .title(for: .normal) %~
    { _ in
      localizedString(key: "Failed_to_post_Tap_to_retry", defaultValue: "Failed to post. Tap to retry")
    }
    |> UIButton.lens.titleLabel.font .~ UIFont.ksr_subhead()
    |> UIButton.lens.image(for: .normal) .~ Library.image(named: "circle-back")
    |> UIButton.lens.titleColor(for: .normal) .~ UIColor.ksr_celebrate_700
    |> UIButton.lens.tintColor .~ UIColor.ksr_celebrate_700
    |> UIButton.lens.titleEdgeInsets .~ UIEdgeInsets(left: Styles.grid(1))
    |> UIButton.lens.contentHorizontalAlignment .~ .left
}
