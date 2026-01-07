@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

final class ActivityErroredBackingsCellViewModelTests: TestCase {
  private let vm: ActivityErroredBackingsCellViewModelType = ActivityErroredBackingsCellViewModel()

  private let erroredBackings = TestObserver<[ProjectAndBackingEnvelope], Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.erroredBackings.observe(self.erroredBackings.observer)
  }

  func testErroredBackings() {
    let backings = [ProjectAndBackingEnvelope(project: .template, backing: .errored)]

    self.erroredBackings.assertDidNotEmitValue()

    self.vm.inputs.configure(with: backings)

    self.erroredBackings.assertValue(backings)
  }
}
