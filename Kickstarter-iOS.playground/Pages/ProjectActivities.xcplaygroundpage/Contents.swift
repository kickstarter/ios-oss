@testable import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit
import PlaygroundSupport
@testable import Kickstarter_Framework

// Setting `isVoiceOverRunning` to `true` outputs a date before every activity.
let isVoiceOverRunning = false

let device = Device.phone5_5inch
let orientation = Orientation.portrait



let project = Project.cosmicSurgery

let baseActivity = .template
  |> Activity.lens.comment .~ (
    .template
      |> Comment.lens.author .~ .brando
      |> Comment.lens.body .~ "Hi, I'm wondering if you're planning on holding a gallery showing with these portraits? I'd love to attend if you'll be in New York!"
  )
  |> Activity.lens.memberData.amount .~ 5800000
  |> Activity.lens.project .~ project
  |> Activity.lens.update .~ (
    .template
      |> Update.lens.title .~ "Spirit animal reward available again"
      |> Update.lens.body .~ "Due to popular demand, and the inspirational momentum of this project, we've added more spirit animal rewards!"
  )
  |> Activity.lens.user .~ .brando
  |> Activity.lens.memberData.backing .~ (
    .template
      |> Backing.lens.amount .~ 25
    )

let backingActivity = baseActivity
  |> Activity.lens.category .~ .backing
  |> Activity.lens.memberData.amount .~ 25
  |> Activity.lens.memberData.rewardId .~ 1

let backingAmountActivity = baseActivity
  |> Activity.lens.category .~ .backingAmount
  |> Activity.lens.memberData.newAmount .~ 25
  |> Activity.lens.memberData.newRewardId .~ 1
  |> Activity.lens.memberData.oldRewardId .~ 2
  |> Activity.lens.memberData.oldAmount .~ 100

let backingCanceledActivity = baseActivity
  |> Activity.lens.category .~ .backingCanceled
  |> Activity.lens.memberData.amount .~ 25
  |> Activity.lens.memberData.rewardId .~ 1

let backingRewardActivity = baseActivity
  |> Activity.lens.category .~ .backingReward
  |> Activity.lens.memberData.newRewardId .~ 1
  |> Activity.lens.memberData.oldRewardId .~ 2

let activityCategories: [Activity.Category] = [.update,
                                               .suspension,
                                               .cancellation,
                                               .failure,
                                               .success,
                                               .launch,
                                               .commentPost,
                                               .commentProject]

let backingActivities = [backingActivity,
                         backingAmountActivity,
                         backingCanceledActivity,
                         backingRewardActivity]

AppEnvironment.replaceCurrentEnvironment(
  apiService: MockService(
    oauthToken: OauthToken(token: "deadbeef"),
    fetchProjectActivitiesResponse: activityCategories.map { baseActivity |> Activity.lens.category .~ $0 } + backingActivities
  ),
  currentUser: Project.cosmicSurgery.creator,
  isVoiceOverRunning: { return isVoiceOverRunning }
)

initialize()
let controller = ProjectActivitiesViewController.configuredWith(project: project)
controller.bindViewModel()

let (parent, _) = playgroundControllers(device: device, orientation: orientation, child: controller)
let frame = parent.view.frame
PlaygroundPage.current.liveView = parent
parent.view.frame = frame
