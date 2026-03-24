import Combine
import GraphAPI
@testable import Kickstarter_Framework
@testable import KsApi
@testable import KsApiTestHelpers
@testable import Library
@testable import LibraryTestHelpers
import XCTest

class PPOViewModelTests: XCTestCase {
  var viewModel: PPOViewModel!
  var cancellables: Set<AnyCancellable>!

  override func setUp() {
    super.setUp()
    self.viewModel = PPOViewModel()
    self.cancellables = []
  }

  override func tearDown() {
    self.viewModel = nil
    self.cancellables = nil
    super.tearDown()
  }

  func testInitialLoading_Once() throws {
    let expectation = XCTestExpectation(description: "Initial loading")
    expectation.expectedFulfillmentCount = 3

    var values: [PPOViewModelPaginator.Results] = []
    self.viewModel.$results
      .sink { value in
        values.append(value)
        expectation.fulfill()
      }
      .store(in: &self.cancellables)

    withEnvironment(apiService: MockService(
      fetchPledgedProjectsResult: Result.success(try GraphAPI.FetchPledgedProjectsQuery.fakeData())
    )) {
      self.viewModel.viewDidAppear()
    }

    wait(for: [expectation], timeout: 0.1)

    guard
      case .unloaded = values[0],
      case .loading = values[1],
      case let .allLoaded(data, _) = values[2]
    else {
      return XCTFail()
    }
    XCTAssertEqual(data.count, 3)
    XCTAssertEqual(data.count, 3)
  }

  func testInitialLoading_Twice() throws {
    let expectation = XCTestExpectation(description: "Initial loading twice")
    expectation.expectedFulfillmentCount = 5

    var values: [PPOViewModelPaginator.Results] = []
    self.viewModel.$results
      .sink { value in
        values.append(value)
        expectation.fulfill()
      }
      .store(in: &self.cancellables)

    withEnvironment(apiService: MockService(
      fetchPledgedProjectsResult: Result.success(try GraphAPI.FetchPledgedProjectsQuery.fakeData())
    )) {
      self.viewModel.viewDidAppear()
      self.viewModel.viewDidAppear() // This should not trigger another load
    }

    wait(for: [expectation], timeout: 0.1)

    XCTAssertEqual(values.count, 5)

    guard
      case .unloaded = values[0],
      case .loading = values[1],
      case let .allLoaded(data, _) = values[4]
    else {
      return XCTFail()
    }
    XCTAssertEqual(data.count, 3)
  }

  func testPullToRefresh_Once() async throws {
    let initialLoadExpectation = XCTestExpectation(description: "Initial load")
    initialLoadExpectation.expectedFulfillmentCount = 3
    let fullyLoadedExpectation = XCTestExpectation(description: "Pull to refresh")
    fullyLoadedExpectation.expectedFulfillmentCount = 5

    var values: [PPOViewModelPaginator.Results] = []

    self.viewModel.$results
      .sink { value in
        values.append(value)
        initialLoadExpectation.fulfill()
        fullyLoadedExpectation.fulfill()
      }
      .store(in: &self.cancellables)

    withEnvironment(apiService: MockService(
      fetchPledgedProjectsResult: Result
        .success(try GraphAPI.FetchPledgedProjectsQuery.fakeData(cursors: 1...3))
    )) {
      self.viewModel.viewDidAppear() // Initial load
    }

    await fulfillment(of: [initialLoadExpectation], timeout: 0.1)

    await withEnvironment(apiService: MockService(
      fetchPledgedProjectsResult: Result
        .success(try GraphAPI.FetchPledgedProjectsQuery.fakeData(cursors: 1...2))
    )) { () async in
      await self.viewModel.refresh()
    }

    await fulfillment(of: [fullyLoadedExpectation], timeout: 0.1)

    XCTAssertEqual(values.count, 5)

    guard
      case .unloaded = values[0],
      case .loading = values[1],
      case let .allLoaded(firstData, _) = values[2]
    else {
      return XCTFail()
    }
    XCTAssertEqual(firstData.count, 3)

    guard
      case .loading = values[3],
      case let .allLoaded(secondData, _) = values[4]
    else {
      return XCTFail()
    }
    XCTAssertEqual(secondData.count, 2)
  }

  func testPullToRefresh_Twice() async throws {
    let initialLoadExpectation = XCTestExpectation(description: "Initial load")
    initialLoadExpectation.expectedFulfillmentCount = 3
    let fullyLoadedExpectation = XCTestExpectation(description: "Pull to refresh twice")
    fullyLoadedExpectation.expectedFulfillmentCount = 7

    var values: [PPOViewModelPaginator.Results] = []

    self.viewModel.$results
      .sink { value in
        values.append(value)
        initialLoadExpectation.fulfill()
        fullyLoadedExpectation.fulfill()
      }
      .store(in: &self.cancellables)

    withEnvironment(apiService: MockService(
      fetchPledgedProjectsResult: Result
        .success(try GraphAPI.FetchPledgedProjectsQuery.fakeData(cursors: 1...3))
    )) {
      self.viewModel.viewDidAppear() // Initial load
    }

    await fulfillment(of: [initialLoadExpectation], timeout: 0.1)

    await withEnvironment(apiService: MockService(
      fetchPledgedProjectsResult: Result
        .success(try GraphAPI.FetchPledgedProjectsQuery.fakeData(cursors: 1...2))
    )) { () async in
      await self.viewModel.refresh() // Refresh
    }

    await withEnvironment(apiService: MockService(
      fetchPledgedProjectsResult: Result
        .success(try GraphAPI.FetchPledgedProjectsQuery.fakeData(cursors: 1...16))
    )) { () async in
      await self.viewModel.refresh() // Refresh a second time
    }

    await fulfillment(of: [fullyLoadedExpectation], timeout: 0.1)

    XCTAssertEqual(values.count, 7)

    guard
      case .unloaded = values[0],
      case .loading = values[1],
      case let .allLoaded(firstData, _) = values[2]
    else {
      return XCTFail()
    }
    XCTAssertEqual(firstData.count, 3)

    guard
      case .loading = values[3],
      case let .allLoaded(secondData, _) = values[4]
    else {
      return XCTFail()
    }
    XCTAssertEqual(secondData.count, 2)

    guard
      case .loading = values[5],
      case let .allLoaded(thirdData, _) = values[6]
    else {
      return XCTFail()
    }
    XCTAssertEqual(thirdData.count, 16)
  }

  func testLoadMore() async throws {
    let initialLoadExpectation = XCTestExpectation(description: "Initial load")
    initialLoadExpectation.expectedFulfillmentCount = 3
    let fullyLoadedExpectation = XCTestExpectation(description: "Load more")
    fullyLoadedExpectation.expectedFulfillmentCount = 5

    var values: [PPOViewModelPaginator.Results] = []

    self.viewModel.$results
      .sink { value in
        values.append(value)
        initialLoadExpectation.fulfill()
        fullyLoadedExpectation.fulfill()
      }
      .store(in: &self.cancellables)

    withEnvironment(apiService: MockService(
      fetchPledgedProjectsResult: Result.success(try GraphAPI.FetchPledgedProjectsQuery.fakeData(
        cursors: 1...4,
        hasNextPage: true
      ))
    )) {
      self.viewModel.viewDidAppear() // Initial load
    }

    await fulfillment(of: [initialLoadExpectation], timeout: 0.1)

    await withEnvironment(apiService: MockService(
      fetchPledgedProjectsResult: Result
        .success(try GraphAPI.FetchPledgedProjectsQuery.fakeData(cursors: 5...7))
    )) { () async in
      await self.viewModel.loadMore() // Load next page
    }

    await fulfillment(of: [fullyLoadedExpectation], timeout: 0.1)

    XCTAssertEqual(values.count, 5)

    guard
      case .unloaded = values[0],
      case .loading = values[1],
      case let .someLoaded(firstData, cursor, _, _) = values[2]
    else {
      return XCTFail()
    }
    XCTAssertEqual(firstData.count, 4)
    XCTAssertEqual(cursor, "4")

    guard
      case .loading = values[3],
      case let .allLoaded(secondData, _) = values[4]
    else {
      return XCTFail()
    }
    XCTAssertEqual(secondData.count, 7)
  }

  func testEventConfirmAddress() {
    let template = PPOProjectCardModel.confirmAddressTemplate
    let address = "fake address"
    let addressId = "fake id"
    let cardEvent = PPOCardEvent.confirmAddress(address: address, addressId: addressId)
    self.verifyPreparedEvent(
      { self.viewModel.handleCardEvent(cardEvent, from: template) },
      event: .confirmAddress(
        backingId: template.backingGraphId,
        addressId: addressId,
        address: address,
        onProgress: { _ in }
      )
    )
  }

  func testEventContactCreator() {
    self.verifyPreparedEvent(
      { self.viewModel.handleCardEvent(.sendMessage, from: .addressLockTemplate) },
      event: .contactCreator(messageSubject: MessageSubject.project(
        id: PPOProjectCardModel.addressLockTemplate.projectId,
        name: PPOProjectCardModel.addressLockTemplate.projectName
      ))
    )
  }

  func testEventFix3DSChallenge() {
    let clientSecret = "xyz"
    let onProgress: (PPOActionState) -> Void = { _ in }
    let cardEvent = PPOCardEvent.authenticateCard(
      clientSecret: clientSecret,
      onProgress: onProgress
    )
    self.verifyPreparedEvent(
      { self.viewModel.handleCardEvent(cardEvent, from: .authenticateCardTemplate) },
      event: .fix3DSChallenge(clientSecret: clientSecret, onProgress: onProgress)
    )
  }

  func testEventFixPaymentMethod() {
    let template = PPOProjectCardModel.fixPaymentTemplate
    self.verifyPreparedEvent(
      { self.viewModel.handleCardEvent(.fixPayment, from: template) },
      event: .fixPaymentMethod(
        projectId: template.projectId,
        backingId: template.backingId
      )
    )
  }

  func testEventOpenSurvey() {
    let template = PPOProjectCardModel.completeSurveyTemplate
    let url = "fakeSurveyUrl"
    self.verifyPreparedEvent(
      { self.viewModel.handleCardEvent(.completeSurvey(url: url), from: template) },
      event: .survey(url: url)
    )
  }

  func testEventOpenPledgeManager() {
    let template = PPOProjectCardModel.openPledgeManagerTemplate
    let url = "fakePledgeManagerUrl"
    self.verifyPreparedEvent(
      { self.viewModel.handleCardEvent(.openPledgeManager(url: url), from: template) },
      event: .openPledgeManager(url: url)
    )
  }

  func testEventViewProjectDetails() {
    let template = PPOProjectCardModel.noRewardPledgeCollected
    let param = template.projectPageParam!
    self.verifyPreparedEvent(
      // This could be tested with any template. All cards allow the user to view project details.
      { self.viewModel.handleCardEvent(.viewProjectDetails(param: param), from: template) },
      event: .projectDetails(param: param)
    )
  }

  func testAnalyticsEvents_NotTriggeredOnRefresh() async throws {
    let appTrackingTransparency = MockAppTrackingTransparency()
    appTrackingTransparency.requestAndSetAuthorizationStatusFlag = false
    appTrackingTransparency.shouldRequestAuthStatus = true
    appTrackingTransparency.updateAdvertisingIdentifier()

    let mockTrackingClient = MockTrackingClient()
    let analytics = KSRAnalytics(
      segmentClient: mockTrackingClient,
      appTrackingTransparency: appTrackingTransparency
    )

    let mockService = MockService(
      fetchPledgedProjectsResult: Result
        .success(try GraphAPI.FetchPledgedProjectsQuery.fakeData(cursors: 1...3))
    )

    let reloadedMockService = MockService(
      fetchPledgedProjectsResult: Result
        .success(try GraphAPI.FetchPledgedProjectsQuery.fakeData(cursors: 4...6))
    )

    let initialLoadExpectation = XCTestExpectation(description: "Initial load")
    initialLoadExpectation.expectedFulfillmentCount = 3
    let refreshExpectation = XCTestExpectation(description: "Refresh complete")
    refreshExpectation.expectedFulfillmentCount = 4

    var values: [PPOViewModelPaginator.Results] = []
    self.viewModel.$results
      .sink { value in
        values.append(value)
        initialLoadExpectation.fulfill()
        refreshExpectation.fulfill()
      }
      .store(in: &self.cancellables)

    await withEnvironment(
      apiService: mockService,
      appTrackingTransparency: appTrackingTransparency,
      ksrAnalytics: analytics
    ) { () async in
      self.viewModel.viewDidAppear()

      // Trigger some actions that generate analytics
      self.viewModel.handleCardEvent(.completeSurvey(url: "fakeUrl"), from: .completeSurveyTemplate)
      self.viewModel.handleCardEvent(.fixPayment, from: .fixPaymentTemplate)
      self.viewModel.handleCardEvent(.sendMessage, from: .addressLockTemplate)

      await fulfillment(of: [initialLoadExpectation], timeout: 0.1)

      // Store analytics event counts before refresh
      let trackCountBefore = mockTrackingClient.tracks.count
      XCTAssertEqual(trackCountBefore, 4)

      await withEnvironment(
        apiService: reloadedMockService,
        appTrackingTransparency: appTrackingTransparency,
        ksrAnalytics: analytics
      ) { () async in
        await self.viewModel.refresh()
      }

      await fulfillment(of: [refreshExpectation], timeout: 0.1)

      // Verify analytics events weren't triggered again
      XCTAssertEqual(mockTrackingClient.tracks.count, trackCountBefore)
    }
  }

  func testInitialLoading_Empty() throws {
    let expectation = XCTestExpectation(description: "Initial loading empty")
    expectation.expectedFulfillmentCount = 3

    var values: [PPOViewModelPaginator.Results] = []
    self.viewModel.$results
      .sink { value in
        values.append(value)
        expectation.fulfill()
      }
      .store(in: &self.cancellables)

    withEnvironment(apiService: MockService(
      fetchPledgedProjectsResult: Result.success(try GraphAPI.FetchPledgedProjectsQuery.fakeData(
        cursors: nil,
        hasNextPage: false
      ))
    )) {
      self.viewModel.viewDidAppear()
    }

    wait(for: [expectation], timeout: 0.1)

    XCTAssertEqual(values.count, 3)

    guard
      case .unloaded = values[0],
      case .loading = values[1],
      case .empty = values[2]
    else {
      return XCTFail()
    }
  }

  // Setup the view model to monitor prepared events, then run the closure, then check to make sure only that one event fired
  private func verifyPreparedEvent(_ closure: () -> Void, event: PPOPreparedEvent) {
    let beforeResults: PPOViewModelPaginator.Results = self.viewModel.results

    let expectation = self.expectation(description: "VerifyPreparedEvent \(event)")

    var values: [PPOPreparedEvent] = []
    self.viewModel.preparedEvents
      .collect(.byTime(DispatchQueue.main, 0.1))
      .sink(receiveValue: { v in
        values = v
        expectation.fulfill()
      })
      .store(in: &self.cancellables)

    closure()

    self.wait(for: [expectation], timeout: 1)

    let afterResults: PPOViewModelPaginator.Results = self.viewModel.results

    XCTAssertEqual(values.count, 1)
    guard case event = values[0] else {
      return XCTFail()
    }

    XCTAssertEqual(beforeResults, afterResults)
  }
}
