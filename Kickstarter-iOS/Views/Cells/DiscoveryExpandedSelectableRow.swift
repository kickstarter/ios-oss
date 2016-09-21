import Library
import Prelude
import UIKit

internal final class DiscoveryExpandedSelectableRowCell: UITableViewCell, ValueCell {
  @IBOutlet private weak var filterTitleLabel: UILabel!
  @IBOutlet private weak var highlightView: UIView!
  @IBOutlet private weak var circleImageView: UIImageView!
  @IBOutlet private weak var checkImageView: UIImageView!

  private var isSelected: Bool = false

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
      |> UILabel.lens.numberOfLines .~ 2

    self.isSelected = value.row.isSelected
  }

  override func bindStyles() {
    super.bindStyles()

    self
      |> baseTableViewCellStyle()
      |> UITableViewCell.lens.contentView.layoutMargins %~~ { _, cell in
        cell.traitCollection.isRegularRegular
          ? .init(top: Styles.grid(2),
                       left: Styles.grid(6),
                       bottom: Styles.grid(2),
                       right: Styles.grid(2))
          : .init(top: Styles.grid(2),
                     left: Styles.grid(4),
                     bottom: Styles.grid(2),
                     right: Styles.grid(2))
    }
  }

  internal func willDisplay() {
    self.filterTitleLabel
      |> UILabel.lens.font %~~ { _, label in
        label.traitCollection.isRegularRegular
          ? self.isSelected ? UIFont.ksr_subhead(size: 18).bolded : .ksr_subhead(size: 18)
          : self.isSelected ? UIFont.ksr_subhead().bolded : .ksr_subhead() }
  }

  internal func animateIn(delayOffset delayOffset: Int) {
    self.contentView.transform = CGAffineTransformMakeTranslation(0.0, 50.0)
    self.alpha = 0
    let delay = 0.03 * Double(delayOffset)

    UIView.animateWithDuration(0.3, delay: delay, options: .CurveEaseOut, animations: {
        self.alpha = 1
      },
      completion: nil)

    UIView.animateWithDuration(0.3,
                               delay: delay,
                               usingSpringWithDamping: 0.7,
                               initialSpringVelocity: 1.0,
                               options: .CurveEaseOut,
                               animations: {
                                self.contentView.transform = CGAffineTransformIdentity
                                },
                               completion: nil)
  }
}
