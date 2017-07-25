import KsApi
import Library
import Prelude
import UIKit

internal final class NoRewardCell: UITableViewCell, ValueCell {

  @IBOutlet fileprivate weak var cardView: UIView!
  @IBOutlet fileprivate weak var pledgeButton: UIButton!
  @IBOutlet fileprivate weak var pledgeTitleLabel: UILabel!
  @IBOutlet fileprivate weak var pledgeSubtitleLabel: UILabel!
  @IBOutlet fileprivate weak var rootStackView: UIStackView!
  @IBOutlet fileprivate weak var copyStackView: UIStackView!

  // value required to bind value to data source
  internal func configureWith(value: Project) {}

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()
      |> NoRewardCell.lens.accessibilityTraits .~ UIAccessibilityTraitButton
      |> (NoRewardCell.lens.contentView..UIView.lens.layoutMargins) %~~ { _, cell in
        cell.traitCollection.isRegularRegular
          ? .init(top: Styles.grid(1), left: Styles.grid(16), bottom: Styles.grid(2), right: Styles.grid(16))
          : .init(top: Styles.grid(1), left: Styles.grid(2), bottom: Styles.grid(2), right: Styles.grid(2))
      }
      |> NoRewardCell.lens.contentView..UIView.lens.backgroundColor .~ projectCellBackgroundColor()

    _ = self.cardView
      |> dropShadowStyle()
      |> UIView.lens.backgroundColor .~ .white

    _ = self.pledgeButton
      |> greenButtonStyle
      |> UIButton.lens.userInteractionEnabled .~ false
      |> UIButton.lens.title(forState: .normal) %~ { _ in Strings.Pledge_without_a_reward() }
      |> UIButton.lens.isAccessibilityElement .~ false
      |> UIButton.lens.accessibilityElementsHidden .~ true

    _ = self.pledgeSubtitleLabel
      |> UILabel.lens.textColor .~ .ksr_text_navy_500
      |> UILabel.lens.font .~ .ksr_body(size: 13)
      |> UILabel.lens.text %~ { _ in Strings.Pledge_any_amount_to_help_bring_this_project_to_life() }

    _ = self.pledgeTitleLabel
      |> UILabel.lens.textColor .~ .ksr_text_navy_700
      |> UILabel.lens.font .~ .ksr_title3(size: 16)
      |> UILabel.lens.text %~ { _ in Strings.Make_a_pledge_without_a_reward() }
      |> UILabel.lens.numberOfLines .~ 0

    _ = self.rootStackView
      |> UIStackView.lens.spacing .~ Styles.grid(3)
      |> UIStackView.lens.layoutMargins .~
        .init(top: Styles.grid(4), left: Styles.grid(2), bottom: Styles.grid(2), right: Styles.grid(2))
      |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true

    _ = self.copyStackView
      |> UIStackView.lens.spacing .~ Styles.grid(3)
      |> UIStackView.lens.layoutMargins .~ .init(topBottom: 0, leftRight: Styles.grid(2))
      |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true
  }
  // swiftlint:enable function_body_length
}
