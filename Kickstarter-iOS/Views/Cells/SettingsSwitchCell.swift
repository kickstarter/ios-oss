import Foundation
import Library
import Prelude

final class SettingsSwitchCell: UITableViewCell, ValueCell {
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var switchButton: UISwitch!

  func configureWith(value: SettingsSwitchCellType) {
    _ = self.titleLabel
    |> UILabel.lens.text .~ value.titleString
  }

  override func bindStyles() {
    _ = self.titleLabel
    |> settingsTitleLabelStyle
  }

  @IBAction func switchToggled(_ sender: UISwitch) {

  }
}
