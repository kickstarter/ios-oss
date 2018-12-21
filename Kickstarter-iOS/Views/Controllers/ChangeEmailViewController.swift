import KsApi
import Library
import Prelude
import ReactiveSwift
import UIKit

internal final class ChangeEmailViewController: UIViewController, MessageBannerViewControllerPresenting {
  @IBOutlet fileprivate weak var currentEmailContainer: UIView!
  @IBOutlet fileprivate weak var currentEmailTitle: UILabel!
  @IBOutlet fileprivate weak var currentEmailValue: UILabel!
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
  internal var messageBannerViewController: MessageBannerViewController?

  private weak var saveButtonView: LoadingBarButtonItemView!

  internal static func instantiate() -> ChangeEmailViewController {
    return Storyboard.Settings.instantiate(ChangeEmailViewController.self)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.messageBannerViewController = self.configureMessageBannerViewController(on: self)

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

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    self.viewModel.inputs.viewDidAppear()
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self.scrollView
      |> \.alwaysBounceVertical .~ true

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

    _ = self.currentEmailContainer
      |> \.isAccessibilityElement .~ true
      |> \.accessibilityLabel %~ { _ in
        guard let emailTitle = self.currentEmailTitle.text else { return nil }
        return emailTitle
    }

    _ = self.currentEmailTitle
      |> settingsTitleLabelStyle
      |> \.isAccessibilityElement .~ false
      |> \.text %~ { _ in Strings.Current_email() }
      |> \.textColor .~ .ksr_text_dark_grey_400

    _ = self.currentEmailValue
      |> settingsDetailLabelStyle
      |> \.isAccessibilityElement .~ false
      |> \.textColor .~ .ksr_text_dark_grey_400

    _ = self.newEmailLabel
      |> settingsTitleLabelStyle
      |> \.text %~ { _ in Strings.New_email() }

    _ = self.newEmailTextField
      |> settingsEmailFieldAutoFillStyle
      |> \.returnKeyType .~ .next
      |> \.attributedPlaceholder %~ { _ in
        settingsAttributedPlaceholder(Strings.login_placeholder_email())
    }

    _ = self.passwordLabel
      |> settingsTitleLabelStyle
      |> \.text %~ { _ in Strings.Current_password() }

    _ = self.passwordTextField
      |> settingsPasswordFormFieldAutoFillStyle
      |> \.returnKeyType .~ .done
      |> \.attributedPlaceholder %~ { _ in
        settingsAttributedPlaceholder(Strings.login_placeholder_password())
    }

    _ = self.resendVerificationEmailButton
      |> UIButton.lens.titleLabel.font .~ .ksr_body()
      |> UIButton.lens.titleColor(for: .normal) .~ .ksr_text_green_700
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.currentEmailContainer.rac.accessibilityValue = self.viewModel.outputs.emailText
    self.currentEmailValue.rac.text = self.viewModel.outputs.emailText
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
        self?.messageBannerViewController?.showBanner(with: .error, message: error)
    }

    self.viewModel.outputs.didChangeEmail
      .observeForUI()
      .observeValues { [weak self] in
        self?.messageBannerViewController?.showBanner(with: .success,
                                           message: Strings.Got_it_your_changes_have_been_saved())
    }

    self.viewModel.outputs.didSendVerificationEmail
      .observeForUI()
      .observeValues { [weak self] in
        self?.messageBannerViewController?.showBanner(with: .success,
                                           message: Strings.Verification_email_sent())
    }

    self.viewModel.outputs.didFailToSendVerificationEmail
      .observeForUI()
      .observeValues { [weak self] error in
        self?.messageBannerViewController?.showBanner(with: .error, message: error)
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

    self.viewModel.outputs.textFieldsAreEnabled
      .observeForUI()
      .observeValues { [weak self] isEnabled in
        self?.enableTextFields(isEnabled)
    }

    Keyboard.change
      .observeForUI()
      .observeValues { [weak self] change in
        self?.scrollView.handleKeyboardVisibilityDidChange(change)
    }
  }

  @IBAction func saveButtonTapped(_ sender: Any) {
    self.viewModel.inputs.saveButtonTapped()
  }

  @IBAction func resendVerificationEmailButtonTapped(_ sender: Any) {
    self.viewModel.inputs.resendVerificationEmailButtonTapped()
  }

  @IBAction func onePasswordButtonTapped(_ sender: Any) {
    self.viewModel.inputs.onePasswordButtonTapped()
  }

  @IBAction func emailFieldTextDidChange(_ sender: UITextField) {
    self.viewModel.inputs.emailFieldTextDidChange(text: sender.text)
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
    _ = self.passwordTextField
      ?|> \.text %~ { _ in string }

    _ =  self.newEmailTextField
      ?|> \.text %~ { _ in string }
    }

  private func enableTextFields(_ isEnabled: Bool) {
    _ = [self.newEmailTextField, self.passwordTextField]
      ||> \.isUserInteractionEnabled .~ isEnabled
  }
}

extension ChangeEmailViewController: UITextFieldDelegate {
  internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {

    self.viewModel.inputs.textFieldShouldReturn(with: textField.returnKeyType)
    return textField.resignFirstResponder()
  }
}
