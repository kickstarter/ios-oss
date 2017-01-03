import KsApi
import Library
import Prelude
import UIKit

internal final class ThanksCategoryCell: UICollectionViewCell, ValueCell {

  @IBOutlet private weak var bgView: UIView!
  @IBOutlet private weak var exploreLabel: UILabel!
  @IBOutlet private weak var liveProjectCountLabel: UILabel!

  func configureWith(value category: KsApi.Category) {
    self.bgView |> UIView.lens.backgroundColor .~ discoveryPrimaryColor(forCategoryId: category.root?.id)

    self.exploreLabel
      |> UILabel.lens.textColor .~ .whiteColor()
      |> UILabel.lens.text %~ { _ in Strings.category_promo_explore_category(category_name: category.name) }
      |> UILabel.lens.font .~ .ksr_callout()

    self.liveProjectCountLabel
      |> UILabel.lens.textColor .~ self.exploreLabel.textColor
      |> UILabel.lens.font .~ .ksr_footnote()

    if let projectsCount = category.projectsCount {
      self.liveProjectCountLabel |> UILabel.lens.text %~ { _ in
        Strings.category_promo_project_count_live_projects(project_count: Format.wholeNumber(projectsCount))
      }
    } else {
      self.liveProjectCountLabel |> UILabel.lens.hidden .~ true
    }
  }
}
