import Foundation
import Library
import Prelude

protocol SettingsPrivacySwitchCellDelegate: class {
  func privacySettingsSwitchCell(_ cell: SettingsPrivacySwitchCell,
                                 didTogglePrivacySwitch on: Bool)
}

final class SettingsPrivacySwitchCell: UITableViewCell, ValueCell, NibLoading {
  @IBOutlet fileprivate weak var primaryDescriptionLabel: UILabel!
  @IBOutlet fileprivate weak var titleLabel: UILabel!
  @IBOutlet fileprivate weak var secondaryDescriptionLabel: UILabel!
  @IBOutlet fileprivate weak var switchButton: UISwitch!
  @IBOutlet fileprivate var separatorViews: [UIView]!

  private let viewModel = SettingsPrivacySwitchCellViewModel()

  weak var delegate: SettingsPrivacySwitchCellDelegate?

  override func awakeFromNib() {
    super.awakeFromNib()

    _ = self
      |> \.accessibilityElements .~ [self.switchButton]
  }

  func configureWith(value: SettingsPrivacySwitchCellValue) {
    self.viewModel.configure(with: value.user)

    _ = self.titleLabel
      |> \.text .~ value.cellType.title

    _ = self.primaryDescriptionLabel
      |> \.text .~ value.cellType.primaryDescription

    _ = self.secondaryDescriptionLabel
      |> \.text .~ value.cellType.secondaryDescription

    _ = self.switchButton
      |> \.accessibilityLabel %~ { _ in value.cellType.title }
      |> \.accessibilityHint %~ { _ in
        "\(value.cellType.primaryDescription), \(value.cellType.secondaryDescription)"
    }
  }

  override func bindStyles() {
    super.bindViewModel()

    _ = self
      |> UIView.lens.backgroundColor .~ .ksr_grey_100

    _ = self.titleLabel
      |> settingsTitleLabelStyle

    _ = self.primaryDescriptionLabel
      |> settingsDescriptionLabelStyle

    _ = self.secondaryDescriptionLabel
      |> settingsDescriptionLabelStyle

    _ = self.switchButton
      |> settingsSwitchStyle

    _ = self.separatorViews
      ||> settingsSeparatorStyle
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.switchButton.rac.on = self.viewModel.privacySwitchIsOn

    self.viewModel.privacySwitchToggledOn
      .observeForControllerAction()
      .observeValues { [weak self] (privacyEnabled) in
        guard let `self` = self else { return }

        self.delegate?.privacySettingsSwitchCell(self, didTogglePrivacySwitch: privacyEnabled)
    }
  }

  @IBAction func switchToggled(_ sender: UISwitch) {
    self.viewModel.switchToggled(on: sender.isOn)
  }
}
