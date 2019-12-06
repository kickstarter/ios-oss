import KsApi
import Library
import Prelude
import UIKit

final class ErroredBackingCell: UITableViewCell, ValueCell {
  // MARK: - Properties

  private let projectNameLabel: UILabel = { UILabel(frame: .zero) }()

  // MARK: - Life cycle

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.configureViews()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  // MARK: - Configuration

  func configureWith(value: GraphBacking) {
    self.projectNameLabel.text = value.project?.name
  }

  private func configureViews() {
    _ = (self.projectNameLabel, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()
  }
}
