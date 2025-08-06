import Library
import Prelude
import UIKit

internal final class DiscoveryFiltersStaticRowCell: UITableViewCell, ValueCell {
  @IBOutlet fileprivate var titleLabel: UILabel!

  func configureWith(value: (title: String, categoryId: Int?)) {
    self.titleLabel.text = value.title

    _ = self.titleLabel
      |> UILabel.lens.textColor .~ LegacyColors.ksr_create_700.uiColor()
  }
}
