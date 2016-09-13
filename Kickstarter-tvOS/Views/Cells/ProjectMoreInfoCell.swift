import UIKit
import ReactiveCocoa
import KsApi
import Library

class ProjectMoreInfoCell: UICollectionViewCell, ValueCell {
  @IBOutlet private weak var creatorLabel: UILabel!
  @IBOutlet private weak var projectNameLabel: UILabel!
  @IBOutlet private weak var blurbLabel: UILabel!
  @IBOutlet private weak var progressBarView: UIView!
  @IBOutlet private weak var pledgedLabel: UILabel!
  @IBOutlet private weak var goalLabel: UILabel!
  @IBOutlet private weak var timeLabel: UILabel!
  @IBOutlet private weak var toGoLabel: UILabel!
  @IBOutlet private weak var backersCountLabel: UILabel!

  let viewModel = SimpleViewModel<Project>()

  override func awakeFromNib() {
    super.awakeFromNib()
  }

  func configureWith(value value: Project) {
    self.viewModel.model(value)
  }

  override func bindViewModel() {
    let project = self.viewModel.model

    project.map { $0.creator.name }
      .skipRepeats()
      .mapConst("")
      .observeNext { [weak self] value in
        self?.creatorLabel.setHTML(value)
    }
    self.projectNameLabel.rac.text = project.map { $0.name }
    self.blurbLabel.rac.text = project.map { $0.blurb }

    self.backersCountLabel.rac.text = project.map { Format.wholeNumber($0.stats.backersCount) }
    self.pledgedLabel.rac.text = project.map { Format.currency($0.stats.pledged, country: $0.country) }
    self.goalLabel.rac.text = project.map { Format.currency($0.stats.goal, country: $0.country) }
  }
}
