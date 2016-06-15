import Library
import UIKit

internal final class DiscoveryExpandedSelectableRowCell: UITableViewCell, ValueCell {
  @IBOutlet private weak var filterTitleLabel: UILabel!

  func configureWith(value value: SelectableRow) {
    if let category = value.params.category where category.isRoot {
      self.filterTitleLabel.text = Strings.discovery_all_of_scope(scope: category.name)
    } else {
      self.filterTitleLabel.text = value.params.category?.name
    }
  }
}
