import KsApi
import Library
import Prelude
import Prelude_UIKit
import ReactiveSwift
import UIKit

internal final class SettingsPrivacyRequestDataCell: UITableViewCell, ValueCell {
  @IBOutlet fileprivate weak var requestDataLabel: UILabel!

  internal func configureWith(value user: User) {

  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()

    _ = self.requestDataLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.Request_my_Personal_Data() }
  }

  internal override func bindViewModel() {
    super.bindViewModel()
  }
}
