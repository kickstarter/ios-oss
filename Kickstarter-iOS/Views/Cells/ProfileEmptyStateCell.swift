import KsApi
import Library
import Prelude
import UIKit

internal final class ProfileEmptyStateCell: UITableViewCell, ValueCell {

  @IBOutlet private weak var iconImageView: UIImageView!
  @IBOutlet private weak var messageLabel: UILabel!

  internal func configureWith(value: (message: String, showIcon: Bool)) {
    self.messageLabel.text = value.message

    _ = self.iconImageView
      |> UIImageView.lens.tintColor .~ (value.showIcon ? .ksr_text_navy_600 : .clear)
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()
      |> UITableViewCell.lens.contentView.layoutMargins %~~ { _, cell in
        cell.traitCollection.isRegularRegular
          ? .init(topBottom: Styles.grid(4), leftRight: Styles.grid(20))
          : .init(topBottom: Styles.grid(10), leftRight: Styles.grid(3))
    }

    _ = self.messageLabel
      |> UILabel.lens.textColor .~ .ksr_text_navy_600
      |> UILabel.lens.font .~ UIFont.ksr_callout(size: 15.0)
  }
}
