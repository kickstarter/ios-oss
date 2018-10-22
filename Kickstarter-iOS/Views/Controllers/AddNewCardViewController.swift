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
    cancelButton.tintColor = UIColor.ksr_green_700
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
      ||> UITextField.lens.textAlignment .~ .right

    _ = [self.cardNumberLabel, self.cardholderNameLabel, self.expirationLabel,
         self.securityCodeLabel, self.zipCodeLabel]
      ||> settingsTitleLabelStyle

    _ = [self.cardNumberTextField, self.expirationTextField, self.securityCodeTextField, self.zipCodeTextField]
      ||> UITextField.lens.keyboardType .~ .numberPad
  }

  @objc fileprivate func cancelButtonTapped() {
    self.dismiss(animated: true, completion: nil)
  }

  @objc fileprivate func saveButtonTapped() {
    self.dismiss(animated: true, completion: nil)
  }
}
