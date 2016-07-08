@testable import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit
import XCPlayground
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

let controller = storyboard(named: "Discovery")
  .instantiateViewControllerWithIdentifier("DiscoveryPageViewController") as! DiscoveryPageViewController
let (parent, _) = playgroundControllers(device: .phone4_7inch, orientation: .portrait, child: controller)

controller.configureWith(sort: .Magic)
controller.change(filter: .defaults)

let frame = parent.view.frame
XCPlaygroundPage.currentPage.liveView = parent
parent.view.frame = frame
