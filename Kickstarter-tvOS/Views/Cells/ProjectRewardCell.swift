import Models
import ReactiveCocoa
import Library

class ProjectRewardCell: UICollectionViewCell, ValueCell {
  @IBOutlet weak var minimumLabel: UILabel!
  @IBOutlet weak var backersCountLabel: UILabel!
  @IBOutlet weak var rewardLabel: UILabel!

  let viewModel = SimpleViewModel<Reward>()

  func configureWith(value value: Reward) {
    self.viewModel.model(value)
  }

  override func awakeFromNib() {
    super.awakeFromNib()

    configureForFocus(false)

    let reward = self.viewModel.model

    minimumLabel.rac.text = reward
      .map { Format.currency($0.minimum, country: Project.Country.US) }
      .map { "\($0) or more" }
    backersCountLabel.rac.hidden = reward.map { $0.backersCount == nil }

    backersCountLabel.rac.text = reward
      .map { $0.backersCount }
      .ignoreNil()
      .map { "\($0) backers" }

    rewardLabel.rac.text = reward.map { $0.description ?? "No reward" }
  }

  override func didUpdateFocusInContext(context: UIFocusUpdateContext,
                                        withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
    super.didUpdateFocusInContext(context, withAnimationCoordinator: coordinator)

    coordinator.addCoordinatedAnimations({
      self.configureForFocus(self.focused)
    }, completion: nil)
  }

  func configureForFocus(focused: Bool) {
    self.backgroundColor = focused ? UIColor.whiteColor(): UIColor.grayColor()
  }
}
