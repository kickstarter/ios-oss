import KsApi
import Library
import Prelude
import UIKit

final class CommentCell: UITableViewCell, ValueCell {
  // MARK: - Properties

  private let viewModel = CommentCellViewModel()

  private lazy var bodyTextView: UITextView = { UITextView(frame: .zero) }()
  private lazy var bottomColumnStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var commentCellHeaderStackView: CommentCellHeaderStackView = {
    CommentCellHeaderStackView(frame: .zero)
  }()

  private lazy var flagButton = { UIButton(frame: .zero) }()
  private lazy var replyButton = { UIButton(frame: .zero) }()

  private lazy var rootStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
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
      |> baseTableViewCellStyle()

    _ = self.rootStackView
      |> commentCellRootStackViewStyle

    _ = self.bodyTextView
      |> commentBodyTextViewStyle

    _ = self.replyButton
      |> replyButtonStyle

    _ = self.flagButton
      |> UIButton.lens.image(for: .normal) %~ { _ in Library.image(named: "flag") }
  }

  // MARK: - Configuration

  internal func configureWith(value: (comment: Comment, viewer: User?)) {
    self.commentCellHeaderStackView.configureWith(comment: value.comment, user: value.viewer)
    self.viewModel.inputs.configureWith(comment: value.comment, viewer: value.viewer)
  }

  private func configureViews() {
    _ = ([self.commentCellHeaderStackView, self.bodyTextView, self.bottomColumnStackView], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.replyButton, UIView(), self.flagButton], self.bottomColumnStackView)
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

private let replyButtonStyle: ButtonStyle = { button in
  button
    |> UIButton.lens
    .title(for: .normal) %~ { _ in localizedString(key: "Reply_a_comment", defaultValue: "Reply") }
    |> UIButton.lens.titleLabel.font .~ UIFont.ksr_subhead()
    |> UIButton.lens.image(for: .normal) .~ Library.image(named: "reply")
    |> UIButton.lens.titleColor(for: .normal) .~ UIColor.ksr_support_400
    |> UIButton.lens.tintColor .~ UIColor.ksr_support_400
    |> UIButton.lens.imageEdgeInsets .~ UIEdgeInsets(left: Styles.grid(-1))
    |> UIButton.lens.contentEdgeInsets .~ UIEdgeInsets(leftRight: Styles.grid(1))
    |> UIButton.lens.contentHorizontalAlignment .~ .left
}
