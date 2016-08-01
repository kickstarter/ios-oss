import Prelude
import ReactiveCocoa
import Result
import XCTest
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers

internal final class ActivitySampleBackingCellViewModelTests: TestCase {
  internal let vm = ActivitySampleBackingCellViewModel()
  internal let backingTitleText = TestObserver<String, NoError>()
  internal let backerImage = TestObserver<String?, NoError>()
  internal let goToActivity = TestObserver<Void, NoError>()

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.backingTitleText.map { $0.string }.observe(self.backingTitleText.observer)
    self.vm.outputs.backerImageURL.map { $0?.absoluteString }.observe(self.backerImage.observer)
    self.vm.outputs.goToActivity.observe(self.goToActivity.observer)
  }

  func testBackingDataEmits() {
    let backer = .template
      |> User.lens.name .~ "Best Friend"
      |> User.lens.avatar.medium .~ "http://coolpic.com/cool.png"

    let creator = .template
      |> User.lens.name .~ "Super Cool Creator"

    let project = .template
      |> Project.lens.name .~ "Super Sweet Project Name"
      |> Project.lens.creator .~ creator

    let activity = .template
      |> Activity.lens.category .~ .backing
      |> Activity.lens.project .~ project
      |> Activity.lens.user .~ backer

    self.vm.inputs.configureWith(activity: activity)

    self.backingTitleText.assertValues(["Best Friend backed Super Sweet Project Name by Super Cool Creator"],
                                       "Attributed backing string emits.")
    self.backerImage.assertValues([backer.avatar.medium])
  }

  func testGoToActivity() {
    let activity = Activity.template

    self.vm.inputs.configureWith(activity: activity)
    self.vm.inputs.seeAllActivityTapped()

    self.goToActivity.assertValueCount(1)
  }
}
