import Foundation
import Library
import Prelude

final class ChangePasswordViewController: UIViewController {
  @IBOutlet fileprivate weak var confirmNewPasswordLabel: UILabel!
  @IBOutlet fileprivate weak var confirmNewPassword: UITextField!
  @IBOutlet fileprivate weak var currentPasswordLabel: UILabel!
  @IBOutlet fileprivate weak var currentPassword: UITextField!
  @IBOutlet fileprivate weak var errorMessageLabel: UILabel!
  @IBOutlet fileprivate weak var newPasswordLabel: UILabel!
  @IBOutlet fileprivate weak var newPassword: UITextField!
  @IBOutlet fileprivate weak var onePasswordButton: UIButton!
  @IBOutlet fileprivate weak var saveButton: UIBarButtonItem!
  @IBOutlet fileprivate weak var scrollView: UIScrollView!

  private let viewModel: ChangePasswordViewModelType = ChangePasswordViewModel()

  internal static func instantiate() -> ChangePasswordViewController {
    return Storyboard.Settings.instantiate(ChangePasswordViewController.self)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    self.viewModel.inputs.viewDidAppear()
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> settingsViewControllerStyle
      |> UIViewController.lens.title %~ { _ in
        Strings.Change_password()
    }

    _ = onePasswordButton
      |> onePasswordButtonStyle

    _ = confirmNewPasswordLabel
      |> settingsTitleLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.Confirm_password() }

    _ = confirmNewPassword
      |> formFieldStyle
      |> UITextField.lens.secureTextEntry .~ true
      |> UITextField.lens.textAlignment .~ .right
      |> UITextField.lens.placeholder %~ { _ in Strings.login_placeholder_password() }

    _ = currentPasswordLabel
      |> settingsTitleLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.Current_password() }

    _ = currentPassword
      |> formFieldStyle
      |> UITextField.lens.secureTextEntry .~ true
      |> UITextField.lens.textAlignment .~ .right
      |> UITextField.lens.placeholder %~ { _ in
        Strings.login_placeholder_password()
    }

    _ = errorMessageLabel
      |> settingsDescriptionLabelStyle

    _ = newPasswordLabel
      |> settingsTitleLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.New_password() }

    _ = newPassword
      |> formFieldStyle
      |> UITextField.lens.secureTextEntry .~ true
      |> UITextField.lens.textAlignment .~ .right
      |> UITextField.lens.placeholder %~ { _ in
        Strings.login_placeholder_password()
    }
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.testPasswordInput
      .observeForUI()
      .observeValues { (passwordInput) in
        print("Current password: \(passwordInput.0) \n New password: \(passwordInput.1) \n Confirm new password: \(passwordInput.2)")
    }

    self.viewModel.outputs.currentPasswordBecomeFirstResponder
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.currentPassword.becomeFirstResponder()
    }

    self.viewModel.outputs.newPasswordBecomeFirstResponder
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.newPassword.becomeFirstResponder()
    }

    self.viewModel.outputs.confirmNewPasswordBecomeFirstResponder
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.confirmNewPassword.becomeFirstResponder()
    }

    self.viewModel.outputs.dismissKeyboard
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.confirmNewPassword.resignFirstResponder()
    }

    Keyboard.change
      .observeForUI()
      .observeValues { [weak self] change in
        self?.handleKeyboardVisibilityDidChange(change)
    }
  }

  private func handleKeyboardVisibilityDidChange(_ change: Keyboard.Change) {
    UIView.animate(withDuration: change.duration,
                   delay: 0.0,
                   options: change.options,
                   animations: { [weak self] in
      self?.scrollView.contentInset.bottom = change.frame.height
    }, completion: nil)
  }

  @IBAction func currentPasswordTextDidChange(_ sender: UITextField) {
    guard let text = sender.text else {
      return
    }

    self.viewModel.inputs.currentPasswordFieldTextChanged(text: text)
  }

  @IBAction func currentPasswordDidEndEditing(_ sender: UITextField) {
    guard let currentPassword = sender.text else {
      return
    }

    self.viewModel.inputs.currentPasswordFieldDidEndEditing(currentPassword: currentPassword)
  }

  @IBAction func currentPasswordDidReturn(_ sender: UITextField) {
    guard let currentPassword = sender.text else {
      return
    }

    self.viewModel.inputs.currentPasswordFieldDidEndEditing(currentPassword: currentPassword)
  }

  @IBAction func newPasswordTextDidChange(_ sender: UITextField) {
    guard let text = sender.text else {
      return
    }

    self.viewModel.inputs.newPasswordFieldTextChanged(text: text)
  }

  @IBAction func newPasswordDidEndEditing(_ sender: UITextField) {
    guard let newPassword = sender.text else {
      return
    }

    self.viewModel.inputs.newPasswordFieldDidEndEditing(newPassword: newPassword)
  }

  @IBAction func newPasswordDidReturn(_ sender: UITextField) {
    guard let newPassword = sender.text else {
      return
    }

    self.viewModel.inputs.newPasswordFieldDidEndEditing(newPassword: newPassword)
  }

  @IBAction func confirmNewPasswordTextDidChange(_ sender: UITextField) {
    guard let text = sender.text else {
      return
    }

    self.viewModel.inputs.newPasswordConfirmationFieldTextChanged(text: text)
  }

  @IBAction func confirmNewPasswordDidEndEditing(_ sender: UITextField) {
    guard let newPasswordConfirmed = sender.text else {
      return
    }

    self.viewModel.inputs
      .newPasswordConfirmationFieldDidEndEditing(newPasswordConfirmed: newPasswordConfirmed)
  }

  @IBAction func confirmNewPasswordDidReturn(_ sender: UITextField) {
    guard let newPasswordConfirmed = sender.text else {
      return
    }

    self.viewModel.inputs
      .newPasswordConfirmationFieldDidEndEditing(newPasswordConfirmed: newPasswordConfirmed)
  }

  @IBAction func saveButtonTapped(_ sender: Any) {
    self.viewModel.inputs.saveButtonTapped()
  }
}
