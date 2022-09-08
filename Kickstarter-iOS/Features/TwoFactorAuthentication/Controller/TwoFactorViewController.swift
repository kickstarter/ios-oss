import Foundation
import Library
import Prelude
import ReactiveExtensions
import ReactiveSwift
import UIKit

internal final class TwoFactorViewController: UIViewController {
  fileprivate let viewModel: TwoFactorViewModelType = TwoFactorViewModel()

  @IBOutlet fileprivate var codeTextField: UITextField!
  @IBOutlet fileprivate var formBackgroundView: UIView!
  @IBOutlet fileprivate var formStackView: UIStackView!
  @IBOutlet fileprivate var resendButton: UIButton!
  @IBOutlet fileprivate var submitButton: UIButton!
  @IBOutlet fileprivate var titleLabel: UILabel!

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

    _ = self
      |> twoFactorControllerStyle
      |> UIViewController.lens.view.layoutMargins %~~ { _, view in
        view.traitCollection.isRegularRegular ? .init(all: Styles.grid(20)) : .init(all: Styles.grid(3))
      }

    _ = self.codeTextField
      |> tfaCodeFieldAutoFillStyle

    _ = self.formBackgroundView
      |> cardStyle()
      |> UIView.lens.layoutMargins %~~ { _, view in
        view.traitCollection.isRegularRegular ? .init(all: Styles.grid(10)) : .init(all: Styles.grid(3))
      }

    _ = self.formStackView
      |> UIStackView.lens.spacing .~ Styles.grid(5)

    _ = self.resendButton
      |> greyButtonStyle
      |> UIButton.lens.title(for: .normal) %~ { _ in Strings.two_factor_buttons_resend() }

    _ = self.submitButton
      |> greenButtonStyle
      |> UIButton.lens.title(for: .normal) %~ { _ in Strings.two_factor_buttons_submit() }

    _ = self.titleLabel
      |> UILabel.lens.textColor .~ .ksr_support_700
      |> UILabel.lens.font .~ .ksr_body()
      |> UILabel.lens.text %~ { _ in Strings.two_factor_message() }
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
      .observeValues {
        NotificationCenter.default.post($0.0)
        NotificationCenter.default.post($0.1)
      }

    self.viewModel.outputs.showError
      .observeForControllerAction()
      .observeValues { [weak self] message in
        self?.showError(message)
      }
  }

  internal static func configuredWith(email: String, password: String) -> TwoFactorViewController {
    let vc = self.instantiate()
    vc.viewModel.inputs.email(email, password: password)
    return vc
  }

  internal static func configuredWith(facebookAccessToken token: String) -> TwoFactorViewController {
    let vc = self.instantiate()
    vc.viewModel.inputs.facebookToken(token)
    return vc
  }

  fileprivate static func instantiate() -> TwoFactorViewController {
    return Storyboard.Login.instantiate(TwoFactorViewController.self)
  }

  fileprivate func showError(_ message: String) {
    self.present(UIAlertController.genericError(message), animated: true, completion: nil)
  }

  @IBAction
  internal func codeEditingChanged(_ textField: UITextField) {
    self.viewModel.inputs.codeChanged(textField.text)
  }

  @IBAction
  internal func resendButtonPressed(_: AnyObject) {
    self.viewModel.inputs.resendPressed()
  }

  @IBAction
  internal func submitButtonPressed(_: AnyObject) {
    self.viewModel.inputs.submitPressed()
  }
}
