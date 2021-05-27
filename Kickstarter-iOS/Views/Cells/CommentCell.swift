import KsApi
import Library
import Prelude
import UIKit

final class CommentCell: UITableViewCell, ValueCell {
  // MARK: - Properties

  private lazy var bodyTextView: UITextView = { UITextView(frame: .zero) }()
  private lazy var bottomRowStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var commentCellHeaderStackView: CommentCellHeaderStackView = {
    CommentCellHeaderStackView(frame: .zero)
  }()

  private lazy var flagButton = { UIButton(frame: .zero) }()
  private lazy var replyButton = { UIButton(frame: .zero) }()
  private lazy var viewRepliesContainer: UIView = { UIView(frame: .zero) }()
  private lazy var viewRepliesStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var viewRepliesLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var viewRepliesIconImageView: UIImageView = { UIImageView(frame: .zero) }()

  private lazy var rootStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private let viewModel = CommentCellViewModel()

  // MARK: - Lifecycle

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

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

    _ = self.viewRepliesContainer
      |> viewRepliesContainerStyle

    _ = self.viewRepliesStackView
      |> viewRepliesStackViewStyle

    _ = self.viewRepliesLabel
      |> \.text %~ { _ in localizedString(key: "View_replies", defaultValue: "View replies") }

    _ = self.viewRepliesIconImageView
      |> UIImageView.lens.image .~ Library.image(named: "right-diagonal")

    _ = self.flagButton
      |> UIButton.lens.image(for: .normal) %~ { _ in Library.image(named: "flag") }
  }

  // MARK: - Configuration

  internal func configureWith(value: (comment: Comment, user: User?)) {
    self.commentCellHeaderStackView.configureWith(comment: value.comment, user: value.user)
    self.viewModel.inputs.configureWith(comment: value.comment, user: value.user)
  }

  private func configureViews() {
    let rootViews = [
      self.commentCellHeaderStackView,
      self.bodyTextView,
      self.viewRepliesContainer,
      self.bottomRowStackView
    ]

    _ = (self.rootStackView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    _ = (rootViews, self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = (self.viewRepliesStackView, self.viewRepliesContainer)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    _ = ([self.viewRepliesLabel, UIView(), self.viewRepliesIconImageView], self.viewRepliesStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.replyButton, UIView(), self.flagButton], self.bottomRowStackView)
      |> ksr_addArrangedSubviewsToStackView()
  }

  // MARK: - View model

  internal override func bindViewModel() {
    self.bodyTextView.rac.text = self.viewModel.outputs.body

    self.viewRepliesContainer.rac.hidden = self.viewModel.outputs.viewRepliesContainerHidden
  }
}

// MARK: Styles

// TODO: Internationalized in the near future.

private let replyButtonStyle: ButtonStyle = { button in
  button
    |> UIButton.lens
    .title(for: .normal) %~ { _ in localizedString(key: "Reply", defaultValue: "Reply") }
    |> UIButton.lens.titleLabel.font .~ UIFont.ksr_subhead()
    |> UIButton.lens.image(for: .normal) .~ Library.image(named: "reply")
    |> UIButton.lens.titleColor(for: .normal) .~ UIColor.ksr_support_400
    |> UIButton.lens.tintColor .~ UIColor.ksr_support_400
    |> UIButton.lens.imageEdgeInsets .~ UIEdgeInsets(left: Styles.grid(-1))
    |> UIButton.lens.contentEdgeInsets .~ UIEdgeInsets(leftRight: Styles.grid(1))
    |> UIButton.lens.contentHorizontalAlignment .~ .left
}

private let viewRepliesContainerStyle: ViewStyle = { view in
  view
    |> roundedStyle(cornerRadius: 2.0)
    |> UIView.lens.layer.borderColor .~ UIColor.ksr_support_200.cgColor
    |> UIView.lens.layer.borderWidth .~ 1.0
}

private let viewRepliesStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.layoutMargins .~ .init(all: Styles.grid(2))
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.alignment .~ .center
}
