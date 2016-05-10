import XCTest
import ReactiveCocoa
import UIKit.UIActivity
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers
@testable import Result
@testable import Models
@testable import Models_TestHelpers
@testable import KsApi
@testable import KsApi_TestHelpers
@testable import Kickstarter_iOS
@testable import Library

final class ThanksViewModelTests: TestCase {
  let vm: ThanksViewModelType = ThanksViewModel()
  let projectName = TestObserver<String, NoError>()
  let goToDiscovery = TestObserver<Models.Category, NoError>()
  let goToProject = TestObserver<Project, NoError>()
  let showShareSheet = TestObserver<Project, NoError>()
  let showFacebookShare = TestObserver<Project, NoError>()
  let showTwitterShare = TestObserver<Project, NoError>()
  let showRatingAlert = TestObserver<(), NoError>()
  let goToAppStoreRating = TestObserver<String, NoError>()
  let showGamesNewsletterAlert = TestObserver<(), NoError>()
  let showGamesNewsletterOptInAlert = TestObserver<String, NoError>()
  let showRecommendations = TestObserver<Models.Category, NoError>()
  let dismissViewController = TestObserver<(), NoError>()
  let postUserUpdatedNotification = TestObserver<String, NoError>()
  let updateUserInEnvironment = TestObserver<User, NoError>()

  override func setUp() {
    super.setUp()

    vm.outputs.projectName.observe(projectName.observer)
    vm.outputs.goToDiscovery.map { params in params.category ?? CategoryFactory.filmAndVideo }
      .observe(goToDiscovery.observer)
    vm.outputs.goToProject.observe(goToProject.observer)
    vm.outputs.showShareSheet.observe(showShareSheet.observer)
    vm.outputs.showFacebookShare.observe(showFacebookShare.observer)
    vm.outputs.showTwitterShare.observe(showTwitterShare.observer)
    vm.outputs.showRatingAlert.observe(showRatingAlert.observer)
    vm.outputs.goToAppStoreRating.observe(goToAppStoreRating.observer)
    vm.outputs.showGamesNewsletterAlert.observe(showGamesNewsletterAlert.observer)
    vm.outputs.showGamesNewsletterOptInAlert.observe(showGamesNewsletterOptInAlert.observer)
    vm.outputs.showRecommendations.map { _, category in category }.observe(showRecommendations.observer)
    vm.outputs.dismissViewController.observe(dismissViewController.observer)
    vm.outputs.postUserUpdatedNotification.map { note in note.name }
      .observe(postUserUpdatedNotification.observer)
    vm.outputs.updateUserInEnvironment.observe(updateUserInEnvironment.observer)
  }

  func testDismissViewController() {
    vm.inputs.project(ProjectFactory.live())
    vm.inputs.viewDidLoad()

    vm.inputs.closeButtonPressed()

    dismissViewController.assertValueCount(1)
    XCTAssertEqual([], trackingClient.events, "No Koala tracking emitted")
  }

  func testGoToDiscovery() {
    vm.inputs.viewDidLoad()
    vm.inputs.categoryCellPressed(CategoryFactory.illustration)

    goToDiscovery.assertValues([CategoryFactory.illustration])
    XCTAssertEqual(["Checkout Finished Discover More"], trackingClient.events)
  }

  func testDisplayProjectName() {
    vm.inputs.project(ProjectFactory.game)
    vm.inputs.viewDidLoad()

    projectName.assertValues(["Exploding Kittens"], "Name of project emits")
  }

  func testRatingAlert_Initial() {
    withEnvironment(currentUser: UserFactory.userWithNewsletters()) {
      vm.inputs.project(ProjectFactory.live())

      showRatingAlert.assertValueCount(0, "Rating Alert does not emit")

      vm.inputs.viewDidLoad()

      showRatingAlert.assertValueCount(1, "Rating Alert emits when view did load")
      showGamesNewsletterAlert.assertValueCount(0, "Games alert does not emit")
    }
  }

  func testRatingAlert_ShowsOnce_AfterRateNow_NonGames_NonGames_Games() {
    withEnvironment(currentUser: UserFactory.userWithNewsletters()) {
      vm.inputs.project(ProjectFactory.live())
      vm.inputs.viewDidLoad()

      showRatingAlert.assertValueCount(1, "Rating alert shows on first viewing")
      showGamesNewsletterAlert.assertValueCount(0, "Games alert does not emit")

      vm.inputs.rateNowButtonPressed()

      let secondVM: ThanksViewModelType = ThanksViewModel()
      let secondShowRatingAlert = TestObserver<(), NoError>()
      secondVM.outputs.showRatingAlert.observe(secondShowRatingAlert.observer)
      let secondShowGamesNewsletterAlert = TestObserver<(), NoError>()
      secondVM.outputs.showGamesNewsletterAlert.observe(secondShowGamesNewsletterAlert.observer)

      secondVM.inputs.project(ProjectFactory.live())
      secondVM.inputs.viewDidLoad()

      secondShowRatingAlert.assertValueCount(0, "Rating alert does not show again after rating happened")
      secondShowGamesNewsletterAlert.assertValueCount(0, "Games alert does not show on non-games project")

      let thirdVM: ThanksViewModelType = ThanksViewModel()
      let thirdShowRatingAlert = TestObserver<(), NoError>()
      thirdVM.outputs.showRatingAlert.observe(thirdShowRatingAlert.observer)
      let thirdShowGamesNewsletterAlert = TestObserver<(), NoError>()
      thirdVM.outputs.showGamesNewsletterAlert.observe(thirdShowGamesNewsletterAlert.observer)

      thirdVM.inputs.project(ProjectFactory.game)
      thirdVM.inputs.viewDidLoad()

      thirdShowRatingAlert.assertValueCount(0, "Rating alert does not show again")
      thirdShowGamesNewsletterAlert.assertValueCount(1, "Games alert shows on games project")
    }
  }

  func testRatingAlert_ShowsOnce_AfterNoThanks_NonGames_NonGames_Games() {
    withEnvironment(currentUser: UserFactory.userWithNewsletters()) {
      vm.inputs.project(ProjectFactory.live())
      vm.inputs.viewDidLoad()

      showRatingAlert.assertValueCount(1, "Rating alert shows on first viewing")
      showGamesNewsletterAlert.assertValueCount(0, "Games alert does not emit")

      vm.inputs.rateNoThanksButtonPressed()

      let secondVM: ThanksViewModelType = ThanksViewModel()
      let secondShowRatingAlert = TestObserver<(), NoError>()
      secondVM.outputs.showRatingAlert.observe(secondShowRatingAlert.observer)
      let secondShowGamesNewsletterAlert = TestObserver<(), NoError>()
      secondVM.outputs.showGamesNewsletterAlert.observe(secondShowGamesNewsletterAlert.observer)

      secondVM.inputs.project(ProjectFactory.live())
      secondVM.inputs.viewDidLoad()

      secondShowRatingAlert.assertValueCount(0, "Rating alert does not show again after dismiss happened")
      secondShowGamesNewsletterAlert.assertValueCount(0, "Games alert does not show on non-games project")

      let thirdVM: ThanksViewModelType = ThanksViewModel()
      let thirdShowRatingAlert = TestObserver<(), NoError>()
      thirdVM.outputs.showRatingAlert.observe(thirdShowRatingAlert.observer)
      let thirdShowGamesNewsletterAlert = TestObserver<(), NoError>()
      thirdVM.outputs.showGamesNewsletterAlert.observe(thirdShowGamesNewsletterAlert.observer)

      thirdVM.inputs.project(ProjectFactory.game)
      thirdVM.inputs.viewDidLoad()

      thirdShowRatingAlert.assertValueCount(0, "Rating alert does not show again")
      thirdShowGamesNewsletterAlert.assertValueCount(1, "Games alert shows on games project")
    }
  }

  func testRatingAlert_ShowsAgain_AfterRemindLater_NonGames_NonGames() {
    withEnvironment(currentUser: UserFactory.userWithNewsletters()) {
      vm.inputs.project(ProjectFactory.live())
      vm.inputs.viewDidLoad()

      showRatingAlert.assertValueCount(1, "Rating alert shows on first viewing")
      showGamesNewsletterAlert.assertValueCount(0, "Games alert does not emit")

      vm.inputs.rateRemindLaterButtonPressed()

      let secondVM: ThanksViewModelType = ThanksViewModel()
      let secondShowRatingAlert = TestObserver<(), NoError>()
      secondVM.outputs.showRatingAlert.observe(secondShowRatingAlert.observer)
      let secondShowGamesNewsletterAlert = TestObserver<(), NoError>()
      secondVM.outputs.showGamesNewsletterAlert.observe(secondShowGamesNewsletterAlert.observer)

      secondVM.inputs.project(ProjectFactory.live())
      secondVM.inputs.viewDidLoad()

      secondShowRatingAlert.assertValueCount(1, "Rating alert shows again after reminder happened")
      secondShowGamesNewsletterAlert.assertValueCount(0, "Games alert does not show on non-games project")
    }
  }

  func testRatingCompleted_WithRateNow() {
    withEnvironment(currentUser: UserFactory.userWithNewsletters()) {
      vm.inputs.project(ProjectFactory.live())
      vm.inputs.viewDidLoad()

      showRatingAlert.assertValueCount(1, "Rating alert shows on first viewing")

      vm.inputs.rateNowButtonPressed()

      XCTAssertEqual(true, AppEnvironment.current.userDefaults.hasSeenAppRating, "Rating pref saved")
      XCTAssertEqual(["Checkout Finished Alert App Store Rating Rate Now"], trackingClient.events)
      goToAppStoreRating.assertValueCount(1, "Proceed to app store")
    }
  }

  func testRatingCompleted_WithRemindLater() {
    withEnvironment(currentUser: UserFactory.userWithNewsletters()) {
      vm.inputs.project(ProjectFactory.live())
      vm.inputs.viewDidLoad()

      showRatingAlert.assertValueCount(1, "Rating alert shows on first viewing")

      vm.inputs.rateRemindLaterButtonPressed()

      XCTAssertEqual(false, AppEnvironment.current.userDefaults.hasSeenAppRating, "Rating pref saved")
      XCTAssertEqual(["Checkout Finished Alert App Store Rating Remind Later"], trackingClient.events)
    }
  }

  func testRatingCompleted_WithNoThanks() {
    withEnvironment(currentUser: UserFactory.userWithNewsletters()) {
      vm.inputs.project(ProjectFactory.live())
      vm.inputs.viewDidLoad()

      showRatingAlert.assertValueCount(1, "Rating alert shows on first viewing")

      vm.inputs.rateNoThanksButtonPressed()

      XCTAssertEqual(true, AppEnvironment.current.userDefaults.hasSeenAppRating, "Rating pref saved")
      XCTAssertEqual(["Checkout Finished Alert App Store Rating No Thanks"], trackingClient.events)
    }
  }

  func testGamesAlert_ShowsOnce() {
    withEnvironment(currentUser: UserFactory.userWithNewsletters()) {
      XCTAssertEqual(false, AppEnvironment.current.userDefaults.hasSeenGamesNewsletterPrompt,
                     "Newsletter pref is not set")

      vm.inputs.project(ProjectFactory.game)
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

      secondVM.inputs.project(ProjectFactory.game)
      secondVM.inputs.viewDidLoad()

      secondShowRatingAlert.assertValueCount(1, "Rating alert shows on games project")
      secondShowGamesNewsletterAlert.assertValueCount(0, "Games alert does not show again on games project")
    }
  }

  func testGamesNewsletterAlert_ShouldNotShow_WhenUserIsSubscribed() {
    withEnvironment(currentUser: UserFactory.gamer) {
      vm.inputs.project(ProjectFactory.game)
      vm.inputs.viewDidLoad()

      showGamesNewsletterAlert.assertValueCount(0, "Games alert does not show on games project")
    }
  }

  func testGamesNewsletterSignup() {
    withEnvironment(currentUser: UserFactory.userWithNewsletters()) {
      vm.inputs.viewDidLoad()
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
    withEnvironment(countryCode: "DE", currentUser: UserFactory.userWithNewsletters()) {
      vm.inputs.viewDidLoad()
      vm.inputs.gamesNewsletterSignupButtonPressed()

      showGamesNewsletterOptInAlert.assertValues(["Kickstarter Loves Games"], "Opt-in alert emits with title")
      XCTAssertEqual(["Newsletter Subscribe"], trackingClient.events)
    }
  }

  func testAlerts_ShowOnce_AfterRateNow_Games_NonGames_NonGames() {
    withEnvironment(currentUser: UserFactory.userWithNewsletters()) {
      vm.inputs.project(ProjectFactory.game)
      vm.inputs.viewDidLoad()

      showRatingAlert.assertValueCount(0, "Rating alert does not show on games project")
      showGamesNewsletterAlert.assertValueCount(1, "Games alert shows on games project")

      let secondVM: ThanksViewModelType = ThanksViewModel()
      let secondShowRatingAlert = TestObserver<(), NoError>()
      secondVM.outputs.showRatingAlert.observe(secondShowRatingAlert.observer)
      let secondShowGamesNewsletterAlert = TestObserver<(), NoError>()
      secondVM.outputs.showGamesNewsletterAlert.observe(secondShowGamesNewsletterAlert.observer)

      secondVM.inputs.project(ProjectFactory.live())
      secondVM.inputs.viewDidLoad()

      secondShowRatingAlert.assertValueCount(1, "Rating alert shows on non-games project")
      secondShowGamesNewsletterAlert.assertValueCount(0, "Games alert does not show on non-games project")

      vm.inputs.rateNowButtonPressed()

      let thirdVM: ThanksViewModelType = ThanksViewModel()
      let thirdShowRatingAlert = TestObserver<(), NoError>()
      thirdVM.outputs.showRatingAlert.observe(thirdShowRatingAlert.observer)
      let thirdShowGamesNewsletterAlert = TestObserver<(), NoError>()
      thirdVM.outputs.showGamesNewsletterAlert.observe(thirdShowGamesNewsletterAlert.observer)

      thirdVM.inputs.project(ProjectFactory.live())
      thirdVM.inputs.viewDidLoad()

      thirdShowRatingAlert.assertValueCount(0, "Rating alert does not show on non-games project after rating")
      thirdShowGamesNewsletterAlert.assertValueCount(0, "Games alert does not show on non-games project")
    }
  }

  func testAlerts_ShowOnce_AfterNoThanks_Games_NonGames_NonGames() {
    withEnvironment(currentUser: UserFactory.userWithNewsletters()) {
      vm.inputs.project(ProjectFactory.game)
      vm.inputs.viewDidLoad()

      showRatingAlert.assertValueCount(0, "Rating alert does not show on games project")
      showGamesNewsletterAlert.assertValueCount(1, "Games alert shows on games project")

      let secondVM: ThanksViewModelType = ThanksViewModel()
      let secondShowRatingAlert = TestObserver<(), NoError>()
      secondVM.outputs.showRatingAlert.observe(secondShowRatingAlert.observer)
      let secondShowGamesNewsletterAlert = TestObserver<(), NoError>()
      secondVM.outputs.showGamesNewsletterAlert.observe(secondShowGamesNewsletterAlert.observer)

      secondVM.inputs.project(ProjectFactory.live())
      secondVM.inputs.viewDidLoad()

      secondShowRatingAlert.assertValueCount(1, "Rating alert shows on non-games project")
      secondShowGamesNewsletterAlert.assertValueCount(0, "Games alert does not show on non-games project")

      vm.inputs.rateNoThanksButtonPressed()

      let thirdVM: ThanksViewModelType = ThanksViewModel()
      let thirdShowRatingAlert = TestObserver<(), NoError>()
      thirdVM.outputs.showRatingAlert.observe(thirdShowRatingAlert.observer)
      let thirdShowGamesNewsletterAlert = TestObserver<(), NoError>()
      thirdVM.outputs.showGamesNewsletterAlert.observe(thirdShowGamesNewsletterAlert.observer)

      thirdVM.inputs.project(ProjectFactory.live())
      thirdVM.inputs.viewDidLoad()

      thirdShowRatingAlert.assertValueCount(0,
                                            "Rating alert does not show on non-games project after No Thanks")
      thirdShowGamesNewsletterAlert.assertValueCount(0, "Games alert does not show on non-games project")
    }
  }

  func testAlerts_ShowGamesOnce_ShowRatingAgain_AfterRemindLater_Games_NonGames_NonGames() {
    withEnvironment(currentUser: UserFactory.userWithNewsletters()) {
      vm.inputs.project(ProjectFactory.game)
      vm.inputs.viewDidLoad()

      showRatingAlert.assertValueCount(0, "Rating alert does not show on games project")
      showGamesNewsletterAlert.assertValueCount(1, "Games alert shows on games project")

      let secondVM: ThanksViewModelType = ThanksViewModel()
      let secondShowRatingAlert = TestObserver<(), NoError>()
      secondVM.outputs.showRatingAlert.observe(secondShowRatingAlert.observer)
      let secondShowGamesNewsletterAlert = TestObserver<(), NoError>()
      secondVM.outputs.showGamesNewsletterAlert.observe(secondShowGamesNewsletterAlert.observer)

      secondVM.inputs.project(ProjectFactory.live())
      secondVM.inputs.viewDidLoad()

      secondShowRatingAlert.assertValueCount(1, "Rating alert shows on non-games project")
      secondShowGamesNewsletterAlert.assertValueCount(0, "Games alert does not show on non-games project")

      vm.inputs.rateRemindLaterButtonPressed()

      let thirdVM: ThanksViewModelType = ThanksViewModel()
      let thirdShowRatingAlert = TestObserver<(), NoError>()
      thirdVM.outputs.showRatingAlert.observe(thirdShowRatingAlert.observer)
      let thirdShowGamesNewsletterAlert = TestObserver<(), NoError>()
      thirdVM.outputs.showGamesNewsletterAlert.observe(thirdShowGamesNewsletterAlert.observer)

      thirdVM.inputs.project(ProjectFactory.live())
      thirdVM.inputs.viewDidLoad()

      thirdShowRatingAlert.assertValueCount(1, "Rating alert shows on non-games project after reminder")
      thirdShowGamesNewsletterAlert.assertValueCount(0, "Games alert does not show on non-games project")
    }
  }

  func testAlerts_ShowOnce_AfterRateNow_NonGames_Games_NonGames() {
    withEnvironment(currentUser: UserFactory.userWithNewsletters()) {
      vm.inputs.project(ProjectFactory.live())
      vm.inputs.viewDidLoad()

      showRatingAlert.assertValueCount(1, "Rating alert shows on non-games project")
      showGamesNewsletterAlert.assertValueCount(0, "Games alert does not show on non-games project")

      vm.inputs.rateNowButtonPressed()

      let secondVM: ThanksViewModelType = ThanksViewModel()
      let secondShowRatingAlert = TestObserver<(), NoError>()
      secondVM.outputs.showRatingAlert.observe(secondShowRatingAlert.observer)
      let secondShowGamesNewsletterAlert = TestObserver<(), NoError>()
      secondVM.outputs.showGamesNewsletterAlert.observe(secondShowGamesNewsletterAlert.observer)

      secondVM.inputs.project(ProjectFactory.game)
      secondVM.inputs.viewDidLoad()

      secondShowRatingAlert.assertValueCount(0, "Rating alert does not show on games project")
      secondShowGamesNewsletterAlert.assertValueCount(1, "Games alert shows on games project")

      let thirdVM: ThanksViewModelType = ThanksViewModel()
      let thirdShowRatingAlert = TestObserver<(), NoError>()
      thirdVM.outputs.showRatingAlert.observe(thirdShowRatingAlert.observer)
      let thirdShowGamesNewsletterAlert = TestObserver<(), NoError>()
      thirdVM.outputs.showGamesNewsletterAlert.observe(thirdShowGamesNewsletterAlert.observer)

      thirdVM.inputs.project(ProjectFactory.live())
      thirdVM.inputs.viewDidLoad()

      thirdShowRatingAlert.assertValueCount(0, "Rating alert does not show on non-games project after rating")
      thirdShowGamesNewsletterAlert.assertValueCount(0, "Games alert does not show on non-games project")
    }
  }

  func testAlerts_ShowOnce_AfterNoThanks_NonGames_Games_NonGames() {
    withEnvironment(currentUser: UserFactory.userWithNewsletters()) {
      vm.inputs.project(ProjectFactory.live())
      vm.inputs.viewDidLoad()

      showRatingAlert.assertValueCount(1, "Rating alert shows on non-games project")
      showGamesNewsletterAlert.assertValueCount(0, "Games alert does not show on non-games project")

      vm.inputs.rateNoThanksButtonPressed()

      let secondVM: ThanksViewModelType = ThanksViewModel()
      let secondShowRatingAlert = TestObserver<(), NoError>()
      secondVM.outputs.showRatingAlert.observe(secondShowRatingAlert.observer)
      let secondShowGamesNewsletterAlert = TestObserver<(), NoError>()
      secondVM.outputs.showGamesNewsletterAlert.observe(secondShowGamesNewsletterAlert.observer)

      secondVM.inputs.project(ProjectFactory.game)
      secondVM.inputs.viewDidLoad()

      secondShowRatingAlert.assertValueCount(0, "Rating alert does not show on games project")
      secondShowGamesNewsletterAlert.assertValueCount(1, "Games alert shows on games project")

      let thirdVM: ThanksViewModelType = ThanksViewModel()
      let thirdShowRatingAlert = TestObserver<(), NoError>()
      thirdVM.outputs.showRatingAlert.observe(thirdShowRatingAlert.observer)
      let thirdShowGamesNewsletterAlert = TestObserver<(), NoError>()
      thirdVM.outputs.showGamesNewsletterAlert.observe(thirdShowGamesNewsletterAlert.observer)

      thirdVM.inputs.project(ProjectFactory.live())
      thirdVM.inputs.viewDidLoad()

      thirdShowRatingAlert.assertValueCount(0,
                                            "Rating alert does not show on non-games project after No Thanks")
      thirdShowGamesNewsletterAlert.assertValueCount(0, "Games alert does not show on non-games project")
    }
  }

  func testAlerts_ShowGamesOnce_ShowRatingAgain_AfterRemindLater_NonGames_Games_NonGames() {
    withEnvironment(currentUser: UserFactory.userWithNewsletters()) {
      vm.inputs.project(ProjectFactory.live())
      vm.inputs.viewDidLoad()

      showRatingAlert.assertValueCount(1, "Rating alert shows on non-games project")
      showGamesNewsletterAlert.assertValueCount(0, "Games alert does not show on non-games project")

      vm.inputs.rateRemindLaterButtonPressed()

      let secondVM: ThanksViewModelType = ThanksViewModel()
      let secondShowRatingAlert = TestObserver<(), NoError>()
      secondVM.outputs.showRatingAlert.observe(secondShowRatingAlert.observer)
      let secondShowGamesNewsletterAlert = TestObserver<(), NoError>()
      secondVM.outputs.showGamesNewsletterAlert.observe(secondShowGamesNewsletterAlert.observer)

      secondVM.inputs.project(ProjectFactory.game)
      secondVM.inputs.viewDidLoad()

      secondShowRatingAlert.assertValueCount(0, "Rating alert does not show on games project")
      secondShowGamesNewsletterAlert.assertValueCount(1, "Games alert shows on games project")

      let thirdVM: ThanksViewModelType = ThanksViewModel()
      let thirdShowRatingAlert = TestObserver<(), NoError>()
      thirdVM.outputs.showRatingAlert.observe(thirdShowRatingAlert.observer)
      let thirdShowGamesNewsletterAlert = TestObserver<(), NoError>()
      thirdVM.outputs.showGamesNewsletterAlert.observe(thirdShowGamesNewsletterAlert.observer)

      thirdVM.inputs.project(ProjectFactory.live())
      thirdVM.inputs.viewDidLoad()

      thirdShowRatingAlert.assertValueCount(1, "Rating alert shows on non-games project after Remind Later")
      thirdShowGamesNewsletterAlert.assertValueCount(0, "Games alert does not show on non-games project")
    }
  }

  func testGoToProject() {
    vm.inputs.viewDidLoad()
    vm.inputs.projectPressed(ProjectFactory.live())

    goToProject.assertValues([ProjectFactory.live()])
    XCTAssertEqual(["Checkout Finished Discover Open Project"], trackingClient.events)
  }

  func testShareSheet() {
    vm.inputs.project(ProjectFactory.live())
    vm.inputs.viewDidLoad()
    vm.inputs.shareMoreButtonPressed()

    showShareSheet.assertValues([ProjectFactory.live()])
    XCTAssertEqual(["Checkout Show Share Sheet"], trackingClient.events)
  }

  func testCancelShareSheet() {
    vm.inputs.viewDidLoad()
    vm.inputs.shareMoreButtonPressed()
    vm.inputs.cancelShareSheetButtonPressed()

    XCTAssertEqual(["Checkout Cancel Share Sheet"], trackingClient.events)
  }

  func testShareFacebook() {
    vm.inputs.project(ProjectFactory.live())
    vm.inputs.viewDidLoad()
    vm.inputs.facebookButtonPressed()

    showFacebookShare.assertValues([ProjectFactory.live()])
    XCTAssertEqual(["Checkout Show Share"], trackingClient.events)
    XCTAssertEqual("facebook", trackingClient.properties.last!["share_type"] as? String)
  }

  func testShowTwitter() {
    vm.inputs.project(ProjectFactory.live())
    vm.inputs.viewDidLoad()
    vm.inputs.twitterButtonPressed()

    showTwitterShare.assertValues([ProjectFactory.live()])
    XCTAssertEqual(["Checkout Show Share"], trackingClient.events)
    XCTAssertEqual("twitter", trackingClient.properties.last!["share_type"] as? String)
  }

  func testShareFinished() {
    vm.inputs.viewDidLoad()
    vm.inputs.shareFinishedWithShareType(UIActivityTypeMessage, completed: true)

    XCTAssertEqual(["Checkout Share Finished"], trackingClient.events)
    XCTAssertEqual(UIActivityTypeMessage, trackingClient.properties.last!["share_type"] as? String)
    XCTAssertEqual(true, trackingClient.properties.last!["did_share"] as? Bool)

    vm.inputs.shareFinishedWithShareType(UIActivityTypeMail, completed: false)

    XCTAssertEqual(["Checkout Share Finished", "Checkout Share Finished"], trackingClient.events)
    XCTAssertEqual(UIActivityTypeMail, trackingClient.properties.last!["share_type"] as? String)
    XCTAssertEqual(false, trackingClient.properties.last!["did_share"] as? Bool)
  }

  func testRecommendationsCategory() {
    vm.inputs.project(ProjectFactory.game)
    vm.inputs.viewDidLoad()

    scheduler.advance()

    showRecommendations.assertValues([CategoryFactory.games])
  }
}
