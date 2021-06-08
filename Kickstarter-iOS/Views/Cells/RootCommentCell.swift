import KsApi
import Library
import Prelude
import UIKit

final class RootCommentCell: UITableViewCell, ValueCell {
  // MARK: - Properties

  private lazy var bodyTextView: UITextView = { UITextView(frame: .zero) }()
  private lazy var commentCellHeaderStackView: CommentCellHeaderStackView = {
    CommentCellHeaderStackView(frame: .zero)
  }()

  private lazy var rootStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private let viewModel = RootCommentCellViewModel()

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
  }

  // MARK: - Configuration

  internal func configureWith(value: Comment) {
    self.commentCellHeaderStackView
      .configureWith(comment: value)
    self.viewModel.inputs.configureWith(comment: value)
  }

  private func configureViews() {
    let rootViews = [
      self.commentCellHeaderStackView,
      self.bodyTextView,
    ]

    _ = (self.rootStackView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    _ = (rootViews, self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()
  }

  // MARK: - View model

  internal override func bindViewModel() {
    self.bodyTextView.rac.text = self.viewModel.outputs.body
  }
}
