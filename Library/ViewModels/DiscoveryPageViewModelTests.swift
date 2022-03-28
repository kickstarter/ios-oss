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
  fileprivate let contentInset = TestObserver<UIEdgeInsets, Never>()
  fileprivate let dismissPersonalizationCell = TestObserver<Void, Never>()
  fileprivate let goToActivityProject = TestObserver<Project, Never>()
  fileprivate let goToActivityProjectRefTag = TestObserver<RefTag, Never>()
  fileprivate let goToCuratedProjects = TestObserver<[KsApi.Category], Never>()
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
  fileprivate let projectsLoadedDiscoveryParams = TestObserver<DiscoveryParams?, Never>()
  fileprivate let projectsLoadedVariant = TestObserver<OptimizelyExperiment.Variant, Never>()
  fileprivate let setScrollsToTop = TestObserver<Bool, Never>()
  fileprivate let showEmptyState = TestObserver<EmptyState, Never>()
  fileprivate let showOnboarding = TestObserver<Bool, Never>()
  fileprivate let showPersonalization = TestObserver<Bool, Never>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.activitiesForSample.observe(self.activitiesForSample.observer)
    self.vm.outputs.asyncReloadData.observe(self.asyncReloadData.observer)
    self.vm.outputs.contentInset.observe(self.contentInset.observer)
    self.vm.outputs.dismissPersonalizationCell.observe(self.dismissPersonalizationCell.observer)
    self.vm.outputs.hideEmptyState.observe(self.hideEmptyState.observer)
    self.vm.outputs.goToActivityProject.map(first).observe(self.goToActivityProject.observer)
    self.vm.outputs.goToActivityProject.map(second).observe(self.goToActivityProjectRefTag.observer)
    self.vm.outputs.goToCuratedProjects.observe(self.goToCuratedProjects.observer)
    self.vm.outputs.goToProjectPlaylist.map(first).observe(self.goToPlaylistProject.observer)
    self.vm.outputs.goToProjectPlaylist.map(second).observe(self.goToPlaylist.observer)
    self.vm.outputs.goToProjectPlaylist.map(third).observe(self.goToPlaylistRefTag.observer)
    self.vm.outputs.goToProjectUpdate.map { $0.1 }.observe(self.goToProjectUpdate.observer)
    self.vm.outputs.notifyDelegateContentOffsetChanged
      .observe(self.notifyDelegateContentOffsetChanged.observer)
    self.vm.outputs.projectsAreLoadingAnimated.observe(self.projectsAreLoadingAnimated.observer)
    self.vm.outputs.projectsLoaded.ignoreValues().observe(self.hasLoadedProjects.observer)
    self.vm.outputs.projectsLoaded.map(second).observe(self.projectsLoadedDiscoveryParams.observer)
    self.vm.outputs.projectsLoaded.map(third).observe(self.projectsLoadedVariant.observer)
    self.vm.outputs.setScrollsToTop.observe(self.setScrollsToTop.observer)
    self.vm.outputs.showEmptyState.observe(self.showEmptyState.observer)
    self.vm.outputs.showOnboarding.observe(self.showOnboarding.observer)
    self.vm.outputs.showPersonalization.observe(self.showPersonalization.observer)

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
    let params = DiscoveryParams.defaults
      |> \.sort .~ .magic

    self.vm.inputs.configureWith(sort: .magic)
    self.scheduler.advance()

    self.projectsLoadedDiscoveryParams.assertDidNotEmitValue()
    self.hasAddedProjects.assertDidNotEmitValue("No projects load at first.")
    self.hasRemovedProjects.assertDidNotEmitValue("No projects load at first.")
    XCTAssertEqual([], self.segmentTrackingClient.events, "No events tracked at first.")

    self.vm.inputs.selectedFilter(.defaults)

    self.projectsAreLoading.assertValues([])
    self.vm.inputs.viewWillAppear()

    self.projectsAreLoading.assertValues([true], "Projects start loading on viewWillAppear")

    self.vm.inputs.viewDidAppear()
    self.scheduler.advance()

    self.projectsLoadedDiscoveryParams.assertValues([params])
    self.asyncReloadData.assertValueCount(1, "Reload data when projects are first added.")
    self.hasAddedProjects.assertValues([true], "Projects are added.")
    self.hasRemovedProjects.assertValues([false], "Projects are not removed.")
    self.projectsAreLoading.assertValues([true, false], "Loading indicator toggles on/off.")

    XCTAssertEqual(
      ["Page Viewed"],
      self.segmentTrackingClient.events,
      "Impression is tracked."
    )

    let segmentClientProps = self.segmentTrackingClient.properties.last

    XCTAssertEqual("discover", segmentClientProps?["context_page"] as? String)

    XCTAssertEqual("magic", segmentClientProps?["discover_sort"] as? String)

    // Scroll down a bit and advance scheduler
    self.vm.inputs.willDisplayRow(2, outOf: 10)
    self.scheduler.advance()

    self.hasAddedProjects.assertValues([true], "No projects are added.")
    self.hasRemovedProjects.assertValues([false], "No projects are removed.")

    XCTAssertEqual(
      ["Page Viewed"],
      self.segmentTrackingClient.events,
      "No new events are tracked."
    )

    // Scroll down to the bottom of the view and advanced scheduler
    self.vm.inputs.willDisplayRow(9, outOf: 10)
    self.scheduler.advance()

    self.projectsLoadedDiscoveryParams.assertValues([params, params])
    self.hasAddedProjects.assertValues([true, true], "More projects are added from pagination.")
    self.hasRemovedProjects.assertValues([false, false], "No projects are removed.")
    self.projectsAreLoading.assertValues(
      [true, false, true, false], "Loading indicator toggles on/off."
    )

    XCTAssertEqual(
      ["Page Viewed"],
      self.segmentTrackingClient.events,
      "No new events are tracked"
    )

    // Make scroll area increase in size, advanced scheduler
    self.vm.inputs.willDisplayRow(9, outOf: 20)
    self.scheduler.advance()

    self.projectsLoadedDiscoveryParams.assertValues([params, params])
    self.hasAddedProjects.assertValues([true, true], "No projects are added.")
    self.hasRemovedProjects.assertValues([false, false], "No projects are removed.")

    XCTAssertEqual(
      ["Page Viewed"],
      self.segmentTrackingClient.events,
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

    let updatedParams = params
      |> DiscoveryParams.lens.category .~ Category.art

    self.projectsLoadedDiscoveryParams.assertValues([params, params, updatedParams, updatedParams])
    self.hasAddedProjects.assertValues([true, true, false, true], "Projects are added.")
    self.hasRemovedProjects.assertValues([false, false, true, false], "Projects are not removed.")
    self.projectsAreLoading.assertValues(
      [true, false, true, false, true, false],
      "Loading indicator toggles on/off."
    )

    XCTAssertEqual(
      ["Page Viewed", "Page Viewed"],
      self.segmentTrackingClient.events,
      "Another event is tracked when the filters are updated."
    )
    XCTAssertEqual(
      [nil, 1],
      self.segmentTrackingClient.properties(forKey: "discover_subcategory_id", as: Int.self),
      "The updated category is tracked."
    )

    // Scroll to the end of the list and advance the scheduler.
    self.vm.inputs.willDisplayRow(18, outOf: 20)
    self.vm.inputs.willDisplayRow(19, outOf: 20)
    self.vm.inputs.willDisplayRow(20, outOf: 20)
    self.scheduler.advance()

    self.projectsLoadedDiscoveryParams
      .assertValues([params, params, updatedParams, updatedParams, updatedParams])
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
      ["Page Viewed", "Page Viewed"],
      self.segmentTrackingClient.events,
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

  func testProjectsLoaded_IsNativeProjectCardsControl() {
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.experiments .~ [
        OptimizelyExperiment.Key.nativeProjectCards.rawValue:
          OptimizelyExperiment.Variant.control.rawValue
      ]

    let params = DiscoveryParams.defaults
      |> \.sort .~ .magic

    withEnvironment(optimizelyClient: mockOptimizelyClient) {
      self.vm.inputs.configureWith(sort: .magic)
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.viewDidAppear()
      self.scheduler.advance()

      self.hasAddedProjects.assertValues([])
      self.projectsLoadedDiscoveryParams.assertValues([])
      self.projectsLoadedVariant.assertValues([])

      self.vm.inputs.selectedFilter(.defaults)
      self.scheduler.advance()

      self.hasAddedProjects.assertValues([true], "Projects load after the filter is changed.")
      self.projectsLoadedDiscoveryParams.assertValues([params])
      self.projectsLoadedVariant.assertValues([.control])

      XCTAssertTrue(mockOptimizelyClient.getVariantPathCalled)
    }
  }

  func testProjectsLoaded_IsNativeProjectCardsVariant1() {
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.experiments .~ [
        OptimizelyExperiment.Key.nativeProjectCards.rawValue:
          OptimizelyExperiment.Variant.variant1.rawValue
      ]

    let params = DiscoveryParams.defaults
      |> \.sort .~ .magic

    withEnvironment(optimizelyClient: mockOptimizelyClient) {
      self.vm.inputs.configureWith(sort: .magic)
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.viewDidAppear()
      self.scheduler.advance()

      self.hasAddedProjects.assertValues([])
      self.projectsLoadedDiscoveryParams.assertValues([])
      self.projectsLoadedVariant.assertValues([])

      self.vm.inputs.selectedFilter(.defaults)
      self.scheduler.advance()

      self.hasAddedProjects.assertValues([true], "Projects load after the filter is changed.")
      self.projectsLoadedDiscoveryParams.assertValues([params])
      self.projectsLoadedVariant.assertValues([.variant1])

      XCTAssertTrue(mockOptimizelyClient.getVariantPathCalled)
    }
  }

  func testContentInset_IsNativeProjectCardsControl() {
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.experiments .~ [
        OptimizelyExperiment.Key.nativeProjectCards.rawValue:
          OptimizelyExperiment.Variant.control.rawValue
      ]

    withEnvironment(optimizelyClient: mockOptimizelyClient) {
      self.vm.inputs.configureWith(sort: .magic)
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.viewDidAppear()
      self.scheduler.advance()

      self.contentInset.assertValues([UIEdgeInsets.zero])

      XCTAssertTrue(mockOptimizelyClient.getVariantPathCalled)
    }
  }

  func testContentInset_IsNativeProjectCardsVariant1() {
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.experiments .~ [
        OptimizelyExperiment.Key.nativeProjectCards.rawValue:
          OptimizelyExperiment.Variant.variant1.rawValue
      ]

    withEnvironment(optimizelyClient: mockOptimizelyClient) {
      self.vm.inputs.configureWith(sort: .magic)
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.viewDidAppear()
      self.scheduler.advance()

      self.contentInset.assertValues([UIEdgeInsets.init(topBottom: Styles.grid(1))])

      XCTAssertTrue(mockOptimizelyClient.getVariantPathCalled)
    }
  }

  func testGoToProject() {
    let project = Project.template
    let discoveryEnvelope = .template
      |> DiscoveryEnvelope.lens.projects .~ (
        (0...2).map { id in .template |> Project.lens.id .~ (100 + id) }
      )

    withEnvironment(
      apiService: MockService(fetchDiscoveryResponse: discoveryEnvelope)
    ) {
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

      XCTAssertEqual(["Page Viewed", "CTA Clicked"], self.segmentTrackingClient.events)

      self.vm.inputs.selectedFilter(.defaults
        |> DiscoveryParams.lens.category .~ Category.art)
      self.vm.inputs.tapped(project: project)

      self.goToPlaylist.assertValueCount(2, "New playlist for project emits.")
      self.goToPlaylistProject.assertValues([project, project])
      self.goToPlaylistRefTag.assertValues(
        [.discoveryWithSort(.magic), .categoryWithSort(.magic)],
        "Go to the project with the category sort ref tag."
      )

      XCTAssertEqual([
        "Page Viewed",
        "CTA Clicked",
        "Page Viewed",
        "CTA Clicked"
      ], self.segmentTrackingClient.events)

      self.vm.inputs.selectedFilter(.defaults |> DiscoveryParams.lens.staffPicks .~ true)
      self.vm.inputs.tapped(project: project)

      XCTAssertEqual([
        "Page Viewed",
        "CTA Clicked",
        "Page Viewed",
        "CTA Clicked",
        "Page Viewed",
        "CTA Clicked"
      ], self.segmentTrackingClient.events)

      self.goToPlaylist.assertValueCount(3, "New playlist for project emits.")
      self.goToPlaylistProject.assertValues([project, project, project])
      self.goToPlaylistRefTag.assertValues(
        [.discoveryWithSort(.magic), .categoryWithSort(.magic), .recommendedWithSort(.magic)],
        "Go to the project with the recommended sort ref tag."
      )

      self.vm.inputs.selectedFilter(.defaults |> DiscoveryParams.lens.social .~ true)
      self.vm.inputs.tapped(project: project)

      XCTAssertEqual([
        "Page Viewed",
        "CTA Clicked",
        "Page Viewed",
        "CTA Clicked",
        "Page Viewed",
        "CTA Clicked",
        "Page Viewed",
        "CTA Clicked"
      ], self.segmentTrackingClient.events)

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

      XCTAssertEqual([
        "Page Viewed",
        "CTA Clicked",
        "Page Viewed",
        "CTA Clicked",
        "Page Viewed",
        "CTA Clicked",
        "Page Viewed",
        "CTA Clicked",
        "Page Viewed",
        "CTA Clicked"
      ], self.segmentTrackingClient.events)

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

    self.vm.inputs.selectedFilter(params)

    self.showOnboarding.assertValues([true])
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

  // MARK: Personalization Section

  func testShowPersonalization_LoggedOut() {
    let mockKeyValueStore = MockKeyValueStore()
      |> \.hasCompletedCategoryPersonalizationFlow .~ true
      |> \.hasDismissedPersonalizationCard .~ false

    let mockOpClient = MockOptimizelyClient()
      |> \.experiments .~ [
        OptimizelyExperiment.Key.onboardingCategoryPersonalizationFlow.rawValue:
          OptimizelyExperiment.Variant.variant1.rawValue
      ]

    let defaultFilter = DiscoveryParams.defaults
      |> DiscoveryParams.lens.includePOTD .~ true

    withEnvironment(
      currentUser: nil,
      optimizelyClient: mockOpClient,
      userDefaults: mockKeyValueStore
    ) {
      self.vm.inputs.configureWith(sort: .magic)
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.viewDidAppear()
      self.vm.inputs.selectedFilter(defaultFilter)

      self.showPersonalization.assertValues([true])

      // Change the filter
      self.vm.inputs.selectedFilter(.defaults |> DiscoveryParams.lens.category .~ Category.art)
      self.showPersonalization.assertValues([true, true], "Section does not hide on default filters")
    }
  }

  func testShowPersonalization_LoggedIn() {
    let mockKeyValueStore = MockKeyValueStore()
      |> \.hasCompletedCategoryPersonalizationFlow .~ true
      |> \.hasDismissedPersonalizationCard .~ false

    let mockOpClient = MockOptimizelyClient()
      |> \.experiments .~ [
        OptimizelyExperiment.Key.onboardingCategoryPersonalizationFlow.rawValue:
          OptimizelyExperiment.Variant.variant1.rawValue
      ]

    let defaultFilter = DiscoveryParams.recommendedDefaults

    withEnvironment(
      currentUser: User.template,
      optimizelyClient: mockOpClient,
      userDefaults: mockKeyValueStore
    ) {
      self.vm.inputs.configureWith(sort: .magic)
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.viewDidAppear()
      self.vm.inputs.selectedFilter(defaultFilter)

      self.showPersonalization.assertValues([true])

      XCTAssertTrue(mockOpClient.getVariantPathCalled)

      // Change the filter
      self.vm.inputs.selectedFilter(.defaults |> DiscoveryParams.lens.category .~ Category.art)
      self.showPersonalization.assertValues([true, true], "Section does not hide on default filters")
    }
  }

  func testShowPersonalization_When_HasCompletedCategorySelection_IsFalse() {
    let mockKeyValueStore = MockKeyValueStore()
      |> \.hasCompletedCategoryPersonalizationFlow .~ false
      |> \.hasDismissedPersonalizationCard .~ false

    let mockOpClient = MockOptimizelyClient()
      |> \.experiments .~ [
        OptimizelyExperiment.Key.onboardingCategoryPersonalizationFlow.rawValue:
          OptimizelyExperiment.Variant.variant1.rawValue
      ]

    let defaultFilter = DiscoveryParams.recommendedDefaults

    withEnvironment(
      currentUser: User.template,
      optimizelyClient: mockOpClient,
      userDefaults: mockKeyValueStore
    ) {
      self.vm.inputs.configureWith(sort: .magic)
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.viewDidAppear()
      self.vm.inputs.selectedFilter(defaultFilter)

      self.showPersonalization.assertValues([false], "Does not show personalization section")
    }
  }

  func testShowPersonalization_When_HasDismissedPersonalizationCell_IsTrue() {
    let mockKeyValueStore = MockKeyValueStore()
      |> \.hasCompletedCategoryPersonalizationFlow .~ true
      |> \.hasDismissedPersonalizationCard .~ true

    let mockOpClient = MockOptimizelyClient()
      |> \.experiments .~ [
        OptimizelyExperiment.Key.onboardingCategoryPersonalizationFlow.rawValue:
          OptimizelyExperiment.Variant.variant1.rawValue
      ]

    let defaultFilter = DiscoveryParams.recommendedDefaults

    withEnvironment(
      currentUser: User.template,
      optimizelyClient: mockOpClient,
      userDefaults: mockKeyValueStore
    ) {
      self.vm.inputs.configureWith(sort: .magic)
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.viewDidAppear()
      self.vm.inputs.selectedFilter(defaultFilter)

      self.showPersonalization.assertValues([false], "Does not show personalization section")
    }
  }

  func testShowPersonalization_Variant2() {
    let mockKeyValueStore = MockKeyValueStore()
      |> \.hasCompletedCategoryPersonalizationFlow .~ true
      |> \.hasDismissedPersonalizationCard .~ false

    let mockOpClient = MockOptimizelyClient()
      |> \.experiments .~ [
        OptimizelyExperiment.Key.onboardingCategoryPersonalizationFlow.rawValue:
          OptimizelyExperiment.Variant.variant2.rawValue
      ]

    let defaultFilter = DiscoveryParams.recommendedDefaults

    withEnvironment(
      currentUser: User.template,
      optimizelyClient: mockOpClient,
      userDefaults: mockKeyValueStore
    ) {
      self.vm.inputs.configureWith(sort: .magic)
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.viewDidAppear()
      self.vm.inputs.selectedFilter(defaultFilter)

      self.showPersonalization.assertValues([false], "Does not show personalization section")
    }
  }

  func testShowPersonalization_Control() {
    let mockKeyValueStore = MockKeyValueStore()
      |> \.hasCompletedCategoryPersonalizationFlow .~ true
      |> \.hasDismissedPersonalizationCard .~ false

    let mockOpClient = MockOptimizelyClient()
      |> \.experiments .~ [
        OptimizelyExperiment.Key.onboardingCategoryPersonalizationFlow.rawValue:
          OptimizelyExperiment.Variant.control.rawValue
      ]

    let defaultFilter = DiscoveryParams.recommendedDefaults

    withEnvironment(
      currentUser: User.template,
      optimizelyClient: mockOpClient,
      userDefaults: mockKeyValueStore
    ) {
      self.vm.inputs.configureWith(sort: .magic)
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.viewDidAppear()
      self.vm.inputs.selectedFilter(defaultFilter)

      self.showPersonalization.assertValues([false], "Does not show personalization section")
    }
  }

  func testDismissPersonalizationCell() {
    let mockKeyValueStore = MockKeyValueStore()
      |> \.hasCompletedCategoryPersonalizationFlow .~ true
      |> \.hasDismissedPersonalizationCard .~ false

    let mockOpClient = MockOptimizelyClient()
      |> \.experiments .~ [
        OptimizelyExperiment.Key.onboardingCategoryPersonalizationFlow.rawValue:
          OptimizelyExperiment.Variant.variant1.rawValue
      ]

    let defaultFilter = DiscoveryParams.recommendedDefaults

    withEnvironment(
      currentUser: User.template,
      optimizelyClient: mockOpClient,
      userDefaults: mockKeyValueStore
    ) {
      self.vm.inputs.configureWith(sort: .magic)
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.viewDidAppear()
      self.vm.inputs.selectedFilter(defaultFilter)

      self.dismissPersonalizationCell.assertDidNotEmitValue()

      self.vm.inputs.personalizationCellDismissTapped()

      self.dismissPersonalizationCell.assertValueCount(1)

      XCTAssertTrue(mockKeyValueStore.hasDismissedPersonalizationCard)
    }
  }

  func testGoToCuratedProjects() {
    let mockKeyValueStore = MockKeyValueStore()
      |> \.hasCompletedCategoryPersonalizationFlow .~ true
      |> \.hasDismissedPersonalizationCard .~ false

    let categories = [KsApi.Category.art, KsApi.Category.illustration]
    mockKeyValueStore.onboardingCategories = try? JSONEncoder().encode(categories)

    let defaultFilter = DiscoveryParams.recommendedDefaults

    withEnvironment(
      currentUser: User.template,
      userDefaults: mockKeyValueStore
    ) {
      self.vm.inputs.configureWith(sort: .magic)
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.viewDidAppear()
      self.vm.inputs.selectedFilter(defaultFilter)

      self.goToCuratedProjects.assertDidNotEmitValue()

      XCTAssertEqual(["Page Viewed"], self.segmentTrackingClient.events)

      self.vm.inputs.personalizationCellTapped()

      XCTAssertEqual(["Page Viewed"], self.segmentTrackingClient.events)

      XCTAssertEqual(
        [nil],
        self.segmentTrackingClient.properties(forKey: "session_ref_tag")
      )
      self.goToCuratedProjects.assertValues([[.art, .illustration]])

      let segmentTrackingClientProperties = self.segmentTrackingClient.properties.last

      XCTAssertEqual("discover", segmentTrackingClientProperties?["context_page"] as? String)
    }
  }

  func testShowPersonalization_WhenOnboardingCompleted() {
    let mockKeyValueStore = MockKeyValueStore()
      |> \.hasCompletedCategoryPersonalizationFlow .~ false // Hasn't completed personalization flow yet
      |> \.hasDismissedPersonalizationCard .~ false

    let mockOpClient = MockOptimizelyClient()
      |> \.experiments .~ [
        OptimizelyExperiment.Key.onboardingCategoryPersonalizationFlow.rawValue:
          OptimizelyExperiment.Variant.variant1.rawValue
      ]

    let defaultFilter = DiscoveryParams.defaults
      |> DiscoveryParams.lens.includePOTD .~ true

    withEnvironment(
      currentUser: nil,
      optimizelyClient: mockOpClient,
      userDefaults: mockKeyValueStore
    ) {
      self.vm.inputs.configureWith(sort: .magic)
      self.vm.inputs.viewWillAppear()
      self.vm.inputs.viewDidAppear()
      self.vm.inputs.selectedFilter(defaultFilter)

      self.showPersonalization.assertValues([false])

      mockKeyValueStore.hasCompletedCategoryPersonalizationFlow = true

      self.vm.inputs.onboardingCompleted()

      self.showPersonalization.assertValues([false, true])
    }
  }

  func testDiscoverySort_Magic() {
    self.vm.inputs.configureWith(sort: .magic)
    self.vm.inputs.selectedFilter(.recommendedDefaults)
    self.vm.inputs.viewWillAppear()
    self.vm.inputs.viewDidAppear()

    let segmentClientProps = self.segmentTrackingClient.properties.last

    XCTAssertEqual("magic", segmentClientProps?["discover_sort"] as? String)
  }

  func testDiscoverySort_Popular() {
    self.vm.inputs.configureWith(sort: .popular)
    self.vm.inputs.selectedFilter(.recommendedDefaults)
    self.vm.inputs.viewWillAppear()
    self.vm.inputs.viewDidAppear()

    let segmentClientProps = self.segmentTrackingClient.properties.last

    XCTAssertEqual("popular", segmentClientProps?["discover_sort"] as? String)
  }

  func testDiscoverySort_Newest() {
    self.vm.inputs.configureWith(sort: .newest)
    self.vm.inputs.selectedFilter(.recommendedDefaults)
    self.vm.inputs.viewWillAppear()
    self.vm.inputs.viewDidAppear()

    let segmentClientProps = self.segmentTrackingClient.properties.last

    XCTAssertEqual("newest", segmentClientProps?["discover_sort"] as? String)
  }

  func testDiscoverySort_EndingSoon() {
    self.vm.inputs.configureWith(sort: .endingSoon)
    self.vm.inputs.selectedFilter(.recommendedDefaults)
    self.vm.inputs.viewWillAppear()
    self.vm.inputs.viewDidAppear()

    let segmentClientProps = self.segmentTrackingClient.properties.last

    XCTAssertEqual("ending_soon", segmentClientProps?["discover_sort"] as? String)
  }
}
