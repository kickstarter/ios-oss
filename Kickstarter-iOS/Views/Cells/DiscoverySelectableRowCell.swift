import Library
import Prelude
import UIKit

internal final class DiscoverySelectableRowCell: UITableViewCell, ValueCell {
  @IBOutlet private weak var filterTitleLabel: UILabel!

  func configureWith(value value: (row: SelectableRow, categoryId: Int?)) {
    if value.row.params.staffPicks == true {
      self.filterTitleLabel.text = Strings.Projects_We_Love()
    } else if value.row.params.starred == true {
      self.filterTitleLabel.text = Strings.discovery_saved()
    } else if value.row.params.social == true {
      self.filterTitleLabel.text = Strings.Following()
    } else if let category = value.row.params.category {
      self.filterTitleLabel.text = category.name
    } else if value.row.params.recommended == true {
      self.filterTitleLabel.text = Strings.discovery_recommended_for_you()
    } else {
      self.filterTitleLabel.text = Strings.All_Projects()
    }

    self.filterTitleLabel |> discoveryFilterLabelStyle(categoryId: value.categoryId,
                                                       isSelected: value.row.isSelected)

    self
      |> UITableViewCell.lens.contentView.layoutMargins .~ .init(top: Styles.grid(2),
                                                                 left: Styles.grid(4),
                                                                 bottom: Styles.grid(2),
                                                                 right: Styles.grid(2))
  }
}
