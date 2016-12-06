@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import Result
import XCTest

internal final class ActivitiesViewControllerTests: TestCase {

  override func setUp() {
    super.setUp()
    AppEnvironment.pushEnvironment(mainBundle: NSBundle.framework)
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    AppEnvironment.popEnvironment()
    UIView.setAnimationsEnabled(false)
    super.tearDown()
  }

  func testActivities_All() {
    let daysAgoDate = self.dateType.init().timeIntervalSince1970 - 60 * 60 * 24 * 2

    let follow = .template
      |> Activity.lens.id .~ 84
      |> Activity.lens.user .~ (.template
        |> User.lens.name .~ "Brandon Williams"
        |> User.lens.avatar.small .~ "https://ksr-ugc.imgix.net/assets/006/258/518/" +
        "b9033f46095b83119188cf9a66d19356_original.jpg?w=40&h=40&fit=crop&v=1461376829" +
        "&auto=format&q=92&s=0fcedf8888ca6990408ccde81888899b"
      )
      |> Activity.lens.category .~ .follow

    let update = .template
      |> Activity.lens.id .~ 51
      |> Activity.lens.project .~ .cosmicSurgery
      |> Activity.lens.update .~ .template
      |> Activity.lens.createdAt .~ daysAgoDate
      |> Activity.lens.category .~ .update

    let backing = .template
      |> Activity.lens.id .~ 62
      |> Activity.lens.project .~ (.cosmicSurgery |> Project.lens.stats.fundingProgress .~ 0.88)
      |> Activity.lens.user .~ (.template
        |> User.lens.name .~ "Judith Light"
        |> User.lens.avatar.small .~ "https://ksr-ugc.imgix.net/assets/006/258/518/" +
        "b9033f46095b83119188cf9a66d19356_original.jpg?w=40&h=40&fit=crop&v=1461376829" +
        "&auto=format&q=92&s=0fcedf8888ca6990408ccde81888899b"
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
        |> User.lens.avatar.small .~ "https://ksr-ugc.imgix.net/assets/006/258/518/" +
        "b9033f46095b83119188cf9a66d19356_original.jpg?w=40&h=40&fit=crop&v=1461376829" +
        "&auto=format&q=92&s=0fcedf8888ca6990408ccde81888899b"
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

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach { language, device in
      withEnvironment(
        apiService: MockService(fetchActivitiesResponse: activities,
        fetchUnansweredSurveyResponsesResponse: [.template |> SurveyResponse.lens.project .~ .cosmicSurgery]),
        currentUser: .template |> User.lens.facebookConnected .~ true,
        language: language,
        userDefaults: MockKeyValueStore()
      ) {
        let vc = ActivitiesViewController.instantiate()
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)
        parent.view.frame.size.height = 2360

        self.scheduler.run()

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testMultipleSurveys_NotFacebookConnected_YouLaunched() {
    let you = .template
      |> User.lens.id .~ 355
      |> User.lens.name .~ "Gina B"

    let launch = .template
      |> Activity.lens.id .~ 73
      |> Activity.lens.project .~ (.cosmicSurgery
        |> Project.lens.creator .~ you
        |> Project.lens.name .~ "A Very Very Important Project About Kittens and Puppies"
        |> Project.lens.stats.fundingProgress .~ 0.01
      )
      |> Activity.lens.user .~ you
      |> Activity.lens.category .~ .launch

    let survey1 = .template |> SurveyResponse.lens.project .~ .cosmicSurgery
    let survey2 = .template |> SurveyResponse.lens.project .~ .anomalisa

    combos(Language.allLanguages, [Device.phone4_7inch]).forEach { language, device in
      withEnvironment(
        apiService: MockService(fetchActivitiesResponse: [launch],
          fetchUnansweredSurveyResponsesResponse: [survey1, survey2]),
        currentUser: you,
        language: language,
        userDefaults: MockKeyValueStore()
      ) {
        let vc = ActivitiesViewController.instantiate()
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)
        parent.view.frame.size.height = 900

        self.scheduler.run()

        FBSnapshotVerifyView(vc.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }
}
