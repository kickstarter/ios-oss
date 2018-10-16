import KsApi
import Library
import Prelude
import ReactiveSwift
import UIKit

internal final class ChangeEmailViewController: UIViewController {
  @IBOutlet fileprivate weak var currentEmailLabel: UILabel!
  @IBOutlet fileprivate weak var currentEmail: UILabel!
  @IBOutlet fileprivate weak var errorLabel: UILabel!
  @IBOutlet fileprivate weak var errorView: UIView!
  @IBOutlet fileprivate weak var newEmailLabel: UILabel!
  @IBOutlet fileprivate weak var newEmailTextField: UITextField!
  @IBOutlet fileprivate weak var onePasswordButton: UIButton!
  @IBOutlet fileprivate weak var passwordLabel: UILabel!
  @IBOutlet fileprivate weak var passwordTextField: UITextField!
  @IBOutlet fileprivate weak var resendVerificationEmailButton: UIButton!
  @IBOutlet fileprivate weak var resendVerificationStackView: UIStackView!
  @IBOutlet fileprivate weak var saveBarButton: UIBarButtonItem!
  @IBOutlet fileprivate weak var scrollView: UIScrollView!
  @IBOutlet fileprivate weak var resendVerificationEmailStackView: UIStackView!

  private let viewModel: ChangeEmailViewModelType = ChangeEmailViewModel()
  private var messageBannerView: MessageBannerViewController!

  internal static func instantiate() -> ChangeEmailViewController {
    return Storyboard.Settings.instantiate(ChangeEmailViewController.self)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    guard let messageBannerView = self.children.first as? MessageBannerViewController else {
      fatalError("Couldn't instantiate MessageBannerViewController")
    }

    self.messageBannerView = messageBannerView

    self.onePasswordButton.addTarget(self,
                                     action: #selector(self.onePasswordButtonTapped),
                                     for: .touchUpInside)

    self.viewModel.inputs.onePassword(
      isAvailable: OnePasswordExtension.shared().isAppExtensionAvailable()
    )

    self.passwordTextField.delegate = self
    self.newEmailTextField.delegate = self

    self.viewModel.inputs.viewDidLoad()
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> settingsViewControllerStyle
      |> UIViewController.lens.title %~ { _ in
        Strings.Change_email()
    }

    _ = onePasswordButton
      |> onePasswordButtonStyle

    _ = errorLabel
      |> settingsDescriptionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.Email_unverified() }

    _ = currentEmailLabel
      |> settingsTitleLabelStyle

    _ = currentEmail
      |> settingsDetailLabelStyle

    _ = newEmailLabel
      |> settingsTitleLabelStyle

    _ = newEmailTextField
      |> formFieldStyle
      |> UITextField.lens.returnKeyType .~ .next
      |> UITextField.lens.textAlignment .~ .right
      |> UITextField.lens.placeholder %~ { _ in
        Strings.login_placeholder_email()
    }

    _ = saveBarButton
      |> UIBarButtonItem.lens.isEnabled %~ { _ in
        false
    }

    _ = passwordLabel
      |> settingsTitleLabelStyle

    _ = passwordTextField
      |> passwordFieldStyle
      |> UITextField.lens.textAlignment .~ .right
      |> UITextField.lens.returnKeyType .~ .go

    _ = resendVerificationEmailButton
      |> UIButton.lens.titleLabel.font .~ .ksr_body()
      |> UIButton.lens.titleColor(for: .normal) .~ .ksr_text_green_700
      |> UIButton.lens.title(for: .normal) %~ { _ in Strings.Resend_verification_email() }
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.resendVerificationStackView.rac.hidden = self.viewModel.outputs.resendVerificationStackViewIsHidden
    self.saveBarButton.rac.enabled = self.viewModel.outputs.saveButtonIsEnabled
    self.currentEmail.rac.text = self.viewModel.outputs.emailText

    self.onePasswordButton.rac.hidden = self.viewModel.outputs.onePasswordButtonIsHidden

    self.passwordTextField.rac.text = self.viewModel.outputs.passwordText

    self.viewModel.outputs.onePasswordFindLoginForURLString
      .observeForControllerAction()
      .observeValues { [weak self] in self?.onePasswordFindLogin(forURLString: $0) }

    self.viewModel.outputs.didFailToChangeEmail
      .observeForUI()
      .observeValues { [weak self] error in
        self?.messageBannerView.showBanner(with: .error, message: error)
    }

    self.viewModel.outputs.didChangeEmail
      .observeForUI()
      .observeValues { [weak self] in
        self?.messageBannerView.showBanner(with: .success,
                                           message: Strings.Got_it_your_changes_have_been_saved())
    }

    self.viewModel.outputs.shouldSubmitForm
      .observeForUI()
      .observeValues { [weak self] in
        self?.viewModel.inputs.submitForm(newEmail: self?.newEmailTextField.text,
                                          password: self?.passwordTextField.text)
    }

    self.viewModel.outputs.passwordFieldBecomeFirstResponder
      .observeForUI()
      .observeValues { [weak self] in
        self?.passwordTextField.becomeFirstResponder()
    }

    self.viewModel.outputs.resetFields
      .observeForUI()
      .observeValues { [weak self] emptyString in
        self?.resetFields(string: emptyString)
    }

    self.viewModel.outputs.dismissKeyboard
      .observeForUI()
      .observeValues { [weak self] in
        self?.dismissKeyboard()
    }

    Keyboard.change
      .observeForUI()
      .observeValues { [weak self] change in
        self?.scrollView.handleKeyboardVisibilityDidChange(change)
    }
  }

  @IBAction func saveButtonTapped(_ sender: Any) {
    self.viewModel.inputs.submitForm(newEmail: self.newEmailTextField.text,
                                     password: self.passwordTextField.text)
  }

  @IBAction func onePasswordButtonTapped(_ sender: Any) {
    self.viewModel.inputs.onePasswordButtonTapped()
  }

  @IBAction func emailFieldDidEndEditing(_ sender: UITextField) {
    self.viewModel.inputs.emailFieldDidEndEditing(email: sender.text)
  }

  @IBAction func emailFieldTextDidChange(_ sender: UITextField) {
    self.viewModel.inputs.emailFieldTextDidChange(text: sender.text)
  }

  @IBAction func passwordFieldDidEndEditing(_ sender: UITextField) {
    self.viewModel.inputs.passwordFieldDidEndEditing(password: sender.text)
  }

  @IBAction func passwordFieldTextDidChange(_ sender: UITextField) {
    self.viewModel.inputs.passwordFieldTextDidChange(text: sender.text)
  }

  fileprivate func onePasswordFindLogin(forURLString string: String) {

    OnePasswordExtension.shared()
      .findLogin(forURLString: string, for: self, sender: self.onePasswordButton) { result, _ in
        guard let result = result else { return }

        self.viewModel.inputs.onePasswordFound(
          password: result[AppExtensionPasswordKey] as? String
        )
    }
  }

  private func dismissKeyboard() {
    self.passwordTextField.resignFirstResponder()
    self.newEmailTextField.resignFirstResponder()
  }

  private func resetFields(string: String) {
    _ = [self.passwordTextField, self.newEmailTextField]
      ||> UITextField.lens.text .~ string
    }
}

extension ChangeEmailViewController: UITextFieldDelegate {
  internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {

    self.viewModel.inputs.textFieldShouldReturn(with: textField.returnKeyType)
    return textField.resignFirstResponder()
  }
}
