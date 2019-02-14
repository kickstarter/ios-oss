import KsApi
import Library
import Prelude
import ReactiveSwift
import UIKit

internal final class CreditCardCell: UITableViewCell, ValueCell {

  private let viewModel: CreditCardCellViewModelType = CreditCardCellViewModel()

  @IBOutlet fileprivate weak var stackView: UIStackView!
  @IBOutlet fileprivate weak var cardImageView: UIImageView!
  @IBOutlet fileprivate weak var cardNumberLabel: UILabel!
  @IBOutlet fileprivate weak var expirationDateLabel: UILabel!

  public func configureWith(value card: GraphUserCreditCard.CreditCard) {
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
    self.cardNumberLabel.rac.text = self.viewModel.outputs.cardNumberText
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
