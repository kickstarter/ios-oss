import KsApi
import Models
import ReactiveCocoa
import ReactiveExtensions
import Result
import Prelude
import Library

internal protocol ThanksViewModelInputs {
  /// Call when the view controller view did load
  func viewDidLoad()
  /// Call when close button is pressed
  func closeButtonPressed()
  /// Call when category cell is pressed
  func categoryCellPressed(category: Models.Category)
  /// Call to set project
  func project(project: Project)
  /// Call when project cell is pressed
  func projectPressed(project: Project)
  /// Call when Facebook button is pressed
  func facebookButtonPressed()
  /// Call when Twitter button is pressed
  func twitterButtonPressed()
  /// Call when More button is pressed
  func shareMoreButtonPressed()
  /// Call when signup button is pressed on games newsletter alert
  func gamesNewsletterSignupButtonPressed()
  /// Call when "rate now" button is pressed on rating alert
  func rateNowButtonPressed()
  /// Call when "remind" button is pressed on rating alert
  func rateRemindLaterButtonPressed()
  /// Call when "no thanks" button is pressed on rating alert
  func rateNoThanksButtonPressed()
  /// Call when cancel button is pressed on share sheet
  func cancelShareSheetButtonPressed()
  /// Call when UIActivityViewController sharing completes
  func shareFinishedWithShareType(shareType: String?, completed: Bool)
  /// Call when the current user has been updated in the environment
  func userUpdated()
}

internal protocol ThanksViewModelOutputs {
  /// Emits when view controller should dismiss
  var dismissViewController: Signal<(), NoError> { get }
  /// Emits DiscoveryParams when should go to Discovery
  var goToDiscovery: Signal<DiscoveryParams, NoError> { get }
  /// Emits iTunes link when should go to App Store
  var goToAppStoreRating: Signal<String, NoError> { get }
  /// Emits project name to display
  var projectName: Signal<String, NoError> { get }
  /// Emits project when should go to Project page
  var goToProject: Signal<Project, NoError> { get }
  /// Emits when should show rating alert
  var showRatingAlert: Signal <(), NoError> { get }
  /// Emits project when should show share sheet
  var showShareSheet: Signal<Project, NoError> { get }
  /// Emits project when should show Facebook share
  var showFacebookShare: Signal<Project, NoError> { get }
  /// Emits project when should show Twitter share
  var showTwitterShare: Signal<Project, NoError> { get }
  /// Emits when should show games newsletter alert
  var showGamesNewsletterAlert: Signal <(), NoError> { get }
  /// Emits newsletter title when should show games newsletter opt-in alert
  var showGamesNewsletterOptInAlert: Signal <String, NoError> { get }
  /// Emits array of projects and a category when should show recommendations
  var showRecommendations: Signal <([Project], Models.Category), NoError> { get }
  /// Emits a User that can be used to replace the current user in the environment
  var updateUserInEnvironment: Signal<User, NoError> { get }
  /// Emits when a user updated notification should be posted
  var postUserUpdatedNotification: Signal<NSNotification, NoError> { get }
}

internal protocol ThanksViewModelType {
  var inputs: ThanksViewModelInputs { get }
  var outputs: ThanksViewModelOutputs { get }
}

internal final class ThanksViewModel: ThanksViewModelType, ThanksViewModelInputs, ThanksViewModelOutputs {

  // swiftlint:disable function_body_length
  init() {

    let project = self.projectProperty.signal.ignoreNil()

    self.projectName = project.map { $0.name }

    self.goToProject = projectPressedProperty.signal.ignoreNil()

    self.showShareSheet = project
      .takeWhen(shareMoreButtonPressedProperty.signal)

    self.showFacebookShare = project
      .takeWhen(facebookButtonPressedProperty.signal)

    self.showTwitterShare = project
      .takeWhen(twitterButtonPressedProperty.signal)

    let shouldShowGamesAlert = project
      .map { project in
        project.category.root.id == Models.Category.gamesId &&
        !(AppEnvironment.current.currentUser?.newsletters?.games ?? false) &&
        !AppEnvironment.current.userDefaults.hasSeenGamesNewsletterPrompt }

    self.showGamesNewsletterAlert = shouldShowGamesAlert
      .filter(isTrue)
      .takeWhen(viewDidLoadProperty.signal)
      .ignoreValues()

    self.showGamesNewsletterOptInAlert = gamesNewsletterSignupButtonPressedProperty.signal
      .filter { AppEnvironment.current.countryCode == "DE" }
      .map { localizedString(
        key: "profile.settings.newsletter.games",
        defaultValue: "Kickstarter Loves Games"
      )
    }

    self.showRatingAlert = shouldShowGamesAlert
      .filter {
        $0 == false &&
        !AppEnvironment.current.userDefaults.hasSeenAppRating &&
        AppEnvironment.current.config?.iTunesLink != nil
      }
      .takeWhen(viewDidLoadProperty.signal)
      .ignoreValues()

    self.goToAppStoreRating = self.rateNowButtonPressedProperty.signal
      .on {
        AppEnvironment.current.userDefaults.hasSeenAppRating = true
        AppEnvironment.current.koala.trackCheckoutFinishAppStoreRatingAlertRateNow()
      }
      .map { AppEnvironment.current.config?.iTunesLink ?? "" }

    self.dismissViewController = self.closeButtonPressedProperty.signal

    self.goToDiscovery = self.categoryCellPressedProperty.signal.ignoreNil()
      .map { DiscoveryParams(category: $0) }

    let rootCategory = project
      .flatMap { p -> SignalProducer<Models.Category, NoError> in
        if let parent = p.category.parent {
          return SignalProducer(value: parent)
        }
        return AppEnvironment.current.apiService.fetchCategory(p.category.root)
          .map { $0.root }
          .delay(AppEnvironment.current.apiDelayInterval, onScheduler: AppEnvironment.current.scheduler)
          .demoteErrors()
    }

    let projects = project
      .combineLatestWith(rootCategory)
      .flatMap { project, category in
        relatedProjects(project, category: category, apiService: AppEnvironment.current.apiService)
    }

    self.showRecommendations = zip(projects, rootCategory)

    self.updateUserInEnvironment = gamesNewsletterSignupButtonPressedProperty.signal
      .map { AppEnvironment.current.currentUser ?? nil }.ignoreNil()
      .switchMap { user in
        AppEnvironment.current.apiService.updateNewsletters(
          weekly: user.newsletters?.weekly,
          promo: user.newsletters?.promo,
          happening: user.newsletters?.happening,
          games: true
        )
        .delay(AppEnvironment.current.apiDelayInterval, onScheduler: AppEnvironment.current.scheduler)
        .demoteErrors()
    }

    self.postUserUpdatedNotification = userUpdatedProperty.signal
      .mapConst(NSNotification(name: CurrentUserNotifications.userUpdated, object: nil))

    self.showGamesNewsletterAlert
      .observeNext { AppEnvironment.current.userDefaults.hasSeenGamesNewsletterPrompt = true }

    self.rateRemindLaterButtonPressedProperty.signal.observeNext {
      AppEnvironment.current.userDefaults.hasSeenAppRating = false
      AppEnvironment.current.koala.trackCheckoutFinishAppStoreRatingAlertRemindLater()
    }

    self.rateNoThanksButtonPressedProperty.signal.observeNext {
      AppEnvironment.current.userDefaults.hasSeenAppRating = true
      AppEnvironment.current.koala.trackCheckoutFinishAppStoreRatingAlertNoThanks()
    }

    self.goToDiscovery.observeNext { _ in AppEnvironment.current.koala.trackCheckoutFinishJumpToDiscovery() }

    self.gamesNewsletterSignupButtonPressedProperty.signal.observeNext { _ in
      AppEnvironment.current.koala.trackNewsletterToggle(true)
    }

    self.goToProject.observeNext { _ in AppEnvironment.current.koala.trackCheckoutFinishJumpToProject() }

    self.cancelShareSheetButtonPressedProperty.signal
      .observeNext { AppEnvironment.current.koala.trackCheckoutCancelShareSheet() }

    self.showShareSheet
      .observeNext { _ in AppEnvironment.current.koala.trackCheckoutShowShareSheet() }

    self.showFacebookShare
      .observeNext { _ in AppEnvironment.current.koala.trackCheckoutShowFacebookShareView() }

    self.showTwitterShare
      .observeNext { _ in AppEnvironment.current.koala.trackCheckoutShowTwitterShareView() }

    self.shareFinishedWithShareTypeProperty.signal
      .observeNext { (shareType, completed) in
        AppEnvironment.current.koala.trackCheckoutShareFinishedWithShareType(
          shareType,
          completed: completed
        )
    }
  }
  // swiftlint:enable function_body_length

  // MARK: ThanksViewModelType
  internal var inputs: ThanksViewModelInputs { return self }
  internal var outputs: ThanksViewModelOutputs { return self }

  // MARK: ThanksViewModelInputs
  private let viewDidLoadProperty = MutableProperty()
  func viewDidLoad() {
    viewDidLoadProperty.value = ()
  }

  private let closeButtonPressedProperty = MutableProperty()
  func closeButtonPressed() {
    closeButtonPressedProperty.value = ()
  }

  private let categoryCellPressedProperty = MutableProperty<Models.Category?>(nil)
  func categoryCellPressed(category: Models.Category) {
    categoryCellPressedProperty.value = category
  }

  private let projectProperty = MutableProperty<Project?>(nil)
  func project(project: Project) {
    projectProperty.value = project
  }

  private let projectPressedProperty = MutableProperty<Project?>(nil)
  func projectPressed(project: Project) {
    projectPressedProperty.value = project
  }

  private let facebookButtonPressedProperty = MutableProperty()
  func facebookButtonPressed() {
    facebookButtonPressedProperty.value = ()
  }

  private let twitterButtonPressedProperty = MutableProperty()
  func twitterButtonPressed() {
    twitterButtonPressedProperty.value = ()
  }

  private let shareMoreButtonPressedProperty = MutableProperty()
  func shareMoreButtonPressed() {
    shareMoreButtonPressedProperty.value = ()
  }

  private let gamesNewsletterSignupButtonPressedProperty = MutableProperty()
  func gamesNewsletterSignupButtonPressed() {
    gamesNewsletterSignupButtonPressedProperty.value = ()
  }

  private let rateNowButtonPressedProperty = MutableProperty()
  func rateNowButtonPressed() {
    rateNowButtonPressedProperty.value = ()
  }

  private let rateRemindLaterButtonPressedProperty = MutableProperty()
  func rateRemindLaterButtonPressed() {
    rateRemindLaterButtonPressedProperty.value = ()
  }

  private let rateNoThanksButtonPressedProperty = MutableProperty()
  func rateNoThanksButtonPressed() {
    rateNoThanksButtonPressedProperty.value = ()
  }

  private let cancelShareSheetButtonPressedProperty = MutableProperty()
  func cancelShareSheetButtonPressed() {
    cancelShareSheetButtonPressedProperty.value = ()
  }

  private let shareFinishedWithShareTypeProperty = MutableProperty<(String?, Bool)>(nil, false)
  func shareFinishedWithShareType(shareType: String?, completed: Bool) {
    shareFinishedWithShareTypeProperty.value = (shareType, completed)
  }

  private let userUpdatedProperty = MutableProperty()
  func userUpdated() {
    userUpdatedProperty.value = ()
  }

  // MARK: ThanksViewModelOutputs
  internal let dismissViewController: Signal<(), NoError>
  internal let goToDiscovery: Signal<DiscoveryParams, NoError>
  internal let goToAppStoreRating: Signal<String, NoError>
  internal let projectName: Signal<String, NoError>
  internal let goToProject: Signal<Project, NoError>
  internal let showRatingAlert: Signal<(), NoError>
  internal let showShareSheet: Signal<Project, NoError>
  internal let showTwitterShare: Signal<Project, NoError>
  internal let showFacebookShare: Signal<Project, NoError>
  internal let showGamesNewsletterAlert: Signal<(), NoError>
  internal let showGamesNewsletterOptInAlert: Signal<String, NoError>
  internal let showRecommendations: Signal<([Project], Models.Category), NoError>
  internal let updateUserInEnvironment: Signal<User, NoError>
  internal let postUserUpdatedNotification: Signal<NSNotification, NoError>
}

private func relatedProjects(project: Project, category: Models.Category, apiService: ServiceType) ->
  SignalProducer<[Project], NoError> {
    let recommendedParams = DiscoveryParams(backed: false, recommended: true, perPage: 3)
    let similarToParams = DiscoveryParams(backed: false, similarTo: project, perPage: 3)
    let staffPickParams = DiscoveryParams(staffPicks: true,
                                          backed: false,
                                          category: category,
                                          perPage: 3)

    let recommendedProjects = apiService.fetchProjects(recommendedParams).retry(2).uncollect()
    let similarToProjects = apiService.fetchProjects(similarToParams).retry(2).uncollect()
    let staffPickProjects = apiService.fetchProjects(staffPickParams).retry(2).uncollect()

    return SignalProducer.concat(recommendedProjects, similarToProjects, staffPickProjects)
      .distincts { $0.id }
      .demoteErrors()
      .take(3)
      .collect()
}
