@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import UIKit.UIActivity
import XCTest

final class ActivityFriendFollowCellViewModelTests: TestCase {
  let vm: ActivityFriendFollowCellViewModel = ActivityFriendFollowCellViewModel()
  let hideFollowButton = TestObserver<Bool, Never>()
  let friendImageURL = TestObserver<String?, Never>()
  let title = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.hideFollowButton.observe(self.hideFollowButton.observer)
    self.vm.outputs.friendImageURL.map { $0?.absoluteString }.observe(self.friendImageURL.observer)
    self.vm.outputs.title.map { $0.string }.observe(self.title.observer)
  }

  func testFriendDetails_Complete() {
    let user = User.template
      |> \.avatar.small .~ "http://coolpic.com/cool.jpg"
      |> \.name .~ "Squiggles McTwiddle"

    let activity = Activity.template
      |> Activity.lens.user .~ user

    self.friendImageURL.assertValueCount(0)
    self.title.assertValueCount(0)

    self.vm.inputs.configureWith(activity: activity)

    self.friendImageURL.assertValues(["http://coolpic.com/cool.jpg"])
    self.title.assertValues(["Squiggles McTwiddle is now following you!"])
  }

  func testFriendDetails_Incomplete() {
    let user = User.template
      |> \.name .~ "Squiggles McTwiddle"

    let activity = Activity.template
      |> Activity.lens.user .~ user

    self.friendImageURL.assertValueCount(0)
    self.title.assertValueCount(0)

    self.vm.inputs.configureWith(activity: activity)

    self.friendImageURL.assertValueCount(1)
    self.title.assertValues(["Squiggles McTwiddle is now following you!"])
  }

  func testFriendFollowing_Friend() {
    let user = User.template
      |> \.avatar.small .~ "http://coolpic.com/cool.jpg"
      |> \.isFriend .~ true
      |> \.name .~ "Squiggles McTwiddle"

    let activity = Activity.template
      |> Activity.lens.user .~ user

    self.hideFollowButton.assertValueCount(0)
    XCTAssertEqual([], self.segmentTrackingClient.events)

    self.vm.inputs.configureWith(activity: activity)

    self.hideFollowButton.assertValues([true], "Hide Follow Button")
    XCTAssertEqual([], self.segmentTrackingClient.events)
  }

  func testFriendFollowing_NonFriend() {
    let user = User.template
      |> \.avatar.medium .~ "http://coolpic.com/cool.jpg"
      |> \.isFriend .~ false
      |> \.name .~ "Squiggles McTwiddle"

    let activity = Activity.template
      |> Activity.lens.user .~ user

    self.hideFollowButton.assertValueCount(0)
    XCTAssertEqual([], self.segmentTrackingClient.events)

    self.vm.inputs.configureWith(activity: activity)

    self.hideFollowButton.assertValues([false], "Show Follow Button")

    self.vm.inputs.followButtonTapped()

    self.hideFollowButton.assertValues([false], "Follow Button does not change")
  }

  func testRetainFriendStatusOnReuse_After_Following() {
    let user = User.template
      |> \.avatar.small .~ "http://coolpic.com/cool.jpg"
      |> \.isFriend .~ false
      |> \.name .~ "Squiggles McTwiddle"

    let activity = Activity.template
      |> Activity.lens.user .~ user

    self.hideFollowButton.assertValueCount(0)

    self.vm.inputs.configureWith(activity: activity)

    self.hideFollowButton.assertValues([false], "Show Follow Button")

    self.vm.inputs.followButtonTapped()
    scheduler.advance()
  }
}
