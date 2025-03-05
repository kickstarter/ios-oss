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
      self.createMockProjectNode(id: "1", name: "Project 1"),
      self.createMockProjectNode(id: "2", name: "Project 2"),
      self.createMockProjectNode(id: "3", name: "Project 3"),
      self.createMockProjectNode(id: "4", name: "Project 4")
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
    AppEnvironment.popEnvironment()
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
      self.useCase.projectIDLoaded(projectID: "123")

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
      self.useCase.projectIDLoaded(projectID: "123")
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

  // Helper method to create mock project nodes for testing
  private func createMockProjectNode(id: String, name: String) -> GraphAPI.FetchSimilarProjectsQuery.Data
    .Project.Node {
    let resultMap: [String: Any] = [
      "__typename": "Project",
      "pid": Int(id)!,
      "name": name,
      "photo": [
        "__typename": "Photo",
        "url": "https://example.com/image.jpg"
      ]
    ]

    return GraphAPI.FetchSimilarProjectsQuery.Data.Project.Node(unsafeResultMap: resultMap)
  }
}
