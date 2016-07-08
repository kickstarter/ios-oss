import Foundation
import UIKit
import ReactiveExtensions
import ReactiveCocoa
import Library
import Prelude

internal final class TwoFactorViewController: UIViewController {
  private let viewModel: TwoFactorViewModelType = TwoFactorViewModel()

  @IBOutlet weak var codeTextField: UITextField!
  @IBOutlet weak var formBackgroundView: UIView!
  @IBOutlet weak var resendButton: UIButton!
  @IBOutlet weak var submitButton: UIButton!
  @IBOutlet weak var titleLabel: UILabel!

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.viewModel.inputs.viewWillAppear()
  }

  override func bindStyles() {
    self |> twoFactorControllerStyle

    self.codeTextField |> tfaCodeFieldStyle

    self.formBackgroundView |> cardStyle()

    self.resendButton |> neutralButtonStyle

    self.submitButton |> positiveButtonStyle

    self.titleLabel
      |> UILabel.lens.textColor .~ .ksr_textDefault
      |> UILabel.lens.font .~ .ksr_body()
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.submitButton.rac.enabled = self.viewModel.outputs.isFormValid

    self.viewModel.outputs.logIntoEnvironment
      .observeNext { [weak self] env in
        AppEnvironment.login(env)
        self?.viewModel.inputs.environmentLoggedIn()
    }

    self.viewModel.outputs.postNotification
      .observeNext(NSNotificationCenter.defaultCenter().postNotification)

    self.viewModel.errors.showError
      .observeForUI()
      .observeNext { [weak self] message in
        self?.showError(message)
      }
  }

  internal func configureWith(email email: String, password: String) {
    self.viewModel.inputs.email(email, password: password)
  }

  internal func configureWith(facebookAccessToken token: String) {
    self.viewModel.inputs.facebookToken(token)
  }

  private func showError(message: String) {
    self.presentViewController(UIAlertController.genericError(message), animated: true, completion: nil)
  }

  @IBAction
  internal func codeEditingChanged(textField: UITextField) {
    self.viewModel.inputs.codeChanged(textField.text)
  }

  @IBAction
  internal func resendButtonPressed(sender: AnyObject) {
    self.viewModel.inputs.resendPressed()
  }

  @IBAction
  internal func submitButtonPressed(sender: AnyObject) {
    self.viewModel.inputs.submitPressed()
  }
}
