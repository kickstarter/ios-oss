import Library
import UIKit

internal final class DiscoverySelectableRowCell: UITableViewCell, ValueCell {
  @IBOutlet private weak var filterTitleLabel: UILabel!
  @IBOutlet private weak var selectedIndicator: UIView!

  func configureWith(value value: SelectableRow) {

    if value.params.staffPicks == true {
      self.filterTitleLabel.text = Strings.discovery_recommended()
    } else if value.params.starred == true {
      self.filterTitleLabel.text = Strings.discovery_saved()
    } else if value.params.social == true {
      self.filterTitleLabel.text = Strings.discovery_friends_backed()
    } else if let category = value.params.category {
      self.filterTitleLabel.text = category.name
    } else if value.params.recommended == true {
      self.filterTitleLabel.text = localizedString(key: "discovery.recommended_for_you",
                                                   defaultValue: "Recommended for you")
    } else {
      self.filterTitleLabel.text = Strings.discovery_everything()
    }

    self.selectedIndicator.hidden = !value.isSelected
  }
}
