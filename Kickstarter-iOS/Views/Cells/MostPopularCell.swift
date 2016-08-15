import Library
import Prelude
import UIKit

internal final class MostPopularCell: UITableViewCell, ValueCell {
  @IBOutlet private weak var mostPopularLabel: UILabel!

  internal func configureWith(value value: Void) {
  }

  internal override func bindStyles() {
    super.bindStyles()

    self
      |> baseTableViewCellStyle()
      |> (MostPopularCell.lens.contentView.layoutMargins • UIEdgeInsets.lens.topBottom)
        .~ (Styles.grid(4), Styles.grid(4))

    self.mostPopularLabel
      |> UILabel.lens.font .~ .ksr_title1(size: 22)
      |> UILabel.lens.textColor .~ .ksr_text_navy_700
      |> UILabel.lens.text %~ { _ in Strings.search_most_popular() }
  }
}
