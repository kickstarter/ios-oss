@testable import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit
import XCPlayground
@testable import Kickstarter_Framework

let brando = User.brando
let blob = User.template

let update = .template
  |> Update.lens.title .~ "Spirit animals on their way"
  |> Update.lens.sequence .~ 42
  |> Update.lens.user .~ blob

let backing = .template
  |> Activity.lens.category .~ .backing
  |> Activity.lens.user .~ brando
  |> Activity.lens.project .~ Project.cosmicSurgery

let follow = .template
  |> Activity.lens.category .~ .follow
  |> Activity.lens.user .~ brando
  |> Activity.lens.project .~ nil

let projectUpdate = .template
  |> Activity.lens.category .~ .update
  |> Activity.lens.update .~ update
  |> Activity.lens.project .~ Project.cosmicSurgery

let launch = .template
  |> Activity.lens.category .~ .launch
  |> Activity.lens.user .~ brando
  |> Activity.lens.project .~ Project.cosmicSurgery

AppEnvironment.replaceCurrentEnvironment(
  apiService: MockService(
    fetchDiscoveryResponse: .template |> DiscoveryEnvelope.lens.projects .~ [
      .todayByScottThrift,
      .cosmicSurgery,
      .anomalisa
    ],
    fetchActivitiesResponse: [projectUpdate, follow, backing]
  )
)

UIView.initialize()
UIViewController.initialize()
let controller = DiscoveryPageViewController.configuredWith(sort: .Magic)

let (parent, _) = playgroundControllers(device: .pad, orientation: .portrait, child: controller)

controller.change(filter: .defaults)

let frame = parent.view.frame
XCPlaygroundPage.currentPage.liveView = parent
parent.view.frame = frame
