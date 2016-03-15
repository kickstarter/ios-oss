import class Foundation.NSError
import class UIKit.UIButton
import class UIKit.UIAlertController
import class UIKit.UIAlertAction
import class UIKit.UIBarButtonItem
import protocol UIKit.UINavigationControllerDelegate
import class MessageUI.MFMailComposeViewController
import protocol MessageUI.MFMailComposeViewControllerDelegate
import struct MessageUI.MFMailComposeResult
import func ReactiveCocoa.<~
import class Library.BorderButton
import class Library.MVVMViewController
import enum Library.HelpType
import func Library.localizedString
import enum Library.Color
import enum Library.LoginIntent
import class SafariServices.SFSafariViewController

internal final class LoginToutViewController: MVVMViewController, MFMailComposeViewControllerDelegate {
  @IBOutlet weak var loginButton: BorderButton!
  @IBOutlet weak var signupButton: BorderButton!
  @IBOutlet weak var helpButton: BorderButton!

  internal let viewModel: LoginToutViewModelType = LoginToutViewModel()
  internal var loginIntent: LoginIntent = .LoginTab

  override func viewDidLoad() {
    super.viewDidLoad()

    self.view.backgroundColor = Color.OffWhite.toUIColor()

    self.navigationItem.rightBarButtonItem = .help(self, selector: "helpButtonPressed")

    if (self.loginIntent != .LoginTab) {
      self.navigationItem.leftBarButtonItem = .close(self, selector: "closeButtonPressed")
    }
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    self.viewModel.inputs.loginIntent(self.loginIntent.trackingString())
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

  internal func showHelp(actions: [(title: String, data: HelpType)]) {
    let helpAlert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)

    // TODO: which do you like better? map+forEach or just forEach?
    actions
      .map { action in
        return UIAlertAction(title: action.title, style: .Default, handler: { [weak self] _ in
          self?.viewModel.inputs.helpTypeButtonPressed(action.data)
          })
      }
      .forEach(helpAlert.addAction)

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
      let svc = SFSafariViewController.help(helpType)
      self.presentViewController(svc, animated: true, completion: nil)
    }
  }

  internal func closeButtonPressed() {
    self.dismissViewControllerAnimated(true, completion: nil)
  }

  @objc internal func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }

  private func startLoginViewController() {
    let loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
    self.navigationController?.pushViewController(loginVC, animated: true)
  }

  private func startSignupViewController() {

  }
}
