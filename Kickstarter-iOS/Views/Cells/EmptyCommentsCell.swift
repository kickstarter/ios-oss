import KsApi
import Library
import Prelude
import UIKit

final class EmptyCommentsCell: UITableViewCell, ValueCell {
  // MARK: - Properties

  private lazy var noCommentsLabel: UILabel = { UILabel(frame: .zero) }()

  fileprivate let viewModel: EmptyCommentsCellViewModelType =
    EmptyCommentsCellViewModel()
  
  // MARK: - Lifecycle

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

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

    _ = self.noCommentsLabel
      |> \.lineBreakMode .~ .byWordWrapping
      |> \.numberOfLines .~ 0
      |> \.adjustsFontForContentSizeCategory .~ true
      |> \.font .~ UIFont.ksr_callout()
  }

  // MARK: - Configuration
  internal func configureWith(value: Project) {
    self.viewModel.inputs.configureWith(project: value)
  }
  
  private func configureViews() {
    _ = (self.noCommentsLabel, self)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToCenterInParent()
  }
  
  // MARK: View Model
  internal override func bindViewModel() {
    self.noCommentsLabel.rac.text = viewModel.outputs.emptyText
  }
}
