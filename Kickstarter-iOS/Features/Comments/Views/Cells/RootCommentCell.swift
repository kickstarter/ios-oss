import KsApi
import Library
import Prelude
import UIKit

private enum Layout {
  enum Border {
    static let height: CGFloat = 1.0
  }
}

protocol RootCommentCellDelegate: AnyObject {
  func commentCellDidTapHeader(_ cell: RootCommentCell, _ author: Comment.Author)
}

final class RootCommentCell: UITableViewCell, ValueCell {
  // MARK: - Properties

  weak var delegate: RootCommentCellDelegate?

  private lazy var bodyTextView: UITextView = { UITextView(frame: .zero) }()
  private lazy var bottomBorder: UIView = {
    UIView(frame: .zero)
      |> \.backgroundColor .~ LegacyColors.ksr_support_200.uiColor()
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var commentCellHeaderStackView: CommentCellHeaderStackView = {
    CommentCellHeaderStackView(frame: .zero)
  }()

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

    self.commentCellHeaderStackView.addGestureRecognizer(UITapGestureRecognizer(
      target: self,
      action: #selector(self.commentCellHeaderTapped)
    ))
    self.configureAccessibilityElements()
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
  }

  // MARK: - Configuration

  internal func configureWith(value: Comment) {
    self.commentCellHeaderStackView
      .configureWith(comment: value)
    self.viewModel.inputs.configureWith(comment: value, project: nil)
  }

  private func configureViews() {
    let rootViews = [
      self.commentCellHeaderStackView,
      self.bodyTextView
    ]

    _ = (self.rootStackView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    _ = (rootViews, self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = (self.bottomBorder, self.contentView)
      |> ksr_addSubviewToParent()

    NSLayoutConstraint.activate([
      self.bottomBorder.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
      self.bottomBorder.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
      self.bottomBorder.bottomAnchor.constraint(equalTo: self.rootStackView.bottomAnchor),
      self.bottomBorder.heightAnchor.constraint(equalToConstant: Layout.Border.height)
    ])
  }

  private func configureAccessibilityElements() {
    self.isAccessibilityElement = false
    self.accessibilityContainerType = .semanticGroup
    self.accessibilityElements = [
      self.commentCellHeaderStackView,
      self.commentCellHeaderStackView.postTimeLabel,
      self.bodyTextView
    ]
    self.commentCellHeaderStackView.isAccessibilityElement = true
    self.commentCellHeaderStackView.accessibilityTraits.insert(.button)
    self.commentCellHeaderStackView.postTimeLabel.isAccessibilityElement = true
    self.bodyTextView.isAccessibilityElement = true
  }

  // MARK: - View model

  internal override func bindViewModel() {
    self.bodyTextView.rac.text = self.viewModel.outputs.body

    self.viewModel.outputs.cellAuthor
      .observeForUI()
      .observeValues { [weak self] author in
        guard let self = self else { return }
        self.delegate?.commentCellDidTapHeader(self, author)
      }
  }

  // MARK: - Actions

  @objc private func commentCellHeaderTapped() {
    self.viewModel.inputs.cellHeaderTapped()
  }
}
