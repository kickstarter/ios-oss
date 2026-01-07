@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

final class PledgeLocalPickupViewModelTests: TestCase {
  private let vm: PledgeLocalPickupViewModelType = PledgeLocalPickupViewModel()

  private let locationLabelText = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.locationLabelText.observe(self.locationLabelText.observer)
  }

  func testLocationLabelText() {
    self.locationLabelText.assertDidNotEmitValue()

    let data = PledgeLocalPickupViewData(locationName: "new york city")

    self.vm.inputs.configure(with: data)

    self.locationLabelText.assertValues(["new york city"])
  }
}
