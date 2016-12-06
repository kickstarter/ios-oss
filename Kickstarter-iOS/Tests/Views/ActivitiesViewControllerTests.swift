@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import Result
import XCTest

private let tolerance: CGFloat = 0.0001

internal final class ActivitiesViewControllerTests: TestCase {
  override func setUp() {
    super.setUp()
    AppEnvironment.pushEnvironment(mainBundle: NSBundle.framework)
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    AppEnvironment.popEnvironment()
    UIView.setAnimationsEnabled(true)
    super.tearDown()
  }

  // all langs, all devices, all devices
  func testActivities_All() {
    let activities = [.follow, .update, .backing, .launch, .success, .failure, .suspension]
      .map {
        .template
          |> Activity.lens.id .~ 1234
          |> Activity.lens.project .~ cosmicSurgeryNoPhoto
          |> Activity.lens.user .~ brandoNoAvatar
          |> Activity.lens.update .~ .template
          |> Activity.lens.category .~ $0
    }

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach { language, device in
      withEnvironment(apiService: MockService(fetchActivitiesResponse: activities,
        fetchUnansweredSurveyResponsesResponse: [.template |> SurveyResponse.lens.project .~ .cosmicSurgery]),
        currentUser: User.template,
        language: language, userDefaults: MockKeyValueStore()) {

        let vc = ActivitiesViewController.instantiate()
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)
        parent.view.frame.size.height = 2000

        self.scheduler.run()

        FBSnapshotVerifyView(vc.view, identifier: "Activities_lang_\(language)", tolerance: tolerance)
      }
    }
  }

  // all langs iphone
  func testOneSurvey() {

  }

  // all langs iphone
  func testMultipleSurveys() {

  }

  // all langs iphone
  func testFriendsHeader() {

  }
}

private let brandoNoAvatar = .brando
  |> User.lens.avatar.medium .~ ""

private let cosmicSurgeryNoPhoto = .cosmicSurgery
  |> Project.lens.id .~ 2222
  |> Project.lens.photo.full .~ ""
