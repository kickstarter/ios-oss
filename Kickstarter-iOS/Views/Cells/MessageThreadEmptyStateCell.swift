import KsApi
import Library
import Prelude
import UIKit

internal final class MessageThreadEmptyStateCell: UITableViewCell, ValueCell {

  @IBOutlet private weak var titleLabel: UILabel!

  internal override func bindStyles() {
    super.bindStyles()

    self.titleLabel
      |> UILabel.lens.textColor .~ .ksr_text_navy_700
      |> UILabel.lens.font .~ UIFont.ksr_headline(size: 18.0)
      |> UILabel.lens.text %~ { _ in Strings.messages_empty_state_title() }
  }

  internal func configureWith(value value: Void) {}
}
