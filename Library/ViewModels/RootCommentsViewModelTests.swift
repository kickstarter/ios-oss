@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class RootCommentsViewModelTests: TestCase {
  internal let vm: RootCommentsViewModelType = RootCommentsViewModel()

  /// Remove when ready for development
  internal let viewDidLoadTestOutput = TestObserver<Bool, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.viewDidLoadTestOutput.observe(self.viewDidLoadTestOutput.observer)
  }

  func testViewDidLoad() {
    self.vm.inputs.viewDidLoad()
    self.scheduler.advance()

    self.viewDidLoadTestOutput.assertValues([true], "View did load emits.")
  }
}
