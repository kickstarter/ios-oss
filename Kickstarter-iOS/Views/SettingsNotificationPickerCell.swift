import Foundation
import KsApi
import Library
import Prelude

protocol SettingsNotificationPickerCellDelegate: class {
  func settingsNotificationPickerCellDidTapFrequencyPickerButton(_ cell: SettingsNotificationPickerCell)
}

final class SettingsNotificationPickerCell: UITableViewCell, NibLoading, ValueCell {
  @IBOutlet fileprivate weak var titleLabel: UILabel!
  @IBOutlet fileprivate weak var selectFrequencyButton: UIButton!
  @IBOutlet fileprivate weak var separatorView: UIView!

  weak var delegate: SettingsNotificationPickerCellDelegate?

  private let viewModel: SettingsNotificationPickerViewModelType = SettingsNotificationPickerViewModel()

  func configureWith(value: SettingsNotificationCellValue) {
    self.viewModel.inputs.configure(with: value)

    _ = titleLabel
      |> UILabel.lens.text .~ value.cellType.title
  }

  override func bindStyles() {
    super.bindStyles()

    _ = titleLabel
      |> settingsTitleLabelStyle

    _ = selectFrequencyButton
      |> UIButton.lens.titleLabel.font .~ .ksr_body()
      |> UIButton.lens.titleColor(for: .normal) .~ .ksr_text_dark_grey_400

    _ = separatorView
      |> separatorStyle
  }

  override func bindViewModel() {
    super.bindViewModel()

    selectFrequencyButton.rac.title = self.viewModel.outputs.frequencyValueText

    self.viewModel.outputs.notifyDelegateDidTapFrequencyButton
      .observeForUI()
      .observeValues { [weak self] in
        guard let _self = self else { return }
        _self.delegate?.settingsNotificationPickerCellDidTapFrequencyPickerButton(_self)
    }
  }

  @IBAction func selectFrequencyButtonTapped(_ sender: Any) {
    self.viewModel.inputs.frequencyPickerButtonTapped()
  }
}
