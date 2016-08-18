@testable import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit
import XCPlayground
@testable import Kickstarter_Framework

let activities = [.update, .backing, .follow, .launch, .success, .failure, .suspension]
  .map {
    .template
      |> Activity.lens.project .~ .cosmicSurgery
      |> Activity.lens.user .~ .brando
      |> Activity.lens.update .~ .template
      |> Activity.lens.category .~ $0
}

AppEnvironment.replaceCurrentEnvironment(
  apiService: MockService(
    oauthToken: OauthToken(token: "deadbeef"),
    fetchActivitiesResponse: activities,
    fetchUnansweredSurveyResponsesResponse: [.template |> SurveyResponse.lens.project .~ .cosmicSurgery]
  ),
  currentUser: Project.cosmicSurgery.creator
)

initialize()
let controller = ActivitiesViewController.instantiate()
let (parent, _) = playgroundControllers(device: .phone4_7inch, orientation: .portrait, child: controller)

let frame = parent.view.frame
XCPlaygroundPage.currentPage.liveView = parent
parent.view.frame = frame
