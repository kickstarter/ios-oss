import Foundation
import KsApi
import Library
import Prelude

final class SettingsNotificationPickerCell: UITableViewCell, NibLoading, ValueCell {
  @IBOutlet fileprivate weak var titleLabel: UILabel!
  @IBOutlet fileprivate weak var currentEmailFrequencyLabel: UILabel!
  @IBOutlet fileprivate weak var separatorView: UIView!

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

    _ = currentEmailFrequencyLabel
      |> UILabel.lens.font .~ .ksr_body()
      |> UILabel.lens.textColor .~ .ksr_text_dark_grey_400

    _ = separatorView
      |> separatorStyle
  }

  override func bindViewModel() {
    super.bindViewModel()

    currentEmailFrequencyLabel.rac.text = self.viewModel.outputs.frequencyValueText
  }
}
