import Library
import Prelude
import UIKit

final class SettingsAccountWarningCell: UITableViewCell, ValueCell, NibLoading {
  @IBOutlet fileprivate weak var arrowIconImage: UIImageView!
  @IBOutlet fileprivate weak var seperatorView: UIView!
  @IBOutlet fileprivate weak var titleLabel: UILabel!
  @IBOutlet fileprivate weak var warningIconImage: UIImageView!

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

    _ = self.seperatorView
      |> settingsSeparatorStyle

    _ = self.warningIconImage
      |> \.tintColor .~ .ksr_apricot_600

    _ = self.arrowIconImage
      |> settingsArrowViewStyle
  }
}
