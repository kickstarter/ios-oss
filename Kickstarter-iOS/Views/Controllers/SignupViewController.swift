import Library
import MessageUI
import Prelude
import Prelude_UIKit
import ReactiveCocoa
import ReactiveSwift
import UIKit

internal final class SignupViewController: UIViewController, MFMailComposeViewControllerDelegate {
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

    self.disclaimerButton.addTarget(self, action: #selector(disclaimerButtonPressed), for: .touchUpInside)
    let newsletterLabelTapGesture = UITapGestureRecognizer(target: self,
                                                           action: #selector(newsletterLabelTapped))
    self.newsletterLabel.addGestureRecognizer(newsletterLabelTapGesture)

    self.viewDidLoadProperty.value = ()
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

  fileprivate let environmentLoggedInProperty = MutableProperty(())
  fileprivate let viewDidLoadProperty = MutableProperty(())

  internal override func bindViewModel() {
    let (
      emailTextFieldBecomeFirstResponder,
      isSignupButtonEnabled,
      logIntoEnvironment,
      passwordTextFieldBecomeFirstResponder,
      postNotification,
      nameTextFieldBecomeFirstResponder,
      setWeeklyNewsletterState,
      showError
    ) = signupViewModel(
      emailChanged: self.emailTextField.reactive.continuousTextValues.skipNil(),
      emailTextFieldReturn: self.emailTextField.reactive.controlEvents(.editingDidEndOnExit).ignoreValues(),
      environmentLoggedIn: environmentLoggedInProperty.signal,
      nameChanged: self.nameTextField.reactive.continuousTextValues.skipNil(),
      nameTextFieldReturn: self.nameTextField.reactive.controlEvents(.editingDidEndOnExit).ignoreValues(),
      passwordChanged: self.passwordTextField.reactive.continuousTextValues.skipNil(),
      passwordTextFieldReturn: self.passwordTextField.reactive.controlEvents(.editingDidEndOnExit).ignoreValues(),
      signupButtonPressed: self.signupButton.reactive.controlEvents(.touchUpInside).ignoreValues(),
      viewDidLoad: viewDidLoadProperty.signal,
      weeklyNewsletterChanged: newsletterSwitch.reactive.isOnValues
    )

    self.emailTextField.reactive.becomeFirstResponder <~ emailTextFieldBecomeFirstResponder
    self.newsletterSwitch.reactive.isOn <~ setWeeklyNewsletterState
    self.passwordTextField.reactive.becomeFirstResponder <~ passwordTextFieldBecomeFirstResponder
    self.signupButton.reactive.isEnabled <~ isSignupButtonEnabled

    logIntoEnvironment
      .observeValues { [weak self] in
        AppEnvironment.login($0)
        self?.environmentLoggedInProperty.value = ()
      }

    postNotification
      .observeForUI()
      .observeValues(NotificationCenter.default.post)

    showError
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
