import KsApi
import Library
import Prelude
import UIKit

internal final class NoRewardCell: UITableViewCell, ValueCell {

  @IBOutlet private weak var cardView: UIView!
  @IBOutlet private weak var pledgeAmountLabel: UILabel!
  @IBOutlet private weak var pledgeAmountStackView: UIStackView!
  @IBOutlet private weak var pledgeButton: UIButton!
  @IBOutlet private weak var pledgeCurrencyLabel: UILabel!
  @IBOutlet private weak var pledgeTitleAndAmountStackView: UIStackView!
  @IBOutlet private weak var pledgeTitleLabel: UILabel!
  @IBOutlet private weak var rootStackView: UIStackView!
  @IBOutlet private weak var separatorView: UIView!

  internal func configureWith(value project: Project) {

    self.contentView.backgroundColor = Library.backgroundColor(forCategoryId: project.category.rootId)
  }

  // swiftlint:disable function_body_length
  internal override func bindStyles() {
    super.bindStyles()

    self
      |> baseTableViewCellStyle()
      |> (UITableViewCell.lens.contentView • UIView.lens.layoutMargins) .~
        .init(top: Styles.grid(1), left: Styles.grid(2), bottom: Styles.grid(2), right: Styles.grid(2))

    self.cardView
      |> dropShadowStyle()
      |> UIView.lens.backgroundColor .~ .whiteColor()

    self.pledgeAmountLabel
      |> UILabel.lens.textColor .~ .ksr_text_navy_500
      |> UILabel.lens.font .~ .ksr_caption1(size: 13)
      |> UILabel.lens.text %~ { _ in Strings.Pledge_any_amount() }

    self.pledgeAmountStackView
      |> UIStackView.lens.spacing .~ Styles.grid(1)
      |> UIStackView.lens.alignment .~ .Center

    self.pledgeButton
      |> greenButtonStyle
      |> UIButton.lens.userInteractionEnabled .~ true
      |> UIButton.lens.title(forState: .Normal) %~ { _ in Strings.Pledge_now_without_a_reward() }

    self.pledgeCurrencyLabel
      |> UILabel.lens.textColor .~ .ksr_text_green_700
      |> UILabel.lens.font .~ .ksr_headline(size: 14)

    self.pledgeTitleAndAmountStackView
      |> UIStackView.lens.spacing .~ Styles.grid(5)
      |> UIStackView.lens.layoutMargins .~ .init(topBottom: 0, leftRight: Styles.grid(2))
      |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true

    self.pledgeTitleLabel
      |> UILabel.lens.textColor .~ .ksr_text_navy_700
      |> UILabel.lens.font .~ .ksr_title3(size: 16)
      |> UILabel.lens.text %~ { _ in Strings.Make_a_pledge_without_a_reward() }

    self.rootStackView
      |> UIStackView.lens.spacing .~ Styles.grid(3)
      |> UIStackView.lens.layoutMargins .~
        .init(top: Styles.grid(4), left: Styles.grid(2), bottom: Styles.grid(2), right: Styles.grid(2))
      |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true

    self.separatorView
      |> separatorStyle
  }
  // swiftlint:enable function_body_length
}
