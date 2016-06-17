import Prelude
import ReactiveCocoa
import Result
import XCTest
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers

internal final class DashboardActionCellViewModelTests: TestCase {
  internal let vm = DashboardActionCellViewModel()
  internal let goToActivity = TestObserver<Project, NoError>()
  internal let goToMessages = TestObserver<Project, NoError>()
  internal let goToPostUpdate = TestObserver<Project, NoError>()
  internal let lastUpdatePublishedAt = TestObserver<String, NoError>()
  internal let showShareSheet = TestObserver<Project, NoError>()

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.goToActivity.observe(goToActivity.observer)
    self.vm.outputs.goToMessages.observe(goToMessages.observer)
    self.vm.outputs.goToPostUpdate.observe(goToPostUpdate.observer)
    self.vm.outputs.lastUpdatePublishedAt.observe(lastUpdatePublishedAt.observer)
    self.vm.outputs.showShareSheet.observe(showShareSheet.observer)
  }

  func testGoToScreens() {
    let project = Project.template
    self.vm.inputs.configureWith(project: project)

    self.vm.inputs.activityTapped()
    self.goToActivity.assertValues([project], "Go to activity screen.")

    self.vm.inputs.messagesTapped()
    self.goToMessages.assertValues([project], "Go to messages screen.")

    self.vm.inputs.shareTapped()
    self.showShareSheet.assertValues([project], "Show share sheet.")

    self.vm.inputs.postUpdateTapped()
    self.goToPostUpdate.assertValues([project], "Go to post update screen.")
  }

  func testLastUpdatePublishedAtEmits() {
    let date = NSDate().timeIntervalSince1970
    let formattedDate = Format.date(secondsInUTC: date, timeStyle: .NoStyle)
    let project = Project.template
      |> Project.lens.creatorData.lastUpdatePublishedAt .~ date

    self.vm.inputs.configureWith(project: project)
    self.lastUpdatePublishedAt.assertValues(["Last updated on \(formattedDate)."])
  }
}
