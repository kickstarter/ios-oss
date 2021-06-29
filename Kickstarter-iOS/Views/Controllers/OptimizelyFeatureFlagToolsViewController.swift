import Foundation
import KsApi
import Library
import Prelude
import UIKit

final class OptimizelyFeatureFlagToolsViewController: UITableViewController {
  // MARK: - Properties

  private var features = OptimizelyFeatures()
  private let reuseId = "FeatureFlagTools.TableViewCell"
  private let viewModel: OptimizelyFeatureFlagToolsViewModelType = OptimizelyFeatureFlagToolsViewModel()

  static func instantiate() -> OptimizelyFeatureFlagToolsViewController {
    return OptimizelyFeatureFlagToolsViewController(style: .plain)
  }

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    _ = self
      |> \.title .~ "Optimizely Feature flags"

    _ = self.tableView
      |> \.tableFooterView .~ UIView(frame: .zero)

    self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: self.reuseId)

    self.viewModel.inputs.viewDidLoad()
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.reloadWithData
      .observeForUI()
      .observeValues { [weak self] features in
        self?.features = features

        self?.tableView.reloadData()
      }

    self.viewModel.outputs.updateUserDefaultsWithFeatures
      .observeForUI()
      .observeValues { [weak self] features in
        self?.updateUserDefaults(with: features)
      }
  }

  @objc private func switchToggled(_ switchControl: UISwitch) {
    self.viewModel.inputs.setFeatureAtIndexEnabled(index: switchControl.tag, isEnabled: switchControl.isOn)
  }

  // MARK: - Private Helpers

  private func updateUserDefaults(with _: OptimizelyFeatures) {
    self.viewModel.inputs.didUpdateUserDefaults()
  }
}

// MARK: - UITableViewDataSource

extension OptimizelyFeatureFlagToolsViewController {
  override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
    return self.features.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: self.reuseId, for: indexPath)
    let (feature, enabled) = self.features[indexPath.row]

    let switchControl = UISwitch(frame: .zero)
      |> baseSwitchControlStyle
      |> \.tag .~ indexPath.row
      |> \.isOn .~ enabled

    switchControl.addTarget(self, action: #selector(self.switchToggled(_:)), for: .valueChanged)

    _ = cell
      ?|> baseTableViewCellStyle()
      ?|> \.accessoryView .~ switchControl

    _ = cell.textLabel
      ?|> baseTableViewCellTitleLabelStyle
      ?|> \.text .~ feature.description

    return cell
  }
}
