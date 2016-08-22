@testable import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit
import XCPlayground
@testable import Kickstarter_Framework

// Set the user's backed project count stats.
let user = .template
  |> User.lens.stats.backedProjectsCount .~ 100
  |> User.lens.stats.createdProjectsCount .~ 2

// Set the device language and environment.
AppEnvironment.replaceCurrentEnvironment(
  language: .en,
  locale: NSLocale(localeIdentifier: "en"),
  mainBundle: NSBundle.framework,
  apiService: MockService(
    fetchUserSelfResponse: user,
    oauthToken: OauthToken(token: "deadbeef")
  )
)

// Instantiate the Settings view controller.
initialize()
let controller = Storyboard.Settings.instantiate(SettingsViewController.self)

// Set the device type and orientation.
let (parent, _) = playgroundControllers(device: .phone4_7inch, orientation: .portrait, child: controller)

// Render the screen.
let frame = parent.view.frame |> CGRect.lens.size.height .~ 1_400
XCPlaygroundPage.currentPage.liveView = parent
parent.view.frame = frame
