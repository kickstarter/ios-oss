import Library
import MessageUI
import Prelude
import Prelude_UIKit
import UIKit

internal final class SignupViewController: UIViewController, MFMailComposeViewControllerDelegate {
  fileprivate let viewModel: SignupViewModelType = SignupViewModel()
  fileprivate let helpViewModel = HelpViewModel()

  @IBOutlet fileprivate weak var scrollView: UIScrollView!
  @IBOutlet fileprivate weak var disclaimerButton: UIButton!
  @IBOutlet fileprivate weak var emailTextField: UITextField!
  @IBOutlet fileprivate weak var formBackgroundView: UIView!
  @IBOutlet fileprivate weak var nameTextField: UITextField!
  @IBOutlet fileprivate weak var newsletterLabel: UILabel!
  @IBOutlet fileprivate weak var newsletterSwitch: UISwitch!
  @IBOutlet fileprivate weak var passwordTextField: UITextField!
  @IBOutlet fileprivate weak var rootStackView: UIStackView!
  @IBOutlet fileprivate weak var signupButton: UIButton!

  internal static func instantiate() -> SignupViewController {
    let vc = Storyboard.Login.instantiate(SignupViewController.self)
    vc.helpViewModel.inputs.configureWith(helpContext: .signup)
    vc.helpViewModel.inputs.canSendEmail(MFMailComposeViewController.canSendMail())
    return vc
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.disclaimerButton.addTarget(self, action: #selector(disclaimerButtonPressed),
                                    for: .touchUpInside)

    self.nameTextField.addTarget(self,
                                 action: #selector(nameTextFieldReturn),
                                 for: .editingDidEndOnExit)

    self.nameTextField.addTarget(self,
                                 action: #selector(nameTextFieldChanged(_:)),
                                 for: [.editingDidEndOnExit, .editingChanged])

    self.emailTextField.addTarget(self,
                                  action: #selector(emailTextFieldReturn),
                                  for: .editingDidEndOnExit)

    self.emailTextField.addTarget(self,
                                  action: #selector(emailTextFieldChanged(_:)),
                                  for: [.editingDidEndOnExit, .editingChanged])

    self.passwordTextField.addTarget(self,
                                     action: #selector(passwordTextFieldReturn),
                                     for: .editingDidEndOnExit)

    self.passwordTextField.addTarget(self,
                                     action: #selector(passwordTextFieldChanged(_:)),
                                     for: [.editingChanged])

    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(newsletterLabelTapped))

    self.newsletterLabel.addGestureRecognizer(tapGestureRecognizer)

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> signupControllerStyle

    _ = self.disclaimerButton
      |> disclaimerButtonStyle

    _ = self.nameTextField
      |> UITextField.lens.returnKeyType .~ .next
      |> UITextField.lens.placeholder %~ { _ in Strings.Name() }

    _ = self.emailTextField
      |> emailFieldStyle
      |> UITextField.lens.returnKeyType .~ .next

    _ = self.formBackgroundView
      |> cardStyle()

    _ = self.newsletterLabel
      |> newsletterLabelStyle

    _ = self.passwordTextField
      |> passwordFieldStyle
      |> UITextField.lens.returnKeyType .~ .go

    _ = self.rootStackView
      |> loginRootStackViewStyle

    _ = self.signupButton
      |> signupButtonStyle
  }

  internal override func bindViewModel() {
    self.emailTextField.rac.becomeFirstResponder = self.viewModel.outputs.emailTextFieldBecomeFirstResponder
    self.newsletterSwitch.rac.on = self.viewModel.outputs.setWeeklyNewsletterState
    self.passwordTextField.rac.becomeFirstResponder =
      self.viewModel.outputs.passwordTextFieldBecomeFirstResponder
    self.signupButton.rac.enabled = self.viewModel.outputs.isSignupButtonEnabled

    self.viewModel.outputs.logIntoEnvironment
      .observeValues { [weak self] in
        AppEnvironment.login($0)
        self?.viewModel.inputs.environmentLoggedIn()
      }

    self.viewModel.outputs.postNotification
      .observeForUI()
      .observeValues(NotificationCenter.default.post)

    self.viewModel.outputs.showError
      .observeForControllerAction()
      .observeValues { [weak self] message in
        self?.present(
          UIAlertController.alert(nil, message: message),
          animated: true, completion: nil
        )
    }

    self.helpViewModel.outputs.showHelpSheet
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.showHelpSheet(helpTypes: $0)
    }

    self.helpViewModel.outputs.showMailCompose
      .observeForControllerAction()
      .observeValues { [weak self] in
        guard let _self = self else { return }
        let controller = MFMailComposeViewController.support()
        controller.mailComposeDelegate = _self
        _self.present(controller, animated: true, completion: nil)
    }

    self.helpViewModel.outputs.showNoEmailError
      .observeForControllerAction()
      .observeValues { [weak self] alert in
        self?.present(alert, animated: true, completion: nil)
    }

    self.helpViewModel.outputs.showWebHelp
      .observeForControllerAction()
      .observeValues { [weak self] helpType in
        self?.goToHelpType(helpType)
    }

    Keyboard.change.observeForUI()
      .observeValues { [weak self] in self?.animateTextViewConstraint($0) }
  }

  @objc internal func emailTextFieldChanged(_ textField: UITextField) {
    self.viewModel.inputs.emailChanged(textField.text ?? "")
  }

  @objc internal func emailTextFieldReturn(_ textField: UITextField) {
    self.viewModel.inputs.emailTextFieldReturn()
  }

  @objc internal func nameTextFieldChanged(_ textField: UITextField) {
    self.viewModel.inputs.nameChanged(textField.text ?? "")
  }

  @objc internal func nameTextFieldReturn(_ textField: UITextField) {
    self.viewModel.inputs.nameTextFieldReturn()
  }

  @objc internal func passwordTextFieldChanged(_ textField: UITextField) {
    self.viewModel.inputs.passwordChanged(textField.text ?? "")
  }

  @objc internal func passwordTextFieldReturn(_ textField: UITextField) {
    self.viewModel.inputs.passwordTextFieldReturn()
  }

  @IBAction internal func weeklyNewsletterChanged(_ newsletterSwitch: UISwitch) {
    self.viewModel.inputs.weeklyNewsletterChanged(newsletterSwitch.isOn)
  }

  @IBAction internal func signupButtonPressed() {
    self.viewModel.inputs.signupButtonPressed()
  }

  @objc fileprivate func disclaimerButtonPressed() {
    self.helpViewModel.inputs.showHelpSheetButtonTapped()
  }

  @objc fileprivate func newsletterLabelTapped() {
    self.helpViewModel.inputs.showHelpSheetButtonTapped()
  }

  @objc internal func mailComposeController(_ controller: MFMailComposeViewController,
                                            didFinishWith result: MFMailComposeResult,
                                            error: Error?) {
    self.helpViewModel.inputs.mailComposeCompletion(result: result)
    self.dismiss(animated: true, completion: nil)
  }

  fileprivate func animateTextViewConstraint(_ change: Keyboard.Change) {
    UIView.animate(withDuration: change.duration, delay: 0.0, options: change.options, animations: {
      self.scrollView.contentInset.bottom = change.frame.height
      }, completion: nil)
  }

  fileprivate func goToHelpType(_ helpType: HelpType) {
    let vc = HelpWebViewController.configuredWith(helpType: helpType)
    self.navigationController?.pushViewController(vc, animated: true)
  }

  fileprivate func showHelpSheet(helpTypes: [HelpType]) {
    let helpSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

    helpTypes.forEach { helpType in
      helpSheet.addAction(
        UIAlertAction(title: helpType.title, style: .default) { [weak helpVM = self.helpViewModel] _ in
          helpVM?.inputs.helpTypeButtonTapped(helpType)
        }
      )
    }

    helpSheet.addAction(UIAlertAction(title: Strings.login_tout_help_sheet_cancel(),
      style: .cancel,
      handler: { [weak helpVM = self.helpViewModel] _ in
        helpVM?.inputs.cancelHelpSheetButtonTapped()
      }))

    //iPad provision
    helpSheet.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem

    self.present(helpSheet, animated: true, completion: nil)
  }
}
