import Foundation
import KsApi
import Library
import Prelude
import UIKit

final class FeatureFlagToolsViewController: UITableViewController {
  private let viewModel = FeatureFlagToolsViewModel()
  private var features = [(Feature, Bool)]()

  private let reuseId = "FeatureFlagTools.TableViewCell"

  static func insantiate() -> FeatureFlagToolsViewController {
    return FeatureFlagToolsViewController.init(nibName: nil, bundle: nil)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    _ = self.tableView
      |> \.tableFooterView .~ UIView(frame: .zero)

    self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseId)

    self.viewModel.inputs.viewDidLoad()
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.reloadWithData
      .observeForUI()
      .observeValues { [weak self] features in
        self?.features = features

        self?.tableView.reloadData()
    }

    self.viewModel.outputs.updateConfigWithFeatures
      .observeForUI()
      .observeValues { [weak self] features in
        self?.updateConfig(with: features)
    }
  }

  @objc func switchTogged(_ switchControl: UISwitch) {
    self.viewModel.inputs.setFeatureAtIndexEnabled(index: switchControl.tag, isEnabled: switchControl.isOn)
  }

  // MARK: - Private Helpers

  private func updateConfig(with features: Features) {
    guard let config = AppEnvironment.current.config else { return }

    let updatedConfig = config |> \.features .~ features

    AppEnvironment.updateConfig(updatedConfig)

    self.viewModel.inputs.didUpdateConfig()
  }
}

// MARK: - UITableViewDataSource

extension FeatureFlagToolsViewController {
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return features.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: reuseId, for: indexPath)
    let feature = features[indexPath.row]

    let switchControl = UISwitch(frame: .zero)
      |> switchStyle
      |> \.tag .~ indexPath.row
      |> \.isOn .~ feature.1

    switchControl.addTarget(self, action: #selector(switchTogged(_:)), for: .valueChanged)

    _ = cell
      ?|> baseTableViewCellStyle()
      ?|> \.accessoryView .~ switchControl

    _ = cell.textLabel
      ?|> titleLabelStyle
      ?|> \.text .~ feature.0.description

    return cell
  }
}

private let titleLabelStyle: LabelStyle = { label in
  label
    |> \.textColor .~ .ksr_soft_black
    |> \.font .~ .ksr_body()
}

private let switchStyle: SwitchControlStyle = { switchControl in
  switchControl
    |> \.onTintColor .~ .ksr_green_700
    |> \.tintColor .~ .ksr_grey_600
}
