@testable import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit
import XCPlayground
@testable import Kickstarter_Framework

let basicParams = DiscoveryParams.defaults

let paramsWithCategory = .defaults
  |> DiscoveryParams.lens.category .~ .art

let paramsWithSubcategory = .defaults
  |> DiscoveryParams.lens.category .~ (
    .documentary
      |> Category.lens.name .~ "Documentary"
)

//: Uncomment initialParams below to test different navigation title strings.
let initialParms = basicParams
//let initialParms = paramsWithCategory
//let initialParms = paramsWithSubcategory

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
  ),
  language: .en,
  mainBundle: NSBundle.framework
)

initialize()
let controller = DiscoveryViewController.instantiate()

let (parent, _) = playgroundControllers(device: .phone4inch, orientation: .portrait, child: controller)

let frame = parent.view.frame
XCPlaygroundPage.currentPage.liveView = parent
parent.view.frame = frame

controller.filterHeaderViewController.updateParams(initialParms, filtersAreHidden: true)





