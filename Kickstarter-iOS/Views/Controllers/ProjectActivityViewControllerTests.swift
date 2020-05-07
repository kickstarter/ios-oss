@testable import Kickstarter_Framework
@testable import KsApi
import Library
import Prelude
import XCTest

internal final class ProjectActivityViewControllerTests: TestCase {
  override func setUp() {
    super.setUp()
    AppEnvironment.pushEnvironment(
      apiService: MockService(
        oauthToken: OauthToken(token: "deadbeef"),
        fetchProjectActivitiesResponse: activityCategories.map {
          baseActivity |> Activity.lens.category .~ $0
        }
          + backingActivities
      ),
      currentUser: Project.cosmicSurgery.creator,
      mainBundle: Bundle.framework
    )

    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    AppEnvironment.popEnvironment()
    UIView.setAnimationsEnabled(true)
    super.tearDown()
  }

  func testProjectActivityView() {
    combos(Language.allLanguages, Device.allCases).forEach { language, device in
      withEnvironment(language: language) {
        let controller = ProjectActivitiesViewController.configuredWith(project: project)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        self.scheduler.run()

        FBSnapshotVerifyView(
          parent.view,
          identifier: "lang_\(language)_device_\(device)",
          overallTolerance: 0.03
        )
      }
    }
  }
}

private let project =
  Project.cosmicSurgery
    |> Project.lens.dates.deadline .~ 123_456_789.0
    |> Project.lens.dates.launchedAt .~ 123_456_789.0
    |> Project.lens.photo.small .~ ""
    |> Project.lens.photo.med .~ ""
    |> Project.lens.photo.full .~ ""

private let user =
  User.brando
    |> \.avatar.large .~ ""
    |> \.avatar.medium .~ ""
    |> \.avatar.small .~ ""

private let baseActivity =
  .template
    |> Activity.lens.createdAt .~ 123_456_789.0
    |> Activity.lens.comment .~ (
      .template
        |> Comment.lens.author .~ .template
        |> Comment.lens.body .~ ("Hi, I'm wondering if you're planning on holding a gallery showing with "
          + "these portraits? I'd love to attend if you'll be in New York!")
    )
    |> Activity.lens.memberData.amount .~ 25
    |> Activity.lens.project .~ project
    |> Activity.lens.update .~ (
      .template
        |> Update.lens.title .~ "Spirit animal reward available again"
        |> Update.lens.body .~ ("Due to popular demand, and the inspirational momentum of this project, we've"
          + " added more spirit animal rewards!")
        |> Update.lens.publishedAt .~ 123_456_789.0
    )
    |> Activity.lens.user .~ user
    |> Activity.lens.memberData.backing .~ .some(
      .template
        |> Backing.lens.amount .~ 25
        |> Backing.lens.backerId .~ user.id
        |> Backing.lens.backer .~ user
    )

private let backingActivity =
  baseActivity
    |> Activity.lens.category .~ .backing
    |> Activity.lens.memberData.amount .~ 25
    |> Activity.lens.memberData.rewardId .~ 1

private let backingAmountActivity =
  baseActivity
    |> Activity.lens.category .~ .backingAmount
    |> Activity.lens.memberData.newAmount .~ 25
    |> Activity.lens.memberData.newRewardId .~ 1
    |> Activity.lens.memberData.oldRewardId .~ 2
    |> Activity.lens.memberData.oldAmount .~ 100

private let backingCanceledActivity =
  baseActivity
    |> Activity.lens.category .~ .backingCanceled
    |> Activity.lens.memberData.amount .~ 25
    |> Activity.lens.memberData.rewardId .~ 1

private let backingRewardActivity =
  baseActivity
    |> Activity.lens.category .~ .backingReward
    |> Activity.lens.memberData.newRewardId .~ 1
    |> Activity.lens.memberData.oldRewardId .~ 2

private let activityCategories: [Activity.Category] = [
  .update,
  .suspension,
  .cancellation,
  .failure,
  .success,
  .launch,
  .commentPost,
  .commentProject
]

private let backingActivities = [
  backingActivity,
  backingAmountActivity,
  backingCanceledActivity,
  backingRewardActivity
]
