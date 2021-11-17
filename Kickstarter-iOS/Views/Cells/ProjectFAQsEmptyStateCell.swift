import Library
import Prelude
import UIKit

final class ProjectFAQsEmptyStateCell: UITableViewCell, ValueCell {
  // MARK: - Properties

  private lazy var titleTextLabel: UILabel = {
    UILabel(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  // MARK: - Lifecycle

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.bindStyles()
    self.configureViews()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()

    _ = self.contentView
      |> \.layoutMargins .~ .init(all: Styles.grid(3))

    // TODO: - Internationalize strings
    _ = self.titleTextLabel
      |> \.font .~ UIFont.ksr_body()
      |> \.numberOfLines .~ 0
      |> \.textColor .~ .ksr_support_700
      |> \.text .~
      "Looks like there aren't any frequently asked questions yet. Ask the project creator directly."
  }

  // MARK: - Configuration

  func configureWith(value _: Void) {
    return
  }

  private func configureViews() {
    _ = (self.titleTextLabel, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()
  }
}
