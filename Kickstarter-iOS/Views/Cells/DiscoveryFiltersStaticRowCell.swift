import Library
import Prelude
import UIKit

internal final class DiscoveryFiltersStaticRowCell: UITableViewCell, ValueCell {
  @IBOutlet private weak var titleLabel: UILabel!

  func configureWith(value value: (title: String, categoryId: Int?)) {
    self.titleLabel.text = value.title

    self.titleLabel
      |> UILabel.lens.textColor .~ discoverySecondaryColor(forCategoryId: value.categoryId)
      |> UILabel.lens.font .~ UIFont.ksr_headline(size: 14)

    self
      |> UITableViewCell.lens.contentView.layoutMargins .~ .init(top: Styles.grid(3),
                                                                 left: Styles.grid(2),
                                                                 bottom: 0.0,
                                                                 right: Styles.grid(2))
    }
}
