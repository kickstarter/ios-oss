@testable import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit
import XCPlayground
@testable import Kickstarter_Framework

let baseActivity = .template
  |> Activity.lens.project .~ .cosmicSurgery
  |> Activity.lens.user .~ .brando
  |> Activity.lens.update .~ .template

let activityCategories: [Activity.Category] = [.update, .backing, .follow, .launch, .success, .failure, .suspension]

AppEnvironment.replaceCurrentEnvironment(
  apiService: MockService(
    oauthToken: OauthToken(token: "deadbeef"),
    fetchActivitiesResponse: activityCategories.map { baseActivity |> Activity.lens.category .~ $0 },
    fetchUnansweredSurveyResponsesResponse: [.template |> SurveyResponse.lens.project .~ .cosmicSurgery]
  ),
  currentUser: Project.cosmicSurgery.creator
)

let controller = storyboard(named: "Activity")
  .instantiateViewControllerWithIdentifier("ActivitiesViewController") as! ActivitiesViewController

XCPlaygroundPage.currentPage.liveView = controller
controller.view
  |> UIView.lens.frame.size.height .~ 1_600
