@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

internal final class ActivityUpdateViewModelTests: TestCase {
  fileprivate let vm: ActivityUpdateViewModelType = ActivityUpdateViewModel()
  fileprivate let body = TestObserver<String, Never>()
  fileprivate let cellAccessibilityLabel = TestObserver<String, Never>()
  fileprivate let notifyDelegateTappedProjectImage = TestObserver<Activity, Never>()
  fileprivate let projectButtonAccessibilityLabel = TestObserver<String, Never>()
  fileprivate let projectImageURL = TestObserver<String?, Never>()
  fileprivate let projectName = TestObserver<String, Never>()
  fileprivate let sequenceTitle = TestObserver<String, Never>()
  fileprivate let title = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()
    self.vm.outputs.body.observe(self.body.observer)
    self.vm.outputs.cellAccessibilityLabel.observe(self.cellAccessibilityLabel.observer)
    self.vm.outputs.notifyDelegateTappedProjectImage.observe(self.notifyDelegateTappedProjectImage.observer)
    self.vm.outputs.projectButtonAccessibilityLabel.observe(self.projectButtonAccessibilityLabel.observer)
    self.vm.outputs.projectImageURL.map { $0?.absoluteString }.observe(self.projectImageURL.observer)
    self.vm.outputs.projectName.observe(self.projectName.observer)
    self.vm.outputs.sequenceTitle.map { $0.string }.observe(self.sequenceTitle.observer)
    self.vm.outputs.title.observe(self.title.observer)
  }

  func testActivityUpdateDataEmits() {
    let project = Project.template
    let update = Update.template
    let activity = .template
      |> Activity.lens.project .~ project
      |> Activity.lens.update .~ update

    self.vm.inputs.configureWith(activity: activity)

    self.body.assertValues([update.body?.htmlStripped()?.truncated(maxLength: 300) ?? ""])
    self.projectButtonAccessibilityLabel.assertValues([project.name])
    self.projectImageURL.assertValues([project.photo.med])
    self.projectName.assertValues([project.name])
    self.sequenceTitle.assertValues([
      Strings.dashboard_activity_update_number_posted_time_count_days_ago(
        space: " ",
        update_number: Format.wholeNumber(activity.update?.sequence ?? 1),
        time_count_days_ago: Format.relative(secondsInUTC: activity.createdAt)
      ).htmlStripped() ?? ""
    ])
    self.title.assertValues([update.title])
  }

  func testCellAccessibilityDataEmits() {
    let project = Project.template
    let update = Update.template
    let activity = .template
      |> Activity.lens.project .~ project
      |> Activity.lens.update .~ update

    self.vm.inputs.configureWith(activity: activity)

    self.cellAccessibilityLabel.assertValues([
      "\(project.name) "
        + (Strings.dashboard_activity_update_number_posted_time_count_days_ago(
          space: " ",
          update_number: Format.wholeNumber(activity.update?.sequence ?? 1),
          time_count_days_ago: Format.relative(secondsInUTC: activity.createdAt)
        ).htmlStripped() ?? "")
    ], "Cell a11y label emits sequence title.")
  }

  func testTappedProjectImageButton() {
    let project = Project.template
    let update = Update.template
    let activity = .template
      |> Activity.lens.project .~ project
      |> Activity.lens.update .~ update

    self.vm.inputs.configureWith(activity: activity)
    self.vm.inputs.tappedProjectImage()
    self.notifyDelegateTappedProjectImage.assertValues([activity])
  }
}
