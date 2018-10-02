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

  override func viewDidLoad() {
    super.viewDidLoad()

    self.viewModel
      .inputs.onePasswordIsAvailable(available: OnePasswordExtension.shared().isAppExtensionAvailable())
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

    self.currentPassword.rac.text = self.viewModel.outputs.currentPasswordPrefillValue
    self.onePasswordButton.rac.hidden = self.viewModel.outputs.onePasswordButtonIsHidden
    self.saveButton.rac.enabled = self.viewModel.outputs.saveButtonIsEnabled
    self.errorMessageLabel.rac.hidden = self.viewModel.outputs.errorLabelIsHidden
    self.errorMessageLabel.rac.text = self.viewModel.outputs.errorLabelMessage

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

    self.viewModel.outputs.onePasswordFindPasswordForURLString
      .observeValues { [weak self] urlString in
        self?.onePasswordFindPassword(forURLString: urlString)
    }

    self.viewModel.outputs.testPasswordInput
      .observeValues {
        print("CHANGE PASSWORD SUCCESS")
    }

    self.viewModel.outputs.changePasswordFailure
      .observeForControllerAction()
      .observeValues { [weak self] errorMessage in
        let alert = UIAlertController(title: "Error",
                                      message: errorMessage,
                                      preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)

        alert.addAction(okAction)

        self?.present(alert, animated: true, completion: nil)
    }

    Keyboard.change
      .observeForUI()
      .observeValues { [weak self] change in
        self?.handleKeyboardVisibilityDidChange(change)
    }
  }

  // MARK: Private Functions
  private func handleKeyboardVisibilityDidChange(_ change: Keyboard.Change) {
    UIView.animate(withDuration: change.duration,
                   delay: 0.0,
                   options: change.options,
                   animations: { [weak self] in
      self?.scrollView.contentInset.bottom = change.frame.height
    }, completion: nil)
  }

  private func onePasswordFindPassword(forURLString string: String) {
    OnePasswordExtension.shared()
      .findLogin(forURLString: string, for: self, sender: self.onePasswordButton) { result, _ in
        guard let result = result, let password =  result[AppExtensionPasswordKey] as? String else {
          return
        }

        self.viewModel.inputs.onePasswordFoundPassword(password: password)
    }
  }

  // MARK: Actions
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

    self.viewModel.inputs.currentPasswordFieldTextChanged(text: currentPassword)
  }

  @IBAction func currentPasswordDidReturn(_ sender: UITextField) {
    guard let currentPassword = sender.text else {
      return
    }

    self.viewModel.inputs.currentPasswordFieldDidReturn(currentPassword: currentPassword)
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

    self.viewModel.inputs.newPasswordFieldTextChanged(text: newPassword)
  }

  @IBAction func newPasswordDidReturn(_ sender: UITextField) {
    guard let newPassword = sender.text else {
      return
    }

    self.viewModel.inputs.newPasswordFieldDidReturn(newPassword: newPassword)
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
      .newPasswordConfirmationFieldTextChanged(text: newPasswordConfirmed)
  }

  @IBAction func confirmNewPasswordDidReturn(_ sender: UITextField) {
    guard let newPasswordConfirmed = sender.text else {
      return
    }

    self.viewModel.inputs
      .newPasswordConfirmationFieldDidReturn(newPasswordConfirmed: newPasswordConfirmed)
  }

  @IBAction func saveButtonTapped(_ sender: Any) {
    self.viewModel.inputs.saveButtonTapped()
  }

  @IBAction func onePasswordButtonTapped(_ sender: Any) {
    self.viewModel.inputs.onePasswordButtonTapped()
  }
}
