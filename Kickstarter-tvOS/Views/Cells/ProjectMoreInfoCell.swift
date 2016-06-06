import UIKit
import ReactiveCocoa
import KsApi
import Library

class ProjectMoreInfoCell: UICollectionViewCell, ValueCell {
  @IBOutlet weak var creatorLabel: UILabel!
  @IBOutlet weak var projectNameLabel: UILabel!
  @IBOutlet weak var blurbLabel: UILabel!
  @IBOutlet weak var progressBarView: UIView!
  @IBOutlet weak var pledgedLabel: UILabel!
  @IBOutlet weak var goalLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var toGoLabel: UILabel!
  @IBOutlet weak var backersCountLabel: UILabel!

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
      .map(Strings.by_creator)
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
