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

  let viewModel: LoginToutViewModelType = LoginToutViewModel()
  internal var loginIntent: LoginIntent = .LoginTab

  override func viewDidLoad() {
    super.viewDidLoad()

    self.view.backgroundColor = Color.OffWhite.toUIColor()

    let helpButton = UIBarButtonItem.help(self, selector: "showHelp")
    self.navigationItem.rightBarButtonItem? = helpButton

    if (self.loginIntent != .LoginTab) {
      let closeButton = UIBarButtonItem.close(self, selector: "closeButtonPressed")
      self.navigationItem.leftBarButtonItem? = closeButton
    }
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    self.viewModel.inputs.loginIntent(self.loginIntent.trackingString())
  }

  override func bindViewModel() {
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
  }

  func startLoginViewController() {
    let loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
    self.navigationController?.pushViewController(loginVC, animated: true)
  }

  func startSignupViewController() {

  }

  @IBAction
  internal func loginButtonPressed(sender: UIButton) {
    self.viewModel.inputs.loginButtonPressed()
  }

  @IBAction func helpButtonPressed(sender: UIButton) {
    showHelp()
  }

  internal func showHelp() {
    let helpAlert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
    HelpType.allValues.forEach { h in
      helpAlert.addAction(UIAlertAction(title: h.title(),
        style: .Default,
        handler: { [weak self] (UIAlertAction) -> Void in
          switch h {
          case .Contact:
            let mcvc = MFMailComposeViewController.support()
            if let sself = self {
            mcvc.mailComposeDelegate = sself
            }
            self?.presentViewController(mcvc, animated: true, completion: nil)
          default:
            let svc = SFSafariViewController.help(h)
            self?.presentViewController(svc, animated: true, completion: nil)
          }
        }))
    }
    helpAlert.addAction(UIAlertAction(title: localizedString(key: "login_tout.help_sheet.cancel",
      defaultValue: "Cancel"),
      style: .Cancel,
      handler: nil))

    self.presentViewController(helpAlert, animated: true, completion: nil)
  }

  internal func closeButtonPressed() {
    self.dismissViewControllerAnimated(true, completion: nil)
  }

  @objc internal func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
}
