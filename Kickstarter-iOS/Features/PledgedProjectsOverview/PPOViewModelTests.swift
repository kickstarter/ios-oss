import Combine
@testable import Kickstarter_Framework
@testable import KsApi
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
      fetchPledgedProjectsResult: Result.success(try self.pledgedProjectsData())
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
    expectation.expectedFulfillmentCount = 3

    var values: [PPOViewModelPaginator.Results] = []
    self.viewModel.$results
      .sink { value in
        values.append(value)
        expectation.fulfill()
      }
      .store(in: &self.cancellables)

    withEnvironment(apiService: MockService(
      fetchPledgedProjectsResult: Result.success(try self.pledgedProjectsData())
    )) {
      self.viewModel.viewDidAppear()
      self.viewModel.viewDidAppear() // This should not trigger another load
    }

    wait(for: [expectation], timeout: 0.1)

    XCTAssertEqual(values.count, 3)

    guard
      case .unloaded = values[0],
      case .loading = values[1],
      case let .allLoaded(data, _) = values[2]
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
      fetchPledgedProjectsResult: Result.success(try self.pledgedProjectsData(cursors: 1...3))
    )) {
      self.viewModel.viewDidAppear() // Initial load
    }

    await fulfillment(of: [initialLoadExpectation], timeout: 0.1)

    await withEnvironment(apiService: MockService(
      fetchPledgedProjectsResult: Result.success(try self.pledgedProjectsData(cursors: 1...2))
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
      fetchPledgedProjectsResult: Result.success(try self.pledgedProjectsData(cursors: 1...3))
    )) {
      self.viewModel.viewDidAppear() // Initial load
    }

    await fulfillment(of: [initialLoadExpectation], timeout: 0.1)

    await withEnvironment(apiService: MockService(
      fetchPledgedProjectsResult: Result.success(try self.pledgedProjectsData(cursors: 1...2))
    )) { () async in
      await self.viewModel.refresh() // Refresh
    }

    await withEnvironment(apiService: MockService(
      fetchPledgedProjectsResult: Result.success(try self.pledgedProjectsData(cursors: 1...16))
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
      fetchPledgedProjectsResult: Result.success(try self.pledgedProjectsData(
        cursors: 1...4,
        hasNextPage: true
      ))
    )) {
      self.viewModel.viewDidAppear() // Initial load
    }

    await fulfillment(of: [initialLoadExpectation], timeout: 0.1)

    await withEnvironment(apiService: MockService(
      fetchPledgedProjectsResult: Result.success(try self.pledgedProjectsData(cursors: 5...7))
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

  func testNavigationBackedProjects() {
    self.verifyNavigationEvent({ self.viewModel.openBackedProjects() }, event: .backedProjects)
  }

  func testNavigationConfirmAddress() {
    let template = PPOProjectCardModel.confirmAddressTemplate
    let address = "fake address"
    let addressId = "fake id"
    self.verifyNavigationEvent(
      { self.viewModel.confirmAddress(from: template, address: address, addressId: addressId) },
      event: .confirmAddress(
        backingId: template.backingGraphId,
        addressId: addressId,
        address: address
      )
    )
  }

  func testNavigationContactCreator() {
    self.verifyNavigationEvent(
      { self.viewModel.contactCreator(from: PPOProjectCardModel.addressLockTemplate) },
      event: .contactCreator(messageSubject: MessageSubject.project(
        id: PPOProjectCardModel.addressLockTemplate.projectId,
        name: PPOProjectCardModel.addressLockTemplate.projectName
      ))
    )
  }

  func testNavigationFix3DSChallenge() {
    let clientSecret = "xyz"
    let onProgress: (PPOActionState) -> Void = { _ in }
    self.verifyNavigationEvent(
      { self.viewModel.fix3DSChallenge(
        from: PPOProjectCardModel.authenticateCardTemplate,
        clientSecret: clientSecret,
        onProgress: onProgress
      ) },
      event: .fix3DSChallenge(clientSecret: clientSecret, onProgress: onProgress)
    )
  }

  func testNavigationFixPaymentMethod() {
    self.verifyNavigationEvent(
      { self.viewModel.fixPaymentMethod(from: PPOProjectCardModel.fixPaymentTemplate) },
      event: .fixPaymentMethod(
        projectId: PPOProjectCardModel.fixPaymentTemplate.projectId,
        backingId: PPOProjectCardModel.fixPaymentTemplate.backingId
      )
    )
  }

  func testNavigationOpenSurvey() {
    self.verifyNavigationEvent(
      { self.viewModel.openSurvey(from: PPOProjectCardModel.completeSurveyTemplate) },
      event: .survey(url: PPOProjectCardModel.completeSurveyTemplate.backingDetailsUrl)
    )
  }

  func testNavigationViewBackingDetails() {
    self.verifyNavigationEvent(
      // This could be tested with any template. All cards allow the user to view backing details.
      { self.viewModel.openSurvey(from: PPOProjectCardModel.fixPaymentTemplate) },
      event: .survey(url: PPOProjectCardModel.fixPaymentTemplate.backingDetailsUrl)
    )
  }

  // Setup the view model to monitor navigation events, then run the closure, then check to make sure only that one event fired
  private func verifyNavigationEvent(_ closure: () -> Void, event: PPONavigationEvent) {
    let beforeResults: PPOViewModelPaginator.Results = self.viewModel.results

    let expectation = self.expectation(description: "VerifyNavigationEvent \(event)")

    var values: [PPONavigationEvent] = []
    self.viewModel.navigationEvents
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

  private func pledgedProjectsData(
    cursors: ClosedRange<Int> = 1...3,
    hasNextPage: Bool = false
  ) throws -> GraphAPI.FetchPledgedProjectsQuery.Data {
    let edges = cursors.map { index in self.projectEdgeJSON(cursor: "\(index)") }
    let edgesJson = "[\(edges.joined(separator: ", "))]"
    return try GraphAPI.FetchPledgedProjectsQuery.Data(jsonString: """
    {
      "pledgeProjectsOverview": {
        "__typename": "PledgeProjectsOverview",
        "pledges": {
          "__typename": "PledgedProjectsOverviewPledgesConnection",
          "totalCount": \(cursors.count),
          "edges": \(edgesJson),
          "pageInfo": {
            "__typename": "PageInfo",
            "hasNextPage": \(String(hasNextPage)),
            "endCursor": \(hasNextPage ? "\"\(cursors.upperBound)\"" : "null"),
            "hasPreviousPage": false,
            "startCursor": "1"
          }
        }
      }
    }
    """)
  }

  private func projectEdgeJSON(
    cursor: String,
    projectName: String = UUID().uuidString
  ) -> String {
    """
    {
      "__typename": "PledgeProjectOverviewItemEdge",
      "cursor": "\(cursor)",
      "node": \(self.projectNodeJSON(projectName: projectName))
    }
    """
  }

  private func projectNodeJSON(
    projectName: String = UUID().uuidString
  ) -> String {
    """
    {
      "__typename": "PledgeProjectOverviewItem",
      "backing": {
        "__typename": "Backing",
        "id": "\(encodeToBase64("Backing-43"))",
        "amount": {
          "__typename": "Money",
          "amount": "1.0",
          "currency": "USD",
          "symbol": "$"
        },
        "deliveryAddress": null,
        "clientSecret": null,
        "backingDetailsPageRoute": "fake-backings-route",
        "project": {
          "__typename": "Project",
          "creator": {
            "__typename": "User",
            "email": null,
            "id": "\(UUID().uuidString)",
            "name": "\(UUID().uuidString)",
            "createdProjects": {
              "__typename": "UserCreatedProjectsConnection",
              "totalCount": 1
            }
          },
          "image": {
            "__typename": "Photo",
            "id": "\(UUID().uuidString)",
            "url": "https://i-dev.kickstarter.com/assets/x"
          },
          "name": "\(projectName)",
          "pid": 999498397,
          "slug": "2071399561/ppo-failed-payment-0",

          "addOns": {
            "__typename": "ProjectRewardConnection",
            "totalCount": 0
          },
          "backersCount": 0,
          "backing": {
            "__typename": "Backing",
            "id": "\(UUID().uuidString)"
          },
          "category": {
            "__typename": "Category",
            "analyticsName": "\(UUID().uuidString)",
            "parentCategory": null
          },
          "commentsCount": 0,
          "country": {
            "__typename": "Country",
            "code": "us"
          },

          "currency": "USD",

          "deadlineAt": "2024-11-16T03:44:39+0000",

          "fxRate": 1.0,
          "goal": {
            "__typename": "Money",
            "amount": 42
          },

          "isInPostCampaignPledgingPhase": false,
          "isWatched": false,
          "isPrelaunchActivated": false,

          "launchedAt": "2024-10-16T03:44:39+0000",

          "percentFunded": 1,

          "pledged": {
            "__typename": "Money",
            "amount": 0
          },
          "posts": {
            "__typename": "PostConnection",
            "totalCount": 0
          },
          "postCampaignPledgingEnabled": false,
          "projectTags": [],
          "rewards": {
            "__typename": "ProjectRewardConnection",
            "totalCount": 0
          },
          "state": "finished",
          "usdExchangeRate": 1.0,
          "video": null
        }
      },
      "flags": [
        {
          "__typename": "PledgedProjectsOverviewPledgeFlags",
          "icon": "alert",
          "message": "Payment failed",
          "type": "alert"
        },
        {
          "__typename": "PledgedProjectsOverviewPledgeFlags",
          "icon": "time",
          "message": "Pledge will be dropped in 0 days",
          "type": "alert"
        }
      ],

      "tierType": "Tier1PaymentFailed"
    }
    """
  }
}
