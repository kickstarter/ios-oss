import ReactiveCocoa
import class Foundation.NSError
import class UIKit.UIButton
import class UIKit.UIAlertController
import class UIKit.UIAlertAction
import class UIKit.UIBarButtonItem
import protocol UIKit.UINavigationControllerDelegate
import class MessageUI.MFMailComposeViewController
import protocol MessageUI.MFMailComposeViewControllerDelegate
import struct MessageUI.MFMailComposeResult
import class Library.BorderButton
import class Library.MVVMViewController
import func Library.localizedString
import enum Library.Color
import class SafariServices.SFSafariViewController
import struct KsApi.ServerConfig
import Prelude

internal final class LoginToutViewController: MVVMViewController, MFMailComposeViewControllerDelegate {
  @IBOutlet internal weak var loginButton: BorderButton!
  @IBOutlet internal weak var signupButton: BorderButton!
  @IBOutlet internal weak var helpButton: BorderButton!

  internal let viewModel: LoginToutViewModelType = LoginToutViewModel()
  internal var loginIntent: LoginIntent = .LoginTab

  override func viewDidLoad() {
    super.viewDidLoad()

    self.viewModel.inputs.loginIntent(self.loginIntent)

    if let _ = self.presentingViewController {
      self.navigationItem.leftBarButtonItem = .close(
        self,
        selector: #selector(LoginToutViewController.closeButtonPressed)
      )
    }
    self.navigationItem.rightBarButtonItem = .help(
      self,
      selector: #selector(LoginToutViewController.helpButtonPressed)
    )

    self.view.backgroundColor = Color.OffWhite.toUIColor()
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    self.viewModel.inputs.viewDidAppear()
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.startLogin
      .observeForUI()
      .observeNext { [weak self] _ in
        self?.startLoginViewController()
    }
    self.viewModel.outputs.startSignup
      .observeForUI()
      .observeNext { [weak self] _ in
        self?.startSignupViewController()
    }

    self.viewModel.outputs.showHelpActionSheet
      .observeForUI()
      .observeNext { [weak self] actions in
        self?.showHelp(actions)
    }

    self.viewModel.outputs.showHelp
      .observeForUI()
      .observeNext { [weak self] helpType in
        self?.showHelpType(helpType)
    }
  }

  @IBAction
  internal func loginButtonPressed(sender: UIButton) {
    self.viewModel.inputs.loginButtonPressed()
  }

  @IBAction func helpButtonPressed() {
    self.viewModel.inputs.helpButtonPressed()
  }

  internal func showHelp(helpTypes: [HelpType]) {
    let helpAlert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)

    helpTypes.forEach { helpType in
      helpAlert.addAction(UIAlertAction(title: helpType.title, style: .Default, handler: { [weak self] _ in
        self?.viewModel.inputs.helpTypeButtonPressed(helpType)
      }))
    }

    helpAlert.addAction(UIAlertAction(title: localizedString(key: "login_tout.help_sheet.cancel",
      defaultValue: "Cancel"),
      style: .Cancel,
      handler: nil)
    )

    self.presentViewController(helpAlert, animated: true, completion: nil)
  }

  private func showHelpType(helpType: HelpType) {
    switch helpType {
    case .Contact:
      let mcvc = MFMailComposeViewController.support()
      mcvc.mailComposeDelegate = self
      self.presentViewController(mcvc, animated: true, completion: nil)
    default:
      let svc = SFSafariViewController.help(helpType, baseURL: ServerConfig.production.webBaseUrl)
      self.presentViewController(svc, animated: true, completion: nil)
    }
  }

  internal func closeButtonPressed() {
    self.dismissViewControllerAnimated(true, completion: nil)
  }

  @objc internal func mailComposeController(controller: MFMailComposeViewController,
                                            didFinishWithResult result: MFMailComposeResult,
                                                                error: NSError?) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }

  private func startLoginViewController() {
    guard let loginVC = self.storyboard?
      .instantiateViewControllerWithIdentifier("LoginViewController") as? LoginViewController else {
        fatalError("Couldn’t instantiate LoginViewController.")
    }

    self.navigationController?.pushViewController(loginVC, animated: true)
  }

  private func startSignupViewController() {
  }
}
