import KsApi
import Library
import Prelude
import UIKit

internal final class CommentCell: UITableViewCell, ValueCell {
  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()
      |> UITableViewCell.lens.backgroundColor .~ .ksr_white
      |> UITableViewCell.lens.contentView.layoutMargins .~
      .init(topBottom: Styles.grid(3), leftRight: Styles.grid(2))
  }

  internal func configureWith(value: Comment) {
    self.textLabel?.text = value.body
  }
}
