@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

final class ActivityErroredBackingsCellViewModelTests: TestCase {
  private let vm: ActivityErroredBackingsCellViewModelType = ActivityErroredBackingsCellViewModel()

  private let erroredBackings = TestObserver<[GraphBacking], Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.erroredBackings.observe(self.erroredBackings.observer)
  }

  func testErroredBackings() {
    let backings = GraphBackingEnvelope.template.backings.nodes

    self.erroredBackings.assertDidNotEmitValue()

    self.vm.inputs.configure(with: backings)

    self.erroredBackings.assertValue(backings)
  }
}
