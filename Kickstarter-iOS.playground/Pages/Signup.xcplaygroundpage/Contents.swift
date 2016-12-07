import Library
import XCPlayground
@testable import Kickstarter_Framework

// Instantiate the Signup view controller.
initialize()
let controller = Storyboard.Login.instantiate(SignupViewController.self)

// Set the device type and orientation.
let (parent, _) = playgroundControllers(device: .phone4inch, orientation: .portrait, child: controller)

// Set the device language.
AppEnvironment.replaceCurrentEnvironment(
  language: .en,
  locale: NSLocale(localeIdentifier: "en"),
  mainBundle: NSBundle.framework
)

// Render the screen.
let frame = parent.view.frame
XCPlaygroundPage.currentPage.liveView = parent
parent.view.frame = frame
