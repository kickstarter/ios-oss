import Foundation
import KsApi
import Library
import Prelude

final class ChangePasswordViewController: UIViewController, MessageBannerViewControllerPresenting {
  @IBOutlet fileprivate weak var changePasswordLabel: UILabel!
  @IBOutlet fileprivate weak var confirmNewPasswordLabel: UILabel!
  @IBOutlet fileprivate weak var confirmNewPasswordTextField: UITextField!
  @IBOutlet fileprivate weak var currentPasswordLabel: UILabel!
  @IBOutlet fileprivate weak var currentPasswordTextField: UITextField!
  @IBOutlet fileprivate weak var validationErrorMessageLabel: UILabel!
  @IBOutlet fileprivate weak var newPasswordLabel: UILabel!
  @IBOutlet fileprivate weak var newPasswordTextField: UITextField!
  @IBOutlet fileprivate weak var onePasswordButton: UIButton!
  @IBOutlet fileprivate weak var scrollView: UIScrollView!

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
    self.saveButtonView.addTarget(self, action: #selector(saveButtonTapped(_:)))

    let navigationBarButton = UIBarButtonItem(customView: self.saveButtonView)
    self.navigationItem.setRightBarButton(navigationBarButton, animated: false)

    self.viewModel.inputs.onePassword(
      isAvailable: OnePasswordExtension.shared().isAppExtensionAvailable()
    )
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
      |> UIViewController.lens.title %~ { _ in
        Strings.Change_password()
    }

    _ = [self.currentPasswordLabel, self.newPasswordLabel, self.confirmNewPasswordLabel]
      ||> \.isAccessibilityElement .~ false

    _ = changePasswordLabel
      |> settingsDescriptionLabelStyle
      |> UILabel.lens.text %~ { _ in
        Strings.Well_ask_you_to_sign_back_into_the_Kickstarter_app_once_youve_changed_your_password()
    }

    _ = onePasswordButton
      |> onePasswordButtonStyle

    _ = confirmNewPasswordLabel
      |> settingsTitleLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.Confirm_password() }

    _ = confirmNewPasswordTextField
      |> settingsNewPasswordFormFieldAutoFillStyle
      |> \.accessibilityLabel %~ { _ in self.confirmNewPasswordLabel.text }
      |> UITextField.lens.returnKeyType .~ .done
      |> \.attributedPlaceholder %~ { _ in
        settingsAttributedPlaceholder(Strings.login_placeholder_password())
    }

    _ = currentPasswordLabel
      |> settingsTitleLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.Current_password() }

    _ = currentPasswordTextField
      |> settingsPasswordFormFieldAutoFillStyle
      |> \.accessibilityLabel %~ { _ in self.currentPasswordLabel.text }
      |> \.attributedPlaceholder %~ { _ in
        settingsAttributedPlaceholder(Strings.login_placeholder_password())
    }

    _ = validationErrorMessageLabel
      |> settingsDescriptionLabelStyle

    _ = newPasswordLabel
      |> settingsTitleLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.New_password() }

    _ = newPasswordTextField
      |> settingsNewPasswordFormFieldAutoFillStyle
      |> \.accessibilityLabel %~ { _ in self.newPasswordLabel.text }
      |> \.attributedPlaceholder %~ { _ in
        settingsAttributedPlaceholder(Strings.login_placeholder_password())
    }
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.currentPasswordTextField.rac.text = self.viewModel.outputs.currentPasswordPrefillValue
    self.onePasswordButton.rac.hidden = self.viewModel.outputs.onePasswordButtonIsHidden
    self.validationErrorMessageLabel.rac.hidden = self.viewModel.outputs.validationErrorLabelIsHidden
    self.validationErrorMessageLabel.rac.text = self.viewModel.outputs.validationErrorLabelMessage

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
      .observeValues { [weak self] (isEnabled) in
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
        self?.confirmNewPasswordTextField.resignFirstResponder()
    }

    self.viewModel.outputs.onePasswordFindPasswordForURLString
      .observeValues { [weak self] urlString in
        self?.onePasswordFindPassword(forURLString: urlString)
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

    Keyboard.change
      .observeForUI()
      .observeValues { [weak self] change in
        self?.scrollView.handleKeyboardVisibilityDidChange(change)
    }
  }

  // MARK: Private Functions
  private func logoutAndDismiss() {
    AppEnvironment.logout()
    PushNotificationDialog.resetAllContexts()

    NotificationCenter.default.post(.init(name: .ksr_sessionEnded))

    self.dismiss(animated: true, completion: nil)
  }

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
