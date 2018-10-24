import Prelude
import UIKit

internal protocol PaymentMethodsFooterViewDelegate: class {
  func didTapAddNewCardButton()
}

internal final class PaymentMethodsFooterView: UIView {

  public var delegate: PaymentMethodsFooterViewDelegate?

  @IBOutlet private weak var addIconImageView: UIImageView!
  @IBOutlet private weak var titleLabel: UILabel!

  override func bindStyles() {
    super.bindViewModel()

    _ = self
      |> \.backgroundColor .~ .ksr_grey_200

    _ = self.titleLabel
      |> \.text .~ "Add a new card"
      |> \.textColor .~ .ksr_green_400
  }

  @IBAction func addNewCardButtonTapped(_ sender: Any) {
    self.delegate?.didTapAddNewCardButton()
  }
}
