import Foundation
import Library
import MessageUI
import UIKit

internal extension MFMailComposeViewController {
  internal static func support() -> MFMailComposeViewController {
    let mcvc = MFMailComposeViewController()

    mcvc.setSubject(
      Strings.support_email_subject()
    )

    mcvc.setToRecipients([Strings.support_email_to()])

    let body = Strings.support_email_body() +
      "\(NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"]) | " +
      "\(UIDevice.currentDevice().systemVersion) | " +
      "\(UIDevice.currentDevice().model)\n" // todo: should be full deviceModel as used in Koala
    mcvc.setMessageBody(body, isHTML: false)

    return mcvc
  }
}
