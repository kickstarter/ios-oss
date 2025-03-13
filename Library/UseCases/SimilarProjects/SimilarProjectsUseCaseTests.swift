@testable import KsApi
@testable import Library
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class SimilarProjectsUseCaseTests: TestCase {
  private var useCase: SimilarProjectsUseCase!
  private let projectTappedObserver = TestObserver<SimilarProject, Never>()
  private let similarProjectsObserver = TestObserver<SimilarProjectsState, Never>()

  override func setUp() {
    super.setUp()

    let remoteConfig = MockRemoteConfigClient()
    remoteConfig.features["similar_projects_carousel"] = true
    AppEnvironment.pushEnvironment(remoteConfigClient: remoteConfig)

    self.useCase = SimilarProjectsUseCase()
    self.useCase.navigateToProject.observe(self.projectTappedObserver.observer)
    self.useCase.similarProjects.producer.start(self.similarProjectsObserver.observer)
  }

  override func tearDown() {
    self.useCase = nil
    AppEnvironment.popEnvironment()
    super.tearDown()
  }

  func testInitialState() {
    // The useCase should start with a loading state
    XCTAssertEqual(1, self.similarProjectsObserver.values.count)

    if case .loading = self.similarProjectsObserver.values[0] {
      // Expected loading state
    } else {
      XCTFail("Expected initial loading state")
    }
  }

  func testProjectIDLoaded_emitsLoadedState() {
    // When loading a project ID
    self.useCase.projectIDLoaded(projectID: "project-123")

    // Verify we're in loading state
    XCTAssertEqual(1, self.similarProjectsObserver.values.count)
    if case .loading = self.similarProjectsObserver.values[0] {
      // Expected loading state
    } else {
      XCTFail("Expected loading state")
    }

    // Advance scheduler to simulate network delay
    self.scheduler.advance(by: .seconds(2))

    // Verify we received loaded state with projects
    XCTAssertEqual(2, self.similarProjectsObserver.values.count)

    if case let .loaded(projects) = similarProjectsObserver.values[1] {
      XCTAssertEqual(4, projects.count, "Expected 4 similar projects")
    } else {
      XCTFail("Expected loaded state with projects")
    }
  }

  func testProjectTapped_emitsNavigateToProject() {
    // Create a fake project
    let project = TestSimilarProject(pid: "project-456")

    // Send project tapped event
    self.useCase.projectTapped(project: project)

    // Verify navigate signal fired
    XCTAssertEqual(1, self.projectTappedObserver.values.count)
    XCTAssertEqual("project-456", self.projectTappedObserver.values[0].pid)
  }
}

// Test helper
private struct TestSimilarProject: SimilarProject {
  let pid: String
}
