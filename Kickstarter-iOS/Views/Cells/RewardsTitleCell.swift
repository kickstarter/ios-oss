import KsApi
import Library
import Prelude
import UIKit

internal final class RewardsTitleCell: UITableViewCell, ValueCell {

  @IBOutlet fileprivate weak var rewardsTitleLabel: UILabel!

  // value required to bind value to data source
  internal func configureWith(value project: Project) {}

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
      |> UILabel.lens.textColor .~ discoveryPrimaryColor()
      |> UILabel.lens.numberOfLines .~ 0
      |> UILabel.lens.font .~ .ksr_caption1(size: 14)
      |> UILabel.lens.text .~ Strings.Or_select_a_different_reward_below_colon()
  }
}
