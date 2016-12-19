import Prelude
import ReactiveSwift
import Result
import XCTest
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers

internal final class ProjectNotificationsViewModelTests: TestCase {
  internal let vm = ProjectNotificationsViewModel()
  internal let projectNotificationsPresent = TestObserver<Bool, NoError>()

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.projectNotifications.map { !$0.isEmpty }.observe(projectNotificationsPresent.observer)
  }

  func testProjectNotificationsEmit() {
    self.vm.inputs.viewDidLoad()
    self.projectNotificationsPresent.assertValues([true], "Project notifications emitted.")
  }
}
