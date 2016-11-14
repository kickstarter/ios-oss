import Library
import Prelude
import UIKit

internal final class DiscoveryExpandableRowCell: UITableViewCell, ValueCell {
  private let viewModel: DiscoveryExpandableRowCellViewModelType = DiscoveryExpandableRowCellViewModel()

  @IBOutlet private weak var filterTitleLabel: UILabel!
  @IBOutlet private weak var projectsCountLabel: UILabel!

  internal func configureWith(value value: (row: ExpandableRow, categoryId: Int?)) {
    self.viewModel.inputs.configureWith(row: value.0, categoryId: value.1)
  }

  internal override func bindStyles() {
    super.bindStyles()

    self
      |> discoveryFilterRowMarginStyle
      |> UITableViewCell.lens.accessibilityTraits .~ UIAccessibilityTraitButton

    self.projectsCountLabel
      |> UILabel.lens.isAccessibilityElement .~ false
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
    self.projectsCountLabel.rac.textColor = self.viewModel.outputs.projectsCountLabelTextColor
    self.projectsCountLabel.rac.alpha = self.viewModel.outputs.projectsCountLabelAlpha

    self.viewModel.outputs.expandCategoryStyle
      .observeForUI()
      .observeNext { [weak filterTitleLabel] expandableRow, categoryId in
        guard let filterTitleLabel = filterTitleLabel else { return }
        filterTitleLabel
        |>  discoveryFilterLabelStyle(categoryId: categoryId, isSelected: expandableRow.isExpanded)
    }

    self.viewModel.outputs.filterIsExpanded
      .observeForUI()
      .observeNext { [weak filterTitleLabel] filterIsExpanded in
        guard let filterTitleLabel = filterTitleLabel else { return }
        filterTitleLabel |> discoveryFilterLabelFontStyle(isSelected: filterIsExpanded)
    }
  }

  internal func willDisplay() {
    self.viewModel.inputs.willDisplay()
  }
}
