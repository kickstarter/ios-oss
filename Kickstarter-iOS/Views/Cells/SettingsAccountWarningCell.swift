import Library
import Prelude
import UIKit

final class SettingsAccountWarningCell: UITableViewCell, ValueCell, NibLoading {
  @IBOutlet fileprivate var arrowIconImage: UIImageView!
  @IBOutlet fileprivate var titleLabel: UILabel!
  @IBOutlet fileprivate var warningIconImage: UIImageView!

  func configureWith(value shouldHideAlertIcon: Bool) {
    _ = self
      |> \.accessibilityTraits .~ .button

    _ = self.warningIconImage
      |> \.isHidden .~ shouldHideAlertIcon

    if !shouldHideAlertIcon {
      _ = self
        |> \.accessibilityHint %~ { _ in
          Strings.Email_unverified()
        }
    }
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self.titleLabel
      |> settingsTitleLabelStyle
      |> \.text %~ { _ in
        SettingsAccountCellType.changeEmail.title
      }

    _ = self.warningIconImage
      |> \.tintColor .~ .ksr_alert

    _ = self.arrowIconImage
      |> settingsArrowViewStyle
  }
}
