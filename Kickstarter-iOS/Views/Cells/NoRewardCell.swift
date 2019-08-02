import KsApi
import Library
import Prelude
import UIKit

internal final class NoRewardCell: UITableViewCell, ValueCell {
  @IBOutlet fileprivate var cardView: UIView!
  @IBOutlet fileprivate var pledgeButton: UIButton!
  @IBOutlet fileprivate var pledgeTitleLabel: UILabel!
  @IBOutlet fileprivate var pledgeSubtitleLabel: UILabel!
  @IBOutlet fileprivate var rootStackView: UIStackView!
  @IBOutlet fileprivate var copyStackView: UIStackView!

  // value required to bind value to data source
  internal func configureWith(value _: Project) {}

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()
      |> NoRewardCell.lens.accessibilityTraits .~ UIAccessibilityTraits.button.rawValue
      |> (NoRewardCell.lens.contentView .. UIView.lens.layoutMargins) %~~ { _, cell in
        cell.traitCollection.isRegularRegular
          ? .init(top: Styles.grid(1), left: Styles.grid(16), bottom: Styles.grid(2), right: Styles.grid(16))
          : .init(top: Styles.grid(1), left: Styles.grid(2), bottom: Styles.grid(2), right: Styles.grid(2))
      }
      |> NoRewardCell.lens.contentView .. UIView.lens.backgroundColor .~ projectCellBackgroundColor()

    _ = self.cardView
      |> darkCardStyle(cornerRadius: 0)
      |> UIView.lens.backgroundColor .~ .white

    _ = self.pledgeButton
      |> greenButtonStyle
      |> UIButton.lens.isUserInteractionEnabled .~ false
      |> UIButton.lens.title(for: .normal) %~ { _ in Strings.Pledge_without_a_reward() }
      |> UIButton.lens.isAccessibilityElement .~ false
      |> UIButton.lens.accessibilityElementsHidden .~ true

    _ = self.pledgeSubtitleLabel
      |> UILabel.lens.textColor .~ .ksr_text_dark_grey_400
      |> UILabel.lens.font .~ .ksr_body(size: 13)
      |> UILabel.lens.text %~ { _ in Strings.Pledge_any_amount_to_help_bring_this_project_to_life() }
      |> UILabel.lens.backgroundColor .~ .white

    _ = self.pledgeTitleLabel
      |> UILabel.lens.textColor .~ .ksr_soft_black
      |> UILabel.lens.font .~ .ksr_title3(size: 16)
      |> UILabel.lens.text %~ { _ in Strings.Make_a_pledge_without_a_reward() }
      |> UILabel.lens.numberOfLines .~ 0
      |> UILabel.lens.backgroundColor .~ .white

    _ = self.rootStackView
      |> UIStackView.lens.spacing .~ Styles.grid(3)
      |> UIStackView.lens.layoutMargins .~
      .init(top: Styles.grid(4), left: Styles.grid(2), bottom: Styles.grid(2), right: Styles.grid(2))
      |> UIStackView.lens.isLayoutMarginsRelativeArrangement .~ true

    _ = self.copyStackView
      |> UIStackView.lens.spacing .~ Styles.grid(3)
      |> UIStackView.lens.layoutMargins .~ .init(topBottom: 0, leftRight: Styles.grid(2))
      |> UIStackView.lens.isLayoutMarginsRelativeArrangement .~ true
  }
}
