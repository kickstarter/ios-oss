import KsApi
import Library
import Prelude
import UIKit

protocol CommentCellDelegate: AnyObject {
  func commentCellDidTapReply(_ cell: CommentCell, comment: Comment)
  func commentCellDidTapViewReplies(_ cell: CommentCell, comment: Comment)
}

final class CommentCell: UITableViewCell, ValueCell {
  // MARK: - Properties

  private lazy var bodyTextView: UITextView = { UITextView(frame: .zero) }()
  private lazy var bottomRowStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var commentCellHeaderStackView: CommentCellHeaderStackView = {
    CommentCellHeaderStackView(frame: .zero)
  }()

  weak var delegate: CommentCellDelegate?

  private lazy var flagButton = { UIButton(frame: .zero) }()
  private lazy var postedButton = { UIButton(frame: .zero) }()
  private lazy var replyButton = { UIButton(frame: .zero) }()
  private lazy var viewRepliesView: ViewRepliesView = {
    ViewRepliesView(frame: .zero)
      |> \.isUserInteractionEnabled .~ true
  }()

  private let viewModel = CommentCellViewModel()

  private lazy var rootStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  // MARK: - Lifecycle

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.bindStyles()
    self.configureViews()
    self.bindViewModel()

    self.replyButton.addTarget(self, action: #selector(self.replyButtonTapped), for: .touchUpInside)
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  // MARK: - Actions

  @objc func replyButtonTapped() {
    self.viewModel.inputs.replyButtonTapped()
  }

  @objc func viewRepliesTapped() {
    self.viewModel.inputs.viewRepliesButtonTapped()
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

    _ = self.postedButton
      |> postedButtonStyle

    _ = self.replyButton
      |> replyButtonStyle

    _ = self.flagButton
      |> UIButton.lens.image(for: .normal) %~ { _ in Library.image(named: "flag") }

    self.viewModel.inputs.bindStyles()
  }

  // MARK: - Configuration

  internal func configureWith(value: (comment: Comment, project: Project)) {
    self.commentCellHeaderStackView
      .configureWith(comment: value.comment)
    self.viewModel.inputs.configureWith(comment: value.comment, project: value.project)
  }

  private func configureViews() {
    let rootViews = [
      self.commentCellHeaderStackView,
      self.bodyTextView,
      self.postedButton,
      self.viewRepliesView,
      self.bottomRowStackView
    ]

    _ = (self.rootStackView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    _ = (rootViews, self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.replyButton, UIView(), self.flagButton], self.bottomRowStackView)
      |> ksr_addArrangedSubviewsToStackView()

    let viewRepliesGesture = UITapGestureRecognizer(target: self, action: #selector(self.viewRepliesTapped))
    self.viewRepliesView.addGestureRecognizer(viewRepliesGesture)
  }

  // MARK: - View model

  internal override func bindViewModel() {
    self.bodyTextView.rac.text = self.viewModel.outputs.body
    self.bottomRowStackView.rac.hidden = self.viewModel.outputs.bottomRowStackViewIsHidden
    self.flagButton.rac.hidden = self.viewModel.outputs.flagButtonIsHidden
    self.replyButton.rac.hidden = self.viewModel.outputs.replyButtonIsHidden
    self.viewRepliesView.rac.hidden = self.viewModel.outputs.viewRepliesViewHidden

    self.postedButton.rac.hidden = self.viewModel.outputs.postedButtonIsHidden

    self.viewModel.outputs.replyCommentTapped
      .observeForUI()
      .observeValues { [weak self] comment in
        guard let self = self else { return }
        self.delegate?.commentCellDidTapReply(self, comment: comment)
      }

    self.viewModel.outputs.viewCommentReplies
      .observeForUI()
      .observeValues { [weak self] comment in
        guard let self = self else { return }
        self.delegate?.commentCellDidTapViewReplies(self, comment: comment)
      }

    self.viewModel.outputs.shouldIndentContent
      .observeForUI()
      .observeValues { shouldIndent in
        _ = self.rootStackView
          |> \.axis .~ .vertical
          |> \.layoutMargins .~ .init(
            top: Styles.grid(1),
            left: Styles.grid(shouldIndent ? CommentCellStyles.Content.leftIndentWidth : 1),
            bottom: Styles.grid(3),
            right: Styles.grid(1)
          )
          |> \.isLayoutMarginsRelativeArrangement .~ true
          |> \.spacing .~ Styles.grid(3)
      }
  }
}

// MARK: Styles

private let replyButtonStyle: ButtonStyle = { button in
  button
    |> UIButton.lens
    .title(for: .normal) %~ { _ in Strings.general_navigation_buttons_reply() }
    |> UIButton.lens.titleLabel.font .~ UIFont.ksr_subhead()
    |> UIButton.lens.image(for: .normal) .~ Library.image(named: "reply")
    |> UIButton.lens.titleColor(for: .normal) .~ UIColor.ksr_support_400
    |> UIButton.lens.tintColor .~ UIColor.ksr_support_400
    |> UIButton.lens.imageEdgeInsets .~ UIEdgeInsets(left: Styles.grid(-1))
    |> UIButton.lens.contentEdgeInsets .~ UIEdgeInsets(leftRight: Styles.grid(1))
    |> UIButton.lens.contentHorizontalAlignment .~ .left
}

private let postedButtonStyle: ButtonStyle = { button in
  button
    |> \.isUserInteractionEnabled .~ false
    |> UIButton.lens.title(for: .normal) %~ { _ in Strings.Posted() }
    |> UIButton.lens.titleLabel.font .~ UIFont.ksr_subhead()
    |> UIButton.lens.image(for: .normal) .~ Library.image(named: "posted")
    |> UIButton.lens.titleColor(for: .normal) .~ UIColor.ksr_create_700
    |> UIButton.lens.tintColor .~ UIColor.ksr_create_700
    |> UIButton.lens.titleEdgeInsets .~ UIEdgeInsets(left: Styles.grid(1))
    |> UIButton.lens.contentHorizontalAlignment .~ .left
}
