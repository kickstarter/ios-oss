import Library
import Prelude
import UIKit

public protocol PaymentMethodsFooterViewDelegate: AnyObject {
  func paymentMethodsFooterViewDidTapAddNewCardButton(_ footerView: PaymentMethodsFooterView)
}

public final class PaymentMethodsFooterView: UIView, NibLoading {
  public weak var delegate: PaymentMethodsFooterViewDelegate?

  @IBOutlet private var addCardButton: UIButton!
  @IBOutlet private var separatorView: UIView!
  @IBOutlet private var loadingIndicator: UIActivityIndicatorView!

  public override func bindStyles() { super.bindStyles() }

  @IBAction func addNewCardButtonTapped(_: Any) {
    self.loadingIndicator.startAnimating()
    self.addCardButton.isHidden = true

    self.addCardButton.isUserInteractionEnabled = false
    self.delegate?.paymentMethodsFooterViewDidTapAddNewCardButton(self)
  }
}

extension PaymentMethodsFooterView: PaymentMethodSettingsViewControllerDelegate {
  func cancelLoadingPaymentMethodsViewController(
    _: PaymentMethodSettingsViewController
  ) {
    self.addCardButton.isHidden = false
    self.addCardButton.isUserInteractionEnabled = true
    self.loadingIndicator.stopAnimating()
  }
}
