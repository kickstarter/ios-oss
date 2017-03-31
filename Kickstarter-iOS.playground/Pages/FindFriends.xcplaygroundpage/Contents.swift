import Library
import Prelude
import PlaygroundSupport
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
  locale: Locale(identifier: "en"),
  mainBundle: Bundle.framework
)

// Instantiate the Find Friends view controller.
initialize()
let controller = FindFriendsViewController.configuredWith(source: FriendsSource.settings)

// Set the device type and orientation.
let (parent, _) = playgroundControllers(device: .phone5_5inch, orientation: .portrait, child: controller)

// Render the screen.
let frame = parent.view.frame
PlaygroundPage.current.liveView = parent
parent.view.frame = frame
