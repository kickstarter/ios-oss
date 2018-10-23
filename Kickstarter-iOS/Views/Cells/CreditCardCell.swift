import KsApi
import Library
import Prelude
import ReactiveSwift
import UIKit

internal final class CreditCardCell: UITableViewCell, ValueCell {

  @IBOutlet fileprivate weak var cardImageView: UIImageView!
  @IBOutlet fileprivate weak var cardNumberLabel: UILabel!
  @IBOutlet fileprivate weak var expirationDateLabel: UILabel!

  public func configureWith(value card: GraphUserCreditCard.CreditCard) {
    self.cardNumberLabel.text = card.lastFour
    self.expirationDateLabel.text = card.expirationDate
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self.cardNumberLabel
      |> settingsTitleLabelStyle

    _ = self.expirationDateLabel
      |> settingsSectionLabelStyle
  }
}
