import Library
import Prelude
import UIKit

public protocol PaymentMethodsFooterViewDelegate: class {
  func paymentMethodsFooterViewDidTapAddNewCardButton(_ footerView: PaymentMethodsFooterView)
}

public final class PaymentMethodsFooterView: UITableViewHeaderFooterView {

  public weak var delegate: PaymentMethodsFooterViewDelegate?

  @IBOutlet private weak var plusLabel: UILabel!
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var separatorView: UIView!

  override public func bindStyles() {
    super.bindViewModel()

    _ = self
      |> \.backgroundColor .~ .ksr_grey_200

    _ = self.plusLabel
      |> \.textColor .~ .ksr_green_700

    _ = self.titleLabel
      |> \.text %~ { _ in
        Strings.Add_new_card()
      }
      |> \.textColor .~ .ksr_green_700

    _ = self.separatorView
      |> separatorStyle
  }

  @IBAction func addNewCardButtonTapped(_ sender: Any) {
    self.delegate?.paymentMethodsFooterViewDidTapAddNewCardButton(self)
  }
}
