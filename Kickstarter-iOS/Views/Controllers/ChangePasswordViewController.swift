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

  internal static func instantiate() -> ChangePasswordViewController {
    return Storyboard.Settings.instantiate(ChangePasswordViewController.self)
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
}
