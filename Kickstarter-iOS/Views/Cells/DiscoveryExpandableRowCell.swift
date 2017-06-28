import Library
import Prelude
import UIKit

internal final class DiscoveryExpandableRowCell: UITableViewCell, ValueCell {
  fileprivate let viewModel: DiscoveryExpandableRowCellViewModelType = DiscoveryExpandableRowCellViewModel()

  @IBOutlet fileprivate weak var filterTitleLabel: UILabel!
  @IBOutlet fileprivate weak var projectsCountLabel: UILabel!

  internal func configureWith(value: (row: ExpandableRow, categoryId: Int?)) {
    self.viewModel.inputs.configureWith(row: value.0, categoryId: value.1)
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> discoveryFilterRowMarginStyle
      |> UITableViewCell.lens.accessibilityTraits .~ UIAccessibilityTraitButton

    _ = self.projectsCountLabel
      |> UILabel.lens.isAccessibilityElement .~ false
      |> UILabel.lens.textColor .~ discoverySecondaryColor()
      |> UILabel.lens.font %~~ { _, label in
        label.traitCollection.isRegularRegular
          ? UIFont.ksr_headline(size: 13)
          : UIFont.ksr_headline(size: 11)
    }
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.rac.accessibilityLabel = self.viewModel.outputs.cellAccessibilityLabel
    self.rac.accessibilityHint = self.viewModel.outputs.cellAccessibilityHint
    self.filterTitleLabel.rac.text = self.viewModel.outputs.filterTitleLabelText
    self.projectsCountLabel.rac.text = self.viewModel.outputs.projectsCountLabelText
    self.projectsCountLabel.rac.hidden = self.viewModel.outputs.projectsCountLabelHidden
    self.projectsCountLabel.rac.alpha = self.viewModel.outputs.projectsCountLabelAlpha

    self.viewModel.outputs.expandCategoryStyle
      .observeForUI()
      .observeValues { [weak filterTitleLabel] expandableRow, categoryId in
        guard let filterTitleLabel = filterTitleLabel else { return }
        _ = filterTitleLabel
          |>  discoveryFilterLabelStyle(categoryId: categoryId, isSelected: expandableRow.isExpanded)
    }

    self.viewModel.outputs.filterIsExpanded
      .observeForUI()
      .observeValues { [weak filterTitleLabel] filterIsExpanded in
        guard let filterTitleLabel = filterTitleLabel else { return }
        _ = filterTitleLabel |> discoveryFilterLabelFontStyle(isSelected: filterIsExpanded)
    }
  }

  internal func willDisplay() {
    self.viewModel.inputs.willDisplay()
  }
}
