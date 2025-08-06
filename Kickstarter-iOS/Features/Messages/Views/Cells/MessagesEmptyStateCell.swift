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
  }
}
