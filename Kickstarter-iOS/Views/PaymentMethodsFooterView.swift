import Library
import Prelude
import UIKit

public protocol PaymentMethodsFooterViewDelegate: class {
  func paymentMethodsFooterViewDidTapAddNewCardButton(_ footerView: PaymentMethodsFooterView)
}

public final class PaymentMethodsFooterView: UITableViewHeaderFooterView {

  public weak var delegate: PaymentMethodsFooterViewDelegate?

  @IBOutlet private weak var addCardButton: UIButton!
  @IBOutlet private weak var separatorView: UIView!

  override public func bindStyles() {
    super.bindViewModel()

    _ = self.addCardButton
      |> UIButton.lens.titleColor(for: .normal) .~ .ksr_green_700
      |> UIButton.lens.titleEdgeInsets .~ UIEdgeInsets(left: Styles.grid(4))
      |> UIButton.lens.imageEdgeInsets .~ UIEdgeInsets(left: Styles.grid(2))
      |> UIButton.lens.title(for: .normal) %~ { _ in
        Strings.Add_new_card()
      }

    _ = self.addCardButton.imageView
      ?|> \.tintColor .~ .ksr_green_700

    _ = self
      |> \.backgroundColor .~ .ksr_grey_200

    _ = self.separatorView
      |> separatorStyle
  }

  @IBAction func addNewCardButtonTapped(_ sender: Any) {
    self.delegate?.paymentMethodsFooterViewDidTapAddNewCardButton(self)
  }
}
