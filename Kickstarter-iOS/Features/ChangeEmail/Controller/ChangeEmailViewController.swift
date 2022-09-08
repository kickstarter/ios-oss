import KsApi
import Library
import Prelude
import ReactiveSwift
import UIKit

internal final class ChangeEmailViewController: UIViewController, MessageBannerViewControllerPresenting {
  @IBOutlet fileprivate var currentEmailContainer: UIView!
  @IBOutlet fileprivate var currentEmailTitle: UILabel!
  @IBOutlet fileprivate var currentEmailValue: UILabel!
  @IBOutlet fileprivate var messageLabelView: UIView!
  @IBOutlet fileprivate var newEmailLabel: UILabel!
  @IBOutlet fileprivate var newEmailTextField: UITextField!
  @IBOutlet fileprivate var passwordLabel: UILabel!
  @IBOutlet fileprivate var passwordTextField: UITextField!
  @IBOutlet fileprivate var resendVerificationEmailButton: UIButton!
  @IBOutlet fileprivate var resendVerificationEmailView: UIView!
  @IBOutlet fileprivate var scrollView: UIScrollView!
  @IBOutlet fileprivate var unverifiedEmailLabel: UILabel!
  @IBOutlet fileprivate var warningMessageLabel: UILabel!

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
    self.saveButtonView.addTarget(self, action: #selector(ChangeEmailViewController.saveButtonTapped(_:)))
    let navigationBarButton = UIBarButtonItem(customView: self.saveButtonView)
    self.navigationItem.setRightBarButton(navigationBarButton, animated: false)

    self.passwordTextField.delegate = self
    self.newEmailTextField.delegate = self

    self.viewModel.inputs.viewDidLoad()
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self.scrollView
      |> \.alwaysBounceVertical .~ true
      |> \.backgroundColor .~ .ksr_support_100

    _ = self
      |> settingsViewControllerStyle
      |> \.title %~ { _ in
        Strings.Change_email()
      }

    _ = self.messageLabelView
      |> \.backgroundColor .~ .ksr_support_100

    _ = self.unverifiedEmailLabel
      |> settingsDescriptionLabelStyle
      |> \.text %~ { _ in Strings.Email_unverified() }

    _ = self.warningMessageLabel
      |> settingsDescriptionLabelStyle
      |> warningMessageLabelStyle

    _ = self.currentEmailContainer
      |> \.isAccessibilityElement .~ true
      |> \.accessibilityLabel .~ self.currentEmailTitle.text

    _ = self.currentEmailTitle
      |> settingsTitleLabelStyle
      |> currentEmailTitleStyle

    _ = self.currentEmailValue
      |> settingsDetailLabelStyle
      |> currentEmailValueStyle

    _ = self.newEmailLabel
      |> settingsTitleLabelStyle
      |> newEmailLabelStyle

    _ = self.newEmailTextField
      |> settingsEmailFieldAutoFillStyle
      |> newEmailTextFieldStyle
      |> \.accessibilityLabel .~ self.newEmailLabel.text

    _ = self.passwordLabel
      |> settingsTitleLabelStyle
      |> passwordLabelStyle

    _ = self.passwordTextField
      |> settingsPasswordFormFieldAutoFillStyle
      |> passwordTextFieldStyle
      |> \.accessibilityLabel .~ self.passwordLabel.text
      |> \.enablesReturnKeyAutomatically .~ true

    _ = self.resendVerificationEmailButton
      |> resendVerificationEmailButtonStyle
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.currentEmailContainer.rac.accessibilityValue = self.viewModel.outputs.emailText
    self.currentEmailValue.rac.text = self.viewModel.outputs.emailText
    self.resendVerificationEmailView.rac.hidden = self.viewModel.outputs.resendVerificationEmailViewIsHidden
    self.resendVerificationEmailButton.rac.title = self.viewModel.outputs.verificationEmailButtonTitle
    self.messageLabelView.rac.hidden = self.viewModel.outputs.messageLabelViewHidden
    self.unverifiedEmailLabel.rac.hidden = self.viewModel.outputs.unverifiedEmailLabelHidden
    self.warningMessageLabel.rac.hidden = self.viewModel.outputs.warningMessageLabelHidden

    self.viewModel.outputs.activityIndicatorShouldShow
      .observeForUI()
      .observeValues { [weak self] shouldShow in
        if shouldShow {
          self?.saveButtonView.startAnimating()
        } else {
          self?.saveButtonView.stopAnimating()
        }
      }

    self.viewModel.outputs.saveButtonIsEnabled
      .observeForUI()
      .observeValues { [weak self] isEnabled in
        self?.saveButtonView.setIsEnabled(isEnabled: isEnabled)
        self?.viewModel.inputs.saveButtonIsEnabled(isEnabled)
      }

    self.viewModel.outputs.didFailToChangeEmail
      .observeForUI()
      .observeValues { [weak self] error in
        self?.messageBannerViewController?.showBanner(with: .error, message: error)
      }

    self.viewModel.outputs.didChangeEmail
      .observeForUI()
      .observeValues { [weak self] in
        self?.messageBannerViewController?.showBanner(
          with: .success,
          message: Strings.Got_it_your_changes_have_been_saved()
        )
      }

    self.viewModel.outputs.didSendVerificationEmail
      .observeForUI()
      .observeValues { [weak self] in
        self?.messageBannerViewController?.showBanner(
          with: .success,
          message: Strings.Verification_email_sent()
        )
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

  @IBAction func saveButtonTapped(_: Any) {
    self.viewModel.inputs.saveButtonTapped()
  }

  @IBAction func resendVerificationEmailButtonTapped(_: Any) {
    self.viewModel.inputs.resendVerificationEmailButtonTapped()
  }

  @IBAction func emailFieldTextDidChange(_ sender: UITextField) {
    self.viewModel.inputs.emailFieldTextDidChange(text: sender.text)
  }

  @IBAction func passwordFieldTextDidChange(_ sender: UITextField) {
    self.viewModel.inputs.passwordFieldTextDidChange(text: sender.text)
  }

  private func dismissKeyboard() {
    self.passwordTextField.resignFirstResponder()
    self.newEmailTextField.resignFirstResponder()
  }

  private func resetFields(string: String) {
    _ = self.passwordTextField
      ?|> \.text %~ { _ in string }

    _ = self.newEmailTextField
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

// MARK: - Styles

private let warningMessageLabelStyle: LabelStyle = { (label: UILabel) in
  label
    |> \.textColor .~ UIColor.ksr_alert
    |> \.text %~ { _ in Strings.We_ve_been_unable_to_send_email() }
}

private let currentEmailTitleStyle: LabelStyle = { (label: UILabel) in
  label
    |> \.isAccessibilityElement .~ false
    |> \.text %~ { _ in Strings.Current_email() }
    |> \.textColor .~ UIColor.ksr_support_700
}

private let currentEmailValueStyle: LabelStyle = { (label: UILabel) in
  label
    |> \.isAccessibilityElement .~ false
    |> \.textColor .~ UIColor.ksr_support_700
}

private let newEmailLabelStyle: LabelStyle = { (label: UILabel) in
  label
    |> \.text %~ { _ in Strings.New_email() }
    |> \.isAccessibilityElement .~ false
}

private let newEmailTextFieldStyle: TextFieldStyle = { (textField: UITextField) in
  textField
    |> \.returnKeyType .~ UIReturnKeyType.next
    |> \.attributedPlaceholder %~ { _ in
      settingsAttributedPlaceholder(Strings.login_placeholder_email())
    }
}

private let passwordLabelStyle: LabelStyle = { (label: UILabel) in
  label
    |> \.text %~ { _ in Strings.Current_password() }
    |> \.isAccessibilityElement .~ false
}

private let passwordTextFieldStyle: TextFieldStyle = { (textField: UITextField) in
  textField
    |> \.returnKeyType .~ UIReturnKeyType.done
    |> \.attributedPlaceholder %~ { _ in
      settingsAttributedPlaceholder(Strings.login_placeholder_password())
    }
}

private let resendVerificationEmailButtonStyle: ButtonStyle = { (button: UIButton) in
  button
    |> UIButton.lens.titleLabel.font .~ .ksr_body()
    |> UIButton.lens.titleColor(for: .normal) .~ .ksr_create_700
}
