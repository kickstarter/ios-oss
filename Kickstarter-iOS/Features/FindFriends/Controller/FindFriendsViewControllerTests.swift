@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import SnapshotTesting
import UIKit

internal final class FindFriendsViewControllerTests: TestCase {
  override func setUp() {
    super.setUp()
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    UIView.setAnimationsEnabled(true)
    super.tearDown()
  }

  func testView_ShowFacebookConnect() {
    orthogonalCombos(Language.allLanguages, [Device.phone4_7inch, Device.phone5_8inch])
      .forEach { language, device in
        withEnvironment(language: language) {
          let controller = FindFriendsViewController.configuredWith(source: FriendsSource.settings)
          let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

          assertSnapshot(matching: parent.view, as: .image, named: "lang_\(language)_device_\(device)")
        }
      }
  }

  func testView_ShowFacebookReconnect() {
    let facebookReconnectUser = User.template
      |> \.facebookConnected .~ true
      |> \.needsFreshFacebookToken .~ true

    orthogonalCombos(Language.allLanguages, [Device.phone4_7inch, Device.phone5_8inch])
      .forEach { language, device in
        withEnvironment(currentUser: facebookReconnectUser, language: language) {
          let controller = FindFriendsViewController.configuredWith(source: FriendsSource.settings)
          let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

          assertSnapshot(matching: parent.view, as: .image, named: "lang_\(language)_device_\(device)")
        }
      }
  }

  func testView_ShowFriends() {
    let currentUser = User.template
      |> \.facebookConnected .~ true

    let friendNoAvatar = User.template
      |> \.avatar.medium .~ ""

    let friend1 = friendNoAvatar
      |> \.name .~ "Ron Swanson"
      |> \.location .~
      (.template |> Location.lens.displayableName .~ "Pawnee, IN")
      |> \.stats.backedProjectsCount .~ 42
      |> \.stats.createdProjectsCount .~ 0
      |> \.isFriend .~ true

    let friend2 = friendNoAvatar
      |> \.name .~ "David Byrne"
      |> \.location .~
      (.template |> Location.lens.displayableName .~ "New York, NY")
      |> \.stats.backedProjectsCount .~ 365
      |> \.stats.createdProjectsCount .~ 5

    let friendsResponse = .template
      |> FindFriendsEnvelope.lens.users .~ [friend1, friend2, friend2, friend1, friendNoAvatar]

    let friendStats = .template
      |> FriendStatsEnvelope.lens.stats.friendProjectsCount .~ 1_738
      |> FriendStatsEnvelope.lens.stats.remoteFriendsCount .~ 5

    orthogonalCombos(Language.allLanguages, [Device.phone4_7inch, Device.phone5_8inch])
      .forEach { language, device in
        withEnvironment(apiService: MockService(
          fetchFriendsResponse: friendsResponse,
          fetchFriendStatsResponse: friendStats
        ), currentUser: currentUser, language: language) {
          let controller = FindFriendsViewController.configuredWith(source: FriendsSource.settings)
          let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

          self.scheduler.run()

          assertSnapshot(matching: parent.view, as: .image, named: "lang_\(language)_device_\(device)")
        }
      }
  }
}
