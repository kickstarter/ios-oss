@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class ProjectNotificationsViewModelTests: TestCase {
  internal let vm = ProjectNotificationsViewModel()
  internal let projectNotificationsPresent = TestObserver<Bool, Never>()

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.projectNotifications.map { !$0.isEmpty }
      .observe(self.projectNotificationsPresent.observer)
  }

  func testProjectNotificationsEmit() {
    self.vm.inputs.viewDidLoad()
    self.projectNotificationsPresent.assertValues([true], "Project notifications emitted.")
  }
}
