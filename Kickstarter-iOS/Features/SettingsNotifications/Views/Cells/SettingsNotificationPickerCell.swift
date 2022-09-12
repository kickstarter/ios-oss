import KsApi
import Library
import Prelude
import UIKit

final class SettingsNotificationPickerCell: UITableViewCell, NibLoading, ValueCell {
  @IBOutlet fileprivate var titleLabel: UILabel!
  @IBOutlet fileprivate var currentEmailFrequencyLabel: UILabel!
  @IBOutlet fileprivate var separatorView: UIView!

  private let viewModel: SettingsNotificationPickerViewModelType = SettingsNotificationPickerViewModel()

  func configureWith(value: SettingsNotificationCellValue) {
    self.viewModel.inputs.configure(with: value)

    _ = self
      |> \.accessibilityTraits .~ value.cellType.accessibilityTraits

    _ = self.titleLabel
      |> UILabel.lens.text .~ value.cellType.title
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self.titleLabel
      |> settingsTitleLabelStyle

    _ = self.currentEmailFrequencyLabel
      |> UILabel.lens.font .~ .ksr_body()
      |> UILabel.lens.textColor .~ .ksr_support_400

    _ = self.separatorView
      |> separatorStyle
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.currentEmailFrequencyLabel.rac.text = self.viewModel.outputs.frequencyValueText
  }
}
