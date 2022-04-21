import Library
import Prelude
import UIKit

protocol SettingsPrivacySwitchCellDelegate: AnyObject {
  func privacySettingsSwitchCell(
    _ cell: SettingsPrivacySwitchCell,
    didTogglePrivacySwitch on: Bool
  )
}

final class SettingsPrivacySwitchCell: UITableViewCell, ValueCell, NibLoading {
  @IBOutlet fileprivate var primaryDescriptionLabel: UILabel!
  @IBOutlet fileprivate var titleLabel: UILabel!
  @IBOutlet fileprivate var secondaryDescriptionLabel: UILabel!
  @IBOutlet fileprivate var switchButton: UISwitch!
  @IBOutlet fileprivate var separatorViews: [UIView]!

  private let viewModel: SettingsPrivacySwitchCellViewModelType = SettingsPrivacySwitchCellViewModel()

  weak var delegate: SettingsPrivacySwitchCellDelegate?

  override func awakeFromNib() {
    super.awakeFromNib()

    _ = self
      |> \.accessibilityElements .~ [self.switchButton].compact()
  }

  func configureWith(value: SettingsPrivacySwitchCellValue) {
    self.viewModel.inputs.configure(with: value.user)

    _ = self.titleLabel
      |> \.text .~ value.cellType.title

    _ = self.primaryDescriptionLabel
      |> \.text .~ value.cellType.primaryDescription

    _ = self.secondaryDescriptionLabel
      |> \.text .~ value.cellType.secondaryDescription

    _ = self.switchButton
      |> \.accessibilityLabel .~ value.cellType.title
      |> \.accessibilityHint .~ "\(value.cellType.primaryDescription), \(value.cellType.secondaryDescription)"
  }

  override func bindStyles() {
    super.bindViewModel()

    _ = self
      |> UIView.lens.backgroundColor .~ .ksr_support_100

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

    self.switchButton.rac.on = self.viewModel.outputs.privacySwitchIsOn

    self.viewModel.outputs.privacySwitchToggledOn
      .observeForControllerAction()
      .observeValues { [weak self] privacyEnabled in
        guard let self = self else { return }

        self.delegate?.privacySettingsSwitchCell(self, didTogglePrivacySwitch: privacyEnabled)
      }
  }

  @IBAction func switchToggled(_ sender: UISwitch) {
    self.viewModel.inputs.switchToggled(on: sender.isOn)
  }
}
