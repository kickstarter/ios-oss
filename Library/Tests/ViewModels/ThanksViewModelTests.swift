#if os(iOS)
import XCTest
import ReactiveCocoa
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
  let goToRefTag = TestObserver<RefTag, NoError>()
  let showRatingAlert = TestObserver<(), NoError>()
  let goToAppStoreRating = TestObserver<String, NoError>()
  let showGamesNewsletterAlert = TestObserver<(), NoError>()
  let showGamesNewsletterOptInAlert = TestObserver<String, NoError>()
  let showRecommendations = TestObserver<[Project], NoError>()
  let dismissViewController = TestObserver<(), NoError>()
  let postUserUpdatedNotification = TestObserver<String, NoError>()
  let updateUserInEnvironment = TestObserver<User, NoError>()
  let facebookIsAvailable = TestObserver<Bool, NoError>()
  let twitterIsAvailable = TestObserver<Bool, NoError>()

  override func setUp() {
    super.setUp()

    vm.outputs.backedProjectText.observe(backedProjectText.observer)
    vm.outputs.goToDiscovery.map { params in params.category ?? Category.filmAndVideo }
      .observe(goToDiscovery.observer)
    vm.outputs.goToProject.map { $0.0 }.observe(goToProject.observer)
    vm.outputs.goToProject.map { $0.1 }.observe(goToRefTag.observer)
    vm.outputs.showRatingAlert.observe(showRatingAlert.observer)
    vm.outputs.goToAppStoreRating.observe(goToAppStoreRating.observer)
    vm.outputs.showGamesNewsletterAlert.observe(showGamesNewsletterAlert.observer)
    vm.outputs.showGamesNewsletterOptInAlert.observe(showGamesNewsletterOptInAlert.observer)
    vm.outputs.showRecommendations.map { projects, _ in projects }.observe(showRecommendations.observer)
    vm.outputs.dismissViewController.observe(dismissViewController.observer)
    vm.outputs.postUserUpdatedNotification.map { note in note.name }
      .observe(postUserUpdatedNotification.observer)
    vm.outputs.updateUserInEnvironment.observe(updateUserInEnvironment.observer)
    vm.outputs.facebookIsAvailable.observe(facebookIsAvailable.observer)
    vm.outputs.twitterIsAvailable.observe(twitterIsAvailable.observer)
  }

  func testDismissViewController() {
    vm.inputs.project(.template)
    vm.inputs.viewDidLoad()

    vm.inputs.closeButtonPressed()

    dismissViewController.assertValueCount(1)
    XCTAssertEqual([], trackingClient.events, "No Koala tracking emitted")
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

      vm.inputs.categoryCellPressed(.illustration)

      goToDiscovery.assertValues([.illustration])
      XCTAssertEqual(["Checkout Finished Discover More"], trackingClient.events)
    }
  }

  func testDisplayBackedProjectText() {
    let project = .template |> Project.lens.category .~ .games
    vm.inputs.project(project)
    vm.inputs.viewDidLoad()

    backedProjectText.assertValues(["You just backed <b>\(project.name)</b>. " +
      "Share this project with friends to help it along!"], "Name of project emits")
  }

  func testRatingAlert_Initial() {
    withEnvironment(currentUser: .template) {
      vm.inputs.project(Project.template)

      showRatingAlert.assertValueCount(0, "Rating Alert does not emit")

      vm.inputs.viewDidLoad()

      showRatingAlert.assertValueCount(1, "Rating Alert emits when view did load")
      showGamesNewsletterAlert.assertValueCount(0, "Games alert does not emit")
    }
  }

  func testRatingAlert_ShowsOnce_AfterRateNow_NonGames_NonGames_Games() {
    withEnvironment(currentUser: .template) {
      vm.inputs.project(Project.template)
      vm.inputs.viewDidLoad()

      showRatingAlert.assertValueCount(1, "Rating alert shows on first viewing")
      showGamesNewsletterAlert.assertValueCount(0, "Games alert does not emit")

      vm.inputs.rateNowButtonPressed()

      let secondVM: ThanksViewModelType = ThanksViewModel()
      let secondShowRatingAlert = TestObserver<(), NoError>()
      secondVM.outputs.showRatingAlert.observe(secondShowRatingAlert.observer)
      let secondShowGamesNewsletterAlert = TestObserver<(), NoError>()
      secondVM.outputs.showGamesNewsletterAlert.observe(secondShowGamesNewsletterAlert.observer)

      secondVM.inputs.project(Project.template)
      secondVM.inputs.viewDidLoad()

      secondShowRatingAlert.assertValueCount(0, "Rating alert does not show again after rating happened")
      secondShowGamesNewsletterAlert.assertValueCount(0, "Games alert does not show on non-games project")

      let thirdVM: ThanksViewModelType = ThanksViewModel()
      let thirdShowRatingAlert = TestObserver<(), NoError>()
      thirdVM.outputs.showRatingAlert.observe(thirdShowRatingAlert.observer)
      let thirdShowGamesNewsletterAlert = TestObserver<(), NoError>()
      thirdVM.outputs.showGamesNewsletterAlert.observe(thirdShowGamesNewsletterAlert.observer)

      thirdVM.inputs.project(.template |> Project.lens.category .~ .games)
      thirdVM.inputs.viewDidLoad()

      thirdShowRatingAlert.assertValueCount(0, "Rating alert does not show again")
      thirdShowGamesNewsletterAlert.assertValueCount(1, "Games alert shows on games project")
    }
  }

  func testRatingAlert_ShowsOnce_AfterNoThanks_NonGames_NonGames_Games() {
    withEnvironment(currentUser: .template) {
      vm.inputs.project(.template)
      vm.inputs.viewDidLoad()

      showRatingAlert.assertValueCount(1, "Rating alert shows on first viewing")
      showGamesNewsletterAlert.assertValueCount(0, "Games alert does not emit")

      vm.inputs.rateNoThanksButtonPressed()

      let secondVM: ThanksViewModelType = ThanksViewModel()
      let secondShowRatingAlert = TestObserver<(), NoError>()
      secondVM.outputs.showRatingAlert.observe(secondShowRatingAlert.observer)
      let secondShowGamesNewsletterAlert = TestObserver<(), NoError>()
      secondVM.outputs.showGamesNewsletterAlert.observe(secondShowGamesNewsletterAlert.observer)

      secondVM.inputs.project(.template)
      secondVM.inputs.viewDidLoad()

      secondShowRatingAlert.assertValueCount(0, "Rating alert does not show again after dismiss happened")
      secondShowGamesNewsletterAlert.assertValueCount(0, "Games alert does not show on non-games project")

      let thirdVM: ThanksViewModelType = ThanksViewModel()
      let thirdShowRatingAlert = TestObserver<(), NoError>()
      thirdVM.outputs.showRatingAlert.observe(thirdShowRatingAlert.observer)
      let thirdShowGamesNewsletterAlert = TestObserver<(), NoError>()
      thirdVM.outputs.showGamesNewsletterAlert.observe(thirdShowGamesNewsletterAlert.observer)

      thirdVM.inputs.project(.template |> Project.lens.category .~ .games)
      thirdVM.inputs.viewDidLoad()

      thirdShowRatingAlert.assertValueCount(0, "Rating alert does not show again")
      thirdShowGamesNewsletterAlert.assertValueCount(1, "Games alert shows on games project")
    }
  }

  func testRatingAlert_ShowsAgain_AfterRemindLater_NonGames_NonGames() {
    withEnvironment(currentUser: .template) {
      vm.inputs.project(.template)
      vm.inputs.viewDidLoad()

      showRatingAlert.assertValueCount(1, "Rating alert shows on first viewing")
      showGamesNewsletterAlert.assertValueCount(0, "Games alert does not emit")

      vm.inputs.rateRemindLaterButtonPressed()

      let secondVM: ThanksViewModelType = ThanksViewModel()
      let secondShowRatingAlert = TestObserver<(), NoError>()
      secondVM.outputs.showRatingAlert.observe(secondShowRatingAlert.observer)
      let secondShowGamesNewsletterAlert = TestObserver<(), NoError>()
      secondVM.outputs.showGamesNewsletterAlert.observe(secondShowGamesNewsletterAlert.observer)

      secondVM.inputs.project(.template)
      secondVM.inputs.viewDidLoad()

      secondShowRatingAlert.assertValueCount(1, "Rating alert shows again after reminder happened")
      secondShowGamesNewsletterAlert.assertValueCount(0, "Games alert does not show on non-games project")
    }
  }

  func testRatingCompleted_WithRateNow() {
    withEnvironment(currentUser: .template) {
      vm.inputs.project(.template)
      vm.inputs.viewDidLoad()

      showRatingAlert.assertValueCount(1, "Rating alert shows on first viewing")

      vm.inputs.rateNowButtonPressed()

      XCTAssertEqual(true, AppEnvironment.current.userDefaults.hasSeenAppRating, "Rating pref saved")
      XCTAssertEqual(["Checkout Finished Alert App Store Rating Rate Now"], trackingClient.events)
      goToAppStoreRating.assertValueCount(1, "Proceed to app store")
    }
  }

  func testRatingCompleted_WithRemindLater() {
    withEnvironment(currentUser: .template) {
      vm.inputs.project(.template)
      vm.inputs.viewDidLoad()

      showRatingAlert.assertValueCount(1, "Rating alert shows on first viewing")

      vm.inputs.rateRemindLaterButtonPressed()

      XCTAssertEqual(false, AppEnvironment.current.userDefaults.hasSeenAppRating, "Rating pref saved")
      XCTAssertEqual(["Checkout Finished Alert App Store Rating Remind Later"], trackingClient.events)
    }
  }

  func testRatingCompleted_WithNoThanks() {
    withEnvironment(currentUser: .template) {
      vm.inputs.project(.template)
      vm.inputs.viewDidLoad()

      showRatingAlert.assertValueCount(1, "Rating alert shows on first viewing")

      vm.inputs.rateNoThanksButtonPressed()

      XCTAssertEqual(true, AppEnvironment.current.userDefaults.hasSeenAppRating, "Rating pref saved")
      XCTAssertEqual(["Checkout Finished Alert App Store Rating No Thanks"], trackingClient.events)
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
    let user = .template |> User.lens.newsletters .~ newsletters

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

      vm.inputs.gamesNewsletterSignupButtonPressed()

      scheduler.advance()

      updateUserInEnvironment.assertValueCount(1)
      showGamesNewsletterOptInAlert.assertValueCount(0, "Opt-in alert does not emit")
      XCTAssertEqual(["Newsletter Subscribe"], trackingClient.events)

      vm.inputs.userUpdated()

      postUserUpdatedNotification.assertValues([CurrentUserNotifications.userUpdated],
                                               "User updated notification emits")
    }
  }

  func testGamesNewsletterOptInAlert() {
    withEnvironment(countryCode: "DE", currentUser: User.template) {
      vm.inputs.project(.template |> Project.lens.category .~ .games)
      vm.inputs.viewDidLoad()

      showGamesNewsletterAlert.assertValueCount(1)

      vm.inputs.gamesNewsletterSignupButtonPressed()

      showGamesNewsletterOptInAlert.assertValues(["Kickstarter Loves Games"], "Opt-in alert emits with title")
      XCTAssertEqual(["Newsletter Subscribe"], trackingClient.events)
    }
  }

  func testAlerts_ShowOnce_AfterRateNow_Games_NonGames_NonGames() {
    let project = .template
      |> Project.lens.category .~ .tabletopGames
      <> Project.lens.category.parent .~ nil

    withEnvironment(currentUser: .template) {
      vm.inputs.project(project)
      vm.inputs.viewDidLoad()

      showRatingAlert.assertValueCount(0, "Rating alert does not show on games project")
      showGamesNewsletterAlert.assertValueCount(1, "Games alert shows on games project")

      let secondVM: ThanksViewModelType = ThanksViewModel()
      let secondShowRatingAlert = TestObserver<(), NoError>()
      secondVM.outputs.showRatingAlert.observe(secondShowRatingAlert.observer)
      let secondShowGamesNewsletterAlert = TestObserver<(), NoError>()
      secondVM.outputs.showGamesNewsletterAlert.observe(secondShowGamesNewsletterAlert.observer)

      secondVM.inputs.project(.template)
      secondVM.inputs.viewDidLoad()

      secondShowRatingAlert.assertValueCount(1, "Rating alert shows on non-games project")
      secondShowGamesNewsletterAlert.assertValueCount(0, "Games alert does not show on non-games project")

      vm.inputs.rateNowButtonPressed()

      let thirdVM: ThanksViewModelType = ThanksViewModel()
      let thirdShowRatingAlert = TestObserver<(), NoError>()
      thirdVM.outputs.showRatingAlert.observe(thirdShowRatingAlert.observer)
      let thirdShowGamesNewsletterAlert = TestObserver<(), NoError>()
      thirdVM.outputs.showGamesNewsletterAlert.observe(thirdShowGamesNewsletterAlert.observer)

      thirdVM.inputs.project(.template)
      thirdVM.inputs.viewDidLoad()

      thirdShowRatingAlert.assertValueCount(0, "Rating alert does not show on non-games project after rating")
      thirdShowGamesNewsletterAlert.assertValueCount(0, "Games alert does not show on non-games project")
    }
  }

  func testAlerts_ShowOnce_AfterNoThanks_Games_NonGames_NonGames() {
    withEnvironment(currentUser: .template) {
      vm.inputs.project(.template |> Project.lens.category .~ .games)
      vm.inputs.viewDidLoad()

      showRatingAlert.assertValueCount(0, "Rating alert does not show on games project")
      showGamesNewsletterAlert.assertValueCount(1, "Games alert shows on games project")

      let secondVM: ThanksViewModelType = ThanksViewModel()
      let secondShowRatingAlert = TestObserver<(), NoError>()
      secondVM.outputs.showRatingAlert.observe(secondShowRatingAlert.observer)
      let secondShowGamesNewsletterAlert = TestObserver<(), NoError>()
      secondVM.outputs.showGamesNewsletterAlert.observe(secondShowGamesNewsletterAlert.observer)

      secondVM.inputs.project(.template)
      secondVM.inputs.viewDidLoad()

      secondShowRatingAlert.assertValueCount(1, "Rating alert shows on non-games project")
      secondShowGamesNewsletterAlert.assertValueCount(0, "Games alert does not show on non-games project")

      vm.inputs.rateNoThanksButtonPressed()

      let thirdVM: ThanksViewModelType = ThanksViewModel()
      let thirdShowRatingAlert = TestObserver<(), NoError>()
      thirdVM.outputs.showRatingAlert.observe(thirdShowRatingAlert.observer)
      let thirdShowGamesNewsletterAlert = TestObserver<(), NoError>()
      thirdVM.outputs.showGamesNewsletterAlert.observe(thirdShowGamesNewsletterAlert.observer)

      thirdVM.inputs.project(.template)
      thirdVM.inputs.viewDidLoad()

      thirdShowRatingAlert.assertValueCount(0,
                                            "Rating alert does not show on non-games project after No Thanks")
      thirdShowGamesNewsletterAlert.assertValueCount(0, "Games alert does not show on non-games project")
    }
  }

  func testAlerts_ShowGamesOnce_ShowRatingAgain_AfterRemindLater_Games_NonGames_NonGames() {
    withEnvironment(currentUser: .template) {
      vm.inputs.project(.template |> Project.lens.category .~ .games)
      vm.inputs.viewDidLoad()

      showRatingAlert.assertValueCount(0, "Rating alert does not show on games project")
      showGamesNewsletterAlert.assertValueCount(1, "Games alert shows on games project")

      let secondVM: ThanksViewModelType = ThanksViewModel()
      let secondShowRatingAlert = TestObserver<(), NoError>()
      secondVM.outputs.showRatingAlert.observe(secondShowRatingAlert.observer)
      let secondShowGamesNewsletterAlert = TestObserver<(), NoError>()
      secondVM.outputs.showGamesNewsletterAlert.observe(secondShowGamesNewsletterAlert.observer)

      secondVM.inputs.project(.template)
      secondVM.inputs.viewDidLoad()

      secondShowRatingAlert.assertValueCount(1, "Rating alert shows on non-games project")
      secondShowGamesNewsletterAlert.assertValueCount(0, "Games alert does not show on non-games project")

      vm.inputs.rateRemindLaterButtonPressed()

      let thirdVM: ThanksViewModelType = ThanksViewModel()
      let thirdShowRatingAlert = TestObserver<(), NoError>()
      thirdVM.outputs.showRatingAlert.observe(thirdShowRatingAlert.observer)
      let thirdShowGamesNewsletterAlert = TestObserver<(), NoError>()
      thirdVM.outputs.showGamesNewsletterAlert.observe(thirdShowGamesNewsletterAlert.observer)

      thirdVM.inputs.project(.template)
      thirdVM.inputs.viewDidLoad()

      thirdShowRatingAlert.assertValueCount(1, "Rating alert shows on non-games project after reminder")
      thirdShowGamesNewsletterAlert.assertValueCount(0, "Games alert does not show on non-games project")
    }
  }

  func testAlerts_ShowOnce_AfterRateNow_NonGames_Games_NonGames() {
    withEnvironment(currentUser: .template) {
      vm.inputs.project(.template)
      vm.inputs.viewDidLoad()

      showRatingAlert.assertValueCount(1, "Rating alert shows on non-games project")
      showGamesNewsletterAlert.assertValueCount(0, "Games alert does not show on non-games project")

      vm.inputs.rateNowButtonPressed()

      let secondVM: ThanksViewModelType = ThanksViewModel()
      let secondShowRatingAlert = TestObserver<(), NoError>()
      secondVM.outputs.showRatingAlert.observe(secondShowRatingAlert.observer)
      let secondShowGamesNewsletterAlert = TestObserver<(), NoError>()
      secondVM.outputs.showGamesNewsletterAlert.observe(secondShowGamesNewsletterAlert.observer)

      secondVM.inputs.project(Project.template |> Project.lens.category .~ Category.games)
      secondVM.inputs.viewDidLoad()

      secondShowRatingAlert.assertValueCount(0, "Rating alert does not show on games project")
      secondShowGamesNewsletterAlert.assertValueCount(1, "Games alert shows on games project")

      let thirdVM: ThanksViewModelType = ThanksViewModel()
      let thirdShowRatingAlert = TestObserver<(), NoError>()
      thirdVM.outputs.showRatingAlert.observe(thirdShowRatingAlert.observer)
      let thirdShowGamesNewsletterAlert = TestObserver<(), NoError>()
      thirdVM.outputs.showGamesNewsletterAlert.observe(thirdShowGamesNewsletterAlert.observer)

      thirdVM.inputs.project(.template)
      thirdVM.inputs.viewDidLoad()

      thirdShowRatingAlert.assertValueCount(0, "Rating alert does not show on non-games project after rating")
      thirdShowGamesNewsletterAlert.assertValueCount(0, "Games alert does not show on non-games project")
    }
  }

  func testAlerts_ShowOnce_AfterNoThanks_NonGames_Games_NonGames() {
    withEnvironment(currentUser: .template) {
      vm.inputs.project(.template)
      vm.inputs.viewDidLoad()

      showRatingAlert.assertValueCount(1, "Rating alert shows on non-games project")
      showGamesNewsletterAlert.assertValueCount(0, "Games alert does not show on non-games project")

      vm.inputs.rateNoThanksButtonPressed()

      let secondVM: ThanksViewModelType = ThanksViewModel()
      let secondShowRatingAlert = TestObserver<(), NoError>()
      secondVM.outputs.showRatingAlert.observe(secondShowRatingAlert.observer)
      let secondShowGamesNewsletterAlert = TestObserver<(), NoError>()
      secondVM.outputs.showGamesNewsletterAlert.observe(secondShowGamesNewsletterAlert.observer)

      secondVM.inputs.project(.template |> Project.lens.category .~ .games)
      secondVM.inputs.viewDidLoad()

      secondShowRatingAlert.assertValueCount(0, "Rating alert does not show on games project")
      secondShowGamesNewsletterAlert.assertValueCount(1, "Games alert shows on games project")

      let thirdVM: ThanksViewModelType = ThanksViewModel()
      let thirdShowRatingAlert = TestObserver<(), NoError>()
      thirdVM.outputs.showRatingAlert.observe(thirdShowRatingAlert.observer)
      let thirdShowGamesNewsletterAlert = TestObserver<(), NoError>()
      thirdVM.outputs.showGamesNewsletterAlert.observe(thirdShowGamesNewsletterAlert.observer)

      thirdVM.inputs.project(.template)
      thirdVM.inputs.viewDidLoad()

      thirdShowRatingAlert.assertValueCount(0,
                                            "Rating alert does not show on non-games project after No Thanks")
      thirdShowGamesNewsletterAlert.assertValueCount(0, "Games alert does not show on non-games project")
    }
  }

  func testAlerts_ShowGamesOnce_ShowRatingAgain_AfterRemindLater_NonGames_Games_NonGames() {
    withEnvironment(currentUser: .template) {
      vm.inputs.project(.template)
      vm.inputs.viewDidLoad()

      showRatingAlert.assertValueCount(1, "Rating alert shows on non-games project")
      showGamesNewsletterAlert.assertValueCount(0, "Games alert does not show on non-games project")

      vm.inputs.rateRemindLaterButtonPressed()

      let secondVM: ThanksViewModelType = ThanksViewModel()
      let secondShowRatingAlert = TestObserver<(), NoError>()
      secondVM.outputs.showRatingAlert.observe(secondShowRatingAlert.observer)
      let secondShowGamesNewsletterAlert = TestObserver<(), NoError>()
      secondVM.outputs.showGamesNewsletterAlert.observe(secondShowGamesNewsletterAlert.observer)

      secondVM.inputs.project(.template |> Project.lens.category .~ .games)
      secondVM.inputs.viewDidLoad()

      secondShowRatingAlert.assertValueCount(0, "Rating alert does not show on games project")
      secondShowGamesNewsletterAlert.assertValueCount(1, "Games alert shows on games project")

      let thirdVM: ThanksViewModelType = ThanksViewModel()
      let thirdShowRatingAlert = TestObserver<(), NoError>()
      thirdVM.outputs.showRatingAlert.observe(thirdShowRatingAlert.observer)
      let thirdShowGamesNewsletterAlert = TestObserver<(), NoError>()
      thirdVM.outputs.showGamesNewsletterAlert.observe(thirdShowGamesNewsletterAlert.observer)

      thirdVM.inputs.project(.template)
      thirdVM.inputs.viewDidLoad()

      thirdShowRatingAlert.assertValueCount(1, "Rating alert shows on non-games project after Remind Later")
      thirdShowGamesNewsletterAlert.assertValueCount(0, "Games alert does not show on non-games project")
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

      vm.inputs.projectPressed(project)

      goToProject.assertValues([project])
      goToRefTag.assertValues([.thanks])
      XCTAssertEqual(["Checkout Finished Discover Open Project"], trackingClient.events)
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

      showRecommendations.assertValues([
        [
          .template |> Project.lens.id .~ 1,
          .template |> Project.lens.id .~ 2,
          .template |> Project.lens.id .~ 5
        ]
      ], "Three non-repeating projects emit")
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

  func testFacebookIsAvailable() {
    facebookIsAvailable.assertValueCount(0, "Facebook did not emit")

    vm.inputs.project(.template)
    vm.inputs.viewDidLoad()

    facebookIsAvailable.assertValues([false], "Facebook is unavailable")
  }

  func testTwitterIsAvailable() {
    twitterIsAvailable.assertValueCount(0, "Twitter did not emit")

    vm.inputs.project(.template)
    vm.inputs.viewDidLoad()

    twitterIsAvailable.assertValues([false], "Facebook is unavailable")
  }
}
#endif
