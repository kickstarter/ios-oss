import KsApi
import Library
import Prelude
import ReactiveSwift
import UIKit

internal final class CreditCardCell: UITableViewCell, ValueCell {

  private let viewModel: CreditCardCellViewModelType = CreditCardCellViewModel()

  @IBOutlet fileprivate weak var cardImageView: UIImageView!
  @IBOutlet fileprivate weak var cardNumberLabel: UILabel!
  @IBOutlet fileprivate weak var expirationDateLabel: UILabel!

  public func configureWith(value card: GraphUserCreditCard.CreditCard) {
    self.viewModel.inputs.configureWith(creditCard: card)
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self.cardNumberLabel
      |> settingsTitleLabelStyle

    _ = self.expirationDateLabel
      |> settingsSectionLabelStyle
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.cardNumberLabel.rac.text = self.viewModel.outputs.cardNumberText
    self.expirationDateLabel.rac.text = self.viewModel.outputs.expirationDateText
  }
}
