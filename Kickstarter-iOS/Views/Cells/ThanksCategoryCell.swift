import KsApi
import Library
import Prelude
import UIKit

internal final class ThanksCategoryCell: UICollectionViewCell, ValueCell {

  @IBOutlet private weak var bgView: GradientView!
  @IBOutlet private weak var exploreLabel: UILabel!
  @IBOutlet private weak var liveProjectCountLabel: UILabel!

  func configureWith(value category: KsApi.Category) {
    let (startColor, endColor) = discoveryGradientColors(forCategoryId: category.root?.id)
    self.bgView.setGradient([(startColor, 0.0), (endColor, 1.0)])

    _ = self.exploreLabel
      |> UILabel.lens.textColor .~ .ksr_text_navy_700
      |> UILabel.lens.text %~ { _ in Strings.category_promo_explore_category(category_name: category.name) }
      |> UILabel.lens.font .~ .ksr_callout()

    _ = self.liveProjectCountLabel
      |> UILabel.lens.textColor .~ self.exploreLabel.textColor
      |> UILabel.lens.font .~ .ksr_footnote()

    if let projectsCount = category.projectsCount {
      _ = self.liveProjectCountLabel |> UILabel.lens.text %~ { _ in
        Strings.category_promo_project_count_live_projects(project_count: Format.wholeNumber(projectsCount))
      }
    } else {
      _ = self.liveProjectCountLabel |> UILabel.lens.hidden .~ true
    }
  }
}
