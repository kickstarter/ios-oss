import Library
import UIKit

internal final class DiscoveryExpandableRowCell: UITableViewCell, ValueCell {
  @IBOutlet private weak var filterTitleLabel: UILabel!
  @IBOutlet private weak var projectsCountLabel: UILabel!
  @IBOutlet private weak var expandedIndicatorView: UIView!
  @IBOutlet private /*strong*/ var expandedConstraint: NSLayoutConstraint!

  func configureWith(value value: ExpandableRow) {
    self.filterTitleLabel.text = value.params.category?.name

    let count = value.params.category?.projectsCount ?? 0
    self.projectsCountLabel.text = Format.wholeNumber(count)
    self.projectsCountLabel.hidden = 0 == count

    self.expandedIndicatorView.hidden = !value.isExpanded
    self.expandedConstraint.active = value.isExpanded
  }
}
