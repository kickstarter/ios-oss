import Library
import Prelude
import UIKit

internal final class DiscoverySelectableRowCell: UITableViewCell, ValueCell {
  @IBOutlet private weak var filterTitleLabel: UILabel!

  private var rowIsSelected: Bool = false

  func configureWith(value: (row: SelectableRow, categoryId: Int?)) {
    if value.row.params.staffPicks == true {
      self.filterTitleLabel.text = Strings.Projects_We_Love()
      self.filterTitleLabel.accessibilityLabel = Strings.Filter_by_projects_we_love()
    } else if value.row.params.hasLiveStreams == .some(true) {
      self.filterTitleLabel.text = "Kickstarter Live"
      self.filterTitleLabel.accessibilityLabel = localizedString(
        key: "Filters_by_projects_with_upcoming_and_past_live_streams",
        defaultValue: "Filters by projects with upcoming and past live streams."
      )

    } else if value.row.params.starred == true {
      self.filterTitleLabel.text = Strings.Saved()
      self.filterTitleLabel.accessibilityLabel = Strings.Filter_by_saved_projects()
    } else if value.row.params.social == true {
      self.filterTitleLabel.text = Strings.Backed_by_people_you_follow()
      self.filterTitleLabel.accessibilityLabel = Strings.Filter_by_projects_backed_by_friends()
    } else if let category = value.row.params.category {
      self.filterTitleLabel.text = category.name
    } else if value.row.params.recommended == true {
      self.filterTitleLabel.text = Strings.discovery_recommended_for_you()
      self.filterTitleLabel.accessibilityLabel = Strings.Filter_by_projects_recommended_for_you()
    } else {
      self.filterTitleLabel.text = Strings.All_Projects()
      self.filterTitleLabel.accessibilityLabel = Strings.Filter_by_all_projects()
    }

    _ = self.filterTitleLabel
      |> discoveryFilterLabelStyle(categoryId: value.categoryId, isSelected: value.row.isSelected)
      |> UILabel.lens.numberOfLines .~ 0

    self.rowIsSelected = value.row.isSelected
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> discoveryFilterRowMarginStyle
      |> UITableViewCell.lens.accessibilityTraits .~ UIAccessibilityTraitButton
  }

  internal func willDisplay() {
    _ = self.filterTitleLabel
      |> discoveryFilterLabelFontStyle(isSelected: self.rowIsSelected)
  }
}
