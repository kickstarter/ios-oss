import Library
import KsApi
import ReactiveExtensions
import UIKit

internal final class BackingCell: UITableViewCell, ValueCell {
  private let viewModel: BackingCellViewModelType = BackingCellViewModel()

  @IBOutlet private weak var pledgedLabel: UILabel!
  @IBOutlet private weak var rewardLabel: UILabel!
  @IBOutlet private weak var deliveryLabel: UILabel!

  func configureWith(value value: (Backing, Project)) {
    self.viewModel.inputs.configureWith(backing: value.0, project: value.1)
  }

  override func bindViewModel() {
    self.pledgedLabel.rac.text = self.viewModel.outputs.pledged
    self.rewardLabel.rac.text = self.viewModel.outputs.reward
    self.deliveryLabel.rac.text = self.viewModel.outputs.delivery
  }
}
