import Library
import Prelude
import UIKit

internal final class DiscoveryExpandableRowCell: UITableViewCell, ValueCell {
  @IBOutlet private weak var filterTitleLabel: UILabel!
  @IBOutlet private weak var projectsCountLabel: UILabel!

  private var isExpanded: Bool = false

  func configureWith(value value: (row: ExpandableRow, categoryId: Int?)) {
    self.filterTitleLabel.text = value.row.params.category?.name

    let count = value.row.params.category?.projectsCount ?? 0
    self.projectsCountLabel.text = Format.wholeNumber(count)
    self.projectsCountLabel.hidden = 0 == count

    self.filterTitleLabel
      |> discoveryFilterLabelStyle(categoryId: value.categoryId, isSelected: value.row.isExpanded)

    self.projectsCountLabel
      |> UILabel.lens.textColor .~ discoverySecondaryColor(forCategoryId: value.categoryId)
      |> UILabel.lens.alpha .~ (value.categoryId == nil) ? 1.0 : (value.row.isExpanded ? 1.0 : 0.4)

    self.isExpanded = value.row.isExpanded
  }

  override func bindStyles() {
    super.bindStyles()

    self
      |> discoveryFilterRowMarginStyle

    self.projectsCountLabel
      |> UILabel.lens.font %~~ { _, label in
        label.traitCollection.isRegularRegular ? UIFont.ksr_headline(size: 13) : UIFont.ksr_headline(size: 11)
    }
  }

  internal func willDisplay() {
    self.filterTitleLabel
      |> discoveryFilterLabelFontStyle(isSelected: self.isExpanded)
  }
}
