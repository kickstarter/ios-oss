import GraphAPI
@testable import KsApi
@testable import Library
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class SimilarProjectsUseCaseTests: TestCase {
  private var useCase: SimilarProjectsUseCase!
  private let projectTappedObserver = TestObserver<ProjectCardProperties, Never>()
  private let similarProjectsObserver = TestObserver<SimilarProjectsState, Never>()
  private var mockService: MockService!

  override func setUp() {
    super.setUp()

    let remoteConfig = MockRemoteConfigClient()
    remoteConfig.features["similar_projects_carousel"] = true
    AppEnvironment.pushEnvironment(remoteConfigClient: remoteConfig)

    // Create mock data for similar projects
    let mockProjectNodes: [GraphAPI.FetchSimilarProjectsQuery.Data.Projects.Node?] = [
      self.createMockProjectNode(id: 1, name: "Project 1"),
      self.createMockProjectNode(id: 2, name: "Project 2"),
      self.createMockProjectNode(id: 3, name: "Project 3"),
      self.createMockProjectNode(id: 4, name: "Project 4")
    ]

    // Create mock project data
    let mockProjects = GraphAPI.FetchSimilarProjectsQuery.Data.Projects(nodes: mockProjectNodes)

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
      try XCTUnwrap(ProjectCardProperties(validProjectFragment.fragments.projectCardFragment))

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

    let missingImageProject = ProjectCardProperties(missingImageFragment.fragments.projectCardFragment)
    XCTAssertNil(missingImageProject, "Parsing should fail with missing image URL")

    // Test with invalid image URL
    let invalidImageFragment = self.createMockProjectNode(imageURL: "127.0.0.1:8000/test")

    let invalidImageProject = ProjectCardProperties(invalidImageFragment.fragments.projectCardFragment)
    XCTAssertNil(invalidImageProject, "Parsing should fail with invalid image URL")

    // Test with invalid state
    let invalidStateNode = self.createMockProjectNode(state: "invalid_state")

    let invalidStateProject = ProjectCardProperties(invalidStateNode.fragments.projectCardFragment)
    XCTAssertNil(invalidStateProject, "Parsing should fail with invalid state")
  }

  // MARK: - ProjectPamphletMainCellProperties Tests

  func testProjectPamphletMainCellProperties_DirectProperties() {
    // Create a mock project node with specific values
    let mockNode = self.createMockProjectNode(
      id: 456,
      name: "Test Project Properties",
      imageURL: "https://example.com/test-image.jpg",
      state: "LIVE",
      goal: 50_000,
      pledged: 25_000
    )

    // Get the ProjectPamphletMainCellProperties from the node
    let properties = mockNode
      .fragments.projectCardFragment
      .fragments.projectPamphletMainCellPropertiesFragment
      .projectPamphletMainCellProperties

    // Test direct properties
    XCTAssertEqual(properties.name, "Test Project Properties")
    XCTAssertEqual(properties.photo, "https://example.com/test-image.jpg")
    XCTAssertEqual(properties.state, .live)
    XCTAssertEqual(properties.goal.amount, 50_000)
    XCTAssertEqual(properties.pledged.amount, 25_000)
    XCTAssertEqual(properties.goal.currency, "USD")
    XCTAssertEqual(properties.pledged.currency, "USD")
    XCTAssertEqual(properties.goal.symbol, "$")
    XCTAssertEqual(properties.pledged.symbol, "$")
    XCTAssertEqual(properties.webURL, "https://www.youtube.com/watch?v=dQw4w9WgXcQ")
  }

  func testProjectPamphletMainCellProperties_DerivedProperties() {
    // Create a mock project node with specific values for testing derived properties
    let mockNode = self.createMockProjectNode(
      id: 789,
      name: "Derived Properties Test",
      goal: 100_000,
      pledged: 75_000
    )

    // Get the ProjectPamphletMainCellProperties from the node
    let properties = mockNode
      .fragments.projectCardFragment
      .fragments.projectPamphletMainCellPropertiesFragment
      .projectPamphletMainCellProperties

    // Test derived properties
    XCTAssertEqual(properties.fundingProgress, 0.75, accuracy: 0.001)
    XCTAssertFalse(properties.goalMet)

    // Test USD conversion properties
    XCTAssertEqual(properties.pledgedUsd, Float(75_000) * properties.usdExchangeRate)
    XCTAssertEqual(properties.goalUsd, Float(100_000) * properties.usdExchangeRate)

    // Test currency-related properties
    XCTAssertEqual(properties.currentCurrency, "USD") // Default currency
    XCTAssertFalse(properties.needsConversion) // Same currency, no conversion needed
  }

  func testProjectPamphletMainCellProperties_GoalMet() {
    // Test when goal is met (pledged >= goal)
    let goalMetNode = self.createMockProjectNode(
      goal: 10_000,
      pledged: 10_000 // Exactly met
    )

    let goalMetProperties = goalMetNode
      .fragments.projectCardFragment
      .fragments.projectPamphletMainCellPropertiesFragment
      .projectPamphletMainCellProperties

    XCTAssertTrue(goalMetProperties.goalMet)

    // Test when goal is exceeded
    let goalExceededNode = self.createMockProjectNode(
      goal: 10_000,
      pledged: 15_000 // Exceeded
    )

    let goalExceededProperties = goalExceededNode
      .fragments.projectCardFragment
      .fragments.projectPamphletMainCellPropertiesFragment
      .projectPamphletMainCellProperties

    XCTAssertTrue(goalExceededProperties.goalMet)
  }

  func testProjectPamphletMainCellProperties_CurrencyConversion() {
    // Create a mock project with different currency
    let mockNode = self.createMockProjectNode()
    let properties = mockNode
      .fragments.projectCardFragment
      .fragments.projectPamphletMainCellPropertiesFragment
      .projectPamphletMainCellProperties

    // Test with default currency (USD)
    XCTAssertFalse(properties.needsConversion)
    XCTAssertTrue(properties.omitUSCurrencyCode)

    // The needsConversion property should return true when currency != currentCurrency
    XCTAssertEqual(properties.currency, "USD")
    XCTAssertEqual(properties.currentCurrency, "USD")
    XCTAssertFalse(properties.needsConversion)

    // Test USD currency code omission
    XCTAssertEqual(properties.currentCurrency, "USD")
    XCTAssertTrue(properties.omitUSCurrencyCode)
  }

  func testProjectPamphletMainCellProperties_ZeroPledgeHandling() {
    let zeroPledgeNode = self.createMockProjectNode(
      goal: 1_000,
      pledged: 0
    )

    let zeroPledgeProperties = zeroPledgeNode
      .fragments.projectCardFragment
      .fragments.projectPamphletMainCellPropertiesFragment
      .projectPamphletMainCellProperties

    XCTAssertEqual(zeroPledgeProperties.fundingProgress, 0.0)
    XCTAssertFalse(zeroPledgeProperties.goalMet)
  }

  // MARK: - Helpers

  // Helper method to create mock project nodes for testing
  private func createMockProjectNode(
    id: Int = 123,
    name: String = "Test Project",
    projectDescription: String = "Test blurb",
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
    url: String = "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
    stateChangedAt: String = "1741737000",
    backersCount: Int = 150,
    fxRate: Float = 1.0,
    projectUsdExchangeRate: Float = 1.0,
    currency: String = "USD",
    countryCode: String = "US",
    countryName: String = "United States"
  ) -> GraphAPI.FetchSimilarProjectsQuery.Data.Projects.Node {
    let projectState = GraphAPI.ProjectState(rawValue: state.uppercased())
    let wrappedState = projectState.isSome ? GraphQLEnum.case(projectState!) : .unknown(state)

    return GraphAPI.FetchSimilarProjectsQuery.Data.Projects.Node(
      image: imageURL.isSome ? GraphAPI.FetchSimilarProjectsQuery.Data.Projects.Node.Image(
        id: "1",
        url: imageURL!
      ) : nil,
      pid: id,
      name: name,
      state: wrappedState,
      isLaunched: isLaunched,
      deadlineAt: deadlineAt,
      percentFunded: percentFunded,
      prelaunchActivated: prelaunchActivated,
      launchedAt: launchedAt,
      isInPostCampaignPledgingPhase: isInPostCampaignPledgingPhase,
      postCampaignPledgingEnabled: isPostCampaignPledgingEnabled,
      url: url,
      isWatched: false,
      goal: goal.isSome ? GraphAPI.FetchSimilarProjectsQuery.Data.Projects.Node.Goal(
        amount: String(goal!),
        currency: .case(GraphAPI.CurrencyCode.usd),
        symbol: "$"
      ) : nil,
      pledged: GraphAPI.FetchSimilarProjectsQuery.Data.Projects.Node.Pledged(
        amount: String(pledged),
        currency: GraphQLEnum.case(GraphAPI.CurrencyCode.usd),
        symbol: "$"
      ),
      backersCount: backersCount,
      commentsCount: 0,
      country: GraphAPI.FetchSimilarProjectsQuery.Data.Projects.Node.Country(
        code: .case(GraphAPI.CountryCode(rawValue: countryCode)!),
        name: countryName
      ),
      currency: .case(GraphAPI.CurrencyCode(rawValue: currency)!),
      isPrelaunchActivated: prelaunchActivated,
      projectTags: [],
      fxRate: Double(fxRate),
      projectDescription: description,
      stateChangedAt: stateChangedAt,
      projectUsdExchangeRate: Double(projectUsdExchangeRate),
      risks: ""
    )
  }
}
