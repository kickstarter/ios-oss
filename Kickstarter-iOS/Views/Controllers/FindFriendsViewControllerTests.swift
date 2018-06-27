import Prelude
@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library

internal final class FindFriendsViewControllerTests: TestCase {

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

  func testView_ShowFacebookConnect() {
    combos(Language.allLanguages, [Device.phone4_7inch, Device.phone5_8inch]).forEach { language, device in
      withEnvironment(language: language) {
        let controller = FindFriendsViewController.configuredWith(source: FriendsSource.settings)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  func testView_ShowFriends() {
    let currentUser = .template
      |> User.lens.facebookConnected .~ true

    let friendNoAvatar = .template
      |> User.lens.avatar.medium .~ ""

    let friend1 = friendNoAvatar
      |> User.lens.name .~ "Ron Swanson"
      |> User.lens.location .~
        (.template |> Location.lens.displayableName .~ "Pawnee, IN")
      |> User.lens.stats.backedProjectsCount .~ 42
      |> User.lens.stats.createdProjectsCount .~ 0
      |> User.lens.isFriend .~ true

    let friend2 = friendNoAvatar
      |> User.lens.name .~ "David Byrne"
      |> User.lens.location .~
        (.template |> Location.lens.displayableName .~ "New York, NY")
      |> User.lens.stats.backedProjectsCount .~ 365
      |> User.lens.stats.createdProjectsCount .~ 5

    let friendsResponse = .template
      |> FindFriendsEnvelope.lens.users .~ [friend1, friend2, friend2, friend1, friendNoAvatar]

    let friendStats = .template
      |> FriendStatsEnvelope.lens.stats.friendProjectsCount .~ 1_738
      |> FriendStatsEnvelope.lens.stats.remoteFriendsCount .~ 5

    combos(Language.allLanguages, [Device.phone4_7inch, Device.phone5_8inch]).forEach { language, device in
      withEnvironment(apiService: MockService(fetchFriendsResponse: friendsResponse,
        fetchFriendStatsResponse: friendStats), currentUser: currentUser, language: language) {

        let controller = FindFriendsViewController.configuredWith(source: FriendsSource.settings)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }
}
