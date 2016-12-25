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

    let app: AnyObject = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as AnyObject? ?? "" as AnyObject
    let os = UIDevice.current.systemVersion
    let user = (AppEnvironment.current.currentUser?.id).flatMap(String.init) ?? "Logged out"

    let body = "\(Strings.support_email_body())\n\(user) | \(app) | \(os) | \(deviceModel())\n"
    mcvc.setMessageBody(body, isHTML: false)

    return mcvc
  }
}

private func deviceModel() -> String {
  var size: Int = 0
  sysctlbyname("hw.machine", nil, &size, nil, 0)
  var machine = [CChar](repeating: 0, count: Int(size))
  sysctlbyname("hw.machine", &machine, &size, nil, 0)
  return String(cString: machine)
}
