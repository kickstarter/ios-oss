import KsApi
import Library
import Prelude
import Prelude_UIKit
import ReactiveSwift
import UIKit

internal final class SettingsPrivacyDeleteAccountCell: UITableViewCell, ValueCell {
  @IBOutlet fileprivate weak var deleteAccountLabel: UILabel!

  internal func configureWith(value user: User) {

  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()

    _ = self.deleteAccountLabel
      |> UILabel.lens.textColor .~ .ksr_red_400
      |> UILabel.lens.font .~ .ksr_body()
      |> UILabel.lens.numberOfLines .~ 2
      |> UILabel.lens.text %~ { _ in Strings.Delete_my_Kickstarter_Account() }
  }

  internal override func bindViewModel() {
    super.bindViewModel()
  }
}
