@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import UIKit
import XCTest

final class ThanksViewModelTests: TestCase {
  let vm: ThanksViewModelType = ThanksViewModel()

  let backedProjectText = TestObserver<String, Never>()
  let goToDiscovery = TestObserver<KsApi.Category, Never>()
  let goToProject = TestObserver<Project, Never>()
  let goToProjects = TestObserver<[Project], Never>()
  let goToRefTag = TestObserver<RefTag, Never>()
  let showRatingAlert = TestObserver<(), Never>()
  let showGamesNewsletterAlert = TestObserver<(), Never>()
  let showGamesNewsletterOptInAlert = TestObserver<String, Never>()
  let showRecommendations = TestObserver<[Project], Never>()
  let dismissToRootViewController = TestObserver<(), Never>()
  let postContextualNotification = TestObserver<(), Never>()
  let postUserUpdatedNotification = TestObserver<Notification.Name, Never>()
  let updateUserInEnvironment = TestObserver<User, Never>()
  let facebookButtonIsHidden = TestObserver<Bool, Never>()
  let twitterButtonIsHidden = TestObserver<Bool, Never>()

  override func setUp() {
    super.setUp()
    self.vm.outputs.backedProjectText.map { $0.string }.observe(self.backedProjectText.observer)
    self.vm.outputs.dismissToRootViewController.observe(self.dismissToRootViewController.observer)
    self.vm.outputs.goToDiscovery.map { params in params.category ?? Category.filmAndVideo }
      .observe(self.goToDiscovery.observer)
    self.vm.outputs.goToProject.map { $0.0 }.observe(self.goToProject.observer)
    self.vm.outputs.goToProject.map { $0.1 }.observe(self.goToProjects.observer)
    self.vm.outputs.goToProject.map { $0.2 }.observe(self.goToRefTag.observer)
    self.vm.outputs.postContextualNotification.observe(self.postContextualNotification.observer)
    self.vm.outputs.postUserUpdatedNotification.map { $0.name }
      .observe(self.postUserUpdatedNotification.observer)
    self.vm.outputs.showGamesNewsletterAlert.observe(self.showGamesNewsletterAlert.observer)
    self.vm.outputs.showGamesNewsletterOptInAlert.observe(self.showGamesNewsletterOptInAlert.observer)
    self.vm.outputs.showRatingAlert.observe(self.showRatingAlert.observer)
    self.vm.outputs.showRecommendations.map { projects, _ in projects }
      .observe(self.showRecommendations.observer)
    self.vm.outputs.updateUserInEnvironment.observe(self.updateUserInEnvironment.observer)
  }

  func testdismissToRootViewController() {
    self.vm.inputs.project(.template)
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.closeButtonTapped()

    self.dismissToRootViewController.assertValueCount(1)
  }

  func testGoToDiscovery() {
    let projects = [
      .template |> Project.lens.id .~ 1,
      .template |> Project.lens.id .~ 2,
      .template |> Project.lens.id .~ 3
    ]

    let project = Project.template
    let response = .template |> DiscoveryEnvelope.lens.projects .~ projects

    withEnvironment(apiService: MockService(fetchDiscoveryResponse: response)) {
      vm.inputs.project(project)
      vm.inputs.viewDidLoad()

      scheduler.advance()

      showRecommendations.assertValueCount(1)

      vm.inputs.categoryCellTapped(.illustration)

      goToDiscovery.assertValues([.illustration])
      XCTAssertEqual(
        ["Triggered App Store Rating Dialog", "Checkout Finished Discover More"],
        self.trackingClient.events
      )
    }
  }

  func testDisplayBackedProjectText() {
    let project = .template |> Project.lens.category .~ .games
    self.vm.inputs.project(project)
    self.vm.inputs.viewDidLoad()

    self.backedProjectText.assertValues(
      [
        "You have successfully backed The Project. " +
          "This project is now one step closer to a reality, thanks to you. Spread the word!"
      ], "Name of project emits"
    )
  }

  func testRatingAlert_Initial() {
    withEnvironment(currentUser: .template) {
      vm.inputs.project(Project.template)

      showRatingAlert.assertValueCount(0, "Rating Alert does not emit")

      vm.inputs.viewDidLoad()

      showRatingAlert.assertValueCount(1, "Rating Alert emits when view did load")
      showGamesNewsletterAlert.assertValueCount(0, "Games alert does not emit")
      XCTAssertEqual(["Triggered App Store Rating Dialog"], self.trackingClient.events)
    }
  }

  func testGamesAlert_ShowsOnce() {
    withEnvironment(currentUser: .template) {
      XCTAssertEqual(
        false, AppEnvironment.current.userDefaults.hasSeenGamesNewsletterPrompt,
        "Newsletter pref is not set"
      )

      vm.inputs.project(.template |> Project.lens.category .~ .games)
      vm.inputs.viewDidLoad()

      showRatingAlert.assertValueCount(0, "Rating alert does not show on games project")
      showGamesNewsletterAlert.assertValueCount(1, "Games alert shows on games project")
      XCTAssertEqual(
        true, AppEnvironment.current.userDefaults.hasSeenGamesNewsletterPrompt,
        "Newsletter pref saved"
      )

      let secondVM: ThanksViewModelType = ThanksViewModel()
      let secondShowRatingAlert = TestObserver<(), Never>()
      secondVM.outputs.showRatingAlert.observe(secondShowRatingAlert.observer)
      let secondShowGamesNewsletterAlert = TestObserver<(), Never>()
      secondVM.outputs.showGamesNewsletterAlert.observe(secondShowGamesNewsletterAlert.observer)

      secondVM.inputs.project(.template |> Project.lens.category .~ .games)
      secondVM.inputs.viewDidLoad()

      secondShowRatingAlert.assertValueCount(1, "Rating alert shows on games project")
      secondShowGamesNewsletterAlert.assertValueCount(0, "Games alert does not show again on games project")
    }
  }

  func testGamesNewsletterAlert_ShouldNotShow_WhenUserIsSubscribed() {
    let newsletters = User.NewsletterSubscriptions.template |> User.NewsletterSubscriptions.lens.games .~ true
    let user = User.template |> \.newsletters .~ newsletters

    withEnvironment(currentUser: user) {
      vm.inputs.project(.template |> Project.lens.category .~ .games)
      vm.inputs.viewDidLoad()

      showGamesNewsletterAlert.assertValueCount(0, "Games alert does not show on games project")
    }
  }

  func testGamesNewsletterSignup() {
    withEnvironment(currentUser: .template) {
      vm.inputs.project(.template |> Project.lens.category .~ .games)
      vm.inputs.viewDidLoad()

      showGamesNewsletterAlert.assertValueCount(1)

      vm.inputs.gamesNewsletterSignupButtonTapped()

      scheduler.advance()

      updateUserInEnvironment.assertValueCount(1)
      showGamesNewsletterOptInAlert.assertValueCount(0, "Opt-in alert does not emit")
      XCTAssertEqual(["Subscribed To Newsletter", "Newsletter Subscribe"], trackingClient.events)

      vm.inputs.userUpdated()

      postUserUpdatedNotification.assertValues(
        [Notification.Name.ksr_userUpdated],
        "User updated notification emits"
      )
    }
  }

  func testContextualNotificationEmitsWhen_userPledgedFirstProject() {
    let user = User.template |> \.stats.backedProjectsCount .~ 0

    withEnvironment(currentUser: user) {
      vm.inputs.viewDidLoad()
      postContextualNotification.assertDidEmitValue()
    }
  }

  func testContextualNotificationDoesNotEmitWhen_userPledgedMoreThanOneProject() {
    let user = User.template |> \.stats.backedProjectsCount .~ 2

    withEnvironment(currentUser: user) {
      vm.inputs.viewDidLoad()
      postContextualNotification.assertDidNotEmitValue()
    }
  }

  func testGamesNewsletterOptInAlert() {
    withEnvironment(countryCode: "DE", currentUser: User.template) {
      vm.inputs.project(.template |> Project.lens.category .~ .games)
      vm.inputs.viewDidLoad()

      showGamesNewsletterAlert.assertValueCount(1)

      vm.inputs.gamesNewsletterSignupButtonTapped()

      showGamesNewsletterOptInAlert.assertValues(["Kickstarter Loves Games"], "Opt-in alert emits with title")
      XCTAssertEqual(["Subscribed To Newsletter", "Newsletter Subscribe"], trackingClient.events)
    }
  }

  func testGoToProject() {
    let projects = [
      .template |> Project.lens.id .~ 1,
      .template |> Project.lens.id .~ 2,
      .template |> Project.lens.id .~ 3
    ]

    let project = Project.template
    let response = .template |> DiscoveryEnvelope.lens.projects .~ projects

    withEnvironment(apiService: MockService(fetchDiscoveryResponse: response)) {
      vm.inputs.project(project)
      vm.inputs.viewDidLoad()

      scheduler.advance()

      showRecommendations.assertValueCount(1)

      vm.inputs.projectTapped(project)

      goToProject.assertValues([project])
      goToProjects.assertValueCount(1)
      goToRefTag.assertValues([.thanks])
      XCTAssertEqual(
        ["Triggered App Store Rating Dialog", "Checkout Finished Discover Open Project"],
        self.trackingClient.events
      )
    }
  }

  func testRecommendationsWithProjects() {
    let projects = [
      .template |> Project.lens.id .~ 1,
      .template |> Project.lens.id .~ 2,
      .template |> Project.lens.id .~ 1,
      .template |> Project.lens.id .~ 2,
      .template |> Project.lens.id .~ 5,
      .template |> Project.lens.id .~ 8
    ]

    let response = .template |> DiscoveryEnvelope.lens.projects .~ projects

    withEnvironment(apiService: MockService(fetchDiscoveryResponse: response)) {
      vm.inputs.project(.template |> Project.lens.id .~ 12)
      vm.inputs.viewDidLoad()

      scheduler.advance()

      showRecommendations.assertValueCount(1, "Recommended projects emit, shuffled.")
    }
  }

  func testRecommendationsWithoutProjects() {
    let response = .template |> DiscoveryEnvelope.lens.projects .~ []

    withEnvironment(apiService: MockService(fetchDiscoveryResponse: response)) {
      vm.inputs.project(.template |> Project.lens.category .~ .games)
      vm.inputs.viewDidLoad()

      scheduler.advance()

      showRecommendations.assertValueCount(0, "Recommended projects did not emit")
    }
  }
}
