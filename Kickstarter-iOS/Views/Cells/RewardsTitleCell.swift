import KsApi
import Library
import Prelude
import UIKit

internal final class RewardsTitleCell: UITableViewCell, ValueCell {

  @IBOutlet private weak var rewardsTitleLabel: UILabel!

  func configureWith(value project: Project) {
    self.contentView.backgroundColor = Library.backgroundColor(forCategoryId: project.category.rootId)
    self.rewardsTitleLabel.textColor = discoveryPrimaryColor(forCategoryId: project.category.rootId)

    if project.personalization.isBacking == true {
      self.rewardsTitleLabel.font = .ksr_caption1(size: 14)
      self.rewardsTitleLabel.text = Strings.Or_change_your_reward_by_selecting_one_below_colon()
    } else {
      self.rewardsTitleLabel.font = .ksr_headline(size: 17)
      self.rewardsTitleLabel.text = Strings.Rewards_count_rewards_colon(
        rewards_count: project.rewards.filter { $0 != .noReward }.count
      )
    }
  }

  internal override func bindStyles() {
    super.bindStyles()

    self
      |> baseTableViewCellStyle()
      |> (UITableViewCell.lens.contentView • UIView.lens.layoutMargins) %~ { margins in
        .init(top: Styles.grid(2), left: margins.left * 2, bottom: Styles.grid(1), right: margins.right * 2)
    }

    self.rewardsTitleLabel
      |> UILabel.lens.numberOfLines .~ 0
  }
}
