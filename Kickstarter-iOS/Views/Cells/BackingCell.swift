import KsApi
import Library
import Prelude
import ReactiveExtensions
import UIKit

internal final class BackingCell: UITableViewCell, ValueCell {
  fileprivate let viewModel: BackingCellViewModelType = BackingCellViewModel()

  @IBOutlet fileprivate weak var deliveryLabel: UILabel!
  @IBOutlet fileprivate weak var pledgedLabel: UILabel!
  @IBOutlet fileprivate weak var rewardLabel: UILabel!
  @IBOutlet fileprivate weak var rootStackView: UIStackView!

  internal func configureWith(value: (Backing, Project)) {
    self.viewModel.inputs.configureWith(backing: value.0, project: value.1)
  }

  internal override func bindStyles() {
    super.bindStyles()

    self
      |> baseTableViewCellStyle()
      |> BackingCell.lens.contentView.layoutMargins %~~ { layoutMargins, cell in
        cell.traitCollection.isRegularRegular
          ? .init(topBottom: Styles.grid(6), leftRight: Styles.grid(16))
          : layoutMargins
    }
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.pledgedLabel.rac.text = self.viewModel.outputs.pledged
    self.rewardLabel.rac.text = self.viewModel.outputs.reward
    self.deliveryLabel.rac.text = self.viewModel.outputs.delivery
    self.deliveryLabel.rac.accessibilityLabel = self.viewModel.outputs.deliveryAccessibilityLabel
    self.rootStackView.rac.alignment = self.viewModel.outputs.rootStackViewAlignment
  }
}
