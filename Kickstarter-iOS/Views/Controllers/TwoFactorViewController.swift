import Foundation
import UIKit
import ReactiveExtensions
import ReactiveSwift
import Library
import Prelude

internal final class TwoFactorViewController: UIViewController {
  fileprivate let viewModel: TwoFactorViewModelType = TwoFactorViewModel()

  @IBOutlet fileprivate weak var codeTextField: UITextField!
  @IBOutlet fileprivate weak var formBackgroundView: UIView!
  @IBOutlet fileprivate weak var formStackView: UIStackView!
  @IBOutlet fileprivate weak var resendButton: UIButton!
  @IBOutlet fileprivate weak var submitButton: UIButton!
  @IBOutlet fileprivate weak var titleLabel: UILabel!

  internal override func viewDidLoad() {
    super.viewDidLoad()
    self.viewModel.inputs.viewDidLoad()
  }

  internal override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.viewModel.inputs.viewWillAppear()
  }

  internal override func bindStyles() {
    super.bindStyles()

    self
      |> twoFactorControllerStyle
      |> UIViewController.lens.view.layoutMargins %~~ { _, view in
        view.traitCollection.isRegularRegular ? .init(all: Styles.grid(20)) : .init(all: Styles.grid(3))
    }

    self.codeTextField
      |> tfaCodeFieldStyle

    self.formBackgroundView
      |> cardStyle()
      |> UIView.lens.layoutMargins %~~ { _, view in
        view.traitCollection.isRegularRegular ? .init(all: Styles.grid(10)) : .init(all: Styles.grid(3))
    }

    self.formStackView
      |> UIStackView.lens.spacing .~ Styles.grid(5)

    self.resendButton
      |> borderButtonStyle

    self.submitButton
      |> greenButtonStyle

    self.titleLabel
      |> UILabel.lens.textColor .~ .ksr_text_navy_700
      |> UILabel.lens.font .~ .ksr_body()
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.codeTextField.rac.becomeFirstResponder = self.viewModel.outputs.codeTextFieldBecomeFirstResponder
    self.submitButton.rac.enabled = self.viewModel.outputs.isFormValid

    self.viewModel.outputs.logIntoEnvironment
      .observeValues { [weak self] env in
        AppEnvironment.login(env)
        self?.viewModel.inputs.environmentLoggedIn()
    }

    self.viewModel.outputs.postNotification
      .observeForUI()
      .observeValues(NotificationCenter.default.post)

    self.viewModel.outputs.showError
      .observeForControllerAction()
      .observeValues { [weak self] message in
        self?.showError(message)
      }
  }

  internal static func configuredWith(email: String, password: String) -> TwoFactorViewController {
    let vc = instantiate()
    vc.viewModel.inputs.email(email, password: password)
    return vc
  }

  internal static func configuredWith(facebookAccessToken token: String) -> TwoFactorViewController {
    let vc = instantiate()
    vc.viewModel.inputs.facebookToken(token)
    return vc
  }

  fileprivate static func instantiate() -> TwoFactorViewController {
    return Storyboard.Login.instantiate(TwoFactorViewController)
  }

  fileprivate func showError(_ message: String) {
    self.present(UIAlertController.genericError(message), animated: true, completion: nil)
  }

  @IBAction
  internal func codeEditingChanged(_ textField: UITextField) {
    self.viewModel.inputs.codeChanged(textField.text)
  }

  @IBAction
  internal func resendButtonPressed(_ sender: AnyObject) {
    self.viewModel.inputs.resendPressed()
  }

  @IBAction
  internal func submitButtonPressed(_ sender: AnyObject) {
    self.viewModel.inputs.submitPressed()
  }
}
