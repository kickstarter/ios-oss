import Prelude
import UIKit

public protocol PaymentMethodsFooterViewDelegate {
  func didTapAddNewCardButton()
}

internal final class PaymentMethodsFooterView: UIView {

  public var delegate: PaymentMethodsFooterViewDelegate?

  @IBOutlet weak var addIconImageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!

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
