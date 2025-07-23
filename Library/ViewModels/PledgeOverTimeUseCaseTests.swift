import GraphAPI
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class PledgeOverTimeUseCaseTests: TestCase {
  let (projectSignal, projectObserver) = Signal<Project, Never>.pipe()
  let (pledgeTotalSignal, pledgeTotalObserver) = Signal<Double, Never>.pipe()
  let (pledgeViewContextSignal, pledgeViewContextObserver) = Signal<PledgeViewContext, Never>.pipe()

  var useCase: PledgeOverTimeUseCase?

  let buildPaymentPlanInputs = TestObserver<(String, String), Never>()
  let pledgeOverTimeIsLoading = TestObserver<Bool, Never>()
  let showPledgeOverTimeUI = TestObserver<Bool, Never>()
  let selectedPlan = TestObserver<PledgePaymentPlansType?, Never>()

  override func setUp() {
    super.setUp()

    self.useCase = PledgeOverTimeUseCase(
      project: self.projectSignal,
      pledgeTotal: self.pledgeTotalSignal,
      context: self.pledgeViewContextSignal
    )
    self.useCase!.outputs.buildPaymentPlanInputs.observe(self.buildPaymentPlanInputs.observer)
    self.useCase!.outputs.pledgeOverTimeIsLoading.observe(self.pledgeOverTimeIsLoading.observer)
    self.useCase!.outputs.showPledgeOverTimeUI.observe(self.showPledgeOverTimeUI.observer)
    self.useCase!.outputs.pledgeOverTimeConfigData.map { $0?.selectedPlan }
      .observe(self.selectedPlan.observer)
  }

  func testUseCase_callsBuildPaymentPlanQuery_withCorrectSlugAndPledgeTotal() {
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

      self.pledgeViewContextObserver.send(value: .pledge)
      self.projectObserver.send(value: project)
      self.pledgeTotalObserver.send(value: pledgeTotal)

      self.buildPaymentPlanInputs.assertValueCount(1)
      XCTAssertEqual(self.buildPaymentPlanInputs.lastValue?.0, "some-slug")
      XCTAssertEqual(self.buildPaymentPlanInputs.lastValue?.1, "928.66")
    }
  }

  func testUseCase_callsBuildPaymentPlanQuery_SkipsRepeats() {
    let mockConfigClient = MockRemoteConfigClient()
    mockConfigClient.features = [
      RemoteConfigFeature.pledgeOverTime.rawValue: true
    ]

    withEnvironment(remoteConfigClient: mockConfigClient) {
      self.buildPaymentPlanInputs.assertDidNotEmitValue()

      let project = Project.template
        |> Project.lens.slug .~ "some-slug"
        |> Project.lens.isPledgeOverTimeAllowed .~ true

      self.pledgeViewContextObserver.send(value: .pledge)
      self.projectObserver.send(value: project)
      self.pledgeTotalObserver.send(value: 100.0)

      self.buildPaymentPlanInputs.assertValueCount(1)
      XCTAssertEqual(self.buildPaymentPlanInputs.lastValue?.0, "some-slug")
      XCTAssertEqual(self.buildPaymentPlanInputs.lastValue?.1, "100.00")

      self.pledgeTotalObserver.send(value: 98.0)

      self.buildPaymentPlanInputs.assertValueCount(2)
      XCTAssertEqual(self.buildPaymentPlanInputs.lastValue?.0, "some-slug")
      XCTAssertEqual(self.buildPaymentPlanInputs.lastValue?.1, "98.00")

      self.pledgeTotalObserver.send(value: 98.0)

      // Count remains the same as the previous one since the value ("98.00") did not change.
      self.buildPaymentPlanInputs.assertValueCount(2)

      self.pledgeTotalObserver.send(value: 165.0)
      self.buildPaymentPlanInputs.assertValueCount(3)
      XCTAssertEqual(self.buildPaymentPlanInputs.lastValue?.0, "some-slug")
      XCTAssertEqual(self.buildPaymentPlanInputs.lastValue?.1, "165.00")

      self.useCase!.paymentPlanSelected(.pledgeInFull)
      self.useCase!.paymentPlanSelected(.pledgeOverTime)
      self.useCase!.paymentPlanSelected(.pledgeInFull)

      // Only emits unique values skipping repeats
      // pledgeTotalObserver stream:
      // 1. 100.00
      // 2. 98.00
      // 3. 98.00
      // 4. 165.00
      // Expected emitted values
      // 1. 100.00
      // 2. 98.00
      // 3. 165.00

      // Updates from paymentPlanSelected should not trigger additional emissions to buildPaymentPlanInputs.
      self.buildPaymentPlanInputs.assertValueCount(3)
    }
  }

  func testUseCase_sendsLoadingEvent_whenPledgeOverTimeIsEnabled() {
    let variables = ["includeRefundedAmount": false]

    let queryData: GraphAPI.BuildPaymentPlanQuery
      .Data = try! testGraphObject(
        jsonString: buildPaymentPlanQueryJson(eligible: true),
        variables: variables
      )
    let mockApiService = MockService(buildPaymentPlanResult: .success(queryData))

    let mockConfigClient = MockRemoteConfigClient()
    mockConfigClient.features = [
      RemoteConfigFeature.pledgeOverTime.rawValue: true
    ]

    withEnvironment(apiService: mockApiService, remoteConfigClient: mockConfigClient) {
      let project = Project.template
        |> Project.lens.slug .~ "some-slug"
        |> Project.lens.isPledgeOverTimeAllowed .~ true

      self.pledgeViewContextObserver.send(value: .pledge)
      self.projectObserver.send(value: project)
      self.pledgeTotalObserver.send(value: 100.0)

      self.showPledgeOverTimeUI.assertValues([true])
      self.pledgeOverTimeIsLoading.assertValues([true, false])
    }
  }

  func testUseCase_doesntLoad_whenPledgeOverTimeIsDisabled() {
    let variables = ["includeRefundedAmount": false]
    let queryData: GraphAPI.BuildPaymentPlanQuery
      .Data = try! testGraphObject(
        jsonString: buildPaymentPlanQueryJson(eligible: true),
        variables: variables
      )
    let mockApiService = MockService(buildPaymentPlanResult: .success(queryData))

    let mockConfigClient = MockRemoteConfigClient()
    mockConfigClient.features = [
      RemoteConfigFeature.pledgeOverTime.rawValue: false
    ]

    withEnvironment(apiService: mockApiService, remoteConfigClient: mockConfigClient) {
      let project = Project.template
        |> Project.lens.slug .~ "some-slug"
        |> Project.lens.isPledgeOverTimeAllowed .~ false

      self.pledgeViewContextObserver.send(value: .pledge)
      self.projectObserver.send(value: project)
      self.pledgeTotalObserver.send(value: 100.0)

      self.pledgeOverTimeIsLoading.assertValues([false])
      self.showPledgeOverTimeUI.assertValues([false])
    }
  }

  func testUseCase_hidesUIAndStopsLoading_whenBuildPaymentPlanQueryFails() {
    let mockApiService = MockService(buildPaymentPlanResult: .failure(.couldNotParseJSON))

    let mockConfigClient = MockRemoteConfigClient()
    mockConfigClient.features = [
      RemoteConfigFeature.pledgeOverTime.rawValue: true
    ]

    withEnvironment(apiService: mockApiService, remoteConfigClient: mockConfigClient) {
      let project = Project.template
        |> Project.lens.slug .~ "some-slug"
        |> Project.lens.isPledgeOverTimeAllowed .~ true

      self.pledgeViewContextObserver.send(value: .pledge)
      self.projectObserver.send(value: project)
      self.pledgeTotalObserver.send(value: 100.0)

      self.pledgeOverTimeIsLoading.assertValues([true, false])
      self.buildPaymentPlanInputs.assertDidEmitValue()
      self.showPledgeOverTimeUI.assertValues([true, false])
    }
  }

  func testUseCase_emitsNilPaymentPlan_andHidesUI_ifPledgeOverTimeIsDisabled() {
    let mockConfigClient = MockRemoteConfigClient()
    mockConfigClient.features = [
      RemoteConfigFeature.pledgeOverTime.rawValue: true
    ]

    withEnvironment(remoteConfigClient: mockConfigClient) {
      self.buildPaymentPlanInputs.assertDidNotEmitValue()

      let project = Project.template
        |> Project.lens.slug .~ "some-slug"
        |> Project.lens.isPledgeOverTimeAllowed .~ false

      self.pledgeViewContextObserver.send(value: .pledge)
      self.projectObserver.send(value: project)
      self.pledgeTotalObserver.send(value: 100.0)

      self.showPledgeOverTimeUI.assertValues([false])
      self.selectedPlan.assertValues([nil])
    }
  }

  func testUseCase_emitsNilPaymentPlan_andHidesUI_ifPledgeOverQueryReturnsAnError() {
    let mockConfigClient = MockRemoteConfigClient()
    mockConfigClient.features = [
      RemoteConfigFeature.pledgeOverTime.rawValue: true
    ]
    let mockService = MockService(buildPaymentPlanResult: .failure(.couldNotParseJSON))

    withEnvironment(apiService: mockService, remoteConfigClient: mockConfigClient) {
      self.buildPaymentPlanInputs.assertDidNotEmitValue()

      let project = Project.template
        |> Project.lens.slug .~ "some-slug"
        |> Project.lens.isPledgeOverTimeAllowed .~ true

      self.pledgeViewContextObserver.send(value: .pledge)
      self.projectObserver.send(value: project)
      self.pledgeTotalObserver.send(value: 100.0)

      self.buildPaymentPlanInputs.assertDidEmitValue()
      self.showPledgeOverTimeUI.assertValues([true, false])
      self.selectedPlan.assertValues([nil])
    }
  }

  func testUseCase_paymentPlanSelected_changesSelectedPaymentPlan() {
    let mockConfigClient = MockRemoteConfigClient()
    mockConfigClient.features = [
      RemoteConfigFeature.pledgeOverTime.rawValue: true
    ]

    let variables = ["includeRefundedAmount": false]
    let result: GraphAPI.BuildPaymentPlanQuery
      .Data = try! testGraphObject(
        jsonString: buildPaymentPlanQueryJson(eligible: true),
        variables: variables
      )
    let mockService = MockService(buildPaymentPlanResult: .success(result))

    withEnvironment(apiService: mockService, remoteConfigClient: mockConfigClient) {
      self.buildPaymentPlanInputs.assertDidNotEmitValue()

      let project = Project.template
        |> Project.lens.slug .~ "some-slug"
        |> Project.lens.isPledgeOverTimeAllowed .~ true
      let pledgeTotal = 928.66

      self.pledgeViewContextObserver.send(value: .pledge)
      self.projectObserver.send(value: project)
      self.pledgeTotalObserver.send(value: pledgeTotal)

      // Defaults to pledgeInFull
      self.selectedPlan.assertValues([.pledgeInFull])

      self.useCase!.paymentPlanSelected(.pledgeOverTime)
      self.selectedPlan.assertValues([.pledgeInFull, .pledgeOverTime])

      self.useCase!.paymentPlanSelected(.pledgeInFull)
      self.selectedPlan.assertValues([.pledgeInFull, .pledgeOverTime, .pledgeInFull])
    }
  }

  func testUseCase_EditPlotPledged_PledgeOverTime_Preselected_whenIsElegible() {
    let variables = ["includeRefundedAmount": false]
    let queryData: GraphAPI.BuildPaymentPlanQuery
      .Data = try! testGraphObject(
        jsonString: buildPaymentPlanQueryJson(eligible: true),
        variables: variables
      )
    let mockApiService = MockService(buildPaymentPlanResult: .success(queryData))

    let mockConfigClient = MockRemoteConfigClient()
    mockConfigClient.features = [
      RemoteConfigFeature.pledgeOverTime.rawValue: true
    ]

    withEnvironment(apiService: mockApiService, remoteConfigClient: mockConfigClient) {
      let project = Project.template
        |> Project.lens.slug .~ "some-slug"
        |> Project.lens.isPledgeOverTimeAllowed .~ true
        |> Project.lens.personalization.backing .~ Backing.templatePlot

      self.pledgeViewContextObserver.send(value: .pledge)
      self.projectObserver.send(value: project)
      self.pledgeTotalObserver.send(value: 100.0)

      self.showPledgeOverTimeUI.assertValues([true])
      self.pledgeOverTimeIsLoading.assertValues([true, false])
      self.selectedPlan.assertLastValue(.pledgeOverTime)
    }
  }

  func testUseCase_EditPlotPledged_PledgeInFull_Preselected_whenIsNotElegible() {
    let variables = ["includeRefundedAmount": false]
    let queryData: GraphAPI.BuildPaymentPlanQuery
      .Data = try! testGraphObject(
        jsonString: buildPaymentPlanQueryJson(eligible: false),
        variables: variables
      )
    let mockApiService = MockService(buildPaymentPlanResult: .success(queryData))

    let mockConfigClient = MockRemoteConfigClient()
    mockConfigClient.features = [
      RemoteConfigFeature.pledgeOverTime.rawValue: true
    ]

    withEnvironment(apiService: mockApiService, remoteConfigClient: mockConfigClient) {
      let project = Project.template
        |> Project.lens.slug .~ "some-slug"
        |> Project.lens.isPledgeOverTimeAllowed .~ true
        |> Project.lens.personalization.backing .~ Backing.templatePlot

      self.pledgeViewContextObserver.send(value: .pledge)
      self.projectObserver.send(value: project)
      self.pledgeTotalObserver.send(value: 100.0)

      self.showPledgeOverTimeUI.assertValues([true])
      self.pledgeOverTimeIsLoading.assertValues([true, false])
      self.selectedPlan.assertLastValue(.pledgeInFull)
    }
  }

  func testUseCase_showsOrHidesUI_basedOnPledgeViewContext() {
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

      let contextsToHideUI: [PledgeViewContext] = [
        .changePaymentMethod,
        .fixPaymentMethod,
        .latePledge,
        .update,
        .updateReward
      ]

      for context in contextsToHideUI {
        self.pledgeViewContextObserver.send(value: context)
        self.showPledgeOverTimeUI.assertLastValue(false)
      }

      let contextsThatShowUI: [PledgeViewContext] = [.pledge, .editPledgeOverTime]
      for context in contextsThatShowUI {
        self.pledgeViewContextObserver.send(value: context)
        self.showPledgeOverTimeUI.assertLastValue(true)
      }
    }
  }
}
