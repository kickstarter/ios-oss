import Foundation
import KsApi
import Library
import Prelude

protocol SettingsNotificationPickerCellDelegate: class {
  func didFailToSaveChange(errorMessage: String)
  func didTapFrequencyPickerButton()
  func didUpdateUser(user: User)
}

final class SettingsNotificationPickerCell: UITableViewCell, NibLoading, ValueCell {
  @IBOutlet fileprivate weak var titleLabel: UILabel!
  @IBOutlet fileprivate weak var selectFrequencyButton: UIButton!

  weak var delegate: SettingsNotificationPickerCellDelegate?

  private let viewModel: SettingsNotificationPickerViewModelType = SettingsNotificationPickerViewModel()

  func configureWith(value: SettingsNotificationCellValue) {

    _ = titleLabel
    |> UILabel.lens.text .~ value.cellType.title
  }

  override func bindStyles() {
    super.bindStyles()

    _ = titleLabel
    |> settingsTitleLabelStyle

    _ = selectFrequencyButton
    |> UIButton.lens.titleLabel.font .~ .ksr_body()
    |> UIButton.lens.titleColor(for: .normal) .~ .ksr_grey_400
  }

  override func bindViewModel() {
    super.bindViewModel()

    selectFrequencyButton.rac.title = self.viewModel.outputs.frequencyValueText
  }

  @IBAction func selectFrequencyButtonTapped(_ sender: Any) {
    self.delegate?.didTapFrequencyPickerButton()
  }
}
