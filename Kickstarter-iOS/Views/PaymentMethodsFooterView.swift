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

  public override func bindStyles() {
    super.bindViewModel()
    _ = self.addCardButton
      |> \.titleEdgeInsets .~ UIEdgeInsets(left: Styles.grid(4))
      |> \.imageEdgeInsets .~ UIEdgeInsets(left: Styles.grid(2))
      |> \.tintColor .~ .ksr_green_700
      |> UIButton.lens.backgroundColor(for: .normal) .~ .white
      |> UIButton.lens.titleColor(for: .normal) .~ .ksr_green_700
      |> UIButton.lens.titleColor(for: .highlighted) .~ .ksr_green_700
      |> UIButton.lens.title(for: .normal) %~ { _ in Strings.Add_new_card() }

    _ = self.addCardButton.imageView
      ?|> \.tintColor .~ .ksr_green_700

    _ = self
      |> \.backgroundColor .~ .ksr_grey_200

    _ = self.separatorView
      |> separatorStyle
  }

  @IBAction func addNewCardButtonTapped(_: Any) {
    self.delegate?.paymentMethodsFooterViewDidTapAddNewCardButton(self)
  }
}
