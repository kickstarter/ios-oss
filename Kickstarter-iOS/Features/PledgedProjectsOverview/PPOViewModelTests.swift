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
      case let .allLoaded(data) = values[2]
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
      case let .allLoaded(data) = values[2]
    else {
      return XCTFail()
    }
    XCTAssertEqual(data.count, 3)
  }

  func testPullToRefresh_Once() throws {
    let expectation = XCTestExpectation(description: "Pull to refresh")
    expectation.expectedFulfillmentCount = 5

    var values: [PPOViewModelPaginator.Results] = []

    self.viewModel.$results
      .sink { value in
        values.append(value)
        expectation.fulfill()
      }
      .store(in: &self.cancellables)

    withEnvironment(apiService: MockService(
      fetchPledgedProjectsResult: Result.success(try self.pledgedProjectsData(cursors: 1...3))
    )) {
      self.viewModel.viewDidAppear() // Initial load
    }

    withEnvironment(apiService: MockService(
      fetchPledgedProjectsResult: Result.success(try self.pledgedProjectsData(cursors: 1...2))
    )) {
      self.viewModel.pullToRefresh() // Refresh
    }

    wait(for: [expectation], timeout: 0.1)

    XCTAssertEqual(values.count, 5)

    guard
      case .unloaded = values[0],
      case .loading = values[1],
      case let .allLoaded(firstData) = values[2]
    else {
      return XCTFail()
    }
    XCTAssertEqual(firstData.count, 3)

    guard
      case .loading = values[3],
      case let .allLoaded(secondData) = values[4]
    else {
      return XCTFail()
    }
    XCTAssertEqual(secondData.count, 2)
  }

  func testPullToRefresh_Twice() throws {
    let expectation = XCTestExpectation(description: "Pull to refresh twice")
    expectation.expectedFulfillmentCount = 7

    var values: [PPOViewModelPaginator.Results] = []

    self.viewModel.$results
      .sink { value in
        values.append(value)
        expectation.fulfill()
      }
      .store(in: &self.cancellables)

    withEnvironment(apiService: MockService(
      fetchPledgedProjectsResult: Result.success(try self.pledgedProjectsData(cursors: 1...3))
    )) {
      self.viewModel.viewDidAppear() // Initial load
    }

    withEnvironment(apiService: MockService(
      fetchPledgedProjectsResult: Result.success(try self.pledgedProjectsData(cursors: 1...2))
    )) {
      self.viewModel.pullToRefresh() // Refresh
    }

    withEnvironment(apiService: MockService(
      fetchPledgedProjectsResult: Result.success(try self.pledgedProjectsData(cursors: 1...16))
    )) {
      self.viewModel.pullToRefresh() // Refresh a second time
    }

    wait(for: [expectation], timeout: 0.1)

    XCTAssertEqual(values.count, 7)

    guard
      case .unloaded = values[0],
      case .loading = values[1],
      case let .allLoaded(firstData) = values[2]
    else {
      return XCTFail()
    }
    XCTAssertEqual(firstData.count, 3)

    guard
      case .loading = values[3],
      case let .allLoaded(secondData) = values[4]
    else {
      return XCTFail()
    }
    XCTAssertEqual(secondData.count, 2)

    guard
      case .loading = values[5],
      case let .allLoaded(thirdData) = values[6]
    else {
      return XCTFail()
    }
    XCTAssertEqual(thirdData.count, 16)
  }

  func testLoadMore() throws {
    let expectation = XCTestExpectation(description: "Load more")
    expectation.expectedFulfillmentCount = 5

    var values: [PPOViewModelPaginator.Results] = []

    self.viewModel.$results
      .sink { value in
        values.append(value)
        expectation.fulfill()
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
    withEnvironment(apiService: MockService(
      fetchPledgedProjectsResult: Result.success(try self.pledgedProjectsData(cursors: 5...7))
    )) {
      self.viewModel.loadMore() // Load next page
    }

    wait(for: [expectation], timeout: 0.1)

    XCTAssertEqual(values.count, 5)

    guard
      case .unloaded = values[0],
      case .loading = values[1],
      case let .someLoaded(firstData, cursor) = values[2]
    else {
      return XCTFail()
    }
    XCTAssertEqual(firstData.count, 4)
    XCTAssertEqual(cursor, "4")

    guard
      case .loading = values[3],
      case let .allLoaded(secondData) = values[4]
    else {
      return XCTFail()
    }
    XCTAssertEqual(secondData.count, 7)
  }

  func testNavigationBackedProjects() {
    verifyNavigationEvent({ self.viewModel.openBackedProjects() }, event: .backingPage)
  }

  func testNavigationConfirmAddress() {
    verifyNavigationEvent({ self.viewModel.confirmAddress() }, event: .confirmAddress)
  }

  func testNavigationContactCreator() {
    verifyNavigationEvent({ self.viewModel.contactCreator() }, event: .contactCreator)
  }

  func testNavigationFix3DSChallenge() {
    verifyNavigationEvent({ self.viewModel.fix3DSChallenge() }, event: .fix3DSChallenge)
  }

  func testNavigationFixPaymentMethod() {
    verifyNavigationEvent({ self.viewModel.fixPaymentMethod() }, event: .fixPaymentMethod)
  }

  func testNavigationOpenSurvey() {
    verifyNavigationEvent({ self.viewModel.openSurvey() }, event: .survey)
  }

  private func verifyNavigationEvent(_ closure: () -> Void, event: PPONavigationEvent) {
    let beforeResults: PPOViewModelPaginator.Results = self.viewModel.results

    var values: [PPONavigationEvent] = []
    self.viewModel.navigationEvents.first().collect()
      .sink(receiveValue: { v in values = v })
      .store(in: &self.cancellables)

    closure()

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
          "endCursor": "\(cursors.upperBound)",
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
        "amount": {
          "__typename": "Money",
          "amount": "1.0",
          "currency": "USD",
          "symbol": "$"
        },
        "id": "\(UUID().uuidString)",
        "project": {
          "__typename": "Project",
          "creator": {
            "__typename": "User",
            "email": null,
            "id": "\(UUID().uuidString)",
            "name": "\(UUID().uuidString)"
          },
          "image": {
            "__typename": "Photo",
            "id": "\(UUID().uuidString)",
            "url": "https://i-dev.kickstarter.com/assets/x"
          },
          "name": "\(projectName)",
          "pid": 999498397,
          "slug": "2071399561/ppo-failed-payment-0"
        }
      },
      "tierType": "Tier1PaymentFailed",
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
      ]
    }
    """
  }
}
