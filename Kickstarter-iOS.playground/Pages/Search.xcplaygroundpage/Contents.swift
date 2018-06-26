@testable import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit
import PlaygroundSupport
@testable import Kickstarter_Framework

AppEnvironment.replaceCurrentEnvironment(
  apiService: MockService(
    fetchDiscoveryResponse: .template |> DiscoveryEnvelope.lens.projects .~ [
      .todayByScottThrift,
      .cosmicSurgery,
      .anomalisa
    ]
  )
)

initialize()
let controller = Storyboard.Search.instantiate(SearchViewController.self)

// Set the device type and orientation.
let (parent, _) = playgroundControllers(device: .phone4_7inch, orientation: .portrait, child: controller)

// Set the device language.
AppEnvironment.replaceCurrentEnvironment(
  language: .es,
  locale: Locale(identifier: "en"),
  mainBundle: Bundle.framework
)

let frame = parent.view.frame
PlaygroundPage.current.liveView = parent
parent.view.frame = frame
