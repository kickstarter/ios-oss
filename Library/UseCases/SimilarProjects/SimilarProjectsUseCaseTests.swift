@testable import KsApi
@testable import Library
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class SimilarProjectsUseCaseTests: TestCase {
  private var useCase: SimilarProjectsUseCase!
  private let projectTappedObserver = TestObserver<SimilarProject, Never>()
  private let similarProjectsObserver = TestObserver<SimilarProjectsState, Never>()
  private var mockService: MockService!

  override func setUp() {
    super.setUp()

    let remoteConfig = MockRemoteConfigClient()
    remoteConfig.features["similar_projects_carousel"] = true
    AppEnvironment.pushEnvironment(remoteConfigClient: remoteConfig)

    // Create mock data for similar projects
    let mockProjectNodes: [GraphAPI.FetchSimilarProjectsQuery.Data.Project.Node?] = [
      self.createMockProjectNode(id: 1, name: "Project 1"),
      self.createMockProjectNode(id: 2, name: "Project 2"),
      self.createMockProjectNode(id: 3, name: "Project 3"),
      self.createMockProjectNode(id: 4, name: "Project 4")
    ]

    // Create mock project data
    let mockProjects = GraphAPI.FetchSimilarProjectsQuery.Data.Project(nodes: mockProjectNodes)

    // Create mock query data
    let mockData = GraphAPI.FetchSimilarProjectsQuery.Data(projects: mockProjects)

    self.mockService = MockService(
      fetchGraphQLResponses: [
        (GraphAPI.FetchSimilarProjectsQuery.self, mockData)
      ]
    )

    // Initialize the use case with our mock service
    self.useCase = SimilarProjectsUseCase()
    self.useCase.navigateToProject.observe(self.projectTappedObserver.observer)
    self.useCase.similarProjects.producer.start(self.similarProjectsObserver.observer)
  }

  override func tearDown() {
    self.useCase = nil
    self.mockService = nil
    super.tearDown()
  }

  func testInitialState() {
    withEnvironment(apiService: self.mockService) {
      // The useCase should start with a loading state
      XCTAssertEqual(1, self.similarProjectsObserver.values.count)

      if case .loading = self.similarProjectsObserver.values[0] {
        // Expected loading state
      } else {
        XCTFail("Expected initial loading state")
      }
    }
  }

  func testProjectIDLoaded_emitsLoadedState() {
    withEnvironment(apiService: self.mockService) {
      // Verify we're in loading state
      XCTAssertEqual(1, self.similarProjectsObserver.values.count)
      if case .loading = self.similarProjectsObserver.values[0] {
        // Expected loading state
      } else {
        XCTFail("Expected loading state")
      }

      // When loading a project ID
      self.useCase.projectIDLoaded(projectID: "1")

      // Verify we received loaded state with projects
      XCTAssertEqual(2, self.similarProjectsObserver.values.count)

      if case let .loaded(projects) = similarProjectsObserver.values[1] {
        XCTAssertEqual(4, projects.count, "Expected 4 similar projects")
      } else {
        XCTFail("Expected loaded state with projects")
      }
    }
  }

  func testProjectTapped_emitsNavigateToProject() {
    withEnvironment(apiService: self.mockService) {
      // When loading a project ID
      self.useCase.projectIDLoaded(projectID: "1")
      guard
        case let .loaded(projects) = similarProjectsObserver.values[1],
        let project = projects.first
      else {
        return XCTFail()
      }

      // Send project tapped event
      self.useCase.projectTapped(project: project)

      // Verify navigate signal fired
      XCTAssertEqual(1, self.projectTappedObserver.values.count)
      XCTAssertEqual(project.projectID, self.projectTappedObserver.values[0].projectID)
    }
  }

  // MARK: - SimilarProject Parsing Tests

  func testSimilarProjectParsing_ValidData_Success() throws {
    // Create a valid ProjectCardFragment with all required fields
    let validProjectFragment = self.createMockProjectNode()

    // Test the parsing constructor
    let similarProject =
      try XCTUnwrap(SimilarProjectFragment(validProjectFragment.fragments.projectCardFragment))

    // Verify the parsing succeeded
    XCTAssertNotNil(similarProject, "Parsing should succeed with valid data")

    // Verify the parsed data is correct
    XCTAssertEqual(similarProject.projectID, 123)
    XCTAssertEqual(similarProject.name, "Test Project")
    XCTAssertEqual(similarProject.isLaunched, true)
    XCTAssertEqual(similarProject.isPrelaunchActivated, false)
    XCTAssertEqual(similarProject.percentFunded, 75)
    XCTAssertEqual(similarProject.state, .live)

    // Verify dates are parsed correctly
    XCTAssertEqual(
      similarProject.launchedAt?.timeIntervalSince1970 ?? 0,
      TimeInterval(1_741_737_648),
      accuracy: 0.001
    )
    XCTAssertEqual(
      similarProject.deadlineAt?.timeIntervalSince1970 ?? 0,
      TimeInterval(1_742_737_648),
      accuracy: 0.001
    )

    // Verify money is parsed correctly
    XCTAssertEqual(similarProject.goal?.amount, 10_000)
    XCTAssertEqual(similarProject.pledged?.amount, 7_500)
  }

  func testSimilarProjectParsing_InvalidData_ReturnsNil() {
    // Test with missing image URL
    let missingImageFragment = self.createMockProjectNode(imageURL: nil)

    let missingImageProject = SimilarProjectFragment(missingImageFragment.fragments.projectCardFragment)
    XCTAssertNil(missingImageProject, "Parsing should fail with missing image URL")

    // Test with invalid image URL
    let invalidImageFragment = self.createMockProjectNode(imageURL: "127.0.0.1:8000/test")

    let invalidImageProject = SimilarProjectFragment(invalidImageFragment.fragments.projectCardFragment)
    XCTAssertNil(invalidImageProject, "Parsing should fail with invalid image URL")

    // Test with invalid state
    let invalidStateNode = self.createMockProjectNode(state: "invalid_state")

    let invalidStateProject = SimilarProjectFragment(invalidStateNode.fragments.projectCardFragment)
    XCTAssertNil(invalidStateProject, "Parsing should fail with invalid state")
  }

  // Helper method to create mock project nodes for testing
  private func createMockProjectNode(
    id: Int = 123,
    name: String = "Test Project",
    imageURL: String? = "https://example.com/image.jpg",
    state: String = "live",
    isLaunched: Bool = true,
    prelaunchActivated: Bool = false,
    launchedAt: String? = "1741737648",
    deadlineAt: String? = "1742737648",
    percentFunded: Int = 75,
    goal: Double? = 10_000,
    pledged: Double = 7_500,
    isInPostCampaignPledgingPhase: Bool = false,
    isPostCampaignPledgingEnabled: Bool = false,
    url: String = "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
  ) -> GraphAPI.FetchSimilarProjectsQuery.Data.Project.Node {
    var resultMap: [String: Any] = [
      "__typename": "Project",
      "pid": id,
      "name": name,
      "state": GraphAPI.ProjectState(rawValue: state) ?? GraphAPI.ProjectState.__unknown(state),
      "isLaunched": isLaunched,
      "prelaunchActivated": prelaunchActivated,
      "percentFunded": percentFunded,
      "pledged": [
        "__typename": "Money",
        "amount": String(pledged),
        "currency": GraphAPI.CurrencyCode.usd,
        "symbol": "$"
      ],
      "isInPostCampaignPledgingPhase": isInPostCampaignPledgingPhase,
      "postCampaignPledgingEnabled": isPostCampaignPledgingEnabled,
      "url": url
    ]

    // Add optional fields
    if let imageURL {
      resultMap["image"] = [
        "__typename": "Photo",
        "url": imageURL
      ]
    }

    if let launchedAt {
      resultMap["launchedAt"] = launchedAt
    }

    if let deadlineAt {
      resultMap["deadlineAt"] = deadlineAt
    }

    if let goal {
      resultMap["goal"] = [
        "__typename": "Money",
        "amount": String(goal),
        "currency": GraphAPI.CurrencyCode.usd,
        "symbol": "$"
      ]
    }

    return GraphAPI.FetchSimilarProjectsQuery.Data.Project.Node(unsafeResultMap: resultMap)
  }
}
