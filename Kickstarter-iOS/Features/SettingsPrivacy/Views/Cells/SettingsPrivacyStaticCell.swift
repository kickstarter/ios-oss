import Library
import Prelude
import UIKit

internal final class SettingsPrivacyStaticCell: UITableViewCell, ValueCell {
  @IBOutlet fileprivate var privacyInfoLabel: UILabel!

  override func awakeFromNib() {
    super.awakeFromNib()

    _ = self
      |> \.accessibilityElementsHidden .~ true
  }

  func configureWith(value: String) {
    _ = self.privacyInfoLabel
      |> UILabel.lens.text %~ { _ in value }

    _ = self.privacyInfoLabel
      |> UILabel.lens.textColor .~ LegacyColors.ksr_support_400.uiColor()
      |> UILabel.lens.numberOfLines .~ 0
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()
      |> UITableViewCell.lens.backgroundColor .~ LegacyColors.ksr_support_100.uiColor()

    _ = self.privacyInfoLabel
      |> UILabel.lens.font .~ .ksr_body(size: 13)
  }
}
