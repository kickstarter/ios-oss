import KsApi
import Library
import Prelude
import ReactiveSwift
import Stripe
import UIKit

internal final class AddNewCardViewController: UIViewController, STPPaymentCardTextFieldDelegate {

  private weak var saveButtonView: LoadingBarButtonItemView!
  @IBOutlet private weak var cardholderNameLabel: UILabel!
  @IBOutlet private weak var cardholderNameTextField: UITextField!
  @IBOutlet private weak var paymentField: STPPaymentCardTextField!

  internal static func instantiate() -> AddNewCardViewController {
    return Storyboard.Settings.instantiate(AddNewCardViewController.self)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    let cancelButton = UIBarButtonItem(title: Strings.Cancel(),
                                       style: .plain,
                                       target: self,
                                       action: #selector(cancelButtonTapped))
    cancelButton.tintColor = .ksr_green_700
    self.navigationItem.leftBarButtonItem = cancelButton

    self.saveButtonView = LoadingBarButtonItemView.instantiate()
    self.saveButtonView.setTitle(title: Strings.Save())
    self.saveButtonView.addTarget(self, action: #selector(saveButtonTapped))
    let navigationBarButton = UIBarButtonItem(customView: self.saveButtonView)
    self.navigationItem.setRightBarButton(navigationBarButton, animated: false)

    self.paymentField.delegate = self
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> settingsViewControllerStyle

    _ = self.cardholderNameLabel
      |> settingsTitleLabelStyle
      |> \.text %~ { _ in Strings.Cardholder_name() }

    _ = self.cardholderNameTextField
      |> formFieldStyle
      |> \.textAlignment .~ .right
      |> \.placeholder %~ { _ in Strings.Name() }

    _ = self.paymentField
      |> \.borderColor .~ nil

  }

  @objc fileprivate func cancelButtonTapped() {
    self.dismiss(animated: true, completion: nil)
  }

  @objc fileprivate func saveButtonTapped() {
    self.dismiss(animated: true, completion: nil)
  }
}
