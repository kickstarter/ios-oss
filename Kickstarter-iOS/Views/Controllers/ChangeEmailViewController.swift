import KsApi
import Library
import Prelude
import ReactiveSwift
import UIKit

internal final class ChangeEmailViewController: UIViewController {
  @IBOutlet fileprivate weak var currentEmailLabel: UILabel!
  @IBOutlet fileprivate weak var currentEmail: UILabel!
  @IBOutlet fileprivate weak var messageLabelView: UIView!
  @IBOutlet fileprivate weak var newEmailLabel: UILabel!
  @IBOutlet fileprivate weak var newEmailTextField: UITextField!
  @IBOutlet fileprivate weak var onePasswordButton: UIButton!
  @IBOutlet fileprivate weak var passwordLabel: UILabel!
  @IBOutlet fileprivate weak var passwordTextField: UITextField!
  @IBOutlet fileprivate weak var resendVerificationEmailButton: UIButton!
  @IBOutlet fileprivate weak var resendVerificationEmailView: UIView!
  @IBOutlet fileprivate weak var scrollView: UIScrollView!
  @IBOutlet fileprivate weak var unverifiedEmailLabel: UILabel!
  @IBOutlet fileprivate weak var warningMessageLabel: UILabel!

  private let viewModel: ChangeEmailViewModelType = ChangeEmailViewModel()
  private var messageBannerView: MessageBannerViewController!

  private weak var saveButtonView: LoadingBarButtonItemView!

  internal static func instantiate() -> ChangeEmailViewController {
    return Storyboard.Settings.instantiate(ChangeEmailViewController.self)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    guard let messageBannerView = self.children.first as? MessageBannerViewController else {
      fatalError("Couldn't instantiate MessageBannerViewController")
    }

    self.messageBannerView = messageBannerView

    self.saveButtonView = LoadingBarButtonItemView.instantiate()
    self.saveButtonView.setTitle(title: Strings.Save())
    self.saveButtonView.addTarget(self, action: #selector(saveButtonTapped(_:)))
    let navigationBarButton = UIBarButtonItem(customView: self.saveButtonView)
    self.navigationItem.setRightBarButton(navigationBarButton, animated: false)

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
      |> \.title %~ { _ in
        Strings.Change_email()
    }

    _ = self.onePasswordButton
      |> onePasswordButtonStyle

    _ = self.messageLabelView
      |> \.backgroundColor .~ .ksr_grey_200

    _ = self.unverifiedEmailLabel
      |> settingsDescriptionLabelStyle
      |> \.text %~ { _ in Strings.Email_unverified() }

    _ = self.warningMessageLabel
      |> settingsDescriptionLabelStyle
      |> \.textColor .~ .ksr_red_400
      |> \.text %~ { _ in Strings.We_ve_been_unable_to_send_email() }

    _ = self.currentEmailLabel
      |> settingsTitleLabelStyle
      |> \.text %~ { _ in Strings.Current_email() }

    _ = self.currentEmail
      |> settingsDetailLabelStyle

    _ = self.newEmailLabel
      |> settingsTitleLabelStyle
      |> \.text %~ { _ in Strings.New_email() }

    _ = self.newEmailTextField
      |> formFieldStyle
      |> \.returnKeyType .~ .next
      |> \.textAlignment .~ .right
      |> \.placeholder %~ { _ in
        Strings.login_placeholder_email()
    }

    _ = self.passwordLabel
      |> settingsTitleLabelStyle
      |> \.text %~ { _ in Strings.Current_password() }

    _ = self.passwordTextField
      |> passwordFieldStyle
      |> \.textAlignment .~ .right
      |> \.returnKeyType .~ .go

    _ = self.resendVerificationEmailButton
      |> UIButton.lens.titleLabel.font .~ .ksr_body()
      |> UIButton.lens.titleColor(for: .normal) .~ .ksr_text_green_700
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.currentEmail.rac.text = self.viewModel.outputs.emailText
    self.resendVerificationEmailView.rac.hidden = self.viewModel.outputs.resendVerificationEmailViewIsHidden
    self.resendVerificationEmailButton.rac.title = self.viewModel.outputs.verificationEmailButtonTitle
    self.onePasswordButton.rac.hidden = self.viewModel.outputs.onePasswordButtonIsHidden
    self.messageLabelView.rac.hidden = self.viewModel.outputs.messageLabelViewHidden
    self.unverifiedEmailLabel.rac.hidden = self.viewModel.outputs.unverifiedEmailLabelHidden
    self.warningMessageLabel.rac.hidden = self.viewModel.outputs.warningMessageLabelHidden
    self.passwordTextField.rac.text = self.viewModel.outputs.passwordText

    self.viewModel.outputs.activityIndicatorShouldShow
      .observeForUI()
      .observeValues { shouldShow in
        if shouldShow {
          self.saveButtonView.startAnimating()
        } else {
          self.saveButtonView.stopAnimating()
        }
    }

    self.viewModel.outputs.saveButtonIsEnabled
      .observeForUI()
      .observeValues { isEnabled in
        self.saveButtonView.setIsEnabled(isEnabled: isEnabled)
    }

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

    self.viewModel.outputs.didSendVerificationEmail
      .observeForUI()
      .observeValues { [weak self] in
        self?.messageBannerView.showBanner(with: .success,
                                           message: Strings.Verification_email_sent())
    }

    self.viewModel.outputs.didFailToSendVerificationEmail
      .observeForUI()
      .observeValues { [weak self] error in
        self?.messageBannerView.showBanner(with: .error, message: error)
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
    self.viewModel.inputs.saveButtonTapped(newEmail: self.newEmailTextField.text,
                                           password: self.passwordTextField.text)
  }

  @IBAction func resendVerificationEmailButtonTapped(_ sender: Any) {
    self.viewModel.inputs.resendVerificationEmailButtonTapped()
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
