import KsApi
import Library
import Prelude
import ReactiveSwift
import UIKit

internal final class CreditCardCell: UITableViewCell {

  @IBOutlet fileprivate weak var cardNumberLabel: UILabel!
  @IBOutlet fileprivate weak var expirationDateLabel: UILabel!
  @IBOutlet fileprivate weak var cardImageView: UIImageView!

  override func bindStyles() {
    super.bindStyles()

    _ = self.cardNumberLabel
      |> settingsTitleLabelStyle

    _ = self.expirationDateLabel
      |> settingsSectionLabelStyle
  }
}
