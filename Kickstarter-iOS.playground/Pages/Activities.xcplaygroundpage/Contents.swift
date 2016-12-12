@testable import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit
import XCPlayground
@testable import Kickstarter_Framework

let creator = .template |> User.lens.avatar.small .~ ""
let survey = .template |> SurveyResponse.lens.project .~
  (.cosmicSurgery |> Project.lens.creator .~ creator)

let daysAgoDate = NSDate().timeIntervalSince1970 - 60 * 60 * 24 * 4

let follow = .template
  |> Activity.lens.id .~ 85
  |> Activity.lens.user .~ (.template
    |> User.lens.name .~ "Brandon Williams"
  )
  |> Activity.lens.category .~ .follow

let update = .template
  |> Activity.lens.id .~ 51
  |> Activity.lens.project .~ .cosmicSurgery
  |> Activity.lens.update .~ (.template |> Update.lens.sequence .~ 4)
  |> Activity.lens.createdAt .~ daysAgoDate
  |> Activity.lens.category .~ .update

let backing = .template
  |> Activity.lens.id .~ 62
  |> Activity.lens.project .~ (.cosmicSurgery
    |> Project.lens.stats.fundingProgress .~ 0.88
  )
  |> Activity.lens.user .~ (.template
    |> User.lens.name .~ "Judith Light"
  )
  |> Activity.lens.category .~ .backing

let launch = .template
  |> Activity.lens.id .~ 73
  |> Activity.lens.project .~ (.cosmicSurgery
    |> Project.lens.name .~ "A Very Important Project About Kittens and Puppies"
    |> Project.lens.stats.fundingProgress .~ 0
  )
  |> Activity.lens.category .~ .launch

let following = .template
  |> Activity.lens.id .~ 0
  |> Activity.lens.user .~ (.template
    |> User.lens.name .~ "David Bowie"
    |> User.lens.isFriend .~ true
  )
  |> Activity.lens.category .~ .follow

let success = .template
  |> Activity.lens.id .~ 45
  |> Activity.lens.project .~ (.cosmicSurgery
    |> Project.lens.name .~ "Help Me Transform This Pile of Wood"
    |> Project.lens.stats.fundingProgress .~ 1.4
  )
  |> Activity.lens.category .~ .success

let failure = .template
  |> Activity.lens.id .~ 36
  |> Activity.lens.project .~ (.cosmicSurgery
    |> Project.lens.name .~ "A Mildly Important Project About Arachnids and Worms"
    |> Project.lens.stats.fundingProgress .~ 0.6
  )
  |> Activity.lens.category .~ .failure

let canceled = .template
  |> Activity.lens.id .~ 27
  |> Activity.lens.project .~ (.cosmicSurgery
    |> Project.lens.name .~ "A Not Very Important Project About Pickles"
    |> Project.lens.stats.fundingProgress .~ 0.1
  )
  |> Activity.lens.category .~ .cancellation

let suspended = .template
  |> Activity.lens.id .~ 18
  |> Activity.lens.project .~ (.cosmicSurgery
    |> Project.lens.name .~ "A Questionably Important Project About Rubber Bands"
    |> Project.lens.stats.fundingProgress .~ 0.04
  )
  |> Activity.lens.category .~ .suspension

let activities = [follow, update, backing, launch, following, success, failure, canceled, suspended]

AppEnvironment.replaceCurrentEnvironment(
  apiService: MockService(
    oauthToken: OauthToken(token: "deadbeef"),
    fetchActivitiesResponse: activities,
    fetchUnansweredSurveyResponsesResponse: [survey]
  ),
  currentUser: Project.cosmicSurgery.creator
)

initialize()
let controller = ActivitiesViewController.instantiate()
let (parent, _) = playgroundControllers(device: .phone4_7inch, orientation: .portrait, child: controller)

let frame = parent.view.frame |> CGRect.lens.size.height .~ 2200
XCPlaygroundPage.currentPage.liveView = parent
parent.view.frame = frame
