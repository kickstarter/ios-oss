import Foundation
import KsApi
import Library
import Prelude

final class SettingsNotificationPickerCell: UITableViewCell, NibLoading, ValueCell {
  @IBOutlet fileprivate weak var titleLabel: UILabel!
  @IBOutlet fileprivate weak var selectFrequencyButton: UIButton!

  func configureWith(value: SettingsNotificationCellValue) {

    _ = titleLabel
    |> UILabel.lens.text .~ value.cellType.title
  }

  override func bindStyles() {
    super.bindStyles()

    _ = titleLabel
    |> settingsSectionLabelStyle

    _ = selectFrequencyButton
    |> UIButton.lens.titleLabel.font .~ .ksr_body()
    |> UIButton.lens.titleColor(for: .normal) .~ .ksr_grey_400
  }

  @IBAction func selectFrequencyButtonTapped(_ sender: Any) {

  }
}
