import Library
import Prelude
import UIKit

final internal class SettingsNewslettersHeaderView: UITableViewHeaderFooterView {

  @IBOutlet fileprivate weak var descriptionLabel: UILabel!
  @IBOutlet fileprivate weak var newsletterSwitch: UISwitch!
  @IBOutlet fileprivate weak var titleLabel: UILabel!

  override func awakeFromNib() {
    super.awakeFromNib()
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self.descriptionLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.font .~ .ksr_body(size: 13)
      |> UILabel.lens.numberOfLines .~ 0

    _ = self.newsletterSwitch
      |> UISwitch.lens.onTintColor .~ .ksr_green_800

    _ = self.titleLabel
      |> settingsSectionLabelStyle
  }
}
