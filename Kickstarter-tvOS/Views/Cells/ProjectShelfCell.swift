import UIKit
import KsApi
import Prelude
import ReactiveCocoa
import AlamofireImage
import Library
import Library

protocol ProjectShelfCellDelegate: class {
  func projectShelfTappedSave(cell: ProjectShelfCell)
  func projectShelfClickedMore(cell: ProjectShelfCell)
}

final class ProjectShelfCell: UICollectionViewCell, ValueCell {
  @IBOutlet private weak var projectNameLabel: UILabel!
  @IBOutlet private weak var categoryLabel: UILabel!
  @IBOutlet private weak var remindMeButton: UIButton!
  @IBOutlet private weak var moreButton: UIButton!
  @IBOutlet private weak var progressBarView: UIView!
  @IBOutlet private weak var percentageLabel: UILabel!
  @IBOutlet private weak var downArrowLabel: UILabel!

  let viewModel = SimpleViewModel<Project>()
  weak var delegate: ProjectShelfCellDelegate?

  override func awakeFromNib() {
    super.awakeFromNib()
    self.downArrowLabel.text = "\u{f3d0}"

    let project = self.viewModel.model

    self.projectNameLabel.rac.text = project.map { $0.name }
    self.categoryLabel.rac.text = project.map { $0.category.name }
    self.percentageLabel.rac.text = project.map { Format.percentage($0.stats.percentFunded) }

    project.map { p in CGFloat(p.stats.fundingProgress) }
      .map(clamp(0.0, 1.0))
      .observeForUI()
      .observeNext { [weak self] progress in
        guard let progressBarView = self?.progressBarView,
          progressContainerView = progressBarView.superview
          else { return }

        progressBarView.transform = CGAffineTransformMakeTranslation(
          (progress - 1.0) * progressContainerView.frame.width,
          0.0
        )
    }
  }

  func configureWith(value value: Project) {
    self.viewModel.model(value)
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
