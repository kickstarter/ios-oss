@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import UIKit.UIActivity
import XCTest

final class FindFriendsStatsCellViewModelTests: TestCase {
  let vm: FindFriendsStatsCellViewModelType = FindFriendsStatsCellViewModel()

  let backedProjectsCountText = TestObserver<String, Never>()
  let followAllText = TestObserver<String, Never>()
  let friendsCountText = TestObserver<String, Never>()
  let hideFollowAllButton = TestObserver<Bool, Never>()
  let showFollowAllFriendsAlert = TestObserver<Int, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.backedProjectsCountText.observe(self.backedProjectsCountText.observer)
    self.vm.outputs.followAllText.observe(self.followAllText.observer)
    self.vm.outputs.friendsCountText.observe(self.friendsCountText.observer)
    self.vm.outputs.hideFollowAllButton.observe(self.hideFollowAllButton.observer)
    self.vm.outputs.notifyDelegateShowFollowAllFriendsAlert.observe(self.showFollowAllFriendsAlert.observer)
  }

  func testText() {
    let stats = FriendStatsEnvelope.template
      |> FriendStatsEnvelope.lens.stats.friendProjectsCount .~ 450
      |> FriendStatsEnvelope.lens.stats.remoteFriendsCount .~ 45

    self.backedProjectsCountText.assertValueCount(0)
    self.followAllText.assertValueCount(0)
    self.friendsCountText.assertValueCount(0)

    self.vm.inputs.configureWith(stats: stats, source: FriendsSource.activity)

    self.backedProjectsCountText.assertValues(["450"])
    self.followAllText.assertValues(["Follow all 45 friends"])
    self.friendsCountText.assertValues(["45"])
  }

  func testFollowAllFriends() {
    let stats = FriendStatsEnvelope.template
      |> FriendStatsEnvelope.lens.stats.friendProjectsCount .~ 3
      |> FriendStatsEnvelope.lens.stats.remoteFriendsCount .~ 2

    let statsPopular = FriendStatsEnvelope.template
      |> FriendStatsEnvelope.lens.stats.friendProjectsCount .~ 1_200
      |> FriendStatsEnvelope.lens.stats.remoteFriendsCount .~ 1_000

    self.hideFollowAllButton.assertValueCount(0)

    self.vm.inputs.configureWith(stats: stats, source: FriendsSource.activity)

    self.hideFollowAllButton.assertValues([true], "Not enough friends, hide Follow All button")

    self.vm.inputs.configureWith(stats: statsPopular, source: FriendsSource.activity)

    self.hideFollowAllButton.assertValues([true, false], "Show Follow All button")
    self.showFollowAllFriendsAlert.assertValueCount(0)

    self.vm.inputs.followAllButtonTapped()

    self.showFollowAllFriendsAlert.assertValues([1_000], "Show Follow All Friends alert with friend count")
  }
}
