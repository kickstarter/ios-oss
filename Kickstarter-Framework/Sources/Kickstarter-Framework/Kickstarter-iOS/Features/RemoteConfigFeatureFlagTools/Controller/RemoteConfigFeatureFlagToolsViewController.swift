import Foundation
import KsApi
import Library
import Prelude
import UIKit

final class RemoteConfigFeatureFlagToolsViewController: UITableViewController {
  // MARK: - Properties

  private var remoteConfigFeatures = RemoteConfigFeatures()
  private var statsigFeatures = StatsigFeatures()
  private let reuseId = "FeatureFlagTools.TableViewCell"
  private let viewModel: RemoteConfigFeatureFlagToolsViewModelType = RemoteConfigFeatureFlagToolsViewModel()

  static func instantiate() -> RemoteConfigFeatureFlagToolsViewController {
    return RemoteConfigFeatureFlagToolsViewController(style: .plain)
  }

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    _ = self
      |> \.title .~ "Remote Config & Statsig Feature flags"

    _ = self.tableView
      |> \.tableFooterView .~ UIView(frame: .zero)

    self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: self.reuseId)

    self.viewModel.inputs.viewDidLoad()
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.reloadWithRemoteConfigData
      .observeForUI()
      .observeValues { [weak self] features in
        self?.remoteConfigFeatures = features
        self?.tableView.reloadData()
      }

    self.viewModel.outputs.updateUserDefaultsWithRemoteConfigFeatures
      .observeForUI()
      .observeValues { [weak self] features in
        self?.updateUserDefaults(with: features)
      }

    self.viewModel.outputs.reloadWithStatsigData
      .observeForUI()
      .observeValues { [weak self] features in
        self?.statsigFeatures = features
        self?.tableView.reloadData()
      }

    self.viewModel.outputs.updateUserDefaultsWithStatsigFeatures
      .observeForUI()
      .observeValues { [weak self] _ in
        self?.viewModel.inputs.didUpdateUserDefaults()
      }
  }

  @objc private func switchToggled(_ switchControl: UISwitch) {
    self.viewModel.inputs.setFeatureAtIndexEnabled(index: switchControl.tag, isEnabled: switchControl.isOn)
  }

  @objc private func statsigSwitchToggled(_ switchControl: UISwitch) {
    self.viewModel.inputs.setStatsigFeatureAtIndexEnabled(
      index: switchControl.tag,
      isEnabled: switchControl.isOn
    )
  }

  // MARK: - Private Helpers

  private func updateUserDefaults(with _: RemoteConfigFeatures) {
    self.viewModel.inputs.didUpdateUserDefaults()
  }
}

// MARK: - UITableViewDataSource

extension RemoteConfigFeatureFlagToolsViewController {
  override func numberOfSections(in _: UITableView) -> Int {
    return 2
  }

  override func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
    return section == 0 ? "Remote Config Feature Flags" : "Statsig Feature Gates"
  }

  override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
    return section == 0 ? self.remoteConfigFeatures.count : self.statsigFeatures.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: self.reuseId, for: indexPath)

    let description: String
    let enabled: Bool
    let selector: Selector

    /// Remote Config Features
    if indexPath.section == 0 {
      let (feature, isEnabled) = self.remoteConfigFeatures[indexPath.row]
      description = feature.description
      enabled = isEnabled
      selector = #selector(self.switchToggled(_:))
    } else {
      /// Statsig Features
      let (feature, isEnabled) = self.statsigFeatures[indexPath.row]
      description = feature.description
      enabled = isEnabled
      selector = #selector(self.statsigSwitchToggled(_:))
    }

    let switchControl = UISwitch(frame: .zero)
      |> baseSwitchControlStyle
      |> \.tag .~ indexPath.row
      |> \.isOn .~ enabled

    switchControl.addTarget(self, action: selector, for: .valueChanged)

    _ = cell
      ?|> baseTableViewCellStyle()
      ?|> \.accessoryView .~ switchControl

    _ = cell.textLabel
      ?|> baseTableViewCellTitleLabelStyle
      ?|> \.text .~ description

    return cell
  }
}
