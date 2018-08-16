@testable import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit
import PlaygroundSupport
@testable import Kickstarter_Framework

// Set the user's backed project count stats.
let user = .template
  |> User.lens.stats.backedProjectsCount .~ 100
  |> User.lens.stats.createdProjectsCount .~ 2

// Set the device language and environment.
AppEnvironment.replaceCurrentEnvironment(
  apiService: MockService(
    oauthToken: OauthToken(token: "deadbeef"),
    fetchUserSelfResponse: user
    ),
  language: .en,
  locale: Locale(identifier: "en") as Locale,
  mainBundle: Bundle(for: RootViewModel.self)
)

// Instantiate the Settings view controller.
initialize()
let controller = Storyboard.Settings.instantiate(SettingsViewController.self)

// Set the device type and orientation.
let (parent, _) = playgroundControllers(device: .phone4_7inch, orientation: .portrait, child: controller)

// Render the screen.
let frame = parent.view.frame |> CGRect.lens.size.height .~ 1_800
PlaygroundPage.current.liveView = parent
parent.view.frame = frame
