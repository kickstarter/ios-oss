import Library
import Prelude
import UIKit

internal final class NoSearchResultsCell: UITableViewCell, ValueCell {
  @IBOutlet fileprivate weak var noResultsLabel: UILabel!
  @IBOutlet fileprivate weak var noQueryLabel: UILabel!
  @IBOutlet fileprivate weak var rootStackView: UIStackView!


  internal func configureWith(value: Void) {
    
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()
      |> NoSearchResultsCell.lens.backgroundColor .~ .clear
      |> NoSearchResultsCell.lens.contentView.layoutMargins %~~ { _, cell in
        cell.traitCollection.isRegularRegular
          ? .init(top: Styles.grid(4), left: Styles.grid(24), bottom: Styles.grid(2), right: Styles.grid(24))
          : .init(topBottom: Styles.grid(2), leftRight: Styles.grid(2))
    }

    _ = self.noResultsLabel
      |> UILabel.lens.font .~ .ksr_body(size: 15)
      |> UILabel.lens.textColor .~ .ksr_text_navy_600

    _ = self.noQueryLabel
      |> UILabel.lens.font .~ .ksr_body(size: 15)
      |> UILabel.lens.textColor .~ .ksr_text_navy_600
      |> UILabel.lens.numberOfLines .~ 0

    _ = self.rootStackView
      |> UIStackView.lens.layoutMargins .~ .init(topBottom: Styles.grid(4), leftRight: Styles.grid(4))
  }

}
