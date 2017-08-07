import KsApi
import Library
import Prelude
import UIKit

internal final class MessagesEmptyStateCell: UITableViewCell, ValueCell {

  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var subTitleLabel: UILabel!

  internal func configureWith(value: String) {
    _ = self.subTitleLabel
      |> UILabel.lens.textColor .~ .ksr_text_dark_grey_400
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
      |> UILabel.lens.textColor .~ .ksr_text_dark_grey_900
      |> UILabel.lens.font .~ UIFont.ksr_headline(size: 18.0)
      |> UILabel.lens.text %~ { _ in Strings.messages_empty_state_title() }
  }
}
