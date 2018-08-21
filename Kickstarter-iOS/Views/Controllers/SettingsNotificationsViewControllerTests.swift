import Library
import Prelude
import Result
@testable import Kickstarter_Framework
@testable import KsApi

final class SettingsNotificationsViewControllerTests: TestCase {

  override func setUp() {
    super.setUp()

    AppEnvironment.pushEnvironment(mainBundle: Bundle.framework)
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    AppEnvironment.popEnvironment()
    UIView.setAnimationsEnabled(true)
    super.tearDown()
  }

  func testSettingsNotificationsViewController() {
    let currentUser = .template
      |> UserAttribute.notification(.friendActivity).lens .~ true
      |> UserAttribute.notification(.mobileFollower).lens .~ true
      |> User.lens.stats.backedProjectsCount .~ 1234
      |> User.lens.stats.memberProjectsCount .~ 2

    let mockService = MockService(fetchUserSelfResponse: currentUser)

    combos(Language.allLanguages, [Device.phone4_7inch, Device.phone5_8inch, Device.pad]).forEach {
      language, device in

      withEnvironment(apiService: mockService,
                      currentUser: currentUser,
                      language: language) {
        let controller = Storyboard.SettingsNotifications.instantiate(
          SettingsNotificationsViewController.self
        )
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testSettingsNotificationsViewController_isCreator() {
    let currentUser = .template
      |> UserAttribute.notification(.pledgeActivity).lens .~ true
      |> UserAttribute.notification(.creatorTips).lens .~ true
      |> User.lens.stats.backedProjectsCount .~ 5
      |> User.lens.stats.memberProjectsCount .~ 2
      |> User.lens.stats.createdProjectsCount .~ 4

    let mockService = MockService(fetchUserSelfResponse: currentUser)

    combos(Language.allLanguages, [Device.phone4_7inch, Device.phone5_8inch, Device.pad]).forEach {
      language, device in

      withEnvironment(apiService: mockService,
                      currentUser: currentUser,
                      language: language) {
        let controller = Storyboard.SettingsNotifications.instantiate(
          SettingsNotificationsViewController.self
        )
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }
}
