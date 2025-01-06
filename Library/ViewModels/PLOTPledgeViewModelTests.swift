@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class PLOTPledgeViewModelTests: TestCase {
  let (projectSignal, projectObserver) = Signal<Project, Never>.pipe()
  let (pledgeTotalSignal, pledgeTotalObserver) = Signal<Double, Never>.pipe()

  var vm: PLOTPledgeViewModel?

  let buildPaymentPlanInputs = TestObserver<(String, String), Never>()

  override func setUp() {
    super.setUp()

    self.vm = PLOTPledgeViewModel(project: self.projectSignal, pledgeTotal: self.pledgeTotalSignal)
    self.vm!.outputs.buildPaymentPlanInputs.observe(self.buildPaymentPlanInputs.observer)
  }

  func testViewModel_callsBuildPaymentPlanQuery_withCorrectSlugAndPledgeTotal() {
    let mockConfigClient = MockRemoteConfigClient()
    mockConfigClient.features = [
      RemoteConfigFeature.pledgeOverTime.rawValue: true
    ]

    withEnvironment(remoteConfigClient: mockConfigClient) {
      self.buildPaymentPlanInputs.assertDidNotEmitValue()

      let project = Project.template
        |> Project.lens.slug .~ "some-slug"
        |> Project.lens.isPledgeOverTimeAllowed .~ true
      let pledgeTotal = 928.66

      self.projectObserver.send(value: project)
      self.pledgeTotalObserver.send(value: pledgeTotal)

      self.buildPaymentPlanInputs.assertValueCount(1)
      XCTAssertEqual(self.buildPaymentPlanInputs.lastValue?.0, "some-slug")
      XCTAssertEqual(self.buildPaymentPlanInputs.lastValue?.1, "928.66")
    }
  }

  func testViewModel_callsBuildPaymentPlanQuery_onlyOnce() {
    let mockConfigClient = MockRemoteConfigClient()
    mockConfigClient.features = [
      RemoteConfigFeature.pledgeOverTime.rawValue: true
    ]

    withEnvironment(remoteConfigClient: mockConfigClient) {
      self.buildPaymentPlanInputs.assertDidNotEmitValue()

      let project = Project.template
        |> Project.lens.slug .~ "some-slug"
        |> Project.lens.isPledgeOverTimeAllowed .~ true

      self.projectObserver.send(value: project)
      self.pledgeTotalObserver.send(value: 100.0)

      self.buildPaymentPlanInputs.assertValueCount(1)
      XCTAssertEqual(self.buildPaymentPlanInputs.lastValue?.0, "some-slug")
      XCTAssertEqual(self.buildPaymentPlanInputs.lastValue?.1, "100.00")

      self.pledgeTotalObserver.send(value: 1.0)
      self.pledgeTotalObserver.send(value: 2.0)
      self.pledgeTotalObserver.send(value: 3.0)
      self.buildPaymentPlanInputs.assertValueCount(1)
    }
  }
}
