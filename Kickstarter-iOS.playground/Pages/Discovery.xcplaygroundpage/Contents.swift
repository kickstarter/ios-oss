@testable import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit
import PlaygroundSupport
@testable import Kickstarter_Framework

PlaygroundPage.current.needsIndefiniteExecution = true

let controller = DiscoveryViewController.instantiate()

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

// Instantiate projects with metadata.
let today = AppEnvironment.current.calendar.startOfDay(for: Date()).timeIntervalSince1970

let starred = .todayByScottThrift
  |> Project.lens.personalization.isStarred .~ true

let backed = .cosmicSurgery
  |> Project.lens.personalization.isBacking .~ true

let featured = .anomalisa
  |> Project.lens.dates.featuredAt .~ today

// Set the current app environment.
AppEnvironment.replaceCurrentEnvironment(
  apiService: MockService(
    fetchActivitiesResponse: [projectUpdate, follow, backing],
    fetchDiscoveryResponse: .template |> DiscoveryEnvelope.lens.projects .~ [
      starred,
      backed,
      featured
    ]
  ),
  currentUser: User.template,
  language: .en,
  locale: Locale(identifier: "en"),
  mainBundle: Bundle.framework
)

// Initialize the view controller.
initialize()

let (parent, _) = playgroundControllers(device: .phone4_7inch, orientation: .portrait, child: controller)

let frame = parent.view.frame

PlaygroundPage.current.liveView = parent
parent.view.frame = frame

