import Library
import Prelude
import UIKit

internal final class DiscoveryExpandedSelectableRowCell: UITableViewCell, ValueCell {
  @IBOutlet private weak var filterTitleLabel: UILabel!
  @IBOutlet private weak var highlightView: UIView!
  @IBOutlet private weak var circleImageView: UIImageView!
  @IBOutlet private weak var checkImageView: UIImageView!

  internal func configureWith(value value: (row: SelectableRow, categoryId: Int?)) {
    if let category = value.row.params.category where category.isRoot {
      self.filterTitleLabel.text = RootCategory(categoryId: category.id).allProjectsString()
    } else {
      self.filterTitleLabel.text = value.row.params.category?.name
    }

    self.highlightView
      |> UIView.lens.backgroundColor .~ discoverySecondaryColor(forCategoryId: value.categoryId)
      |> UIView.lens.alpha .~ 0.08
      |> UIView.lens.hidden .~ !value.row.isSelected

    self.circleImageView
      |> UIView.lens.tintColor .~ discoverySecondaryColor(forCategoryId: value.categoryId)
      |> UIView.lens.hidden .~ !value.row.isSelected

    self.checkImageView
      |> UIView.lens.hidden .~ !value.row.isSelected

    self.filterTitleLabel
      |> UILabel.lens.textColor .~ discoverySecondaryColor(forCategoryId: value.categoryId)
      |> UILabel.lens.font .~ value.row.isSelected ? UIFont.ksr_subhead().bolded : .ksr_subhead()

    self
      |> UITableViewCell.lens.contentView.layoutMargins .~ .init(top: Styles.grid(2),
                                                                 left: Styles.grid(4),
                                                                 bottom: Styles.grid(2),
                                                                 right: Styles.grid(2))
  }

  internal func animateIn(delayOffset delayOffset: Int) {
    self.contentView.frame.origin.y -= 50
    let delay = 0.0 + (0.01 * Double(delayOffset))

    UIView.animateWithDuration(0.2,
                               delay: delay,
                               usingSpringWithDamping: 0.7,
                               initialSpringVelocity: 1.0,
                               options: .CurveEaseOut,
                               animations: {
                                self.contentView.frame.origin.y += 50
                                },
                               completion: nil)
  }
}
