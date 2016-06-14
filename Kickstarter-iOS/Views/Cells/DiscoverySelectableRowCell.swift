import Library
import UIKit

internal final class DiscoverySelectableRowCell: UITableViewCell, ValueCell {
  @IBOutlet private weak var filterTitleLabel: UILabel!
  @IBOutlet private weak var selectedIndicator: UIView!

  func configureWith(value value: SelectableRow) {

    if value.params.staffPicks == true {
      self.filterTitleLabel.text = localizedString(key: "discovery.recommended",
                                                   defaultValue: "Staff Picks")
    } else if value.params.starred == true {
      self.filterTitleLabel.text = localizedString(key: "discovery.saved",
                                                   defaultValue: "Starred")
    } else if value.params.social == true {
      self.filterTitleLabel.text = localizedString(key: "discovery.friends_backed",
                                                   defaultValue: "Friends Backed")
    } else if let category = value.params.category {
      self.filterTitleLabel.text = category.name
    } else {
      self.filterTitleLabel.text = localizedString(key: "discovery.everything",
                                                   defaultValue: "Everything")
    }

    self.selectedIndicator.hidden = !value.isSelected
  }
}
