@testable import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit
import XCPlayground
@testable import Kickstarter_Framework

AppEnvironment.replaceCurrentEnvironment(apiService:
  MockService(
    fetchDiscoveryResponse: .template |> DiscoveryEnvelope.lens.projects .~ [
      .todayByScottThrift,
      .cosmicSurgery,
      .anomalisa
    ]
  )
)

let controller = storyboard(named: "Discovery")
  .instantiateViewControllerWithIdentifier("DiscoveryPageViewController") as! DiscoveryPageViewController

controller.configureWith(sort: .Magic)
controller.change(filter: .defaults)
controller.bindViewModel()

XCPlaygroundPage.currentPage.liveView = controller
controller.view |> UIView.lens.frame.size.height .~ 1_250
