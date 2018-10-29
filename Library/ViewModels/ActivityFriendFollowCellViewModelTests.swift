import XCTest
import ReactiveSwift
import UIKit.UIActivity
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers
@testable import Result
@testable import KsApi
@testable import Library
import Prelude

final class ActivityFriendFollowCellViewModelTests: TestCase {
  let vm: ActivityFriendFollowCellViewModel = ActivityFriendFollowCellViewModel()
  let hideFollowButton = TestObserver<Bool, NoError>()
  let friendImageURL = TestObserver<String?, NoError>()
  let title = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()

    vm.outputs.hideFollowButton.observe(hideFollowButton.observer)
    vm.outputs.friendImageURL.map { $0?.absoluteString }.observe(friendImageURL.observer)
    vm.outputs.title.map { $0.string }.observe(title.observer)
  }

  func testFriendDetails_Complete() {
    let user = User.template
      |> \.avatar.small .~ "http://coolpic.com/cool.jpg"
      |> \.name .~ "Squiggles McTwiddle"

    let activity = Activity.template
      |> Activity.lens.user .~ user

    friendImageURL.assertValueCount(0)
    title.assertValueCount(0)

    vm.inputs.configureWith(activity: activity)

    friendImageURL.assertValues(["http://coolpic.com/cool.jpg"])
    title.assertValues(["Squiggles McTwiddle is now following you!"])
  }

  func testFriendDetails_Incomplete() {
    let user = User.template
      |> \.name .~ "Squiggles McTwiddle"

    let activity = Activity.template
      |> Activity.lens.user .~ user

    friendImageURL.assertValueCount(0)
    title.assertValueCount(0)

    vm.inputs.configureWith(activity: activity)

    friendImageURL.assertValueCount(1)
    title.assertValues(["Squiggles McTwiddle is now following you!"])
  }

  func testFriendFollowing_Friend() {
    let user = User.template
      |> \.avatar.small .~ "http://coolpic.com/cool.jpg"
      |> \.isFriend .~ true
      |> \.name .~ "Squiggles McTwiddle"

    let activity = Activity.template
      |> Activity.lens.user .~ user

    hideFollowButton.assertValueCount(0)
    XCTAssertEqual([], self.trackingClient.events)

    vm.inputs.configureWith(activity: activity)

    hideFollowButton.assertValues([true], "Hide Follow Button")
    XCTAssertEqual([], self.trackingClient.events)
  }

  func testFriendFollowing_NonFriend() {
    let user = User.template
      |> \.avatar.medium .~ "http://coolpic.com/cool.jpg"
      |> \.isFriend .~ false
      |> \.name .~ "Squiggles McTwiddle"

    let activity = Activity.template
      |> Activity.lens.user .~ user

    hideFollowButton.assertValueCount(0)
    XCTAssertEqual([], self.trackingClient.events)

    vm.inputs.configureWith(activity: activity)

    hideFollowButton.assertValues([false], "Show Follow Button")

    vm.inputs.followButtonTapped()

    hideFollowButton.assertValues([false], "Follow Button does not change")
    XCTAssertEqual(["Facebook Friend Follow", "Followed Facebook Friend"], self.trackingClient.events)
    XCTAssertEqual(["activity", "activity"],
      self.trackingClient.properties(forKey: "source", as: String.self))
  }

  func testRetainFriendStatusOnReuse_After_Following() {
    let user = User.template
      |> \.avatar.small .~ "http://coolpic.com/cool.jpg"
      |> \.isFriend .~ false
      |> \.name .~ "Squiggles McTwiddle"

    let activity = Activity.template
      |> Activity.lens.user .~ user

    hideFollowButton.assertValueCount(0)

    vm.inputs.configureWith(activity: activity)

    hideFollowButton.assertValues([false], "Show Follow Button")

    vm.inputs.followButtonTapped()
    scheduler.advance()
  }
}
