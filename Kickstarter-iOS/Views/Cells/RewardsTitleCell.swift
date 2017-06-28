import KsApi
import Library
import Prelude
import UIKit

internal final class RewardsTitleCell: UITableViewCell, ValueCell {

  @IBOutlet fileprivate weak var rewardsTitleLabel: UILabel!

  func configureWith(value project: Project) {
    self.rewardsTitleLabel.textColor = discoveryPrimaryColor()

    switch (project.personalization.isBacking, project.state) {
    case (true?, .live):
      self.rewardsTitleLabel.font = .ksr_caption1(size: 14)
      self.rewardsTitleLabel.text = Strings.Or_select_a_different_reward_below_colon()
    case (_, .live):
      self.rewardsTitleLabel.font = .ksr_headline(size: 17)
      self.rewardsTitleLabel.text = Strings.Rewards_count_rewards_colon(
        rewards_count: project.rewards.filter { $0 != .noReward }.count
      )
    case (true?, _):
      self.rewardsTitleLabel.font = .ksr_subhead(size: 14)
      self.rewardsTitleLabel.text = Strings.Rewards_count_rewards(
        rewards_count: project.rewards.filter { $0 != .noReward }.count
      )
    default:
      self.rewardsTitleLabel.font = .ksr_headline(size: 14)
      self.rewardsTitleLabel.text = Strings.Rewards_count_rewards(
        rewards_count: project.rewards.filter { $0 != .noReward }.count
      )
    }
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()
      |> (UITableViewCell.lens.contentView..UIView.lens.layoutMargins) %~~ { margins, cell in
        .init(top: Styles.grid(2),
              left: cell.traitCollection.isRegularRegular ? Styles.grid(20) : margins.left * 2,
              bottom: Styles.grid(1),
              right: cell.traitCollection.isRegularRegular ? Styles.grid(20) : margins.right * 2)
      }
      |> UITableViewCell.lens.contentView..UIView.lens.backgroundColor .~ projectCellBackgroundColor()

    _ = self.rewardsTitleLabel
      |> UILabel.lens.numberOfLines .~ 0
  }
}
