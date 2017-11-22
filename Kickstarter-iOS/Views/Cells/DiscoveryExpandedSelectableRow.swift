import Library
import Prelude
import UIKit

internal final class DiscoveryExpandedSelectableRowCell: UITableViewCell, ValueCell {
  @IBOutlet private weak var filterTitleLabel: UILabel!
  @IBOutlet private weak var highlightView: UIView!
  @IBOutlet private weak var circleImageView: UIImageView!
  @IBOutlet private weak var checkImageView: UIImageView!

  private var rowIsSelected: Bool = false

  internal func configureWith(value: (row: SelectableRow, categoryId: Int?)) {
    if let category = value.row.params.category, category.isRoot {
      self.filterTitleLabel.text = RootCategory(categoryId: category.intID ?? -1).allProjectsString()
    } else {
      self.filterTitleLabel.text = value.row.params.category?.name
    }

    _ = self.highlightView
      |> UIView.lens.backgroundColor .~ .ksr_green_500
      |> UIView.lens.alpha .~ 0.08
      |> UIView.lens.hidden .~ !value.row.isSelected

    _ = self.circleImageView
      |> UIView.lens.tintColor .~ .ksr_green_500
      |> UIView.lens.hidden .~ !value.row.isSelected

    _ = self.checkImageView
      |> UIView.lens.hidden .~ !value.row.isSelected

    _ = self.filterTitleLabel
      |> UILabel.lens.textColor .~ .ksr_green_500
      |> UILabel.lens.numberOfLines .~ 2

    self.rowIsSelected = value.row.isSelected
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self
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
     |> UITableViewCell.lens.accessibilityTraits .~ UIAccessibilityTraitButton
  }

  internal func willDisplay() {
    _ = self.filterTitleLabel
      |> UILabel.lens.font %~~ { _, label in
        label.traitCollection.isRegularRegular
          ? self.rowIsSelected ? UIFont.ksr_subhead(size: 18).bolded : .ksr_subhead(size: 18)
          : self.rowIsSelected ? UIFont.ksr_subhead().bolded : .ksr_subhead() }
  }

  internal func animateIn(delayOffset: Int) {
    self.contentView.transform = CGAffineTransform(translationX: 0.0, y: 50.0)
    self.alpha = 0
    let delay = 0.03 * Double(delayOffset)

    UIView.animate(withDuration: 0.3, delay: delay, options: .curveEaseOut, animations: {
        self.alpha = 1
      },
      completion: nil)

    UIView.animate(withDuration: 0.3,
                               delay: delay,
                               usingSpringWithDamping: 0.7,
                               initialSpringVelocity: 1.0,
                               options: .curveEaseOut,
                               animations: {
                                self.contentView.transform = CGAffineTransform.identity
                                },
                               completion: nil)
  }
}
