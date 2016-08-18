@testable import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit
import XCPlayground
@testable import Kickstarter_Framework

initialize()
let controller = FacebookConfirmationViewController
  .configuredWith(facebookUserEmail: "", facebookAccessToken: "")

// Set the device type and orientation.
let (parent, _) = playgroundControllers(device: .phone4_7inch, orientation: .portrait, child: controller)

// Set the device language.
AppEnvironment.replaceCurrentEnvironment(
  language: .de,
  locale: NSLocale(localeIdentifier: "en"),
  mainBundle: NSBundle.framework
)

let frame = parent.view.frame
XCPlaygroundPage.currentPage.liveView = parent
parent.view.frame = frame
