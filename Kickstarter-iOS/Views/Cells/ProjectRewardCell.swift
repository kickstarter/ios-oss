import UIKit
import Library
import ReactiveCocoa
import KsApi

internal final class ProjectRewardCell: UITableViewCell, ValueCell {
  private let viewModel: ProjectRewardCellViewModelType = ProjectRewardCellViewModel()

  @IBOutlet internal weak var titleLabel: UILabel!
  @IBOutlet internal weak var backersLabel: UILabel!
  @IBOutlet internal weak var limitedView: UIView!
  @IBOutlet internal weak var limitedLabel: UILabel!
  @IBOutlet internal weak var allGoneView: UIView!
  @IBOutlet internal weak var descriptionLabel: UILabel!
  @IBOutlet internal weak var shippingView: UIView!
  @IBOutlet internal weak var estimatedDeliveryLabel: UILabel!
  @IBOutlet internal weak var shippingRestrictionsView: UIView!
  @IBOutlet internal weak var shippingSummaryLabel: UILabel!
  @IBOutlet internal weak var youSelectedView: UIView!

  // swiftlint:disable function_body_length
  override internal func bindViewModel() {
    self.titleLabel.rac.text = self.viewModel.outputs.title
    self.descriptionLabel.rac.text = self.viewModel.outputs.description
    self.backersLabel.rac.text = self.viewModel.outputs.backers
    self.backersLabel.rac.hidden = self.viewModel.outputs.backersHidden
    self.limitedLabel.rac.text = self.viewModel.outputs.limit
    self.limitedView.rac.hidden = self.viewModel.outputs.limitHidden
    self.allGoneView.rac.hidden = self.viewModel.outputs.allGoneHidden
    self.rac.alpha = self.viewModel.outputs.rewardDisabled.map { $0 ? 0.5 : 1.0 }
    self.shippingView.rac.hidden = self.viewModel.outputs.shippingHidden
    self.estimatedDeliveryLabel.rac.text = self.viewModel.outputs.estimatedDelivery
    self.shippingRestrictionsView.rac.hidden = self.viewModel.outputs.shippingRestrictionsHidden
    self.shippingSummaryLabel.rac.text = self.viewModel.outputs.shippingSummary
    self.youSelectedView.rac.hidden = self.viewModel.outputs.backerLabelHidden
    self.rac.backgroundColor = self.viewModel.outputs.backerLabelHidden
      .map { $0 ? .ksr_white : .ksr_lightGreen }
  }
  // swiftlint:enable function_body_length

  internal func configureWith(value value: (Project, Reward)) {
    self.viewModel.inputs.project(value.0, reward: value.1)
  }
}
