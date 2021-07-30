import KsApi
import Library
import Prelude
import ReactiveSwift
import UIKit

internal final class CreditCardCell: UITableViewCell, ValueCell {
  private let viewModel: CreditCardCellViewModelType = CreditCardCellViewModel()

  @IBOutlet fileprivate var stackView: UIStackView!
  @IBOutlet fileprivate var cardImageView: UIImageView!
  @IBOutlet fileprivate var cardNumberLabel: UILabel!
  @IBOutlet fileprivate var expirationDateLabel: UILabel!

  public func configureWith(value card: UserCreditCards.CreditCard) {
    self.viewModel.inputs.configureWith(creditCard: card)
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self.stackView
      |> \.isLayoutMarginsRelativeArrangement .~ true
      |> \.layoutMargins .~ .init(topBottom: Styles.grid(1), leftRight: Styles.grid(2))

    _ = self.cardImageView
      |> \.contentMode .~ .scaleAspectFit

    _ = self.cardNumberLabel
      |> settingsTitleLabelStyle
      |> \.lineBreakMode .~ .byTruncatingMiddle

    _ = self.expirationDateLabel
      |> settingsDescriptionLabelStyle
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.cardNumberLabel.rac.accessibilityLabel = self.viewModel.outputs.cardNumberAccessibilityLabel
    self.cardNumberLabel.rac.text = self.viewModel.outputs.cardNumberTextLongStyle
    self.expirationDateLabel.rac.text = self.viewModel.outputs.expirationDateText

    self.viewModel.outputs.cardImage
      .observeForUI()
      .observeValues { [weak self] image in
        guard let _self = self else { return }
        _ = _self.cardImageView
          ?|> \.image .~ image
      }
  }
}
