import Library
import KsApi
import Prelude
import UIKit

final class ManageViewPledgeRewardReceivedViewController: ToggleViewController {
  // MARK: - Properties

  private let viewModel: ManageViewPledgeRewardReceivedViewModelType
    = ManageViewPledgeRewardReceivedViewModel()

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    self.toggle.addTarget(self, action: #selector(toggleValueDidChange(_:)), for: .valueChanged)

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
      |> \.text %~ { _ in localizedString(key: "Reward_received", defaultValue: "Reward received") }

    _ = self.toggle
      |> checkoutSwitchControlStyle
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.rewardReceived
      .observeForUI()
      .observeValues { [weak self] isOn in
        self?.toggle.isOn = isOn
    }
  }
}
