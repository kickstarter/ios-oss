import XCTest
import ReactiveSwift
import UIKit
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers
@testable import Result
@testable import KsApi
@testable import Library
import Prelude

final class ThanksViewModelTests: TestCase {
  let vm: ThanksViewModelType = ThanksViewModel()

  let backedProjectText = TestObserver<String, NoError>()
  let goToDiscovery = TestObserver<KsApi.Category, NoError>()
  let goToProject = TestObserver<Project, NoError>()
  let goToProjects = TestObserver<[Project], NoError>()
  let goToRefTag = TestObserver<RefTag, NoError>()
  let showRatingAlert = TestObserver<(), NoError>()
  let showGamesNewsletterAlert = TestObserver<(), NoError>()
  let showGamesNewsletterOptInAlert = TestObserver<String, NoError>()
  let showRecommendations = TestObserver<[Project], NoError>()
  let dismissToRootViewController = TestObserver<(), NoError>()
  let postContextualNotification = TestObserver<(), NoError>()
  let postUserUpdatedNotification = TestObserver<Notification.Name, NoError>()
  let updateUserInEnvironment = TestObserver<User, NoError>()
  let facebookButtonIsHidden = TestObserver<Bool, NoError>()
  let twitterButtonIsHidden = TestObserver<Bool, NoError>()

  override func setUp() {
    super.setUp()
    vm.outputs.backedProjectText.map { $0.string }.observe(backedProjectText.observer)
    vm.outputs.dismissToRootViewController.observe(dismissToRootViewController.observer)
    vm.outputs.goToDiscovery.map { params in params.category ?? Category.filmAndVideo }
      .observe(goToDiscovery.observer)
    vm.outputs.goToProject.map { $0.0 }.observe(goToProject.observer)
    vm.outputs.goToProject.map { $0.1 }.observe(goToProjects.observer)
    vm.outputs.goToProject.map { $0.2 }.observe(goToRefTag.observer)
    vm.outputs.postContextualNotification.observe(postContextualNotification.observer)
    vm.outputs.postUserUpdatedNotification.map { $0.name }.observe(postUserUpdatedNotification.observer)
    vm.outputs.showGamesNewsletterAlert.observe(showGamesNewsletterAlert.observer)
    vm.outputs.showGamesNewsletterOptInAlert.observe(showGamesNewsletterOptInAlert.observer)
    vm.outputs.showRatingAlert.observe(showRatingAlert.observer)
    vm.outputs.showRecommendations.map { projects, _ in projects }.observe(showRecommendations.observer)
    vm.outputs.updateUserInEnvironment.observe(updateUserInEnvironment.observer)
  }

  func testdismissToRootViewController() {
    vm.inputs.project(.template)
    vm.inputs.viewDidLoad()

    vm.inputs.closeButtonTapped()

    dismissToRootViewController.assertValueCount(1)
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
      XCTAssertEqual(["Triggered App Store Rating Dialog", "Checkout Finished Discover More"],
                     self.trackingClient.events)
    }
  }

  func testDisplayBackedProjectText() {
    let project = .template |> Project.lens.category .~ .games
    vm.inputs.project(project)
    vm.inputs.viewDidLoad()

    backedProjectText.assertValues(
      ["You have successfully backed The Project. " +
      "This project is now one step closer to a reality, thanks to you. Spread the word!"
      ], "Name of project emits")
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
      XCTAssertEqual(false, AppEnvironment.current.userDefaults.hasSeenGamesNewsletterPrompt,
                     "Newsletter pref is not set")

      vm.inputs.project(.template |> Project.lens.category .~ .games)
      vm.inputs.viewDidLoad()

      showRatingAlert.assertValueCount(0, "Rating alert does not show on games project")
      showGamesNewsletterAlert.assertValueCount(1, "Games alert shows on games project")
      XCTAssertEqual(true, AppEnvironment.current.userDefaults.hasSeenGamesNewsletterPrompt,
                     "Newsletter pref saved")

      let secondVM: ThanksViewModelType = ThanksViewModel()
      let secondShowRatingAlert = TestObserver<(), NoError>()
      secondVM.outputs.showRatingAlert.observe(secondShowRatingAlert.observer)
      let secondShowGamesNewsletterAlert = TestObserver<(), NoError>()
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

      postUserUpdatedNotification.assertValues([Notification.Name.ksr_userUpdated],
                                               "User updated notification emits")
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
      XCTAssertEqual(["Triggered App Store Rating Dialog", "Checkout Finished Discover Open Project"],
                     self.trackingClient.events)
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
