import Library
import Prelude
import XCPlayground
@testable import Kickstarter_Framework
@testable import KsApi

let currentUser = .template
  |> User.lens.facebookConnected .~ true

let friendsResponse = .template
  |> FindFriendsEnvelope.lens.users .~ [User.brando]

// Set the device environment and language.
AppEnvironment.replaceCurrentEnvironment(
  apiService: MockService(fetchFriendsResponse: friendsResponse),
  currentUser: currentUser,
  language: .en,
  locale: NSLocale(localeIdentifier: "en"),
  mainBundle: NSBundle.framework
)

// Instantiate the Find Friends view controller.
initialize()
let controller = FindFriendsViewController.configuredWith(source: FriendsSource.settings)

// Set the device type and orientation.
let (parent, _) = playgroundControllers(device: .phone4inch, orientation: .portrait, child: controller)

// Render the screen.
let frame = parent.view.frame
XCPlaygroundPage.currentPage.liveView = parent
parent.view.frame = frame
