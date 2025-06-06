import KsApi
import Library
import Prelude
import UIKit

internal final class MessagesEmptyStateCell: UITableViewCell, ValueCell {
  @IBOutlet private var titleLabel: UILabel!
  @IBOutlet private var subTitleLabel: UILabel!

  internal func configureWith(value: String) {
    _ = self.subTitleLabel
      |> UILabel.lens.textColor .~ LegacyColors.ksr_support_400.uiColor()
      |> UILabel.lens.font .~ UIFont.ksr_subhead(size: 16.0)
      |> UILabel.lens.text .~ value
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()
      |> UITableViewCell.lens.contentView.layoutMargins %~~ { _, cell in
        cell.traitCollection.isRegularRegular
          ? .init(topBottom: Styles.grid(5), leftRight: Styles.grid(12))
          : .init(topBottom: Styles.grid(4), leftRight: Styles.grid(2))
      }

    _ = self.titleLabel
      |> UILabel.lens.textColor .~ LegacyColors.ksr_support_700.uiColor()
      |> UILabel.lens.font .~ UIFont.ksr_headline(size: 18.0)
      |> UILabel.lens.text %~ { _ in Strings.messages_empty_state_title() }
  }
}
