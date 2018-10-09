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
  @IBOutlet fileprivate weak var messageBannerView: UIView!
  @IBOutlet fileprivate weak var messageBannerLabel: UILabel!
  @IBOutlet fileprivate weak var newEmailLabel: UILabel!
  @IBOutlet fileprivate weak var newEmailTextField: UITextField!
  @IBOutlet fileprivate weak var onePasswordButton: UIButton!
  @IBOutlet fileprivate weak var passwordLabel: UILabel!
  @IBOutlet fileprivate weak var passwordTextField: UITextField!
  @IBOutlet fileprivate weak var resendVerificationEmailView: UIView!
  @IBOutlet fileprivate weak var resendVerificationEmailButton: UIButton!
  @IBOutlet fileprivate weak var saveBarButton: UIBarButtonItem!
  @IBOutlet fileprivate weak var scrollView: UIScrollView!

  private let viewModel: ChangeEmailViewModelType = ChangeEmailViewModel()

  internal static func instantiate() -> ChangeEmailViewController {
    return Storyboard.Settings.instantiate(ChangeEmailViewController.self)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.onePasswordButton.addTarget(self,
                                     action: #selector(self.onePasswordButtonTapped),
                                     for: .touchUpInside)

    self.viewModel.inputs.onePassword(
      isAvailable: OnePasswordExtension.shared().isAppExtensionAvailable()
    )

    self.viewModel.inputs.viewDidLoad()
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.resendVerificationEmailView.rac.hidden = self.viewModel.outputs.resendVerificationEmailButtonIsHidden
    self.errorLabel.rac.hidden = self.viewModel.outputs.errorLabelIsHidden
    self.messageBannerView.rac.hidden = self.viewModel.outputs.messageBannerViewIsHidden
    self.saveBarButton.rac.enabled = self.viewModel.outputs.saveButtonIsEnabled

    self.currentEmail.rac.text = self.viewModel.outputs.emailText

    self.onePasswordButton.rac.hidden = self.viewModel.outputs.onePasswordButtonIsHidden

    self.passwordTextField.rac.text = self.viewModel.outputs.passwordText

    self.viewModel.outputs.onePasswordFindLoginForURLString
      .observeForControllerAction()
      .observeValues { [weak self] in self?.onePasswordFindLogin(forURLString: $0) }

    Keyboard.change
      .observeForUI()
      .observeValues { [weak self] change in
        self?.scrollView.handleKeyboardVisibilityDidChange(change)
    }
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

    _ = messageBannerView
      |> roundedStyle(cornerRadius: 4)

    _ = messageBannerLabel
      |> UILabel.lens.font .~ .ksr_subhead()
      |> UILabel.lens.text %~ { _ in Strings.Verification_email_sent() }

    _ = newEmailLabel
      |> settingsTitleLabelStyle

    _ = newEmailTextField
      |> formFieldStyle
      |> UITextField.lens.textAlignment .~ .right
      |> UITextField.lens.placeholder %~ { _ in
        Strings.login_placeholder_email()
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

  @IBAction func saveButtonTapped(_ sender: Any) {
    self.viewModel.inputs.saveButtonTapped()
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
}
