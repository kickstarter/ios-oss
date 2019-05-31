@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class ActivitySampleFollowCellViewModelTests: TestCase {
  internal let vm = ActivitySampleFollowCellViewModel()
  internal let friendFollowText = TestObserver<String, Never>()
  internal let friendImage = TestObserver<String?, Never>()
  internal let goToActivity = TestObserver<Void, Never>()

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.friendFollowText.observe(self.friendFollowText.observer)
    self.vm.outputs.friendImageURL.map { $0?.absoluteString }.observe(self.friendImage.observer)
    self.vm.outputs.goToActivity.observe(self.goToActivity.observer)
  }

  func testFriendFollowDataEmits() {
    let user = User.template
      |> \.name .~ "Cool Person"
      |> \.avatar.medium .~ "http://coolpic.com/cool.png"

    let activity = .template
      |> Activity.lens.category .~ .follow
      |> Activity.lens.user .~ user

    self.vm.inputs.configureWith(activity: activity)

    self.friendFollowText.assertValues(
      [Strings.activity_user_name_is_now_following_you(user_name: user.name)]
    )
    self.friendImage.assertValues([user.avatar.medium])
  }

  func testGoToActivity() {
    let activity = Activity.template

    self.vm.inputs.configureWith(activity: activity)
    self.vm.inputs.seeAllActivityTapped()

    self.goToActivity.assertValueCount(1)
  }
}
