import Prelude
import ReactiveCocoa
import Result
import XCTest
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers

internal final class DashboardContextCellViewModelTests: TestCase {
  internal let vm = DashboardContextCellViewModel()
  internal let backersCount = TestObserver<String, NoError>()
  internal let deadline = TestObserver<String, NoError>()
  internal let pledged = TestObserver<String, NoError>()
  internal let projectImageURL = TestObserver<NSURL?, NoError>()

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.backersCount.observe(backersCount.observer)
    self.vm.outputs.deadline.observe(deadline.observer)
    self.vm.outputs.pledged.observe(pledged.observer)
    self.vm.outputs.projectImageURL.observe(projectImageURL.observer)
  }

  func testProjectDataEmits() {
    let date = NSDate().timeIntervalSince1970
    let project = Project.template
      |> Project.lens.stats.backersCount .~ 5
      |> Project.lens.stats.pledged .~ 1234
      |> Project.lens.dates.deadline .~ date

    self.vm.inputs.configureWith(project: project)

    self.backersCount.assertValues(["5"])
    self.deadline.assertValues([String(date)])
    self.pledged.assertValues(["$1,234"])
    self.projectImageURL.assertValues([NSURL(string: Project.Photo.template.full)])
  }
}
