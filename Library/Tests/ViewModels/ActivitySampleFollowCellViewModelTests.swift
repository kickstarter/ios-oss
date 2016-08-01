import Prelude
import ReactiveCocoa
import Result
import XCTest
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers

internal final class ActivitySampleFollowCellViewModelTests: TestCase {
  internal let vm = ActivitySampleFollowCellViewModel()
  internal let friendFollowText = TestObserver<String, NoError>()
  internal let friendImage = TestObserver<String?, NoError>()
  internal let goToActivity = TestObserver<Void, NoError>()

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.friendFollowText.observe(self.friendFollowText.observer)
    self.vm.outputs.friendImageURL.map { $0?.absoluteString }.observe(self.friendImage.observer)
    self.vm.outputs.goToActivity.observe(self.goToActivity.observer)
  }

  func testFriendFollowDataEmits() {
    let user = .template
      |> User.lens.name .~ "Cool Person"
      |> User.lens.avatar.medium .~ "http://coolpic.com/cool.png"

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
