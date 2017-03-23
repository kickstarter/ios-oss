import XCTest
import ReactiveSwift
import UIKit.UIActivity
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers
@testable import Result
@testable import KsApi
@testable import Library
import Prelude

final class FindFriendsStatsCellViewModelTests: TestCase {
  let vm: FindFriendsStatsCellViewModelType = FindFriendsStatsCellViewModel()

  let backedProjectsCountText = TestObserver<String, NoError>()
  let followAllText = TestObserver<String, NoError>()
  let friendsCountText = TestObserver<String, NoError>()
  let hideFollowAllButton = TestObserver<Bool, NoError>()
  let showFollowAllFriendsAlert = TestObserver<Int, NoError>()

  override func setUp() {
    super.setUp()

    vm.outputs.backedProjectsCountText.observe(backedProjectsCountText.observer)
    vm.outputs.followAllText.observe(followAllText.observer)
    vm.outputs.friendsCountText.observe(friendsCountText.observer)
    vm.outputs.hideFollowAllButton.observe(hideFollowAllButton.observer)
    vm.outputs.notifyDelegateShowFollowAllFriendsAlert.observe(showFollowAllFriendsAlert.observer)
  }

  func testText() {
    let stats = FriendStatsEnvelope.template
      |> FriendStatsEnvelope.lens.stats.friendProjectsCount .~ 450
      |> FriendStatsEnvelope.lens.stats.remoteFriendsCount .~ 45

    backedProjectsCountText.assertValueCount(0)
    followAllText.assertValueCount(0)
    friendsCountText.assertValueCount(0)

    vm.inputs.configureWith(stats: stats, source: FriendsSource.activity)

    backedProjectsCountText.assertValues(["450"])
    followAllText.assertValues(["Follow all 45 friends"])
    friendsCountText.assertValues(["45"])
  }

  func testFollowAllFriends() {
    let stats = FriendStatsEnvelope.template
      |> FriendStatsEnvelope.lens.stats.friendProjectsCount .~ 3
      |> FriendStatsEnvelope.lens.stats.remoteFriendsCount .~ 2

    let statsPopular = FriendStatsEnvelope.template
      |> FriendStatsEnvelope.lens.stats.friendProjectsCount .~ 1200
      |> FriendStatsEnvelope.lens.stats.remoteFriendsCount .~ 1000

    hideFollowAllButton.assertValueCount(0)

    vm.inputs.configureWith(stats: stats, source: FriendsSource.activity)

    hideFollowAllButton.assertValues([true], "Not enough friends, hide Follow All button")

    vm.inputs.configureWith(stats: statsPopular, source: FriendsSource.activity)

    hideFollowAllButton.assertValues([true, false], "Show Follow All button")
    showFollowAllFriendsAlert.assertValueCount(0)

    vm.inputs.followAllButtonTapped()

    showFollowAllFriendsAlert.assertValues([1000], "Show Follow All Friends alert with friend count")
  }
}
