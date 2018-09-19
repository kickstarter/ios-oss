import Foundation
import Library
import Prelude

enum ChangeEmailCellType {
  case currentEmail
  case resendVerificationEmail
  case newEmail
  case password
}

final class ChangeEmailViewController: UIViewController {
  @IBOutlet fileprivate weak var currentEmailLabel: UILabel!
  @IBOutlet fileprivate weak var currentEmail: UILabel!
  @IBOutlet fileprivate weak var errorLabel: UILabel!
  @IBOutlet fileprivate weak var errorView: UIView!
  @IBOutlet fileprivate weak var messageBannerView: UIView!
  @IBOutlet fileprivate weak var messageBannerLabel: UILabel!
  @IBOutlet fileprivate weak var newEmailLabel: UILabel!
  @IBOutlet fileprivate weak var newEmail: UITextField!
  @IBOutlet fileprivate weak var onePasswordButton: UIButton!
  @IBOutlet fileprivate weak var passwordLabel: UILabel!
  @IBOutlet fileprivate weak var password: UITextField!
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

    self.viewModel.inputs.viewDidLoad()
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.resendVerificationEmailView.rac.hidden = self.viewModel.outputs.resendVerificationEmailButtonIsHidden
    self.errorLabel.rac.hidden = self.viewModel.outputs.errorLabelIsHidden
    self.messageBannerView.rac.hidden = self.viewModel.outputs.messageBannerViewIsHidden
    self.saveBarButton.rac.enabled = self.viewModel.outputs.saveButtonIsEnabled
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
      |> UILabel.lens.text .~ "The email address is unverified."

    _ = currentEmailLabel
      |> settingsTitleLabelStyle

    _ = currentEmail
      |> settingsDetailLabelStyle

    _ = messageBannerView
      |> roundedStyle(cornerRadius: 4)

    _ = messageBannerLabel
      |> UILabel.lens.font .~ .ksr_subhead()
      |> UILabel.lens.text .~ "We've sent you a verification email. Click the link in it and your address will be verified."

    _ = newEmailLabel
      |> settingsTitleLabelStyle

    _ = newEmail
      |> formFieldStyle
      |> UITextField.lens.textAlignment .~ .right
      |> UITextField.lens.placeholder %~ { _ in
        Strings.login_placeholder_email()
    }

    _ = passwordLabel
      |> settingsTitleLabelStyle

    _ = password
      |> passwordFieldStyle
      |> UITextField.lens.textAlignment .~ .right
      |> UITextField.lens.returnKeyType .~ .go

    _ = resendVerificationEmailButton
      |> UIButton.lens.titleLabel.font .~ .ksr_body()
      |> UIButton.lens.titleColor(for: .normal) .~ .ksr_text_green_700
      |> UIButton.lens.title(for: .normal) .~ "Re-send verification email"
  }


  @IBAction func saveButtonTapped(_ sender: Any) {
    self.viewModel.inputs.saveButtonTapped()
  }

  @IBAction func onePasswordButtonTapped(_ sender: Any) {
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
}
