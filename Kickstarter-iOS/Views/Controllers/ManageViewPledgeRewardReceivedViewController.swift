import KsApi
import Library
import Prelude
import UIKit

final class ManageViewPledgeRewardReceivedViewController: ToggleViewController {
  // MARK: - Properties

  private let viewModel: ManageViewPledgeRewardReceivedViewModelType
    = ManageViewPledgeRewardReceivedViewModel()

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    self.toggle.addTarget(
      self,
      action: #selector(ManageViewPledgeRewardReceivedViewController.toggleValueDidChange(_:)),
      for: .valueChanged
    )

    self.viewModel.inputs.viewDidLoad()
  }

  // MARK: - Actions

  @objc private func toggleValueDidChange(_ toggle: UISwitch) {
    self.viewModel.inputs.rewardReceivedToggleTapped(isOn: toggle.isOn)
  }

  // MARK: - Configuration

  public func configureWith(project: Project) {
    self.viewModel.inputs.configureWith(project)
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.titleLabel
      |> checkoutTitleLabelStyle
      |> \.text %~ { _ in Strings.Reward_received() }

    _ = self.toggle
      |> checkoutSwitchControlStyle
      |> \.accessibilityLabel %~ { _ in Strings.Reward_received() }
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.toggle.rac.on = self.viewModel.outputs.rewardReceived
  }
}
