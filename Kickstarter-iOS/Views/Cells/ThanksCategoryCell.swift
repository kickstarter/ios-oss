import KsApi
import Library
import Prelude
import UIKit

internal final class ThanksCategoryCell: UITableViewCell, ValueCell {
  @IBOutlet fileprivate var seeAllProjectsButton: UIButton!

  func configureWith(value category: KsApi.Category) {
    _ = self.seeAllProjectsButton
      |> greyButtonStyle
      |> UIButton.lens.title(for: .normal) %~ {
        _ in Strings.See_all_category_name_projects(category_name: category.name)
    }
  }
}
