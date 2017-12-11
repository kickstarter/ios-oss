import KsApi
import Library
import Prelude
import UIKit

internal final class ThanksCategoryCell: UITableViewCell, ValueCell {

  @IBOutlet fileprivate weak var cardView: UIView!
  @IBOutlet fileprivate weak var seeAllProjectsLabel: UILabel!

  func configureWith(value category: KsApi.Category) {
    
    _ = self.seeAllProjectsLabel
      |> UILabel.lens.textAlignment .~ .center
      |> UILabel.lens.textColor .~ .ksr_text_dark_grey_500
      |> UILabel.lens.text %~ { _ in Strings.category_promo_explore_category(category_name: category.name) }
      |> UILabel.lens.font .~ .ksr_callout()

    _ = self.cardView
      |> cardStyle()
  }
}
