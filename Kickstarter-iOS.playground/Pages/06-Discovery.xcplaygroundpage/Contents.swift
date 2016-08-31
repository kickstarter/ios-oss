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

// Instantiate users for logged in and out states.
let brando = User.brando
let blob = User.template

// Instantiate activity sample types.
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

// Instantiate projects with metadata
let today = AppEnvironment.current.calendar.startOfDayForDate(NSDate()).timeIntervalSince1970

let potd = .todayByScottThrift
  |> Project.lens.dates.potdAt .~ today

let starred = .todayByScottThrift
  |> Project.lens.personalization.isStarred .~ true

let backed = .cosmicSurgery
  |> Project.lens.personalization.isBacking .~ true

let featured = .anomalisa
  |> Project.lens.dates.featuredAt .~ today

// Set the current app environment.
AppEnvironment.replaceCurrentEnvironment(
  apiService: MockService(
    fetchDiscoveryResponse: .template |> DiscoveryEnvelope.lens.projects .~ [
      potd,
      starred,
      backed,
      featured
    ],
    fetchActivitiesResponse: [projectUpdate, follow, backing]
  ),
  language: .en,
  locale: NSLocale(localeIdentifier: "en"),
  mainBundle: NSBundle.framework
)

// Initialize the view controller.
initialize()
let controller = DiscoveryViewController.instantiate()

let (parent, _) = playgroundControllers(device: .phone4inch, orientation: .portrait, child: controller)

let frame = parent.view.frame
XCPlaygroundPage.currentPage.liveView = parent
parent.view.frame = frame
