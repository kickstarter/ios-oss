import KsApi
import Library
import Prelude
import UIKit

internal final class CommentCell: UITableViewCell, ValueCell {

  internal override func bindStyles() {
    super.bindStyles()

    let cellBackgroundColor = UIColor.ksr_white

    _ = self
      |> baseTableViewCellStyle()
      |> UITableViewCell.lens.backgroundColor .~ cellBackgroundColor
      |> UITableViewCell.lens.contentView.layoutMargins .~
      .init(topBottom: Styles.grid(3), leftRight: Styles.grid(2))
  }

  internal func configureWith(value: Comment) {
    self.textLabel?.text = value.id + " " + value.body
  }
}

