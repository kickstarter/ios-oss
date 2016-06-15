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
final class FindFriendsFriendFollowCellViewModelTests: TestCase {
  // swiftlint:enable type_name
  let vm: FindFriendsFriendFollowCellViewModelType = FindFriendsFriendFollowCellViewModel()

  let enableFollowButton = TestObserver<Bool, NoError>()
  let enableUnfollowButton = TestObserver<Bool, NoError>()
  let imageURL = TestObserver<String?, NoError>()
  let location = TestObserver<String, NoError>()
  let friendName = TestObserver<String, NoError>()
  let projectsBackedText = TestObserver<String, NoError>()
  let projectsCreatedText = TestObserver<String, NoError>()
  let hideFollowButton = TestObserver<Bool, NoError>()
  let hideUnfollowButton = TestObserver<Bool, NoError>()
  let hideProjectsCreated = TestObserver<Bool, NoError>()

  override func setUp() {
    super.setUp()

    vm.outputs.enableFollowButton.observe(enableFollowButton.observer)
    vm.outputs.enableUnfollowButton.observe(enableUnfollowButton.observer)
    vm.outputs.imageURL.map { $0?.absoluteString }.observe(imageURL.observer)
    vm.outputs.location.observe(location.observer)
    vm.outputs.name.observe(friendName.observer)
    vm.outputs.projectsBackedText.observe(projectsBackedText.observer)
    vm.outputs.projectsCreatedText.observe(projectsCreatedText.observer)
    vm.outputs.hideFollowButton.observe(hideFollowButton.observer)
    vm.outputs.hideUnfollowButton.observe(hideUnfollowButton.observer)
    vm.outputs.hideProjectsCreated.observe(hideProjectsCreated.observer)
  }

  func testFriendDetails_Complete() {
    let brooklyn = Location.template
      |> Location.lens.displayableName .~ "Brooklyn, NY"

    let friend = User.template
      |> User.lens.avatar.medium .~ "http://coolpic.com/cool.jpg"
      |> User.lens.id .~ 145
      |> User.lens.location .~ brooklyn
      |> User.lens.name .~ "Jed"
      |> User.lens.stats.backedProjectsCount .~ 20
      |> User.lens.stats.createdProjectsCount .~ 2

    imageURL.assertValueCount(0)
    location.assertValueCount(0)
    friendName.assertValueCount(0)
    projectsBackedText.assertValueCount(0)
    projectsCreatedText.assertValueCount(0)
    hideProjectsCreated.assertValueCount(0)

    vm.inputs.configureWith(friend: friend, source: FriendsSource.settings)

    imageURL.assertValues(["http://coolpic.com/cool.jpg"])
    location.assertValues(["Brooklyn, NY"])
    friendName.assertValues(["Jed"])
    projectsBackedText.assertValues(["20 backed"])
    projectsCreatedText.assertValues(["2 created"])
    hideProjectsCreated.assertValues([false], "Show projects created text")
  }

  func testFriendDetails_Incomplete() {
    let friend = User.template
      |> User.lens.name .~ "Ned"

    location.assertValueCount(0)
    friendName.assertValueCount(0)
    projectsBackedText.assertValueCount(0)
    hideProjectsCreated.assertValueCount(0)

    vm.inputs.configureWith(friend: friend, source: FriendsSource.settings)

    imageURL.assertValueCount(1)
    location.assertValues([""], "Location emits empty string")
    friendName.assertValues(["Ned"])
    projectsBackedText.assertValues(["0 backed"], "Projects text emits")
    projectsCreatedText.assertValueCount(0, "Created projects does not emit")
    hideProjectsCreated.assertValues([false], "Hide projects created text")
  }

  func testFollowing_Friend() {
    let friend = User.template
      |> User.lens.name .~ "Jed"
      |> User.lens.id .~ 245
      |> User.lens.isFriend .~ true

    hideFollowButton.assertValueCount(0)
    hideUnfollowButton.assertValueCount(0)
    enableFollowButton.assertValueCount(0)
    enableUnfollowButton.assertValueCount(0)

    vm.inputs.configureWith(friend: friend, source: FriendsSource.activity)

    hideFollowButton.assertValues([true], "Hide Follow Button")
    hideUnfollowButton.assertValues([false], "Show Unfollow Button")
    enableFollowButton.assertValues([false], "Disable Follow Button")
    enableUnfollowButton.assertValues([true], "Enable Unfollow Button")
    XCTAssertEqual([], self.trackingClient.events)

    vm.inputs.unfollowButtonTapped()

    hideFollowButton.assertValues([true], "Follow Button does not change")
    hideUnfollowButton.assertValues([false], "Unfollow Button does not change")
    enableFollowButton.assertValues([false], "Enable Follow Button does not emit")
    enableUnfollowButton.assertValues([true, false, true],
                                      "Enable Unfollow Button emits false/true with loader")
    XCTAssertEqual(["Facebook Friend Unfollow"], self.trackingClient.events)
    XCTAssertEqual(["activity"], self.trackingClient.properties.map { $0["source"] as! String? })

    scheduler.advance()

    hideFollowButton.assertValues([true, false], "Show Follow Button")
    hideUnfollowButton.assertValues([false, true], "Hide Unfollow Button")
    enableFollowButton.assertValues([false, true], "Enable Follow Button")
    enableUnfollowButton.assertValues([true, false, true, false], "Disable Unfollow Button")

    vm.inputs.followButtonTapped()

    hideFollowButton.assertValues([true, false], "Follow Button does not change")
    hideUnfollowButton.assertValues([false, true], "Unfollow Button does not change")
    enableFollowButton.assertValues([false, true, false, true],
                                    "Enable Follow Button emits false/true with loader")
    enableUnfollowButton.assertValues([true, false, true, false], "Unfollow Button does not change")
    XCTAssertEqual(["Facebook Friend Unfollow", "Facebook Friend Follow"], self.trackingClient.events)
    XCTAssertEqual(["activity", "activity"], self.trackingClient.properties.map { $0["source"] as! String? })

    scheduler.advance()

    hideFollowButton.assertValues([true, false, true], "Hide Follow Button")
    hideUnfollowButton.assertValues([false, true, false], "Show Unfollow Button")
    enableFollowButton.assertValues([false, true, false, true, false], "Disable Follow Button")
    enableUnfollowButton.assertValues([true, false, true, false, true], "Enable Unfollow Button")

    vm.inputs.unfollowButtonTapped()

    hideFollowButton.assertValues([true, false, true], "Follow Button does not change")
    hideUnfollowButton.assertValues([false, true, false], "Unfollow Button does not change")
    enableFollowButton.assertValues([false, true, false, true, false], "Enable Follow Button does not emit")
    enableUnfollowButton.assertValues([true, false, true, false, true, false, true],
                                      "Enable Unfollow Button emits false/true with loader")
    XCTAssertEqual(["Facebook Friend Unfollow", "Facebook Friend Follow", "Facebook Friend Unfollow"],
                   self.trackingClient.events)
    XCTAssertEqual(["activity", "activity", "activity"],
                   self.trackingClient.properties.map { $0["source"] as! String? })

    scheduler.advance()

    hideFollowButton.assertValues([true, false, true, false], "Show Follow Button")
    hideUnfollowButton.assertValues([false, true, false, true], "Hide Unfollow Button")
    enableFollowButton.assertValues([false, true, false, true, false, true], "Enable Follow Button")
    enableUnfollowButton.assertValues([true, false, true, false, true, false, true, false],
                                      "Disable Unfollow Button")
  }

  func testFollowing_NonFriend() {
    let friend = User.template
      |> User.lens.name .~ "Zed"
      |> User.lens.id .~ 200
      |> User.lens.isFriend .~ false

    hideFollowButton.assertValueCount(0)
    hideUnfollowButton.assertValueCount(0)
    enableFollowButton.assertValueCount(0)
    enableUnfollowButton.assertValueCount(0)

    vm.inputs.configureWith(friend: friend, source: FriendsSource.activity)

    hideFollowButton.assertValues([false], "Show Follow Button")
    hideUnfollowButton.assertValues([true], "Hide Unfollow Button")
    enableFollowButton.assertValues([true], "Enable Follow Button")
    enableUnfollowButton.assertValues([false], "Disable Unfollow Button")
    XCTAssertEqual([], self.trackingClient.events)

    vm.inputs.followButtonTapped()

    hideFollowButton.assertValues([false], "Follow Button does not change")
    hideUnfollowButton.assertValues([true], "Unfollow Button does not change")
    enableFollowButton.assertValues([true, false, true],
                                    "Enable Unfollow Button emits false/true with loader")
    enableUnfollowButton.assertValues([false], "Enable Unfollow Button does not emit")
    XCTAssertEqual(["Facebook Friend Follow"], self.trackingClient.events)
    XCTAssertEqual(["activity"], self.trackingClient.properties.map { $0["source"] as! String? })

    scheduler.advance()

    hideFollowButton.assertValues([false, true], "Hide Follow Button")
    hideUnfollowButton.assertValues([true, false], "Show Unfollow Button")
    enableFollowButton.assertValues([true, false, true, false], "Disable Follow Button")
    enableUnfollowButton.assertValues([false, true], "Enable Unfollow Button")
    XCTAssertEqual(["Facebook Friend Follow"], self.trackingClient.events, "Tracking does not change")
    XCTAssertEqual(["activity"], self.trackingClient.properties.map { $0["source"] as! String? })

    vm.inputs.unfollowButtonTapped()

    hideFollowButton.assertValues([false, true], "Follow Button does not change")
    hideUnfollowButton.assertValues([true, false], "Unfollow Button does not change")
    enableFollowButton.assertValues([true, false, true, false], "Enable Follow Button does not emit")
    enableUnfollowButton.assertValues([false, true, false, true],
                                      "Enable Unfollow Button emits false/true with loader")
    XCTAssertEqual(["Facebook Friend Follow", "Facebook Friend Unfollow"], self.trackingClient.events)
    XCTAssertEqual(["activity", "activity"], self.trackingClient.properties.map { $0["source"] as! String? })

    scheduler.advance()

    hideFollowButton.assertValues([false, true, false], "Show Follow Button")
    hideUnfollowButton.assertValues([true, false, true], "Hide Unfollow Button")
    enableFollowButton.assertValues([true, false, true, false, true], "Enable Follow Button")
    enableUnfollowButton.assertValues([false, true, false, true, false], "Disable Unfollow Button")
    XCTAssertEqual(["Facebook Friend Follow", "Facebook Friend Unfollow"],
                   self.trackingClient.events, "Tracking does not change")
    XCTAssertEqual(["activity", "activity"], self.trackingClient.properties.map { $0["source"] as! String? })

    vm.inputs.followButtonTapped()

    hideFollowButton.assertValues([false, true, false], "Follow Button does not change")
    hideUnfollowButton.assertValues([true, false, true], "Unfollow Button does not change")
    enableFollowButton.assertValues([true, false, true, false, true, false, true],
                                    "Enable Follow Button emits false/true with loader")
    enableUnfollowButton.assertValues([false, true, false, true, false], "Unfollow Button does not change")
    XCTAssertEqual(["Facebook Friend Follow", "Facebook Friend Unfollow", "Facebook Friend Follow"],
                   self.trackingClient.events)
    XCTAssertEqual(["activity", "activity", "activity"],
                   self.trackingClient.properties.map { $0["source"] as! String? })

    scheduler.advance()

    hideFollowButton.assertValues([false, true, false, true], "Hide Follow Button")
    hideUnfollowButton.assertValues([true, false, true, false], "Show Unfollow Button")
    enableFollowButton.assertValues([true, false, true, false, true, false, true, false],
                                    "Disable Follow Button")
    enableUnfollowButton.assertValues([false, true, false, true, false, true], "Enable Unfollow Button")
    XCTAssertEqual(["Facebook Friend Follow", "Facebook Friend Unfollow", "Facebook Friend Follow"],
                   self.trackingClient.events, "Tracking does not change")
    XCTAssertEqual(["activity", "activity", "activity"],
                   self.trackingClient.properties.map { $0["source"] as! String? })
  }

  func testRetainFriendStatusOnReuse_After_Following() {
    let friend = User.template
      |> User.lens.name .~ "Zed"
      |> User.lens.id .~ 200
      |> User.lens.isFriend .~ false

    hideFollowButton.assertValueCount(0)
    hideUnfollowButton.assertValueCount(0)
    enableFollowButton.assertValueCount(0)
    enableUnfollowButton.assertValueCount(0)

    vm.inputs.configureWith(friend: friend, source: FriendsSource.activity)

    hideFollowButton.assertValues([false], "Show Follow Button")
    hideUnfollowButton.assertValues([true], "Hide Unfollow Button")
    enableFollowButton.assertValues([true], "Enable Follow Button")
    enableUnfollowButton.assertValues([false], "Disable Unfollow Button")

    vm.inputs.followButtonTapped()

    hideFollowButton.assertValues([false], "Follow Button does not change")
    hideUnfollowButton.assertValues([true], "Unfollow Button does not change")
    enableFollowButton.assertValues([true, false, true],
                                    "Enable Unfollow Button emits false/true with loader")
    enableUnfollowButton.assertValues([false], "Enable Unfollow Button does not emit")

    scheduler.advance()

    hideFollowButton.assertValues([false, true], "Hide Follow Button")
    hideUnfollowButton.assertValues([true, false], "Show Unfollow Button")
    enableFollowButton.assertValues([true, false, true, false], "Disable Follow Button")
    enableUnfollowButton.assertValues([false, true], "Enable Unfollow Button")

    let vm2: FindFriendsFriendFollowCellViewModelType = FindFriendsFriendFollowCellViewModel()
    let hideFollowButton2 = TestObserver<Bool, NoError>()
    let hideUnfollowButton2 = TestObserver<Bool, NoError>()
    let enableFollowButton2 = TestObserver<Bool, NoError>()
    let enableUnfollowButton2 = TestObserver<Bool, NoError>()
    vm2.outputs.hideFollowButton.observe(hideFollowButton2.observer)
    vm2.outputs.hideUnfollowButton.observe(hideUnfollowButton2.observer)
    vm2.outputs.enableFollowButton.observe(enableFollowButton2.observer)
    vm2.outputs.enableUnfollowButton.observe(enableUnfollowButton2.observer)

    hideFollowButton2.assertValueCount(0)
    hideUnfollowButton2.assertValueCount(0)
    enableFollowButton2.assertValueCount(0)
    enableUnfollowButton2.assertValueCount(0)

    vm2.inputs.configureWith(friend: friend, source: FriendsSource.activity)

    hideFollowButton2.assertValues([true], "Hide Follow Button")
    hideUnfollowButton2.assertValues([false], "Show Unfollow Button")
    enableFollowButton2.assertValues([false], "Disable Follow Button")
    enableUnfollowButton2.assertValues([true], "Enable Unfollow Button")
  }

  func testRetainFriendStatusOnReuse_After_Unfollowing() {
    let friend = User.template
      |> User.lens.name .~ "Nerd"
      |> User.lens.id .~ 208
      |> User.lens.isFriend .~ true

    hideFollowButton.assertValueCount(0)
    hideUnfollowButton.assertValueCount(0)
    enableFollowButton.assertValueCount(0)
    enableUnfollowButton.assertValueCount(0)

    vm.inputs.configureWith(friend: friend, source: FriendsSource.activity)

    hideFollowButton.assertValues([true], "Hide Follow Button")
    hideUnfollowButton.assertValues([false], "Show Unfollow Button")
    enableFollowButton.assertValues([false], "Disable Follow Button")
    enableUnfollowButton.assertValues([true], "Enable Unfollow Button")

    vm.inputs.unfollowButtonTapped()

    hideFollowButton.assertValues([true], "Follow Button does not change")
    hideUnfollowButton.assertValues([false], "Unfollow Button does not change")
    enableFollowButton.assertValues([false], "Enable Follow Button does not emit")
    enableUnfollowButton.assertValues([true, false, true],
                                      "Enable Unfollow Button emits false/true with loader")
    XCTAssertEqual(["Facebook Friend Unfollow"], self.trackingClient.events)
    XCTAssertEqual(["activity"], self.trackingClient.properties.map { $0["source"] as! String? })

    scheduler.advance()

    hideFollowButton.assertValues([true, false], "Show Follow Button")
    hideUnfollowButton.assertValues([false, true], "Hide Unfollow Button")
    enableFollowButton.assertValues([false, true], "Enable Follow Button")
    enableUnfollowButton.assertValues([true, false, true, false], "Disable Unfollow Button")

    let vm2: FindFriendsFriendFollowCellViewModelType = FindFriendsFriendFollowCellViewModel()
    let hideFollowButton2 = TestObserver<Bool, NoError>()
    let hideUnfollowButton2 = TestObserver<Bool, NoError>()
    let enableFollowButton2 = TestObserver<Bool, NoError>()
    let enableUnfollowButton2 = TestObserver<Bool, NoError>()
    vm2.outputs.hideFollowButton.observe(hideFollowButton2.observer)
    vm2.outputs.hideUnfollowButton.observe(hideUnfollowButton2.observer)
    vm2.outputs.enableFollowButton.observe(enableFollowButton2.observer)
    vm2.outputs.enableUnfollowButton.observe(enableUnfollowButton2.observer)

    hideFollowButton2.assertValueCount(0)
    hideUnfollowButton2.assertValueCount(0)
    enableFollowButton2.assertValueCount(0)
    enableUnfollowButton2.assertValueCount(0)

    vm2.inputs.configureWith(friend: friend, source: FriendsSource.activity)

    hideFollowButton2.assertValues([false], "Show Follow Button")
    hideUnfollowButton2.assertValues([true], "Hide Unfollow Button")
    enableFollowButton2.assertValues([true], "Enable Follow Button")
    enableUnfollowButton2.assertValues([false], "Disable Unfollow Button")
  }

  func testFollowFriend_WithError() {
    let error = ErrorEnvelope(
      errorMessages: ["Something went wrong."],
      ksrCode: .UnknownCode,
      httpCode: 404,
      exception: nil
    )

    let friend = User.template
      |> User.lens.name .~ "Zed"
      |> User.lens.id .~ 200
      |> User.lens.isFriend .~ false

    withEnvironment(apiService: MockService(followFriendError: error)) {
      hideFollowButton.assertValueCount(0)
      hideUnfollowButton.assertValueCount(0)
      enableFollowButton.assertValueCount(0)
      enableUnfollowButton.assertValueCount(0)

      vm.inputs.configureWith(friend: friend, source: FriendsSource.activity)

      hideFollowButton.assertValues([false], "Show Follow Button")
      hideUnfollowButton.assertValues([true], "Hide Unfollow Button")
      enableFollowButton.assertValues([true], "Enable Follow Button")
      enableUnfollowButton.assertValues([false], "Disable Unfollow Button")
      XCTAssertEqual([], self.trackingClient.events)

      vm.inputs.followButtonTapped()

      hideFollowButton.assertValues([false], "Follow Button does not change")
      hideUnfollowButton.assertValues([true], "Unfollow Button does not change")
      enableFollowButton.assertValues([true, false, true],
                                      "Enable Unfollow Button emits false/true with loader")
      enableUnfollowButton.assertValues([false], "Enable Unfollow Button does not emit")
      XCTAssertEqual(["Facebook Friend Follow"], self.trackingClient.events)
      XCTAssertEqual(["activity"], self.trackingClient.properties.map { $0["source"] as! String? })

      scheduler.advance()

      hideFollowButton.assertValues([false], "Follow Button does not emit")
      hideUnfollowButton.assertValues([true], "Unfollow Button does not emit")
      enableFollowButton.assertValues([true, false, true], "Follow Button remains enabled")
      enableUnfollowButton.assertValues([false], "Enable Unfollow Button does not emit")
      XCTAssertEqual(["Facebook Friend Follow"], self.trackingClient.events, "Tracking does not change")
      XCTAssertEqual(["activity"], self.trackingClient.properties.map { $0["source"] as! String? })
    }
  }

  func testUnfollowFriend_WithError() {
    let error = ErrorEnvelope(
      errorMessages: ["Something went wrong."],
      ksrCode: .UnknownCode,
      httpCode: 404,
      exception: nil
    )

    let friend = User.template
      |> User.lens.name .~ "Jed"
      |> User.lens.id .~ 245
      |> User.lens.isFriend .~ true

    withEnvironment(apiService: MockService(unfollowFriendError: error)) {
      hideFollowButton.assertValueCount(0)
      hideUnfollowButton.assertValueCount(0)
      enableFollowButton.assertValueCount(0)
      enableUnfollowButton.assertValueCount(0)

      vm.inputs.configureWith(friend: friend, source: FriendsSource.activity)

      hideFollowButton.assertValues([true], "Hide Follow Button")
      hideUnfollowButton.assertValues([false], "Show Unfollow Button")
      enableFollowButton.assertValues([false], "Disable Follow Button")
      enableUnfollowButton.assertValues([true], "Enable Unfollow Button")
      XCTAssertEqual([], self.trackingClient.events)

      vm.inputs.unfollowButtonTapped()

      hideFollowButton.assertValues([true], "Follow Button does not change")
      hideUnfollowButton.assertValues([false], "Unfollow Button does not change")
      enableFollowButton.assertValues([false], "Enable Follow Button does not emit")
      enableUnfollowButton.assertValues([true, false, true],
                                        "Enable Unfollow Button emits false/true with loader")
      XCTAssertEqual(["Facebook Friend Unfollow"], self.trackingClient.events)
      XCTAssertEqual(["activity"], self.trackingClient.properties.map { $0["source"] as! String? })

      scheduler.advance()

      hideFollowButton.assertValues([true], "Follow Button does not emit")
      hideUnfollowButton.assertValues([false], "Unfollow Button does not emit")
      enableFollowButton.assertValues([false], "Follow Button remains disabled")
      enableUnfollowButton.assertValues([true, false, true], "Unfollow Button remains enabled")
      XCTAssertEqual(["Facebook Friend Unfollow"], self.trackingClient.events, "Tracking does not change")
      XCTAssertEqual(["activity"], self.trackingClient.properties.map { $0["source"] as! String? })
    }
  }
}
