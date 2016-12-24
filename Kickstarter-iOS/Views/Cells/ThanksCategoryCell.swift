import KsApi
import Library
import Prelude
import UIKit

internal final class ThanksCategoryCell: UICollectionViewCell, ValueCell {

  @IBOutlet fileprivate weak var bgView: UIView!
  @IBOutlet fileprivate weak var exploreLabel: UILabel!
  @IBOutlet fileprivate weak var liveProjectCountLabel: UILabel!

  func configureWith(value category: KsApi.Category) {
    _ = self.bgView
      |> UIView.lens.backgroundColor .~ (UIColorFromCategoryId(category.id) ?? .ksr_text_navy_900)

    _ = self.exploreLabel
      |> UILabel.lens.textColor .~ (shouldOverlayBeDark(category) ? .ksr_text_navy_900 : .white)
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

private func shouldOverlayBeDark(_ category: KsApi.Category) -> Bool {
  switch category.root?.id ?? 0 {
  case 1, 3, 14, 15, 18:
    return true
  default:
    return false
  }

}
