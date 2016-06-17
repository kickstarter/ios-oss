import class MessageUI.MFMailComposeViewController
import class Foundation.NSBundle
import class UIKit.UIDevice
import enum Library.Strings

public extension MFMailComposeViewController {
  public static func support() -> MFMailComposeViewController {
    let mcvc = MFMailComposeViewController()

    mcvc.setSubject(
      Strings.support_email_subject()
    )

    mcvc.setToRecipients([Strings.support_email_to()])

    let body = Strings.support_email_body() +
      "\(NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"]) | " +
      "\(UIDevice.currentDevice().systemVersion) | " +
      "\(UIDevice.currentDevice().model)\n" // todo: should be full string as used in Koala
    mcvc.setMessageBody(body, isHTML: false)

    return mcvc
  }
}
