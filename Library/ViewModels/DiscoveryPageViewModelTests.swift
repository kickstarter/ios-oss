@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import UIKit
import XCTest

internal final class DiscoveryPageViewModelTests: TestCase {
  fileprivate var vm: DiscoveryPageViewModelType = DiscoveryPageViewModel()

  fileprivate let activitiesForSample = TestObserver<[Activity], Never>()
  fileprivate let asyncReloadData = TestObserver<(), Never>()
  fileprivate let configureEditorialTableViewHeader = TestObserver<String, Never>()
  fileprivate let goToActivityProject = TestObserver<Project, Never>()
  fileprivate let goToActivityProjectRefTag = TestObserver<RefTag, Never>()
  fileprivate let goToEditorialProjectList = TestObserver<DiscoveryParams.TagID, Never>()
  fileprivate let goToPlaylist = TestObserver<[Project], Never>()
  fileprivate let goToPlaylistProject = TestObserver<Project, Never>()
  fileprivate let goToPlaylistRefTag = TestObserver<RefTag, Never>()
  fileprivate let goToProjectUpdate = TestObserver<Update, Never>()
  fileprivate let hasAddedProjects = TestObserver<Bool, Never>()
  fileprivate let hasLoadedProjects = TestObserver<(), Never>()
  fileprivate let hasRemovedProjects = TestObserver<Bool, Never>()
  fileprivate let hideEmptyState = TestObserver<(), Never>()
  fileprivate let notifyDelegateContentOffsetChanged = TestObserver<CGPoint, Never>()
  fileprivate let projectsAreLoading = TestObserver<Bool, Never>()
  fileprivate let projectsAreLoadingAnimated = TestObserver<(Bool, Bool), Never>()
  fileprivate let setScrollsToTop = TestObserver<Bool, Never>()
  private let scrollToProjectRow = TestObserver<Int, Never>()
  fileprivate let showEditorialHeader = TestObserver<DiscoveryEditorialCellValue?, Never>()
  fileprivate let showEditorialHeaderImageName = TestObserver<String?, Never>()
  fileprivate let showEditorialHeaderSubtitle = TestObserver<String?, Never>()
  fileprivate let showEditorialHeaderTagId = TestObserver<DiscoveryParams.TagID?, Never>()
  fileprivate let showEditorialHeaderTitle = TestObserver<String?, Never>()
  fileprivate let showEmptyState = TestObserver<EmptyState, Never>()
  fileprivate let showOnboarding = TestObserver<Bool, Never>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.activitiesForSample.observe(self.activitiesForSample.observer)
    self.vm.outputs.asyncReloadData.observe(self.asyncReloadData.observer)
    self.vm.outputs.configureEditorialTableViewHeader
      .observe(self.configureEditorialTableViewHeader.observer)
    self.vm.outputs.hideEmptyState.observe(self.hideEmptyState.observer)
    self.vm.outputs.goToActivityProject.map(first).observe(self.goToActivityProject.observer)
    self.vm.outputs.goToActivityProject.map(second).observe(self.goToActivityProjectRefTag.observer)
    self.vm.outputs.goToEditorialProjectList.observe(self.goToEditorialProjectList.observer)
    self.vm.outputs.goToProjectPlaylist.map(first).observe(self.goToPlaylistProject.observer)
    self.vm.outputs.goToProjectPlaylist.map(second).observe(self.goToPlaylist.observer)
    self.vm.outputs.goToProjectPlaylist.map(third).observe(self.goToPlaylistRefTag.observer)
    self.vm.outputs.goToProjectUpdate.map { $0.1 }.observe(self.goToProjectUpdate.observer)
    self.vm.outputs.notifyDelegateContentOffsetChanged
      .observe(self.notifyDelegateContentOffsetChanged.observer)
    self.vm.outputs.projectsAreLoadingAnimated.observe(self.projectsAreLoadingAnimated.observer)
    self.vm.outputs.projectsLoaded.ignoreValues().observe(self.hasLoadedProjects.observer)
    self.vm.outputs.scrollToProjectRow.observe(self.scrollToProjectRow.observer)
    self.vm.outputs.setScrollsToTop.observe(self.setScrollsToTop.observer)
    self.vm.outputs.showEditorialHeader.observe(self.showEditorialHeader.observer)
    self.vm.outputs.showEditorialHeader.map { $0?.title }.observe(self.showEditorialHeaderTitle.observer)
    self.vm.outputs.showEditorialHeader.map { $0?.subtitle }
      .observe(self.showEditorialHeaderSubtitle.observer)
    self.vm.outputs.showEditorialHeader.map { $0?.imageName }
      .observe(self.showEditorialHeaderImageName.observer)
    self.vm.outputs.showEditorialHeader.map { $0?.tagId }.observe(self.showEditorialHeaderTagId.observer)
    self.vm.outputs.showEmptyState.observe(self.showEmptyState.observer)
    self.vm.outputs.showOnboarding.observe(self.showOnboarding.observer)

    self.vm.outputs.projectsLoaded
      .map { $0.0.count }
      .combinePrevious(0)
      .map { prev, next in next > prev }
      .observe(self.hasAddedProjects.observer)
    self.vm.outputs.projectsLoaded
      .map { $0.0.count }
      .combinePrevious(0)
      .map { prev, next in next < prev }
      .observe(self.hasRemovedProjects.observer)
    self.vm.outputs.projectsAreLoadingAnimated.map { $0.0 }.observe(self.projectsAreLoading.observer)
  }

  func testPaginating() {
    self.vm.inputs.configureWith(sort: .magic)
    self.scheduler.advance()

    self.hasAddedProjects.assertDidNotEmitValue("No projects load at first.")
    self.hasRemovedProjects.assertDidNotEmitValue("No projects load at first.")
    XCTAssertEqual([], self.trackingClient.events, "No events tracked at first.")

    self.vm.inputs.selectedFilter(.defaults)

    self.projectsAreLoading.assertValues([])
    self.vm.inputs.viewWillAppear()

    self.projectsAreLoading.assertValues([true], "Projects start loading on viewWillAppear")

    self.vm.inputs.viewDidAppear()
    self.scheduler.advance()

    self.asyncReloadData.assertValueCount(1, "Reload data when projects are first added.")
    self.hasAddedProjects.assertValues([true], "Projects are added.")
    self.hasRemovedProjects.assertValues([false], "Projects are not removed.")
    self.projectsAreLoading.assertValues([true, false], "Loading indicator toggles on/off.")
    XCTAssertEqual(
      ["Explore Page Viewed"],
      self.trackingClient.events,
      "Impression is tracked."
    )

    // Scroll down a bit and advance scheduler
    self.vm.inputs.willDisplayRow(2, outOf: 10)
    self.scheduler.advance()

    self.hasAddedProjects.assertValues([true], "No projects are added.")
    self.hasRemovedProjects.assertValues([false], "No projects are removed.")
    XCTAssertEqual(
      ["Explore Page Viewed"],
      self.trackingClient.events,
      "No new events are tracked."
    )

    // Scroll down to the bottom of the view and advanced scheduler
    self.vm.inputs.willDisplayRow(9, outOf: 10)
    self.scheduler.advance()

    self.hasAddedProjects.assertValues([true, true], "More projects are added from pagination.")
    self.hasRemovedProjects.assertValues([false, false], "No projects are removed.")
    self.projectsAreLoading.assertValues(
      [true, false, true, false], "Loading indicator toggles on/off."
    )
    XCTAssertEqual(
      ["Explore Page Viewed"],
      self.trackingClient.events,
      "No new events are tracked"
    )

    // Make scroll area increase in size, advanced scheduler
    self.vm.inputs.willDisplayRow(9, outOf: 20)
    self.scheduler.advance()

    self.hasAddedProjects.assertValues([true, true], "No projects are added.")
    self.hasRemovedProjects.assertValues([false, false], "No projects are removed.")
    XCTAssertEqual(
      ["Explore Page Viewed"],
      self.trackingClient.events,
      "No new events are tracked."
    )

    // Change the filter params used
    self.vm.inputs.viewDidDisappear(animated: true)
    self.vm.inputs.selectedFilter(
      .defaults |> DiscoveryParams.lens.category .~ Category.art
    )
    self.vm.inputs.viewDidAppear()

    self.hasAddedProjects.assertValues([true, true, false], "No projects are added.")
    self.hasRemovedProjects.assertValues([false, false, true], "Projects are removed right away.")

    // Advance scheduler so that the API request is made
    self.scheduler.advance()

    self.hasAddedProjects.assertValues([true, true, false, true], "Projects are added.")
    self.hasRemovedProjects.assertValues([false, false, true, false], "Projects are not removed.")
    self.projectsAreLoading.assertValues(
      [true, false, true, false, true, false],
      "Loading indicator toggles on/off."
    )
    XCTAssertEqual(
      ["Explore Page Viewed", "Explore Page Viewed"],
      self.trackingClient.events,
      "Another event is tracked when the filters are updated."
    )
    XCTAssertEqual(
      [nil, 1],
      self.trackingClient.properties(forKey: "discover_subcategory_id", as: Int.self),
      "The updated category is tracked."
    )

    // Scroll to the end of the list and advance the scheduler.
    self.vm.inputs.willDisplayRow(18, outOf: 20)
    self.vm.inputs.willDisplayRow(19, outOf: 20)
    self.vm.inputs.willDisplayRow(20, outOf: 20)
    self.scheduler.advance()

    self.asyncReloadData.assertValueCount(1, "View is only reloaded once in the beginning.")
    self.hasAddedProjects.assertValues(
      [true, true, false, true, true],
      "Projects are added."
    )
    self.hasRemovedProjects.assertValues(
      [false, false, true, false, false],
      "Projects are not removed."
    )
    self.projectsAreLoading.assertValues(
      [true, false, true, false, true, false, true, false],
      "Loading indicator toggles on/off."
    )
    XCTAssertEqual(
      ["Explore Page Viewed", "Explore Page Viewed"],
      self.trackingClient.events,
      "No new events are tracked."
    )
  }

  /**
   Tests how changing filters affects loading projects when the view is visible and hidden.
   */
  func testViewLifecycle() {
    // Configure and load up view model
    self.vm.inputs.configureWith(sort: .magic)
    self.vm.inputs.viewWillAppear()
    self.vm.inputs.viewDidAppear()
    self.scheduler.advance()

    self.hasAddedProjects.assertValues([])

    // Select initial filter
    self.vm.inputs.selectedFilter(.defaults)
    self.scheduler.advance()

    self.hasAddedProjects.assertValues([true], "Projects load after the filter is changed.")

    // Navigate away from page
    self.vm.inputs.viewDidDisappear(animated: true)
    self.scheduler.advance()

    self.hasAddedProjects.assertValues([true], "Nothing changes when navigating away from view.")

    // Change filter
    self.vm.inputs.selectedFilter(.defaults |> DiscoveryParams.lens.staffPicks .~ true)
    self.scheduler.advance()

    self.hasAddedProjects.assertValues(
      [true, false],
      "Changing filters while away from view clears projects immediately."
    )

    // Change filter again
    self.vm.inputs.selectedFilter(.defaults |> DiscoveryParams.lens.starred .~ true)
    self.scheduler.advance()

    self.hasAddedProjects.assertValues(
      [true, false],
      "Changing filter again does not do anything."
    )

    // Come back to page
    self.vm.inputs.viewDidAppear()
    self.scheduler.advance()

    self.hasAddedProjects.assertValues(
      [true, false, true], "Projects load once the view appears again."
    )

    // Navigate away and back
    self.vm.inputs.viewDidDisappear(animated: true)
    self.vm.inputs.viewDidAppear()
    self.scheduler.advance()

    self.hasAddedProjects.assertValues(
      [true, false, true],
      "Switch away from the view and coming back doesn't do anything"
    )
  }

  func testGoToProject() {
    let project = Project.template
    let discoveryEnvelope = .template
      |> DiscoveryEnvelope.lens.projects .~ (
        (0...2).map { id in .template |> Project.lens.id .~ (100 + id) }
      )

    withEnvironment(apiService: MockService(fetchDiscoveryResponse: discoveryEnvelope)) {
      self.vm.inputs.configureWith(sort: .magic)
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.viewDidAppear()
      self.vm.inputs.selectedFilter(.defaults)
      self.scheduler.advance()

      self.vm.inputs.tapped(project: project)

      self.goToPlaylist.assertValues([discoveryEnvelope.projects], "Project playlist emits.")
      self.goToPlaylistProject.assertValues([project])
      self.goToPlaylistRefTag.assertValues(
        [.discoveryWithSort(.magic)],
        "Go to the project with discovery ref tag."
      )

      self.vm.inputs.selectedFilter(.defaults
        |> DiscoveryParams.lens.category .~ Category.art)
      self.vm.inputs.tapped(project: project)

      self.goToPlaylist.assertValueCount(2, "New playlist for project emits.")
      self.goToPlaylistProject.assertValues([project, project])
      self.goToPlaylistRefTag.assertValues(
        [.discoveryWithSort(.magic), .categoryWithSort(.magic)],
        "Go to the project with the category sort ref tag."
      )

      self.vm.inputs.selectedFilter(.defaults |> DiscoveryParams.lens.staffPicks .~ true)
      self.vm.inputs.tapped(project: project)

      self.goToPlaylist.assertValueCount(3, "New playlist for project emits.")
      self.goToPlaylistProject.assertValues([project, project, project])
      self.goToPlaylistRefTag.assertValues(
        [.discoveryWithSort(.magic), .categoryWithSort(.magic), .recommendedWithSort(.magic)],
        "Go to the project with the recommended sort ref tag."
      )

      self.vm.inputs.selectedFilter(.defaults |> DiscoveryParams.lens.social .~ true)
      self.vm.inputs.tapped(project: project)

      self.goToPlaylist.assertValueCount(4, "New playlist for project emits.")
      self.goToPlaylistProject.assertValues([project, project, project, project])
      self.goToPlaylistRefTag.assertValues(
        [
          .discoveryWithSort(.magic), .categoryWithSort(.magic), .recommendedWithSort(.magic),
          .socialWithSort(.magic)
        ], "Go to the project with the social ref tag."
      )

      let activityProject = Project.template
      let activity = .template |> Activity.lens.project .~ activityProject

      self.vm.inputs.tapped(activity: activity)
      self.goToActivityProject.assertValues([activityProject], "Activity sample project emits.")
      self.goToActivityProjectRefTag.assertValues(
        [.activitySample], "Go to the project with the activity sample ref tag."
      )

      self.vm.inputs.configureWith(sort: .endingSoon)
      self.vm.inputs.tapped(project: project)
      self.goToPlaylistProject.assertValues([project, project, project, project, project])
      self.goToPlaylistRefTag.assertValues(
        [
          .discoveryWithSort(.magic), .categoryWithSort(.magic), .recommendedWithSort(.magic),
          .socialWithSort(.magic), .socialWithSort(.endingSoon)
        ], "Sort changes on ref tag."
      )
    }
  }

  func testGoToProjectUpdate() {
    let update = Update.template

    let activity = .template
      |> Activity.lens.category .~ .update
      |> Activity.lens.project .~ Project.template
      |> Activity.lens.update .~ update

    self.vm.inputs.tapped(activity: activity)
    self.goToProjectUpdate.assertValues([update])
  }

  func testShowActivitySample() {
    let activity1 = .template
      |> Activity.lens.id .~ 111

    let activity2 = .template
      |> Activity.lens.id .~ 222

    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: User.template))

    withEnvironment(apiService: MockService(fetchActivitiesResponse: [activity1])) {
      self.vm.inputs.configureWith(sort: .magic)
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.viewDidAppear()
      self.scheduler.advance()

      self.activitiesForSample.assertValues([[activity1]], "Activity sample is shown.")

      // Change the filter.
      self.vm.inputs.selectedFilter(.defaults
        |> DiscoveryParams.lens.category .~ Category.art)
      self.vm.inputs.viewDidDisappear(animated: true)
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.viewDidAppear()

      self.activitiesForSample.assertValues([[activity1], []], "Activity sample is hidden.")

      // Change the filter again.
      self.vm.inputs.selectedFilter(.defaults |> DiscoveryParams.lens.starred .~ true)
      self.vm.inputs.viewDidDisappear(animated: true)
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.viewDidAppear()

      self.activitiesForSample.assertValues([[activity1], []], "Activity sample is still hidden.")

      withEnvironment(apiService: MockService(fetchActivitiesResponse: [activity2])) {
        self.vm.inputs.viewWillAppear()
        self.vm.inputs.viewDidAppear()
        self.scheduler.advance()

        self.activitiesForSample.assertValues(
          [[activity1], [], [activity2]],
          "New activity sample is shown."
        )
      }
    }
  }

  func testActivitySampleWithLifecycle() {
    let activity = Activity.template

    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: User.template))

    withEnvironment(apiService: MockService(fetchActivitiesResponse: [activity])) {
      self.vm.inputs.configureWith(sort: .magic)
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.viewDidAppear()
      self.vm.inputs.selectedFilter(.defaults)
      self.scheduler.advance()

      self.activitiesForSample.assertValues([[activity]], "Activity sample is shown.")

      // Tap on activity to go to project screen, then close project screen.
      self.vm.inputs.tapped(activity: activity)
      self.vm.inputs.viewDidDisappear(animated: true)
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.viewDidAppear()

      self.activitiesForSample.assertValues([[activity]], "Activity sample is still shown.")

      // Change tab.
      self.vm.inputs.viewDidDisappear(animated: false)
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.viewDidAppear()

      self.activitiesForSample.assertValues([[activity]], "Activity sample is still shown.")

      // Swipe half way to new sort, but return to same sort.
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.viewDidAppear()

      self.activitiesForSample.assertValues([[activity]], "Activity sample is still shown.")

      // Swipe to new sort, swipe back.
      self.vm.inputs.viewDidDisappear(animated: true)
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.viewDidAppear()

      self.activitiesForSample.assertValues([[activity], []], "Activity sample is cleared.")
    }
  }

  func testClearActivitiesWhenLoggedOut() {
    let activity = .template
      |> Activity.lens.id .~ 111

    AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: User.template))

    withEnvironment(apiService: MockService(fetchActivitiesResponse: [activity])) {
      self.vm.inputs.configureWith(sort: .magic)
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.viewDidAppear()
      self.scheduler.advance()

      self.activitiesForSample.assertValues([[activity]], "Activity sample is shown.")
    }

    // Switch to profile tab to log out.
    self.vm.inputs.viewDidDisappear(animated: false)
    AppEnvironment.logout()
    self.vm.inputs.viewWillAppear()
    self.vm.inputs.viewDidAppear()

    self.activitiesForSample.assertValues(
      [[activity], []],
      "Activities are cleared out when logging out."
    )
  }

  func testRefreshProjects_ModalLogin() {
    let projectEnv = .template
      |> DiscoveryEnvelope.lens.projects .~ (1...7).map { .template |> Project.lens.id .~ $0 }

    self.vm.inputs.configureWith(sort: .magic)
    self.vm.inputs.viewWillAppear()
    self.vm.inputs.viewDidAppear()
    self.vm.inputs.selectedFilter(.defaults)

    self.scheduler.advance()
    self.hasAddedProjects.assertValues([true], "Projects added for logged out user.")

    withEnvironment(apiService: MockService(fetchDiscoveryResponse: projectEnv)) {
      AppEnvironment.login(AccessTokenEnvelope(accessToken: "cafebeef", user: User.template))
      self.vm.inputs.userSessionStarted()
      self.hasAddedProjects.assertValues([true], "Previous projects not cleared.")

      self.scheduler.advance()
      self.hasAddedProjects.assertValues([true, true], "New projects added for logged in user.")
    }
  }

  func testRefreshProjects_TabLogin() {
    let projectEnv = .template
      |> DiscoveryEnvelope.lens.projects .~ (1...7).map { .template |> Project.lens.id .~ $0 }

    self.vm.inputs.configureWith(sort: .magic)
    self.vm.inputs.viewWillAppear()
    self.vm.inputs.viewDidAppear()
    self.vm.inputs.selectedFilter(.defaults)

    self.scheduler.advance()

    self.hasAddedProjects.assertValues([true], "Projects added for logged out user.")

    self.vm.inputs.viewDidDisappear(animated: false)

    withEnvironment(apiService: MockService(fetchDiscoveryResponse: projectEnv)) {
      AppEnvironment.login(AccessTokenEnvelope(accessToken: "cafebeef", user: User.template))
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.viewDidAppear()
      self.vm.inputs.userSessionStarted()
      self.hasAddedProjects.assertValues([true], "Previous projects not cleared.")

      self.scheduler.advance()

      self.hasAddedProjects.assertValues([true, true], "New projects added for logged in user.")
    }
  }

  func testConfigureEditorialTableViewHeader_TagId() {
    self.vm.inputs.configureWith(sort: .magic)
    self.vm.inputs.viewWillAppear()
    self.vm.inputs.viewDidAppear()

    let params = DiscoveryParams.defaults
      |> \.tagId .~ .goRewardless

    self.configureEditorialTableViewHeader.assertDidNotEmitValue()

    self.vm.inputs.selectedFilter(params)

    self.configureEditorialTableViewHeader.assertValues(
      ["These projects could use your support."],
      "Table view header is shown"
    )
  }

  func testConfigureEditorialTableViewHeader_NoTagId() {
    self.vm.inputs.configureWith(sort: .magic)
    self.vm.inputs.viewWillAppear()
    self.vm.inputs.viewDidAppear()
    self.vm.inputs.selectedFilter(.defaults)

    self.configureEditorialTableViewHeader.assertDidNotEmitValue()
  }

  // MARK: - Editorial Header

  func testShowEditorialHeader_LoggedOut_OnMagic_DefaultFilters_FeatureFlag_IsOn() {
    let mockConfig = Config.template
      |> \.features .~ [Feature.goRewardless.rawValue: true]
    let defaultFilters = DiscoveryParams.defaults
      |> DiscoveryParams.lens.includePOTD .~ true

    withEnvironment(config: mockConfig, currentUser: nil) {
      self.vm.inputs.configureWith(sort: .magic)
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.viewDidAppear()
      self.vm.inputs.selectedFilter(defaultFilters)

      self.vm.inputs.configUpdated(config: mockConfig)

      self.scheduler.advance(by: .seconds(1))

      self.showEditorialHeader.assertValueCount(1)
      self.showEditorialHeaderTitle.assertValues(["Back it because you believe in it."])
      self.showEditorialHeaderSubtitle.assertValues(["Find projects that speak to you ▸"])
      self.showEditorialHeaderImageName.assertValues(["go-rewardless-home"])
      self.showEditorialHeaderTagId.assertValues([.goRewardless])
    }
  }

  func testShowEditorialHeader_LoggedOut_NonMagic_FeatureFlag_IsOn() {
    let mockConfig = Config.template
      |> \.features .~ [Feature.goRewardless.rawValue: true]

    withEnvironment(config: mockConfig, currentUser: nil) {
      self.vm.inputs.configureWith(sort: .popular)
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.viewDidAppear()
      self.vm.inputs.selectedFilter(.defaults)

      self.vm.inputs.configUpdated(config: mockConfig)

      self.scheduler.advance(by: .seconds(1))

      self.showEditorialHeader.assertDidNotEmitValue()
    }
  }

  func testShowEditorialHeader_LoggedOut_OnMagic_OtherFilters_FeatureFlag_IsOn() {
    let mockConfig = Config.template
      |> \.features .~ [Feature.goRewardless.rawValue: true]
    let otherFilter = DiscoveryParams.defaults
      |> \.category .~ Category.tabletopGames

    withEnvironment(config: mockConfig, currentUser: nil) {
      self.vm.inputs.configureWith(sort: .magic)
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.viewDidAppear()
      self.vm.inputs.selectedFilter(otherFilter)

      self.vm.inputs.configUpdated(config: mockConfig)

      self.scheduler.advance(by: .seconds(1))

      self.showEditorialHeader.assertValueCount(1)
      self.showEditorialHeaderTitle.assertValues([nil])
      self.showEditorialHeaderSubtitle.assertValues([nil])
      self.showEditorialHeaderImageName.assertValues([nil])
      self.showEditorialHeaderTagId.assertValues([nil])
    }
  }

  func testShowEditorialHeader_LoggedOut_OnMagic_DefaultFilters_FeatureFlag_IsOff() {
    let mockConfig = Config.template
      |> \.features .~ [Feature.goRewardless.rawValue: false]
    let loggedOutDefaults = DiscoveryParams.defaults
      |> DiscoveryParams.lens.includePOTD .~ true

    withEnvironment(config: mockConfig, currentUser: nil) {
      self.vm.inputs.configureWith(sort: .magic)
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.viewDidAppear()
      self.vm.inputs.selectedFilter(loggedOutDefaults)

      self.vm.inputs.configUpdated(config: mockConfig)

      self.scheduler.advance(by: .seconds(1))

      self.showEditorialHeader.assertValueCount(1)
      self.showEditorialHeaderTitle.assertValues([nil])
      self.showEditorialHeaderSubtitle.assertValues([nil])
      self.showEditorialHeaderImageName.assertValues([nil])
      self.showEditorialHeaderTagId.assertValues([nil])
    }
  }

  func testShowEditorialHeader_LoggedIn_OnMagic_DefaultFilters_FeatureFlag_IsOn() {
    let mockConfig = Config.template
      |> \.features .~ [Feature.goRewardless.rawValue: true]
    let defaultFilters = DiscoveryParams.recommendedDefaults

    withEnvironment(config: mockConfig, currentUser: User.template) {
      self.vm.inputs.configureWith(sort: .magic)
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.viewDidAppear()
      self.vm.inputs.selectedFilter(defaultFilters)

      self.vm.inputs.configUpdated(config: mockConfig)

      self.scheduler.advance(by: .seconds(1))

      self.showEditorialHeader.assertValueCount(1)
      self.showEditorialHeaderTitle.assertValues(["Back it because you believe in it."])
      self.showEditorialHeaderSubtitle.assertValues(["Find projects that speak to you ▸"])
      self.showEditorialHeaderImageName.assertValues(["go-rewardless-home"])
      self.showEditorialHeaderTagId.assertValues([.goRewardless])
    }
  }

  func testShowEditorialHeader_LoggedIn_NonMagic_FeatureFlag_IsOn() {
    let mockConfig = Config.template
      |> \.features .~ [Feature.goRewardless.rawValue: true]

    withEnvironment(config: mockConfig, currentUser: .template) {
      self.vm.inputs.configureWith(sort: .popular)
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.viewDidAppear()
      self.vm.inputs.selectedFilter(DiscoveryParams.recommendedDefaults)

      self.vm.inputs.configUpdated(config: mockConfig)

      self.showEditorialHeader.assertDidNotEmitValue()
    }
  }

  func testShowEditorialHeader_LoggedIn_OnMagic_OtherFilters_FeatureFlag_IsOn() {
    let mockConfig = Config.template
      |> \.features .~ [Feature.goRewardless.rawValue: true]
    let otherFilter = DiscoveryParams.defaults
      |> \.category .~ Category.filmAndVideo

    withEnvironment(config: mockConfig, currentUser: .template) {
      self.vm.inputs.configureWith(sort: .magic)
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.viewDidAppear()
      self.vm.inputs.selectedFilter(otherFilter)

      self.vm.inputs.configUpdated(config: mockConfig)

      self.scheduler.advance(by: .seconds(1))

      self.showEditorialHeader.assertValueCount(1)
      self.showEditorialHeaderTitle.assertValues([nil])
      self.showEditorialHeaderSubtitle.assertValues([nil])
      self.showEditorialHeaderImageName.assertValues([nil])
      self.showEditorialHeaderTagId.assertValues([nil])
    }
  }

  func testShowEditorialHeader_LoggedIn_OnMagic_ChangingFilters_FeatureFlag_IsOn() {
    let mockConfig = Config.template
      |> \.features .~ [Feature.goRewardless.rawValue: true]
    let otherFilter = DiscoveryParams.defaults
      |> \.category .~ Category.filmAndVideo
    let defaultFilters = DiscoveryParams.recommendedDefaults

    withEnvironment(config: mockConfig, currentUser: .template) {
      self.vm.inputs.configureWith(sort: .magic)
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.viewDidAppear()
      self.vm.inputs.selectedFilter(defaultFilters)

      self.vm.inputs.configUpdated(config: mockConfig)

      self.scheduler.advance(by: .seconds(1))

      self.showEditorialHeader.assertValueCount(1)
      self.showEditorialHeaderTitle.assertValues(["Back it because you believe in it."])
      self.showEditorialHeaderSubtitle.assertValues(["Find projects that speak to you ▸"])
      self.showEditorialHeaderImageName.assertValues(["go-rewardless-home"])
      self.showEditorialHeaderTagId.assertValues([.goRewardless])

      self.vm.inputs.selectedFilter(otherFilter)

      self.showEditorialHeader.assertValueCount(2)
      self.showEditorialHeaderTitle.assertValues([
        "Back it because you believe in it.",
        nil
      ])
      self.showEditorialHeaderSubtitle.assertValues([
        "Find projects that speak to you ▸",
        nil
      ])
      self.showEditorialHeaderImageName.assertValues([
        "go-rewardless-home",
        nil
      ])
      self.showEditorialHeaderTagId.assertValues([.goRewardless, nil])

      self.vm.inputs.selectedFilter(defaultFilters)

      self.showEditorialHeaderTitle.assertValues([
        "Back it because you believe in it.",
        nil,
        "Back it because you believe in it."
      ])
      self.showEditorialHeaderSubtitle.assertValues([
        "Find projects that speak to you ▸",
        nil,
        "Find projects that speak to you ▸"
      ])
      self.showEditorialHeaderImageName.assertValues([
        "go-rewardless-home",
        nil,
        "go-rewardless-home"
      ])
      self.showEditorialHeaderTagId.assertValues([.goRewardless, nil, .goRewardless])
    }
  }

  func testShowEditorialHeader_LoggedIn_OnMagic_DefaultFilters_FeatureFlag_IsToggled() {
    let mockConfig = Config.template
      |> \.features .~ [Feature.goRewardless.rawValue: true]
    let defaultFilters = DiscoveryParams.recommendedDefaults

    withEnvironment(config: mockConfig, currentUser: .template) {
      self.vm.inputs.configureWith(sort: .magic)
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.viewDidAppear()
      self.vm.inputs.selectedFilter(defaultFilters)

      self.vm.inputs.configUpdated(config: mockConfig)

      self.scheduler.advance(by: .seconds(1))

      self.showEditorialHeader.assertValueCount(1)
      self.showEditorialHeaderTitle.assertValues(["Back it because you believe in it."])
      self.showEditorialHeaderSubtitle.assertValues(["Find projects that speak to you ▸"])
      self.showEditorialHeaderImageName.assertValues(["go-rewardless-home"])
      self.showEditorialHeaderTagId.assertValues([.goRewardless])

      let updatedConfig = Config.template
        |> \.features .~ [Feature.goRewardless.rawValue: false]

      withEnvironment(config: updatedConfig) {
        self.vm.inputs.configUpdated(config: updatedConfig)

        self.scheduler.advance(by: .seconds(1))

        self.showEditorialHeader.assertValueCount(2)
        self.showEditorialHeaderTitle.assertValues([
          "Back it because you believe in it.",
          nil
        ])
        self.showEditorialHeaderSubtitle.assertValues([
          "Find projects that speak to you ▸",
          nil
        ])
        self.showEditorialHeaderImageName.assertValues([
          "go-rewardless-home",
          nil
        ])
        self.showEditorialHeaderTagId.assertValues([.goRewardless, nil])

        self.vm.inputs.configUpdated(config: updatedConfig)

        self.showEditorialHeader.assertValueCount(2, "Doesn't repeat if value is the same")
      }
    }
  }

  func testShowEditorialHeader_LoggedIn_OnMagic_DefaultFilters_FeatureFlag_IsOff() {
    let mockConfig = Config.template
      |> \.features .~ [Feature.goRewardless.rawValue: false]

    withEnvironment(config: mockConfig, currentUser: .template) {
      self.vm.inputs.configureWith(sort: .magic)
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.viewDidAppear()
      self.vm.inputs.selectedFilter(DiscoveryParams.recommendedDefaults)

      self.vm.inputs.configUpdated(config: mockConfig)

      self.scheduler.advance(by: .seconds(1))

      self.showEditorialHeader.assertValueCount(1)
      self.showEditorialHeaderTitle.assertValues([nil])
      self.showEditorialHeaderSubtitle.assertValues([nil])
      self.showEditorialHeaderImageName.assertValues([nil])
      self.showEditorialHeaderTagId.assertValues([nil])
    }
  }

  func testShowEditorialHeader_LoggedIn_OnMagic_DefaultFilters_FeatureFlag_IsOn_UsesCachedConfig() {
    let mockConfig = Config.template
      |> \.features .~ [Feature.goRewardless.rawValue: false]

    withEnvironment(config: mockConfig, currentUser: .template) {
      self.vm.inputs.configureWith(sort: .magic)
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.viewDidAppear()
      self.vm.inputs.selectedFilter(DiscoveryParams.recommendedDefaults)

      self.scheduler.advance(by: .seconds(1))

      self.showEditorialHeader.assertValueCount(1)
      self.showEditorialHeaderTitle.assertValues([nil])
      self.showEditorialHeaderSubtitle.assertValues([nil])
      self.showEditorialHeaderImageName.assertValues([nil])
      self.showEditorialHeaderTagId.assertValues([nil])
    }
  }

  // MARK: - Onboarding

  func testShowOnboarding_LoggedOutOnMagic() {
    self.vm.inputs.configureWith(sort: .magic)
    self.vm.inputs.viewWillAppear()
    self.vm.inputs.viewDidAppear()
    self.vm.inputs.selectedFilter(.defaults)

    self.showOnboarding.assertValues([true])
  }

  func testShowOnboarding_LoggedOutOnNonMagic() {
    self.vm.inputs.configureWith(sort: .popular)
    self.vm.inputs.viewWillAppear()
    self.vm.inputs.viewDidAppear()
    self.vm.inputs.selectedFilter(.defaults)

    self.showOnboarding.assertValues([false])
  }

  func testShowOnboarding_LoggedIn() {
    withEnvironment(currentUser: .template) {
      self.vm.inputs.configureWith(sort: .magic)
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.viewDidAppear()
      self.vm.inputs.selectedFilter(.defaults)

      self.showOnboarding.assertValues([false])
    }
  }

  func testShowOnboarding_LoggedOut_OnMagic_HasTagId() {
    self.vm.inputs.configureWith(sort: .magic)
    self.vm.inputs.viewWillAppear()
    self.vm.inputs.viewDidAppear()

    let params = DiscoveryParams.defaults
      |> \.tagId .~ .goRewardless

    self.vm.inputs.selectedFilter(params)

    self.showOnboarding.assertValues([false])
  }

  // MARK: - Scroll to top

  func testScrollsToTop() {
    self.vm.inputs.configureWith(sort: .magic)

    self.setScrollsToTop.assertValueCount(0)

    self.vm.inputs.viewDidAppear()

    self.setScrollsToTop.assertValues([true])

    self.vm.inputs.viewDidDisappear(animated: true)

    self.setScrollsToTop.assertValues([true, false])
  }

  func testEmptyStates() {
    let projectEnv = .template
      |> DiscoveryEnvelope.lens.projects .~ [Project]()

    let projectEnvWithProjects = .template
      |> DiscoveryEnvelope.lens.projects .~ (1...4).map { .template |> Project.lens.id .~ $0 }

    self.vm.inputs.configureWith(sort: .magic)
    self.vm.inputs.viewWillAppear()
    self.vm.inputs.viewDidAppear()
    self.scheduler.advance()

    withEnvironment(apiService: MockService(fetchDiscoveryResponse: projectEnv)) {
      self.vm.inputs.selectedFilter(.defaults |> DiscoveryParams.lens.starred .~ true)

      self.showEmptyState.assertValueCount(0)

      self.scheduler.advance()

      self.showEmptyState.assertValues([.starred])
      self.hideEmptyState.assertValueCount(1)

      // switch to another empty state
      self.vm.inputs.selectedFilter(.defaults |> DiscoveryParams.lens.recommended .~ true)

      self.hideEmptyState.assertValueCount(2)

      self.scheduler.advance()

      self.showEmptyState.assertValues([.starred, .recommended])

      // switch to non-empty state
      withEnvironment(apiService: MockService(fetchDiscoveryResponse: projectEnvWithProjects)) {
        self.vm.inputs.selectedFilter(.defaults |> DiscoveryParams.lens.social .~ true)

        self.hideEmptyState.assertValueCount(3)

        self.scheduler.advance()

        self.showEmptyState.assertValues(
          [.starred, .recommended], "Show empty state does not emit."
        )

        // switch back to empty state
        withEnvironment(apiService: MockService(fetchDiscoveryResponse: projectEnv)) {
          self.vm.inputs.selectedFilter(.defaults |> DiscoveryParams.lens.social .~ false)

          self.hideEmptyState.assertValueCount(6)

          self.scheduler.advance()

          self.showEmptyState.assertValues([.starred, .recommended])

          self.vm.inputs.selectedFilter(.defaults |> DiscoveryParams.lens.social .~ true)

          self.hideEmptyState.assertValueCount(7)

          self.scheduler.advance()

          self.showEmptyState.assertValues([.starred, .recommended, .socialDisabled])
        }
      }
    }
  }

  func testEmptyStates_Social() {
    let projectEnv = .template
      |> DiscoveryEnvelope.lens.projects .~ [Project]()

    let antisocialUser = User.template |> \.social .~ false
    let socialUser = User.template |> \.social .~ true

    self.vm.inputs.configureWith(sort: .magic)
    self.vm.inputs.viewWillAppear()
    self.vm.inputs.viewDidAppear()
    self.scheduler.advance()

    withEnvironment(apiService: MockService(fetchDiscoveryResponse: projectEnv)) {
      AppEnvironment.login(AccessTokenEnvelope(accessToken: "deadbeef", user: User.template))

      self.vm.inputs.selectedFilter(.defaults |> DiscoveryParams.lens.social .~ true)

      self.showEmptyState.assertValueCount(0)

      self.scheduler.advance()

      self.showEmptyState.assertValues([.socialDisabled], "Emits .socialDisabled for nil social.")
      self.hideEmptyState.assertValueCount(1)

      withEnvironment(currentUser: antisocialUser) {
        self.vm.inputs.selectedFilter(.defaults |> DiscoveryParams.lens.recommended .~ true)
        self.scheduler.advance()

        self.hideEmptyState.assertValueCount(2)

        self.vm.inputs.selectedFilter(.defaults |> DiscoveryParams.lens.social .~ true)
        self.scheduler.advance()

        self.showEmptyState.assertValues(
          [.socialDisabled, .recommended, .socialDisabled],
          "Emits .socialDisabled for false social."
        )
        self.hideEmptyState.assertValueCount(3)

        self.vm.inputs.viewDidDisappear(animated: true)

        // User enables social on the pushed Friends screen, then navigates back.
        withEnvironment(currentUser: socialUser) {
          self.vm.inputs.viewWillAppear()
          self.vm.inputs.viewDidAppear()
          self.scheduler.advance()

          self.showEmptyState.assertValues(
            [.socialDisabled, .recommended, .socialDisabled, .socialNoPledges],
            "Emits .socialNoPledges for true social."
          )
          self.hideEmptyState.assertValueCount(3)
        }
      }
    }
  }

  func testScrollAndUpdateProjects_ViaProjectNavigator() {
    let playlist = (0...10).map { idx in .template |> Project.lens.id .~ (idx + 42) }
    let projectEnv = .template
      |> DiscoveryEnvelope.lens.projects .~ playlist

    let playlist2 = (0...20).map { idx in .template |> Project.lens.id .~ (idx + 72) }
    let projectEnv2 = .template
      |> DiscoveryEnvelope.lens.projects .~ playlist2

    withEnvironment(apiService: MockService(fetchDiscoveryResponse: projectEnv)) {
      self.vm.inputs.configureWith(sort: .magic)
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.viewDidAppear()
      self.vm.inputs.selectedFilter(.defaults)

      self.scheduler.advance()

      self.hasAddedProjects.assertValues([true], "Projects are loaded.")

      self.vm.inputs.tapped(project: playlist[4])
      self.vm.inputs.viewDidDisappear(animated: true)
      self.vm.inputs.transitionedToProject(at: 5, outOf: playlist.count)

      self.scrollToProjectRow.assertValues([5])

      self.vm.inputs.transitionedToProject(at: 6, outOf: playlist.count)

      self.scrollToProjectRow.assertValues([5, 6])

      self.vm.inputs.transitionedToProject(at: 7, outOf: playlist.count)

      self.scrollToProjectRow.assertValues([5, 6, 7])

      withEnvironment(apiService: MockService(fetchDiscoveryResponse: projectEnv2)) {
        self.vm.inputs.transitionedToProject(at: 8, outOf: playlist.count)

        self.scheduler.advance()

        self.scrollToProjectRow.assertValues([5, 6, 7, 8])
        self.hasAddedProjects.assertValues([true, true], "More projects are loaded.")

        self.vm.inputs.transitionedToProject(at: 7, outOf: playlist2.count)

        self.scrollToProjectRow.assertValues([5, 6, 7, 8, 7])
      }
    }
  }

  func testProjectsLoad_IfPulledToRefresh() {
    let playlist = (0...10).map { idx in .template |> Project.lens.id .~ (idx + 42) }
    let projectEnv = .template
      |> DiscoveryEnvelope.lens.projects .~ playlist

    withEnvironment(apiService: MockService(fetchDiscoveryResponse: projectEnv)) {
      self.vm.inputs.configureWith(sort: .magic)
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.viewDidAppear()
      self.vm.inputs.selectedFilter(.defaults)

      self.projectsAreLoading.assertValueCount(1)

      self.scheduler.advance()

      self.projectsAreLoading.assertValueCount(2)

      self.vm.inputs.pulledToRefresh()

      self.scheduler.advance()

      self.projectsAreLoading.assertValueCount(6)
    }
  }

  func testProjectsDontLoad_IfPulledToRefreshWithError() {
    withEnvironment(apiService: MockService(fetchDiscoveryError: .couldNotParseErrorEnvelopeJSON)) {
      self.vm.inputs.configureWith(sort: .magic)
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.selectedFilter(.defaults)

      self.scheduler.advance()

      self.projectsAreLoading.assertValueCount(1)

      self.vm.inputs.pulledToRefresh()

      self.scheduler.advance()

      self.projectsAreLoading.assertValueCount(1)
    }
  }

  func testProjectAreLoadingAnimated() {
    let playlist = (0...10).map { idx in .template |> Project.lens.id .~ (idx + 42) }
    let projectEnv = .template
      |> DiscoveryEnvelope.lens.projects .~ playlist

    let playlist2 = (0...20).map { idx in .template |> Project.lens.id .~ (idx + 72) }
    let projectEnv2 = .template
      |> DiscoveryEnvelope.lens.projects .~ playlist2

    withEnvironment(apiService: MockService(fetchDiscoveryResponse: projectEnv)) {
      self.vm.inputs.configureWith(sort: .magic)
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.viewDidAppear()
      self.vm.inputs.selectedFilter(.defaults)

      XCTAssertEqual(
        true, self.projectsAreLoadingAnimated.values.last?.0,
        "Start loading on viewWillAppear."
      )
      XCTAssertEqual(
        false, self.projectsAreLoadingAnimated.values.last?.1,
        "Shouldn't animate on first load."
      )

      self.scheduler.advance()

      XCTAssertEqual(
        false, self.projectsAreLoadingAnimated.values.last?.0,
        "Projects should stop loading after server returns."
      )
      XCTAssertEqual(
        false, self.projectsAreLoadingAnimated.values.last?.1,
        "Shouldn't animate on first load."
      )

      withEnvironment(apiService: MockService(fetchDiscoveryResponse: projectEnv2)) {
        self.scheduler.advance()

        self.vm.inputs.pulledToRefresh()

        XCTAssertEqual(
          true, self.projectsAreLoadingAnimated.values.last?.0,
          "Should start loading on pullToRefresh event."
        )
        XCTAssertEqual(
          true, self.projectsAreLoadingAnimated.values.last?.1,
          "Should animate if projects are loading after pulling to refresh."
        )

        self.scheduler.advance()

        XCTAssertEqual(
          false, self.projectsAreLoadingAnimated.values.last?.0,
          "Should stop loading after server returns."
        )
        XCTAssertEqual(
          true, self.projectsAreLoadingAnimated.values.last?.1,
          "Should animate if projects are loading after pulling to refresh."
        )
      }
    }
  }

  func testGoToEditorialProjectList() {
    let discoveryEnvelope = .template
      |> DiscoveryEnvelope.lens.projects .~ (
        (0...2).map { id in .template |> Project.lens.id .~ (100 + id) }
      )
    let mockConfig = Config.template
      |> \.features .~ [Feature.goRewardless.rawValue: true]
    let loggedOutFilters = DiscoveryParams.defaults
      |> \.includePOTD .~ true

    self.showEditorialHeader.assertDidNotEmitValue()
    self.showEditorialHeaderTitle.assertDidNotEmitValue()
    self.showEditorialHeaderSubtitle.assertDidNotEmitValue()
    self.showEditorialHeaderImageName.assertDidNotEmitValue()
    self.showEditorialHeaderTagId.assertDidNotEmitValue()
    self.goToEditorialProjectList.assertDidNotEmitValue()

    withEnvironment(
      apiService: MockService(fetchDiscoveryResponse: discoveryEnvelope),
      config: mockConfig
    ) {
      self.vm.inputs.configureWith(sort: .magic)
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.viewDidAppear()
      self.vm.inputs.selectedFilter(loggedOutFilters)

      self.vm.inputs.configUpdated(config: mockConfig)

      self.scheduler.advance()

      self.scheduler.advance(by: .seconds(1))

      self.showEditorialHeader.assertValueCount(1)
      self.showEditorialHeaderTitle.assertValues(["Back it because you believe in it."])
      self.showEditorialHeaderSubtitle.assertValues(["Find projects that speak to you ▸"])
      self.showEditorialHeaderImageName.assertValues(["go-rewardless-home"])
      self.showEditorialHeaderTagId.assertValues([.goRewardless])
      self.goToEditorialProjectList.assertDidNotEmitValue()

      self.vm.inputs.discoveryEditorialCellTapped(with: .goRewardless)

      self.goToEditorialProjectList.assertValues([.goRewardless])
    }
  }

  func testGoToEditorialProject() {
    let project = Project.template
    let discoveryEnvelope = .template
      |> DiscoveryEnvelope.lens.projects .~ (
        (0...2).map { id in .template |> Project.lens.id .~ (100 + id) }
      )

    withEnvironment(apiService: MockService(fetchDiscoveryResponse: discoveryEnvelope)) {
      self.vm.inputs.configureWith(sort: .magic)
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.viewDidAppear()
      self.vm.inputs.selectedFilter(.defaults |> DiscoveryParams.lens.tagId .~ .goRewardless)
      self.scheduler.advance()

      self.vm.inputs.tapped(project: project)

      self.goToPlaylist.assertValues([discoveryEnvelope.projects], "Project playlist emits.")
      self.goToPlaylistProject.assertValues([project])
      self.goToPlaylistRefTag.assertValues(
        [.projectCollection(DiscoveryParams.TagID.goRewardless)],
        "Go to the project with Go Rewardless Editorial ref tag."
      )
    }
  }

  func testTrackEditorialHeaderTapped() {
    XCTAssertEqual([], self.trackingClient.events)

    self.vm.inputs.discoveryEditorialCellTapped(with: .goRewardless)

    XCTAssertEqual(["Editorial Card Clicked"], self.trackingClient.events)
    XCTAssertEqual(
      ["ios_project_collection_tag_518"],
      self.trackingClient.properties(forKey: "session_ref_tag", as: String.self)
    )

    self.vm.inputs.discoveryEditorialCellTapped(with: .goRewardless)

    XCTAssertEqual(["Editorial Card Clicked", "Editorial Card Clicked"], self.trackingClient.events)
    XCTAssertEqual(
      ["ios_project_collection_tag_518", "ios_project_collection_tag_518"],
      self.trackingClient.properties(forKey: "session_ref_tag")
    )
  }

  func testNotifyDelegateContentOffsetChanged() {
    self.notifyDelegateContentOffsetChanged.assertDidNotEmitValue()

    let discoveryEnvelope = .template
      |> DiscoveryEnvelope.lens.projects .~ (
        (0...2).map { id in .template |> Project.lens.id .~ (100 + id) }
      )

    withEnvironment(apiService: MockService(fetchDiscoveryResponse: discoveryEnvelope)) {
      self.vm.inputs.configureWith(sort: .magic)
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.viewDidAppear()
      self.vm.inputs.selectedFilter(.defaults)

      self.vm.inputs.scrollViewDidScroll(toContentOffset: .init(x: 0, y: 100))

      self.notifyDelegateContentOffsetChanged.assertValues(
        [],
        "Does not emit while projects are loading"
      )

      self.scheduler.advance()

      self.notifyDelegateContentOffsetChanged.assertValues([.init(x: 0, y: 100)])

      self.vm.inputs.scrollViewDidScroll(toContentOffset: .init(x: 0, y: 250))

      self.notifyDelegateContentOffsetChanged.assertValues([
        .init(x: 0, y: 100),
        .init(x: 0, y: 250)
      ])
    }
  }
}
