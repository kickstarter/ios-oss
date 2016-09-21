import Library
import Prelude
import UIKit

internal final class DiscoveryFiltersStaticRowCell: UITableViewCell, ValueCell {
  @IBOutlet private weak var titleLabel: UILabel!

  func configureWith(value value: (title: String, categoryId: Int?)) {
    self.titleLabel.text = value.title

    self.titleLabel
      |> UILabel.lens.textColor .~ discoverySecondaryColor(forCategoryId: value.categoryId)
  }

  override func bindStyles() {
    super.bindStyles()

    self
      |> baseTableViewCellStyle()
      |> UITableViewCell.lens.contentView.layoutMargins %~~ { _, cell in
        cell.traitCollection.isRegularRegular
          ? .init(top: Styles.grid(4),
                       left: Styles.grid(4),
                       bottom: Styles.grid(1),
                       right: Styles.grid(2))
          : .init(top: Styles.grid(3),
                     left: Styles.grid(2),
                     bottom: 0.0,
                     right: Styles.grid(2))
    }

    self.titleLabel
      |> UILabel.lens.font %~~ { _, label in
        label.traitCollection.isRegularRegular ? UIFont.ksr_headline() : UIFont.ksr_headline(size: 14)
    }
  }
}
