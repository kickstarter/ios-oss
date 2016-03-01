import Models
import ReactiveCocoa
import protocol Library.ViewModeledCellType
import class Library.SimpleViewModel
import enum Library.Format

class ProjectRewardCell: UICollectionViewCell, ViewModeledCellType {
  @IBOutlet weak var minimumLabel: UILabel!
  @IBOutlet weak var backersCountLabel: UILabel!
  @IBOutlet weak var rewardLabel: UILabel!

  typealias ViewModel = SimpleViewModel<Reward>
  let viewModel = MutableProperty<SimpleViewModel<Reward>?>(nil)

  override func awakeFromNib() {
    super.awakeFromNib()
    configureForFocus(false)
  }

  override func bindViewModel() {
    let reward = self.viewModel.producer.ignoreNil().map { $0.model }

    minimumLabel.rac_text <~ reward.map { Format.currency($0.minimum, country: Project.Country.US) }
      .map { "\($0) or more" }
    backersCountLabel.rac_hidden <~ reward.map { $0.backersCount == nil }

    backersCountLabel.rac_text <~ reward
      .map { $0.backersCount }
      .ignoreNil()
      .map { "\($0) backers" }

    rewardLabel.rac_text <~ reward.map { $0.description ?? "No reward" }
  }

  override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
    super.didUpdateFocusInContext(context, withAnimationCoordinator: coordinator)

    coordinator.addCoordinatedAnimations({
      self.configureForFocus(self.focused)
    }, completion: nil)
  }

  func configureForFocus(focused: Bool) {
    self.backgroundColor = focused ? UIColor.whiteColor() : UIColor.grayColor()
  }
}
