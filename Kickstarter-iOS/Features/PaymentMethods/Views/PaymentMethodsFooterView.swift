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

  public override func bindStyles() {
    super.bindViewModel()
    _ = self.addCardButton
      |> \.titleEdgeInsets .~ UIEdgeInsets(left: Styles.grid(4))
      |> \.imageEdgeInsets .~ UIEdgeInsets(left: Styles.grid(2))
      |> \.tintColor .~ .ksr_create_700
      |> UIButton.lens.backgroundColor(for: .normal) .~ .ksr_white
      |> UIButton.lens.titleColor(for: .normal) .~ .ksr_create_700
      |> UIButton.lens.titleColor(for: .highlighted) .~ .ksr_create_700
      |> UIButton.lens.title(for: .normal) %~ { _ in Strings.Add_new_card() }

    _ = self.addCardButton.imageView
      ?|> \.tintColor .~ .ksr_create_700

    _ = self
      |> \.backgroundColor .~ .ksr_white

    _ = self.separatorView
      |> separatorStyle
  }

  @IBAction func addNewCardButtonTapped(_: Any) {
    if featureSettingsPaymentSheetEnabled() {
      self.loadingIndicator.startAnimating()
      self.addCardButton.isHidden = true
    }

    self.addCardButton.isUserInteractionEnabled = false
    self.delegate?.paymentMethodsFooterViewDidTapAddNewCardButton(self)
  }
}

extension PaymentMethodsFooterView: PaymentMethodsViewControllerDelegate {
  func cancelLoadingPaymentMethodsViewController(
    _: PaymentMethodsViewController) {
    self.addCardButton.isHidden = false
    self.addCardButton.isUserInteractionEnabled = true
    self.loadingIndicator.stopAnimating()
  }
}
