import KsApi
import Library
import Prelude
import ReactiveSwift
import UIKit

internal final class AddNewCardViewController: UIViewController {
  @IBOutlet fileprivate weak var cardNumberLabel: UILabel!
  @IBOutlet fileprivate weak var cardNumberTextField: UITextField!
  @IBOutlet fileprivate weak var cardholderNameLabel: UILabel!
  @IBOutlet fileprivate weak var cardholderNameTextField: UITextField!
  @IBOutlet fileprivate weak var expirationLabel: UILabel!
  @IBOutlet fileprivate weak var expirationTextField: UITextField!
  @IBOutlet fileprivate weak var securityCodeLabel: UILabel!
  @IBOutlet fileprivate weak var securityCodeTextField: UITextField!
  @IBOutlet fileprivate weak var zipCodeLabel: UILabel!
  @IBOutlet fileprivate weak var zipCodeTextField: UITextField!

  private weak var saveButtonView: LoadingBarButtonItemView!

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
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> settingsViewControllerStyle

    _ = [self.cardNumberTextField, self.cardholderNameTextField, self.expirationTextField,
         self.securityCodeTextField, self.zipCodeTextField]
      ||> formFieldStyle
      ||> \.textAlignment .~ .right

    _ = [self.cardNumberLabel, self.cardholderNameLabel, self.expirationLabel,
         self.securityCodeLabel, self.zipCodeLabel]
      ||> settingsTitleLabelStyle

    _ = [self.cardNumberTextField, self.expirationTextField, self.securityCodeTextField,
         self.zipCodeTextField]
      ||> \.keyboardType .~ .numberPad

    _ = self.cardNumberLabel
      |> \.text %~ { _ in Strings.Card_number() }

    _ = self.cardholderNameLabel
      |> \.text %~ { _ in Strings.Cardholder_name() }

    _ = self.expirationLabel
      |> \.text %~ { _ in Strings.Expiration() }

    _ = self.securityCodeLabel
      |> \.text %~ { _ in Strings.Security_code() }

    _ = self.zipCodeLabel
      |> \.text %~ { _ in Strings.Zip_code() }

    _ = self.cardholderNameTextField
      |> \.placeholder %~ { _ in Strings.Name() }

    _ = self.expirationTextField
      |> \.placeholder %~ { _ in Strings.MMYY() }

    _ = self.securityCodeTextField
      |> \.placeholder %~ { _ in Strings.CVC() }
  }

  @objc fileprivate func cancelButtonTapped() {
    self.dismiss(animated: true, completion: nil)
  }

  @objc fileprivate func saveButtonTapped() {
    self.dismiss(animated: true, completion: nil)
  }
}
