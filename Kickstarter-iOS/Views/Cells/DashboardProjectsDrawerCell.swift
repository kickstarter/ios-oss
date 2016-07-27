import KsApi
import Library
import Prelude
import UIKit

internal final class DashboardProjectsDrawerCell: UITableViewCell, ValueCell {

  @IBOutlet weak var projectNumLabel: UILabel!
  @IBOutlet weak var projectNameLabel: UILabel!
  @IBOutlet weak var checkmarkImageView: UIImageView!

  private let viewModel: DashboardProjectsDrawerCellViewModelType =
    DashboardProjectsDrawerCellViewModel()

  internal func configureWith(value value: ProjectsDrawerData) {
    self.viewModel.inputs.configureWith(project: value.project,
                                        indexNum: value.indexNum,
                                        isChecked: value.isChecked)
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.projectNumLabel.rac.text = self.viewModel.outputs.projectNumberText
    self.projectNameLabel.rac.text = self.viewModel.outputs.projectNameText
    self.checkmarkImageView.rac.hidden = self.viewModel.outputs.isCheckmarkHidden

    self.rac.accessibilityLabel = self.viewModel.outputs.cellAccessibilityLabel
    self.rac.accessibilityValue = self.viewModel.outputs.cellAccessibilityValue

    self
      |> UITableViewCell.lens.isAccessibilityElement .~ true
      |> UITableViewCell.lens.accessibilityTraits .~ UIAccessibilityTraitButton
  }

  internal override func bindStyles() {
    self.projectNumLabel |> dashboardDrawerProjectNumberTextLabelStyle
    self.projectNameLabel |> dashboardDrawerProjectNameTextLabelStyle

    self.checkmarkImageView |> UIImageView.lens.tintColor .~ .ksr_navy_600
  }
}
