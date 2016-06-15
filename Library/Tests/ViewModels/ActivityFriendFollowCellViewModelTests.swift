import XCTest
import ReactiveCocoa
import UIKit.UIActivity
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers
@testable import Result
@testable import KsApi
@testable import KsApi_TestHelpers
@testable import Library
import Prelude

// swiftlint:disable type_name
final class ActivityFriendFollowCellViewModelTests: TestCase {
  // swiftlint:enable type_name
  let vm: ActivityFriendFollowCellViewModel = ActivityFriendFollowCellViewModel()
  let hideFollowButton = TestObserver<Bool, NoError>()
  let friendImageURL = TestObserver<String?, NoError>()
  let title = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()

    vm.outputs.hideFollowButton.observe(hideFollowButton.observer)
    vm.outputs.friendImageURL.map { $0?.absoluteString }.observe(friendImageURL.observer)
    vm.outputs.title.observe(title.observer)
  }

  func testFriendDetails_Complete() {
    let user = User.template
      |> User.lens.avatar.medium .~ "http://coolpic.com/cool.jpg"
      |> User.lens.name .~ "Squiggles McTwiddle"

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
      |> User.lens.name .~ "Squiggles McTwiddle"

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
      |> User.lens.avatar.medium .~ "http://coolpic.com/cool.jpg"
      |> User.lens.isFriend .~ true
      |> User.lens.name .~ "Squiggles McTwiddle"

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
      |> User.lens.avatar.medium .~ "http://coolpic.com/cool.jpg"
      |> User.lens.isFriend .~ false
      |> User.lens.name .~ "Squiggles McTwiddle"

    let activity = Activity.template
      |> Activity.lens.user .~ user

    hideFollowButton.assertValueCount(0)
    XCTAssertEqual([], self.trackingClient.events)

    vm.inputs.configureWith(activity: activity)

    hideFollowButton.assertValues([false], "Show Follow Button")

    vm.inputs.followButtonTapped()

    hideFollowButton.assertValues([false], "Follow Button does not change")
    XCTAssertEqual(["Facebook Friend Follow"], self.trackingClient.events)
    XCTAssertEqual(["activity"], self.trackingClient.properties.map { $0["source"] as! String? })

    scheduler.advance()

    hideFollowButton.assertValues([false, true], "Hide Follow Button")
  }

  func testRetainFriendStatusOnReuse_After_Following() {
    let user = User.template
      |> User.lens.avatar.medium .~ "http://coolpic.com/cool.jpg"
      |> User.lens.isFriend .~ false
      |> User.lens.name .~ "Squiggles McTwiddle"

    let activity = Activity.template
      |> Activity.lens.user .~ user

    hideFollowButton.assertValueCount(0)

    vm.inputs.configureWith(activity: activity)

    hideFollowButton.assertValues([false], "Show Follow Button")

    vm.inputs.followButtonTapped()
    scheduler.advance()

    hideFollowButton.assertValues([false, true], "Hide Follow Button")

    let vm2: ActivityFriendFollowCellViewModel = ActivityFriendFollowCellViewModel()
    let hideFollowButton2 = TestObserver<Bool, NoError>()
    vm2.outputs.hideFollowButton.observe(hideFollowButton2.observer)

    hideFollowButton2.assertValueCount(0)

    vm2.inputs.configureWith(activity: activity)

    hideFollowButton2.assertValues([true], "Hide Follow Button")
  }
}
