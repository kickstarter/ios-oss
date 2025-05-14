import Library
import Prelude
import UIKit

internal final class DiscoverProjectsTitleCell: UITableViewCell, ValueCell {
  @IBOutlet fileprivate var titleLabel: UILabel!

  internal func configureWith(value _: Void) {}

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()
      |> DiscoverProjectsTitleCell.lens.backgroundColor .~ .clear
      |> DiscoverProjectsTitleCell.lens.contentView.layoutMargins %~~ { _, cell in
        cell.traitCollection.isRegularRegular
          ? .init(top: Styles.grid(4), left: Styles.grid(24), bottom: Styles.grid(2), right: Styles.grid(24))
          : .init(topBottom: Styles.grid(2), leftRight: Styles.grid(2))
      }

    _ = self.titleLabel
      |> UILabel.lens.backgroundColor .~ LegacyColors.ksr_white.uiColor()
      |> UILabel.lens.font .~ .ksr_title1(size: 22)
      |> UILabel.lens.textColor .~ LegacyColors.ksr_support_700.uiColor()
      |> UILabel.lens.text %~ { _ in
        Strings.activity_empty_state_logged_in_button()
      }
  }
}
