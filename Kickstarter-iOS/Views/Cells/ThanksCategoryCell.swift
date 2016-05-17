import UIKit
import Library
import ReactiveCocoa
import Models

internal final class ThanksCategoryCell: UICollectionViewCell, ValueCell {

  @IBOutlet private weak var bgView: UIView!
  @IBOutlet private weak var exploreLabel: StyledLabel!
  @IBOutlet private weak var liveProjectCountLabel: StyledLabel!

  func configureWith(value category: Models.Category) {
    self.bgView.backgroundColor = UIColorFromCategoryId(category.id) ?? Color.TextDefault.toUIColor()
    self.exploreLabel.color = shouldOverlayBeDark(category) ? Color.Black : Color.White
    self.exploreLabel.text = localizedString(key: "category_promo.explore_category",
                                             defaultValue: "Explore %{category_name}",
                                             count: nil,
                                             substitutions: ["category_name": category.name])

    self.liveProjectCountLabel.color = self.exploreLabel.color
    if let projectsCount = category.projectsCount {
      self.liveProjectCountLabel.text = localizedString(
        key: "category_promo.project_count_live_projects",
        defaultValue: "%{project_count} live projects",
        count: nil,
        substitutions: ["project_count": Format.wholeNumber(projectsCount)])
    } else {
      self.liveProjectCountLabel.hidden = true
    }
  }
}

private func shouldOverlayBeDark(category: Models.Category) -> Bool {
  switch category.root?.id ?? 0 {
  case 1, 3, 14, 15, 18:
    return true
  default:
    return false
  }

}
