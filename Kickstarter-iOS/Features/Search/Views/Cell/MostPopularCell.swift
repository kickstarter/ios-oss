import Library
import Prelude
import UIKit

internal final class MostPopularCell: UITableViewCell, ValueCell {
  @IBOutlet fileprivate var mostPopularLabel: UILabel!

  internal func configureWith(value _: Void) {}

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()
      |> MostPopularCell.lens.backgroundColor .~ .clear
      |> MostPopularCell.lens.contentView.layoutMargins %~~ { _, cell in
        cell.traitCollection.isRegularRegular
          ? .init(top: Styles.grid(4), left: Styles.grid(24), bottom: Styles.grid(2), right: Styles.grid(24))
          : .init(topBottom: Styles.grid(2), leftRight: Styles.grid(2))
      }

    _ = self.mostPopularLabel
      |> UILabel.lens.backgroundColor .~ .ksr_white
      |> UILabel.lens.font .~ .ksr_title1(size: 22)
      |> UILabel.lens.textColor .~ .ksr_support_700
      |> UILabel.lens.text %~ { _ in
        // TODO: When this flag is removed, you can rename/refactor this cell class.
        featureSearchFiltersEnabled() ? Strings.activity_empty_state_logged_in_button() : Strings
          .Popular_Projects()
      }
  }
}
