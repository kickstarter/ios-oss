import Library
import PlaygroundSupport
@testable import Kickstarter_Framework

// Instantiate the Login Tout view controller.
initialize()
let controller = Storyboard.Login.instantiate(LoginToutViewController.self)

// Set the device type and orientation.
let (parent, _) = playgroundControllers(device: .phone4inch, orientation: .portrait, child: controller)

// Set the device language.
AppEnvironment.replaceCurrentEnvironment(
  language: .en,
  locale: Locale(identifier: "en"),
  mainBundle: Bundle.framework
)

// Render the screen.
let frame = parent.view.frame
PlaygroundPage.current.liveView = parent
parent.view.frame = frame
