import KsApi
import Library
import Prelude
import UIKit

final class ChangePasswordViewController: UIViewController, MessageBannerViewControllerPresenting {
  @IBOutlet fileprivate var changePasswordLabel: UILabel!
  @IBOutlet fileprivate var confirmNewPasswordLabel: UILabel!
  @IBOutlet fileprivate var confirmNewPasswordTextField: UITextField!
  @IBOutlet fileprivate var currentPasswordLabel: UILabel!
  @IBOutlet fileprivate var currentPasswordTextField: UITextField!
  @IBOutlet fileprivate var validationErrorMessageLabel: UILabel!
  @IBOutlet fileprivate var newPasswordLabel: UILabel!
  @IBOutlet fileprivate var newPasswordTextField: UITextField!
  @IBOutlet fileprivate var scrollView: UIScrollView!
  @IBOutlet fileprivate var stackView: UIStackView!

  private var saveButtonView: LoadingBarButtonItemView!
  internal var messageBannerViewController: MessageBannerViewController?

  private let viewModel: ChangePasswordViewModelType = ChangePasswordViewModel()

  internal static func instantiate() -> ChangePasswordViewController {
    return Storyboard.Settings.instantiate(ChangePasswordViewController.self)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.messageBannerViewController = self.configureMessageBannerViewController(on: self)

    self.saveButtonView = LoadingBarButtonItemView.instantiate()
    self.saveButtonView.setTitle(title: Strings.Save())
    self.saveButtonView.addTarget(self, action: #selector(self.saveButtonTapped(_:)))

    let navigationBarButton = UIBarButtonItem(customView: self.saveButtonView)
    self.navigationItem.setRightBarButton(navigationBarButton, animated: false)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    self.viewModel.inputs.viewDidAppear()
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self.scrollView
      |> \.alwaysBounceVertical .~ true
      |> \.backgroundColor .~ .ksr_support_100

    _ = self.stackView
      |> \.layoutMargins .~ .init(topBottom: Styles.grid(1), leftRight: Styles.grid(2))

    _ = self
      |> settingsViewControllerStyle
      |> UIViewController.lens.title %~ { _ in
        Strings.Change_password()
      }

    _ = [self.currentPasswordLabel, self.newPasswordLabel, self.confirmNewPasswordLabel]
      ||> \.isAccessibilityElement .~ false

    _ = self.changePasswordLabel
      |> settingsDescriptionLabelStyle
      |> UILabel.lens.text %~ { _ in
        Strings.Well_ask_you_to_sign_back_into_the_Kickstarter_app_once_youve_changed_your_password()
      }

    _ = self.confirmNewPasswordLabel
      |> settingsTitleLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.Confirm_password() }

    _ = self.confirmNewPasswordTextField
      |> settingsNewPasswordFormFieldAutoFillStyle
      |> \.accessibilityLabel .~ self.confirmNewPasswordLabel.text
      |> UITextField.lens.returnKeyType .~ .done
      |> \.attributedPlaceholder %~ { _ in
        settingsAttributedPlaceholder(Strings.login_placeholder_password())
      }

    _ = self.currentPasswordLabel
      |> settingsTitleLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.Current_password() }

    _ = self.currentPasswordTextField
      |> settingsPasswordFormFieldAutoFillStyle
      |> \.accessibilityLabel .~ self.currentPasswordLabel.text
      |> \.attributedPlaceholder %~ { _ in
        settingsAttributedPlaceholder(Strings.login_placeholder_password())
      }

    _ = self.validationErrorMessageLabel
      |> settingsDescriptionLabelStyle

    _ = self.newPasswordLabel
      |> settingsTitleLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.New_password() }

    _ = self.newPasswordTextField
      |> settingsNewPasswordFormFieldAutoFillStyle
      |> \.accessibilityLabel .~ self.newPasswordLabel.text
      |> \.attributedPlaceholder %~ { _ in
        settingsAttributedPlaceholder(Strings.login_placeholder_password())
      }
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.validationErrorMessageLabel.rac.hidden = self.viewModel.outputs.validationErrorLabelIsHidden
    self.validationErrorMessageLabel.rac.text = self.viewModel.outputs.validationErrorLabelMessage

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
      }

    self.viewModel.outputs.currentPasswordBecomeFirstResponder
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.currentPasswordTextField.becomeFirstResponder()
      }

    self.viewModel.outputs.newPasswordBecomeFirstResponder
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.newPasswordTextField.becomeFirstResponder()
      }

    self.viewModel.outputs.confirmNewPasswordBecomeFirstResponder
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.confirmNewPasswordTextField.becomeFirstResponder()
      }

    self.viewModel.outputs.dismissKeyboard
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.dismissKeyboard()
      }

    self.viewModel.outputs.changePasswordFailure
      .observeForControllerAction()
      .observeValues { [weak self] errorMessage in
        self?.messageBannerViewController?.showBanner(with: .error, message: errorMessage)
      }

    self.viewModel.outputs.changePasswordSuccess
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.logoutAndDismiss()
      }

    self.viewModel.outputs.accessibilityFocusValidationErrorLabel
      .observeForUI()
      .observeValues { [weak self] _ in
        UIAccessibility.post(notification: .layoutChanged, argument: self?.validationErrorMessageLabel)
      }

    Keyboard.change
      .observeForUI()
      .observeValues { [weak self] change in
        self?.scrollView.handleKeyboardVisibilityDidChange(change)
      }
  }

  // MARK: - Functions

  private func logoutAndDismiss() {
    AppEnvironment.logout()
    PushNotificationDialog.resetAllContexts()

    NotificationCenter.default.post(.init(name: .ksr_sessionEnded))

    self.dismiss(animated: true, completion: nil)
  }

  private func dismissKeyboard() {
    [self.newPasswordTextField, self.confirmNewPasswordTextField, self.currentPasswordTextField]
      .forEach { $0?.resignFirstResponder() }
  }

  // MARK: - Actions

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

  @IBAction func saveButtonTapped(_: Any) {
    self.viewModel.inputs.saveButtonTapped()
  }
}
