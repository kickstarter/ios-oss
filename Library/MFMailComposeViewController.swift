import class MessageUI.MFMailComposeViewController
import class Foundation.NSBundle
import class UIKit.UIDevice

public extension MFMailComposeViewController {
  public static func support() -> MFMailComposeViewController {
    let mcvc = MFMailComposeViewController()
    mcvc.setSubject(localizedString(key: "support.email.subject", defaultValue: "Hello Kickstarter App Support"))
    mcvc.setToRecipients([localizedString(key: "support.email.to", defaultValue: "app@kickstarter.com")])
    let body = localizedString(key: "support.email.body", defaultValue: "How can we help you? Please try to be as specific as possible.\n\n\n\n\n--------\n") +
    "\(NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"]) | " +
    "\(UIDevice.currentDevice().systemVersion) | " +
    "\(UIDevice.currentDevice().model)\n" // todo: should be full string as used in Koala
    mcvc.setMessageBody(body, isHTML: false)

    return mcvc
  }
}
