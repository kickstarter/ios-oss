import Library
import PlaygroundSupport
@testable import Kickstarter_Framework

// Instantiate the Signup view controller.
initialize()
let controller = Storyboard.Login.instantiate(SignupViewController.self)

// Set the device type and orientation.
let (parent, _) = playgroundControllers(device: .phone4inch, orientation: .portrait, child: controller)

// Set the device language.
AppEnvironment.replaceCurrentEnvironment(
  language: .en,
  locale: Locale(identifier: "en") as Locale,
  mainBundle: Bundle.framework
)

// Render the screen.
let frame = parent.view.frame
PlaygroundPage.current.liveView = parent
parent.view.frame = frame
