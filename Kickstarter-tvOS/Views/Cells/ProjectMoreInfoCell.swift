import UIKit
import ReactiveCocoa
import Models
import Library

class ProjectMoreInfoCell: UICollectionViewCell, ViewModeledCellType {
  @IBOutlet weak var creatorLabel: UILabel!
  @IBOutlet weak var projectNameLabel: UILabel!
  @IBOutlet weak var blurbLabel: UILabel!
  @IBOutlet weak var progressBarView: UIView!
  @IBOutlet weak var pledgedLabel: UILabel!
  @IBOutlet weak var goalLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var toGoLabel: UILabel!
  @IBOutlet weak var backersCountLabel: UILabel!

  let viewModelProperty = MutableProperty<SimpleViewModel<Project>?>(nil)

  override func awakeFromNib() {
    super.awakeFromNib()
  }

  override func bindViewModel() {
    let project = self.viewModel.map { $0.model }

    project.map { $0.creator.name }
      .skipRepeats()
      .map(Strings.by_creator)
      .startWithNext { [weak self] value in
        self?.creatorLabel.setHTML(value)
    }
    self.projectNameLabel.rac_text <~ project.map { $0.name }
    self.blurbLabel.rac_text <~ project.map { $0.blurb }

    self.backersCountLabel.rac_text <~ project.map { Format.wholeNumber($0.stats.backersCount) }
    self.pledgedLabel.rac_text <~ project.map { Format.currency($0.stats.pledged, country: $0.country) }
    self.goalLabel.rac_text <~ project.map { Format.currency($0.stats.goal, country: $0.country) }
  }
}
