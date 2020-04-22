@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import UIKit.UIActivity
import XCTest

final class FindFriendsFriendFollowCellViewModelTests: TestCase {
  let vm: FindFriendsFriendFollowCellViewModelType = FindFriendsFriendFollowCellViewModel()

  let cellAccessibilityValue = TestObserver<String, Never>()
  let enableFollowButton = TestObserver<Bool, Never>()
  let enableUnfollowButton = TestObserver<Bool, Never>()
  let followButtonAccessibilityLabel = TestObserver<String, Never>()
  let imageURL = TestObserver<String?, Never>()
  let location = TestObserver<String, Never>()
  let friendName = TestObserver<String, Never>()
  let projectsBackedText = TestObserver<String, Never>()
  let projectsCreatedText = TestObserver<String, Never>()
  let hideFollowButton = TestObserver<Bool, Never>()
  let hideUnfollowButton = TestObserver<Bool, Never>()
  let hideProjectsCreated = TestObserver<Bool, Never>()
  let unfollowButtonAccessibilityLabel = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.enableFollowButton.observe(self.enableFollowButton.observer)
    self.vm.outputs.enableUnfollowButton.observe(self.enableUnfollowButton.observer)
    self.vm.outputs.imageURL.map { $0?.absoluteString }.observe(self.imageURL.observer)
    self.vm.outputs.location.observe(self.location.observer)
    self.vm.outputs.name.observe(self.friendName.observer)
    self.vm.outputs.projectsBackedText.observe(self.projectsBackedText.observer)
    self.vm.outputs.projectsCreatedText.observe(self.projectsCreatedText.observer)
    self.vm.outputs.hideFollowButton.observe(self.hideFollowButton.observer)
    self.vm.outputs.hideUnfollowButton.observe(self.hideUnfollowButton.observer)
    self.vm.outputs.hideProjectsCreated.observe(self.hideProjectsCreated.observer)
    self.vm.outputs.followButtonAccessibilityLabel.observe(self.followButtonAccessibilityLabel.observer)
    self.vm.outputs.unfollowButtonAccessibilityLabel.observe(self.unfollowButtonAccessibilityLabel.observer)
    self.vm.outputs.cellAccessibilityValue.observe(self.cellAccessibilityValue.observer)
  }

  func testFriendDetails_Complete() {
    let brooklyn = Location.template
      |> Location.lens.displayableName .~ "Brooklyn, NY"

    let friend = User.template
      |> \.avatar.medium .~ "http://coolpic.com/cool.jpg"
      |> \.id .~ 145
      |> \.location .~ brooklyn
      |> \.name .~ "Jed"
      |> \.stats.backedProjectsCount .~ 20
      |> \.stats.createdProjectsCount .~ 2

    self.imageURL.assertValueCount(0)
    self.location.assertValueCount(0)
    self.friendName.assertValueCount(0)
    self.projectsBackedText.assertValueCount(0)
    self.projectsCreatedText.assertValueCount(0)
    self.hideProjectsCreated.assertValueCount(0)

    self.vm.inputs.configureWith(friend: friend, source: FriendsSource.settings)

    self.imageURL.assertValues(["http://coolpic.com/cool.jpg"])
    self.location.assertValues(["Brooklyn, NY"])
    self.friendName.assertValues(["Jed"])
    self.projectsBackedText.assertValues(["20 backed"])
    self.projectsCreatedText.assertValues(["2 created"])
    self.hideProjectsCreated.assertValues([false], "Show projects created text")
  }

  func testFriendDetails_Incomplete() {
    let friend = User.template
      |> \.name .~ "Ned"

    self.location.assertValueCount(0)
    self.friendName.assertValueCount(0)
    self.projectsBackedText.assertValueCount(0)
    self.hideProjectsCreated.assertValueCount(0)

    self.vm.inputs.configureWith(friend: friend, source: FriendsSource.settings)

    self.imageURL.assertValueCount(1)
    self.location.assertValues([""], "Location emits empty string")
    self.friendName.assertValues(["Ned"])
    self.projectsBackedText.assertValues(["0 backed"], "Projects text emits")
    self.projectsCreatedText.assertValueCount(0, "Created projects does not emit")
    self.hideProjectsCreated.assertValues([true], "Hide projects created text")
  }

  func testFollowing_Friend() {
    let friend = User.template
      |> \.name .~ "Jed"
      |> \.id .~ 245
      |> \.isFriend .~ true

    self.hideFollowButton.assertValueCount(0)
    self.hideUnfollowButton.assertValueCount(0)
    self.enableFollowButton.assertValueCount(0)
    self.enableUnfollowButton.assertValueCount(0)
    self.followButtonAccessibilityLabel.assertValueCount(0)
    self.unfollowButtonAccessibilityLabel.assertValueCount(0)
    self.cellAccessibilityValue.assertValueCount(0)

    self.vm.inputs.configureWith(friend: friend, source: FriendsSource.activity)

    self.hideFollowButton.assertValues([true], "Hide Follow Button")
    self.hideUnfollowButton.assertValues([false], "Show Unfollow Button")
    self.enableFollowButton.assertValues([false], "Disable Follow Button")
    self.enableUnfollowButton.assertValues([true], "Enable Unfollow Button")
    self.followButtonAccessibilityLabel
      .assertValues(["Follow Jed"], "Accessibility label assigned to the Button")
    self.unfollowButtonAccessibilityLabel.assertValues(
      ["Unfollow Jed"],
      "Accessibility label assigned to the Button"
    )
    self.cellAccessibilityValue.assertValues(["Followed"])

    XCTAssertEqual([], self.trackingClient.events)

    self.vm.inputs.unfollowButtonTapped()

    self.hideFollowButton.assertValues([true], "Follow Button does not change")
    self.hideUnfollowButton.assertValues([false], "Unfollow Button does not change")
    self.enableFollowButton.assertValues([false], "Enable Follow Button does not emit")
    self.enableUnfollowButton.assertValues(
      [true, false, true],
      "Enable Unfollow Button emits false/true with loader"
    )
    XCTAssertEqual(["Facebook Friend Unfollow", "Unfollowed Facebook Friend"], self.trackingClient.events)
    XCTAssertEqual(["activity", "activity"], self.trackingClient.properties.map { $0["source"] as! String? })

    self.followButtonAccessibilityLabel
      .assertValues(["Follow Jed"], "Accessibility label assigned to the Button")
    self.unfollowButtonAccessibilityLabel.assertValues(
      ["Unfollow Jed"],
      "Accessibility label assigned to the Button"
    )

    scheduler.advance()

    self.hideFollowButton.assertValues([true, false], "Show Follow Button")
    self.hideUnfollowButton.assertValues([false, true], "Hide Unfollow Button")
    self.enableFollowButton.assertValues([false, true], "Enable Follow Button")
    self.enableUnfollowButton.assertValues([true, false, true, false], "Disable Unfollow Button")
    self.cellAccessibilityValue.assertValues(["Followed", "Not followed"])

    self.vm.inputs.followButtonTapped()

    self.hideFollowButton.assertValues([true, false], "Follow Button does not change")
    self.hideUnfollowButton.assertValues([false, true], "Unfollow Button does not change")
    self.enableFollowButton.assertValues(
      [false, true, false, true],
      "Enable Follow Button emits false/true with loader"
    )
    self.enableUnfollowButton.assertValues([true, false, true, false], "Unfollow Button does not change")
    XCTAssertEqual([
      "Facebook Friend Unfollow", "Unfollowed Facebook Friend",
      "Facebook Friend Follow", "Followed Facebook Friend"
    ], self.trackingClient.events)
    XCTAssertEqual([
      "activity", "activity",
      "activity", "activity"
    ], self.trackingClient.properties.map { $0["source"] as! String? })

    scheduler.advance()

    self.hideFollowButton.assertValues([true, false, true], "Hide Follow Button")
    self.hideUnfollowButton.assertValues([false, true, false], "Show Unfollow Button")
    self.enableFollowButton.assertValues([false, true, false, true, false], "Disable Follow Button")
    self.enableUnfollowButton.assertValues([true, false, true, false, true], "Enable Unfollow Button")
    self.cellAccessibilityValue.assertValues(["Followed", "Not followed", "Followed"])

    self.vm.inputs.unfollowButtonTapped()

    self.hideFollowButton.assertValues([true, false, true], "Follow Button does not change")
    self.hideUnfollowButton.assertValues([false, true, false], "Unfollow Button does not change")
    self.enableFollowButton
      .assertValues([false, true, false, true, false], "Enable Follow Button does not emit")
    self.enableUnfollowButton.assertValues(
      [true, false, true, false, true, false, true],
      "Enable Unfollow Button emits false/true with loader"
    )
    XCTAssertEqual(
      [
        "Facebook Friend Unfollow", "Unfollowed Facebook Friend",
        "Facebook Friend Follow", "Followed Facebook Friend",
        "Facebook Friend Unfollow", "Unfollowed Facebook Friend"
      ],
      self.trackingClient.events
    )
    XCTAssertEqual([
      "activity", "activity",
      "activity", "activity",
      "activity", "activity"
    ], self.trackingClient.properties.map { $0["source"] as! String? })

    scheduler.advance()

    self.hideFollowButton.assertValues([true, false, true, false], "Show Follow Button")
    self.hideUnfollowButton.assertValues([false, true, false, true], "Hide Unfollow Button")
    self.enableFollowButton.assertValues([false, true, false, true, false, true], "Enable Follow Button")
    self.enableUnfollowButton.assertValues(
      [true, false, true, false, true, false, true, false],
      "Disable Unfollow Button"
    )

    // Accessibility labels remains the same through all the sequences of following/unfollowing
    self.followButtonAccessibilityLabel
      .assertValues(["Follow Jed"], "Accessibility label assigned to the Button")
    self.unfollowButtonAccessibilityLabel.assertValues(
      ["Unfollow Jed"],
      "Accessibility label assigned to the Button"
    )
  }

  func testFollowing_NonFriend() {
    let friend = User.template
      |> \.name .~ "Zed"
      |> \.id .~ 200
      |> \.isFriend .~ false

    self.hideFollowButton.assertValueCount(0)
    self.hideUnfollowButton.assertValueCount(0)
    self.enableFollowButton.assertValueCount(0)
    self.enableUnfollowButton.assertValueCount(0)

    self.vm.inputs.configureWith(friend: friend, source: FriendsSource.activity)

    self.hideFollowButton.assertValues([false], "Show Follow Button")
    self.hideUnfollowButton.assertValues([true], "Hide Unfollow Button")
    self.enableFollowButton.assertValues([true], "Enable Follow Button")
    self.enableUnfollowButton.assertValues([false], "Disable Unfollow Button")
    self.followButtonAccessibilityLabel
      .assertValues(["Follow Zed"], "Accessibility label assigned to the Button")
    self.unfollowButtonAccessibilityLabel.assertValues(
      ["Unfollow Zed"],
      "Accessibility label assigned to the Button"
    )
    XCTAssertEqual([], self.trackingClient.events)

    self.vm.inputs.followButtonTapped()

    self.hideFollowButton.assertValues([false], "Follow Button does not change")
    self.hideUnfollowButton.assertValues([true], "Unfollow Button does not change")
    self.enableFollowButton.assertValues(
      [true, false, true],
      "Enable Unfollow Button emits false/true with loader"
    )
    self.enableUnfollowButton.assertValues([false], "Enable Unfollow Button does not emit")
    XCTAssertEqual(["Facebook Friend Follow", "Followed Facebook Friend"], self.trackingClient.events)
    XCTAssertEqual(["activity", "activity"], self.trackingClient.properties.map { $0["source"] as! String? })

    scheduler.advance()

    self.hideFollowButton.assertValues([false, true], "Hide Follow Button")
    self.hideUnfollowButton.assertValues([true, false], "Show Unfollow Button")
    self.enableFollowButton.assertValues([true, false, true, false], "Disable Follow Button")
    self.enableUnfollowButton.assertValues([false, true], "Enable Unfollow Button")
    XCTAssertEqual(
      ["Facebook Friend Follow", "Followed Facebook Friend"],
      self.trackingClient.events, "Tracking does not change"
    )
    XCTAssertEqual(["activity", "activity"], self.trackingClient.properties.map { $0["source"] as! String? })

    self.vm.inputs.unfollowButtonTapped()

    self.hideFollowButton.assertValues([false, true], "Follow Button does not change")
    self.hideUnfollowButton.assertValues([true, false], "Unfollow Button does not change")
    self.enableFollowButton.assertValues([true, false, true, false], "Enable Follow Button does not emit")
    self.enableUnfollowButton.assertValues(
      [false, true, false, true],
      "Enable Unfollow Button emits false/true with loader"
    )
    XCTAssertEqual(
      [
        "Facebook Friend Follow", "Followed Facebook Friend",
        "Facebook Friend Unfollow", "Unfollowed Facebook Friend"
      ],
      self.trackingClient.events
    )
    XCTAssertEqual([
      "activity", "activity",
      "activity", "activity"
    ], self.trackingClient.properties.map { $0["source"] as! String? })

    scheduler.advance()

    self.hideFollowButton.assertValues([false, true, false], "Show Follow Button")
    self.hideUnfollowButton.assertValues([true, false, true], "Hide Unfollow Button")
    self.enableFollowButton.assertValues([true, false, true, false, true], "Enable Follow Button")
    self.enableUnfollowButton.assertValues([false, true, false, true, false], "Disable Unfollow Button")
    XCTAssertEqual(
      [
        "Facebook Friend Follow", "Followed Facebook Friend",
        "Facebook Friend Unfollow", "Unfollowed Facebook Friend"
      ],
      self.trackingClient.events, "Tracking does not change"
    )
    XCTAssertEqual([
      "activity", "activity",
      "activity", "activity"
    ], self.trackingClient.properties.map { $0["source"] as! String? })

    self.vm.inputs.followButtonTapped()

    self.hideFollowButton.assertValues([false, true, false], "Follow Button does not change")
    self.hideUnfollowButton.assertValues([true, false, true], "Unfollow Button does not change")
    self.enableFollowButton.assertValues(
      [true, false, true, false, true, false, true],
      "Enable Follow Button emits false/true with loader"
    )
    self.enableUnfollowButton
      .assertValues([false, true, false, true, false], "Unfollow Button does not change")
    XCTAssertEqual(
      [
        "Facebook Friend Follow", "Followed Facebook Friend",
        "Facebook Friend Unfollow", "Unfollowed Facebook Friend",
        "Facebook Friend Follow", "Followed Facebook Friend"
      ],
      self.trackingClient.events
    )
    XCTAssertEqual([
      "activity", "activity",
      "activity", "activity",
      "activity", "activity"
    ], self.trackingClient.properties.map { $0["source"] as! String? })

    scheduler.advance()

    self.hideFollowButton.assertValues([false, true, false, true], "Hide Follow Button")
    self.hideUnfollowButton.assertValues([true, false, true, false], "Show Unfollow Button")
    self.enableFollowButton.assertValues(
      [true, false, true, false, true, false, true, false],
      "Disable Follow Button"
    )
    self.enableUnfollowButton.assertValues([false, true, false, true, false, true], "Enable Unfollow Button")
    XCTAssertEqual(
      [
        "Facebook Friend Follow", "Followed Facebook Friend",
        "Facebook Friend Unfollow", "Unfollowed Facebook Friend",
        "Facebook Friend Follow", "Followed Facebook Friend"
      ],
      self.trackingClient.events, "Tracking does not change"
    )
    XCTAssertEqual(
      [
        "activity", "activity",
        "activity", "activity",
        "activity", "activity"
      ],
      self.trackingClient.properties.map { $0["source"] as! String? }
    )
  }

  func testFollowFriend_WithError() {
    let error = ErrorEnvelope(
      errorMessages: ["Something went wrong."],
      ksrCode: .UnknownCode,
      httpCode: 404,
      exception: nil
    )

    let friend = User.template
      |> \.name .~ "Zed"
      |> \.id .~ 200
      |> \.isFriend .~ false

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
      enableFollowButton.assertValues(
        [true, false, true],
        "Enable Unfollow Button emits false/true with loader"
      )
      enableUnfollowButton.assertValues([false], "Enable Unfollow Button does not emit")
      XCTAssertEqual(["Facebook Friend Follow", "Followed Facebook Friend"], self.trackingClient.events)
      XCTAssertEqual(
        ["activity", "activity"],
        self.trackingClient.properties.map { $0["source"] as! String? }
      )

      scheduler.advance()

      hideFollowButton.assertValues([false], "Follow Button does not emit")
      hideUnfollowButton.assertValues([true], "Unfollow Button does not emit")
      enableFollowButton.assertValues([true, false, true], "Follow Button remains enabled")
      enableUnfollowButton.assertValues([false], "Enable Unfollow Button does not emit")
      XCTAssertEqual(
        ["Facebook Friend Follow", "Followed Facebook Friend"],
        self.trackingClient.events, "Tracking does not change"
      )
      XCTAssertEqual(
        ["activity", "activity"],
        self.trackingClient.properties.map { $0["source"] as! String? }
      )
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
      |> \.name .~ "Jed"
      |> \.id .~ 245
      |> \.isFriend .~ true

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
      enableUnfollowButton.assertValues(
        [true, false, true],
        "Enable Unfollow Button emits false/true with loader"
      )
      XCTAssertEqual(["Facebook Friend Unfollow", "Unfollowed Facebook Friend"], self.trackingClient.events)
      XCTAssertEqual(
        ["activity", "activity"],
        self.trackingClient.properties.map { $0["source"] as! String? }
      )

      scheduler.advance()

      hideFollowButton.assertValues([true], "Follow Button does not emit")
      hideUnfollowButton.assertValues([false], "Unfollow Button does not emit")
      enableFollowButton.assertValues([false], "Follow Button remains disabled")
      enableUnfollowButton.assertValues([true, false, true], "Unfollow Button remains enabled")
      XCTAssertEqual(
        ["Facebook Friend Unfollow", "Unfollowed Facebook Friend"],
        self.trackingClient.events, "Tracking does not change"
      )
      XCTAssertEqual(
        ["activity", "activity"],
        self.trackingClient.properties.map { $0["source"] as! String? }
      )
    }
  }

  func testFriendDetails_NilCreatedProjectsCount() {
    let friend = User.template
      |> \.stats.createdProjectsCount .~ nil

    self.hideProjectsCreated.assertValues([])

    self.vm.inputs.configureWith(friend: friend, source: FriendsSource.settings)

    self.hideProjectsCreated.assertValues([true])
  }
}
