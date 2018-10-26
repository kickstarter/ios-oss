import Library
import Prelude
import UIKit

internal protocol PaymentMethodsFooterViewDelegate: class {
  func didTapAddNewCardButton()
}

internal final class PaymentMethodsFooterView: UITableViewHeaderFooterView {

  public weak var delegate: PaymentMethodsFooterViewDelegate?

  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var separatorView: UIView!

  override func bindStyles() {
    super.bindViewModel()

    _ = self
      |> \.backgroundColor .~ .ksr_grey_200

    _ = self.titleLabel
      |> \.text .~ "+  Add a new card"
      |> \.textColor .~ .ksr_green_700

    _ = self.separatorView
      |> separatorStyle
  }

  @IBAction func addNewCardButtonTapped(_ sender: Any) {
    self.delegate?.didTapAddNewCardButton()
  }
}
