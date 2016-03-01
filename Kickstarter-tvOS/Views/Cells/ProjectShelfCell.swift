import UIKit
import Models
import Prelude
import ReactiveCocoa
import AlamofireImage

protocol ProjectShelfCellDelegate: class {
  func projectShelfTappedSave(cell: ProjectShelfCell)
  func projectShelfClickedMore(cell: ProjectShelfCell)
}

final class ProjectShelfCell: UICollectionViewCell, ViewModeledCellType {
  @IBOutlet private weak var projectNameLabel: UILabel!
  @IBOutlet private weak var categoryLabel: UILabel!
  @IBOutlet private weak var remindMeButton: UIButton!
  @IBOutlet weak var moreButton: UIButton!
  @IBOutlet weak var progressBarView: UIView!
  @IBOutlet weak var percentageLabel: UILabel!
  @IBOutlet weak var downArrowLabel: UILabel!

  let viewModel = MutableProperty<SimpleViewModel<Project>?>(nil)
  weak var delegate: ProjectShelfCellDelegate?

  override func awakeFromNib() {
    super.awakeFromNib()
    self.downArrowLabel.text = "\u{f3d0}"
  }

  override func bindViewModel() {
    let project = self.viewModel.producer.ignoreNil().map { $0.model }.observeForUI()

    self.projectNameLabel.rac_text <~ project.map { $0.name }
    self.categoryLabel.rac_text <~ project.map { $0.category.name }
    self.percentageLabel.rac_text <~ project.map { Format.percentage($0.percentFunded) }

    project.map { p in CGFloat(p.fundingProgress) }
      .map(clamp(0.0, 1.0))
      .observeForUI()
      .startWithNext { [weak self] progress in
        guard let progressBarView = self?.progressBarView,
          progressContainerView = progressBarView.superview
        else { return }

        progressBarView.transform = CGAffineTransformMakeTranslation(
          (progress - 1.0) * progressContainerView.frame.width,
          0.0
        )
    }
  }

  override var preferredFocusedView: UIView? {
    return self.remindMeButton
  }

  @IBAction func saveButtonPressed(sender: UIButton) {
    delegate?.projectShelfTappedSave(self)
  }

  @IBAction func moreButtonPressed(sender: UIButton) {
    delegate?.projectShelfClickedMore(self)
  }
}
