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
      |> \.tintColor .~ LegacyColors.ksr_create_700.uiColor()
      |> UIButton.lens.backgroundColor(for: .normal) .~ LegacyColors.ksr_white.uiColor()
      |> UIButton.lens.titleColor(for: .normal) .~ LegacyColors.ksr_create_700.uiColor()
      |> UIButton.lens.titleColor(for: .highlighted) .~ LegacyColors.ksr_create_700.uiColor()
      |> UIButton.lens.title(for: .normal) %~ { _ in Strings.Add_new_card() }
      |> UIButton.lens.titleLabel.font .~ .ksr_subhead()

    _ = self.addCardButton.imageView
      ?|> \.tintColor .~ LegacyColors.ksr_create_700.uiColor()

    _ = self
      |> \.backgroundColor .~ LegacyColors.ksr_white.uiColor()

    _ = self.separatorView
      |> separatorStyle
  }

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
