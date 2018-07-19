import Library
import Prelude
import UIKit

internal final class SettingsPrivacyStaticCell: UITableViewCell, ValueCell {
  @IBOutlet fileprivate weak var privacyInfoLabel: UILabel!

  func configureWith(value: String) {
    self.privacyInfoLabel.text = value

    _ = self.privacyInfoLabel
      |> UILabel.lens.textColor .~ .ksr_text_dark_grey_500
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()
      |> UITableViewCell.lens.contentView.layoutMargins %~~ { _, cell in
        cell.traitCollection.isRegularRegular
          ? .init(top: Styles.grid(4),
                  left: Styles.grid(4),
                  bottom: Styles.grid(1),
                  right: Styles.grid(2))
          : .init(top: Styles.grid(3),
                  left: Styles.grid(2),
                  bottom: 0.0,
                  right: Styles.grid(2))
    }

    _ = self.privacyInfoLabel
      |> UILabel.lens.font .~ .ksr_body(size: 13)
  }
  }
