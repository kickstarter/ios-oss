import ApolloTestSupport
import GraphAPI
import GraphAPITestMocks
@testable import KsApi
@testable import KsApiTestHelpers
@testable import Library
@testable import LibraryTestHelpers
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class BackerDashboardProjectsViewModelTests: TestCase {
  private let vm: BackerDashboardProjectsViewModelType = BackerDashboardProjectsViewModel()

  private let emptyStateIsVisible = TestObserver<Bool, Never>()
  private let emptyStateProjectsType = TestObserver<ProfileProjectsType, Never>()
  private let isRefreshing = TestObserver<Bool, Never>()
  private let isLoadingNextPage = TestObserver<Bool, Never>()
  private let goToProject = TestObserver<ProjectCardProperties, Never>()
  private let goToProjectRefTag = TestObserver<RefTag, Never>()
  private let projects = TestObserver<[ProjectCardProperties], Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.emptyStateIsVisible.map(first).observe(self.emptyStateIsVisible.observer)
    self.vm.outputs.emptyStateIsVisible.map(second).observe(self.emptyStateProjectsType.observer)
    self.vm.outputs.isRefreshing.observe(self.isRefreshing.observer)
    self.vm.outputs.isLoadingNextPage.observe(self.isLoadingNextPage.observer)
    self.vm.outputs.goToProject.map(first).observe(self.goToProject.observer)
    self.vm.outputs.goToProject.map(second).observe(self.goToProjectRefTag.observer)
    self.vm.outputs.projects.observe(self.projects.observer)
  }

  func testProjects() {
    let response1 = self.dataForMyBackingsFetch(numberOfProjects: 3)
    let response2 = self.dataForMyBackingsFetch(numberOfProjects: 4)
    let response3 = self.dataForMyBackingsFetch(numberOfProjects: 5)

    withEnvironment(
      apiService: MockService(fetchBackerBackedProjectsResponse: response1),
      currentUser: .template
    ) {
      self.vm.inputs.configureWith(projectsType: .backed)
      self.vm.inputs.viewDidAppear(false)
      self.vm.inputs.currentUserUpdated()

      self.projects.assertValueCount(0)
      self.emptyStateIsVisible.assertValueCount(0)
      self.isRefreshing.assertValues([true])
      self.isLoadingNextPage.assertLastValue(false)

      XCTAssertEqual([], self.segmentTrackingClient.events)
      XCTAssertEqual([], self.segmentTrackingClient.properties(forKey: "type", as: String.self))

      self.scheduler.advance()

      XCTAssertEqual(self.projects.lastValue?.count, 3)
      self.emptyStateIsVisible.assertValues([false])
      self.emptyStateProjectsType.assertValues([.backed])
      self.isRefreshing.assertValues([true, false])

      self.vm.inputs.viewDidAppear(true)
      self.isRefreshing.assertValues([true, false], "Projects don't refresh.")

      self.scheduler.advance()

      XCTAssertEqual(self.projects.lastValue?.count, 3)
      self.projects.assertValueCount(1, "Projects have only been fetched once")
      self.emptyStateIsVisible.assertValues([false])
      self.isRefreshing.assertValues([true, false], "Projects don't refresh.")

      let updatedUser = User.template |> \.stats.backedProjectsCount .~ 1

      // Come back after backing a project.
      withEnvironment(
        apiService: MockService(fetchBackerBackedProjectsResponse: response2),
        currentUser: updatedUser
      ) {
        self.vm.inputs.currentUserUpdated()
        self.vm.inputs.viewDidAppear(false)

        self.isRefreshing.assertValues([true, false, true])
        self.isLoadingNextPage.assertLastValue(false)

        self.scheduler.advance()

        XCTAssertEqual(self.projects.lastValue?.count, 4)
        self.emptyStateIsVisible.assertValues([false, false])
        self.isRefreshing.assertValues([true, false, true, false])
        self.isLoadingNextPage.assertLastValue(false)
      }

      // Refresh.
      withEnvironment(
        apiService: MockService(fetchBackerBackedProjectsResponse: response3),
        currentUser: updatedUser
      ) {
        self.vm.inputs.refresh()

        self.isRefreshing.assertValues([true, false, true, false, true])
        self.isLoadingNextPage.assertLastValue(false)

        self.scheduler.advance()

        XCTAssertEqual(self.projects.lastValue?.count, 5)
        self.emptyStateIsVisible.assertValues([false, false, false])
        self.isRefreshing.assertValues([true, false, true, false, true, false])
        self.isLoadingNextPage.assertLastValue(false)
      }
    }
  }

  func testNoProjects() {
    let response = self.dataForSavedProjectsFetch(numberOfProjects: 0)

    withEnvironment(
      apiService: MockService(fetchBackerSavedProjectsResponse: response),
      currentUser: .template
    ) {
      self.vm.inputs.configureWith(projectsType: .saved)
      self.vm.inputs.viewDidAppear(false)

      self.projects.assertValueCount(0)
      self.emptyStateIsVisible.assertValueCount(0)
      self.isLoadingNextPage.assertValues([false])
      self.isRefreshing.assertValues([true])

      self.scheduler.advance()

      XCTAssert(self.projects.lastValue?.isEmpty == true)
      self.emptyStateIsVisible.assertValues([true], "Empty state is shown for user with no projects.")
      self.emptyStateProjectsType.assertValues([.saved])
      self.isRefreshing.assertValues([true, false])

      XCTAssertEqual([], self.segmentTrackingClient.events)
      XCTAssertEqual([], self.segmentTrackingClient.properties(forKey: "type", as: String.self))

      self.vm.inputs.viewDidAppear(true)

      self.scheduler.advance()

      XCTAssert(self.projects.lastValue?.isEmpty == true, "Projects emits empty list")
      self.emptyStateIsVisible.assertValues([true], "Empty state does not emit.")
    }
  }

  func testProjectCellTapped() {
    let response = self.dataForMyBackingsFetch(numberOfProjects: 3)
    let projectCardFragment = response.projects?.nodes?[0]?.fragments.projectCardFragment
    let projectCardProperties = ProjectCardProperties(projectCardFragment!)!

    withEnvironment(
      apiService: MockService(fetchBackerBackedProjectsResponse: response),
      currentUser: .template
    ) {
      self.vm.inputs.configureWith(projectsType: .backed)
      self.vm.inputs.viewDidAppear(false)

      self.scheduler.advance()

      self.vm.inputs.projectTapped(projectCardProperties)

      XCTAssertEqual(
        projectCardProperties.projectID,
        self.goToProject.lastValue?.projectID,
        "Project emitted"
      )
      self.goToProjectRefTag.assertValues([.profileBacked], "RefTag = profile_backed emitted.")

      XCTAssertEqual(self.segmentTrackingClient.events, ["CTA Clicked"])

      XCTAssertEqual(
        ["profile"],
        self.segmentTrackingClient.properties(forKey: "context_page", as: String.self)
      )
      XCTAssertEqual(
        ["backed"],
        self.segmentTrackingClient.properties(forKey: "context_section", as: String.self)
      )
      XCTAssertEqual(
        ["account_menu"],
        self.segmentTrackingClient.properties(forKey: "context_location", as: String.self)
      )
    }
  }

  func testRefresh() {
    let response = self.dataForMyBackingsFetch(numberOfProjects: 3)
    let user = User.template

    withEnvironment(apiService: MockService(fetchBackerBackedProjectsResponse: response), currentUser: user) {
      self.vm.inputs.configureWith(projectsType: .backed)
      self.vm.inputs.viewDidAppear(false)
      self.vm.inputs.currentUserUpdated()

      self.isRefreshing.assertLastValue(true)
      self.isLoadingNextPage.assertLastValue(false)

      // Load all projects to end refreshing.
      self.scheduler.advance()
      self.isRefreshing.assertLastValue(false)
      self.isLoadingNextPage.assertLastValue(false)

      // Test that updating the saved projects count doesn't trigger re-fetching backed projects.
      let userSavedCountChanged = user |> \.stats.starredProjectsCount .~ 3
      withEnvironment(
        apiService: MockService(fetchBackerBackedProjectsResponse: response),
        currentUser: userSavedCountChanged
      ) {
        self.vm.inputs.viewDidAppear(true)
        self.isRefreshing.assertLastValue(false)
        self.isLoadingNextPage.assertLastValue(false)
      }

      // Test that updating the backed projects count triggers re-fetching backed projects.
      let userBackedCountChanged = userSavedCountChanged |> \.stats.backedProjectsCount .~ 1
      withEnvironment(
        apiService: MockService(fetchBackerBackedProjectsResponse: response),
        currentUser: userBackedCountChanged
      ) {
        self.vm.inputs.viewDidAppear(true)
        self.isRefreshing.assertLastValue(true)
        self.isLoadingNextPage.assertLastValue(false)

        self.scheduler.advance()
        self.isRefreshing.assertLastValue(false)
        self.isLoadingNextPage.assertLastValue(false)
      }
    }
  }

  func testLoadNextPage() {
    let response = self.dataForMyBackingsFetch(numberOfProjects: 3)

    let user = User.template

    withEnvironment(apiService: MockService(fetchBackerBackedProjectsResponse: response), currentUser: user) {
      self.vm.inputs.configureWith(projectsType: .backed)
      self.vm.inputs.viewDidAppear(false)
      self.vm.inputs.currentUserUpdated()

      self.isRefreshing.assertLastValue(true)
      self.isLoadingNextPage.assertLastValue(false)

      // Finish loading.
      self.scheduler.advance()
      self.isRefreshing.assertLastValue(false)
      self.isLoadingNextPage.assertLastValue(false)

      // Trigger next page fetch.
      self.vm.inputs.willDisplayRow(10, outOf: 10)

      self.isRefreshing.assertLastValue(false)
      self.isLoadingNextPage.assertLastValue(true)

      // Finish loading.
      self.scheduler.advance()
      self.isRefreshing.assertLastValue(false)
      self.isLoadingNextPage.assertLastValue(false)
    }
  }

  // - MARK: Helpers

  func dataForMyBackingsFetch(numberOfProjects: Int) -> GraphAPI.FetchMyBackedProjectsQuery.Data {
    let mock = GraphAPI.ProjectCardFragment.mockProjectsConnectionQuery(numberOfProjects: numberOfProjects)
    return GraphAPI.FetchMyBackedProjectsQuery.Data.from(mock)
  }

  func dataForSavedProjectsFetch(numberOfProjects: Int) -> GraphAPI.FetchMySavedProjectsQuery.Data {
    let mock = GraphAPI.ProjectCardFragment.mockProjectsConnectionQuery(numberOfProjects: numberOfProjects)
    return GraphAPI.FetchMySavedProjectsQuery.Data.from(mock)
  }
}
