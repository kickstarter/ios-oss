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
  let pledgeOverTimeIsLoading = TestObserver<Bool, Never>()
  let showPledgeOverTimeUI = TestObserver<Bool, Never>()

  override func setUp() {
    super.setUp()

    self.vm = PLOTPledgeViewModel(project: self.projectSignal, pledgeTotal: self.pledgeTotalSignal)
    self.vm!.outputs.buildPaymentPlanInputs.observe(self.buildPaymentPlanInputs.observer)
    self.vm!.outputs.pledgeOverTimeIsLoading.observe(self.pledgeOverTimeIsLoading.observer)
    self.vm!.outputs.showPledgeOverTimeUI.observe(self.showPledgeOverTimeUI.observer)
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

  func testViewModel_sendsLoadingEvent_whenPledgeOverTimeIsEnabled() {
    let queryData = try! GraphAPI.BuildPaymentPlanQuery
      .Data(jsonString: buildPaymentPlanQueryJson(eligible: true))
    let mockApiService = MockService(buildPaymentPlanResult: .success(queryData))

    let mockConfigClient = MockRemoteConfigClient()
    mockConfigClient.features = [
      RemoteConfigFeature.pledgeOverTime.rawValue: true
    ]

    withEnvironment(apiService: mockApiService, remoteConfigClient: mockConfigClient) {
      let project = Project.template
        |> Project.lens.slug .~ "some-slug"
        |> Project.lens.isPledgeOverTimeAllowed .~ true

      self.projectObserver.send(value: project)
      self.pledgeTotalObserver.send(value: 100.0)

      self.showPledgeOverTimeUI.assertValues([true])
      self.pledgeOverTimeIsLoading.assertValues([true, false])
    }
  }

  func testViewModel_doesntLoad_whenPledgeOverTimeIsDisabled() {
    let queryData = try! GraphAPI.BuildPaymentPlanQuery
      .Data(jsonString: buildPaymentPlanQueryJson(eligible: true))
    let mockApiService = MockService(buildPaymentPlanResult: .success(queryData))

    let mockConfigClient = MockRemoteConfigClient()
    mockConfigClient.features = [
      RemoteConfigFeature.pledgeOverTime.rawValue: false
    ]

    withEnvironment(apiService: mockApiService, remoteConfigClient: mockConfigClient) {
      let project = Project.template
        |> Project.lens.slug .~ "some-slug"
        |> Project.lens.isPledgeOverTimeAllowed .~ false

      self.projectObserver.send(value: project)
      self.pledgeTotalObserver.send(value: 100.0)

      self.pledgeOverTimeIsLoading.assertValues([false])
      self.showPledgeOverTimeUI.assertValues([false])
    }
  }

  func testViewModel_hidesUIAndStopsLoading_whenBuildPaymentPlanQueryFails() {
    let mockApiService = MockService(buildPaymentPlanResult: .failure(.couldNotParseJSON))

    let mockConfigClient = MockRemoteConfigClient()
    mockConfigClient.features = [
      RemoteConfigFeature.pledgeOverTime.rawValue: true
    ]

    withEnvironment(apiService: mockApiService, remoteConfigClient: mockConfigClient) {
      let project = Project.template
        |> Project.lens.slug .~ "some-slug"
        |> Project.lens.isPledgeOverTimeAllowed .~ true

      self.projectObserver.send(value: project)
      self.pledgeTotalObserver.send(value: 100.0)

      self.pledgeOverTimeIsLoading.assertValues([true, false])
      self.buildPaymentPlanInputs.assertDidEmitValue()
      self.showPledgeOverTimeUI.assertValues([true, false])
    }
  }
}
