@testable import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit
import XCPlayground
@testable import Kickstarter_Framework

// Instantiate the Settings view controller.
initialize()
let controller = Storyboard.DebugPushNotifications.instantiate(DebugPushNotificationsViewController.self)

// Set the device type and orientation.
let (parent, _) = playgroundControllers(device: .phone4_7inch, orientation: .portrait, child: controller)

// Render the screen.
let frame = parent.view.frame |> CGRect.lens.size.height .~ 1_400
XCPlaygroundPage.currentPage.liveView = parent
parent.view.frame = frame
