import Library
import Prelude
import UIKit

internal final class SettingsPrivacyStaticCell: UITableViewCell, ValueCell {
  @IBOutlet fileprivate weak var privacyInfoLabel: UILabel!

  func configureWith(value: String) {
    _ = self.privacyInfoLabel
      |> UILabel.lens.text %~ { _ in value }

    _ = self.privacyInfoLabel
      |> UILabel.lens.textColor .~ .ksr_text_dark_grey_500
      |> UILabel.lens.numberOfLines .~ 0
  }

  override func bindStyles() {
    super.bindStyles()

      _ = self
        |> baseTableViewCellStyle()
        |> UITableViewCell.lens.backgroundColor .~ .ksr_grey_100

      _ = self.privacyInfoLabel
        |> UILabel.lens.font .~ .ksr_body(size: 13)
    }
  }
