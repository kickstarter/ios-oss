#if os(iOS)
// swiftlint:disable file_length
import KsApi
import Models
import Prelude
import ReactiveCocoa
import ReactiveExtensions
import Result
import Social.SLComposeViewController

public protocol ThanksViewModelInputs {
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

public protocol ThanksViewModelOutputs {
  /// Emits when view controller should dismiss
  var dismissViewController: Signal<(), NoError> { get }

  /// Emits DiscoveryParams when should go to Discovery
  var goToDiscovery: Signal<DiscoveryParams, NoError> { get }

  /// Emits iTunes link when should go to App Store
  var goToAppStoreRating: Signal<String, NoError> { get }

  /// Emits project name to display
  var backedProjectText: Signal<String, NoError> { get }

  /// Emits project when should go to Project page
  var goToProject: Signal<(Project, RefTag), NoError> { get }

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

  /// Emits a bool whether Facebook is available for sharing
  var facebookIsAvailable: Signal<Bool, NoError> { get }

  /// Emits a bool whether Twitter is available for sharing
  var twitterIsAvailable: Signal<Bool, NoError> { get }
}

public protocol ThanksViewModelType {
  var inputs: ThanksViewModelInputs { get }
  var outputs: ThanksViewModelOutputs { get }
}

public final class ThanksViewModel: ThanksViewModelType, ThanksViewModelInputs, ThanksViewModelOutputs {

  // swiftlint:disable function_body_length
  public init() {
    self.facebookIsAvailable = self.viewDidLoadProperty.signal
      .map { SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) }

    self.twitterIsAvailable = self.viewDidLoadProperty.signal
      .map { SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) }

    let project = self.projectProperty.signal.ignoreNil()

    self.backedProjectText = project.map {
      localizedString(key: "project.checkout.share.you_just_backed_project_share_this_project_html",
        defaultValue: "You just backed <b>%{project_name}</b>. " +
        "Share this project with friends to help it along!",
        count: nil,
        substitutions: ["project_name": $0.name])
      }
      .takeWhen(viewDidLoadProperty.signal)

    self.goToProject = projectPressedProperty.signal.ignoreNil()
      .map { ($0, RefTag.thanks) }

    self.showShareSheet = project
      .takeWhen(shareMoreButtonPressedProperty.signal)

    self.showFacebookShare = project
      .takeWhen(facebookButtonPressedProperty.signal)

    self.showTwitterShare = project
      .takeWhen(twitterButtonPressedProperty.signal)

    let shouldShowGamesAlert = project
      .map { project in
        project.category.rootId == Models.Category.gamesId &&
        !(AppEnvironment.current.currentUser?.newsletters.games ?? false) &&
        !AppEnvironment.current.userDefaults.hasSeenGamesNewsletterPrompt
    }

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
      .on(next: { AppEnvironment.current.userDefaults.hasSeenAppRating = true })

    self.goToAppStoreRating = self.rateNowButtonPressedProperty.signal
      .map { AppEnvironment.current.config?.iTunesLink ?? "" }

    self.dismissViewController = self.closeButtonPressedProperty.signal

    self.goToDiscovery = self.categoryCellPressedProperty.signal.ignoreNil()
      .map { DiscoveryParams.defaults |> DiscoveryParams.lens.category .~ $0 }

    let rootCategory = project
      .map { $0.category.rootId }
      .ignoreNil()
      .flatMap {
        return AppEnvironment.current.apiService.fetchCategory(id: $0)
          .delay(AppEnvironment.current.apiDelayInterval, onScheduler: AppEnvironment.current.scheduler)
          .map { $0.root ?? $0 }
          .demoteErrors()
    }

    let projects = project
      .combineLatestWith(rootCategory)
      .flatMap { project, category in
        relatedProjects(project, category: category, apiService: AppEnvironment.current.apiService)
      }
      .filter { projects in !projects.isEmpty }

    self.showRecommendations = zip(projects, rootCategory)

    self.updateUserInEnvironment = gamesNewsletterSignupButtonPressedProperty.signal
      .map { AppEnvironment.current.currentUser ?? nil }.ignoreNil()
      .switchMap { user in
        AppEnvironment.current.apiService.updateUserSelf(user |> User.lens.newsletters.games .~ true)
          .delay(AppEnvironment.current.apiDelayInterval, onScheduler: AppEnvironment.current.scheduler)
          .demoteErrors()
    }

    self.postUserUpdatedNotification = userUpdatedProperty.signal
      .mapConst(NSNotification(name: CurrentUserNotifications.userUpdated, object: nil))

    self.showGamesNewsletterAlert
      .observeNext { AppEnvironment.current.userDefaults.hasSeenGamesNewsletterPrompt = true }

    project
      .takeWhen(self.rateRemindLaterButtonPressedProperty.signal)
      .observeNext { project in
        AppEnvironment.current.userDefaults.hasSeenAppRating = false
        AppEnvironment.current.koala.trackCheckoutFinishAppStoreRatingAlertRemindLater(project: project)
    }

    project
      .takeWhen(self.rateNoThanksButtonPressedProperty.signal)
      .observeNext { project in
        AppEnvironment.current.koala.trackCheckoutFinishAppStoreRatingAlertNoThanks(project: project)
    }

    project
      .takeWhen(self.goToDiscovery)
      .observeNext { project in
        AppEnvironment.current.koala.trackCheckoutFinishJumpToDiscovery(project: project)
    }

    project
      .takeWhen(self.gamesNewsletterSignupButtonPressedProperty.signal)
      .observeNext { project in
        AppEnvironment.current.koala.trackNewsletterToggle(true, project: project)
    }

    project
      .takeWhen(self.goToAppStoreRating)
      .observeNext { project in
        AppEnvironment.current.koala.trackCheckoutFinishAppStoreRatingAlertRateNow(project: project)
    }

    project
      .takeWhen(self.goToProject)
      .observeNext { project in
        AppEnvironment.current.koala.trackCheckoutFinishJumpToProject(project: project)
    }

    project
      .takeWhen(self.cancelShareSheetButtonPressedProperty.signal)
      .observeNext { project in
        AppEnvironment.current.koala.trackCheckoutCancelShareSheet(project: project)
    }

    project
      .takeWhen(self.showShareSheet)
      .observeNext { project in
        AppEnvironment.current.koala.trackCheckoutShowShareSheet(project: project)
    }

    let projectAndShareTypeAndCompleted = project
      .takePairWhen(self.shareFinishedWithShareTypeProperty.signal)
      .map { ($0, $1.0, $1.1) }

    projectAndShareTypeAndCompleted
      .observeNext { project, shareType, completed in
        AppEnvironment.current.koala.trackCheckoutShowShare(project: project, shareType: shareType)
    }

    projectAndShareTypeAndCompleted
      .filter { _, _, completed in completed }
      .flatMap { SignalProducer(value: $0).delay(1.0, onScheduler: AppEnvironment.current.scheduler) }
      .observeNext { project, shareType, _ in
        AppEnvironment.current.koala.trackCheckoutShare(project: project, shareType: shareType)
    }

    projectAndShareTypeAndCompleted
      .filter { _, _, completed in !completed }
      .flatMap { SignalProducer(value: $0).delay(1.0, onScheduler: AppEnvironment.current.scheduler) }
      .observeNext { project, shareType, _ in
        AppEnvironment.current.koala.trackCheckoutCancelShare(project: project, shareType: shareType)
    }
  }
  // swiftlint:enable function_body_length

  // MARK: ThanksViewModelType
  public var inputs: ThanksViewModelInputs { return self }
  public var outputs: ThanksViewModelOutputs { return self }

  // MARK: ThanksViewModelInputs
  private let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    viewDidLoadProperty.value = ()
  }

  private let closeButtonPressedProperty = MutableProperty()
  public func closeButtonPressed() {
    closeButtonPressedProperty.value = ()
  }

  private let categoryCellPressedProperty = MutableProperty<Models.Category?>(nil)
  public func categoryCellPressed(category: Models.Category) {
    categoryCellPressedProperty.value = category
  }

  private let projectProperty = MutableProperty<Project?>(nil)
  public func project(project: Project) {
    projectProperty.value = project
  }

  private let projectPressedProperty = MutableProperty<Project?>(nil)
  public func projectPressed(project: Project) {
    projectPressedProperty.value = project
  }

  private let facebookButtonPressedProperty = MutableProperty()
  public func facebookButtonPressed() {
    facebookButtonPressedProperty.value = ()
  }

  private let twitterButtonPressedProperty = MutableProperty()
  public func twitterButtonPressed() {
    twitterButtonPressedProperty.value = ()
  }

  private let shareMoreButtonPressedProperty = MutableProperty()
  public func shareMoreButtonPressed() {
    shareMoreButtonPressedProperty.value = ()
  }

  private let gamesNewsletterSignupButtonPressedProperty = MutableProperty()
  public func gamesNewsletterSignupButtonPressed() {
    gamesNewsletterSignupButtonPressedProperty.value = ()
  }

  private let rateNowButtonPressedProperty = MutableProperty()
  public func rateNowButtonPressed() {
    rateNowButtonPressedProperty.value = ()
  }

  private let rateRemindLaterButtonPressedProperty = MutableProperty()
  public func rateRemindLaterButtonPressed() {
    rateRemindLaterButtonPressedProperty.value = ()
  }

  private let rateNoThanksButtonPressedProperty = MutableProperty()
  public func rateNoThanksButtonPressed() {
    rateNoThanksButtonPressedProperty.value = ()
  }

  private let cancelShareSheetButtonPressedProperty = MutableProperty()
  public func cancelShareSheetButtonPressed() {
    cancelShareSheetButtonPressedProperty.value = ()
  }

  private let shareFinishedWithShareTypeProperty = MutableProperty<(String?, Bool)>(nil, false)
  public func shareFinishedWithShareType(shareType: String?, completed: Bool) {
    shareFinishedWithShareTypeProperty.value = (shareType, completed)
  }

  private let userUpdatedProperty = MutableProperty()
  public func userUpdated() {
    userUpdatedProperty.value = ()
  }

  // MARK: ThanksViewModelOutputs
  public let dismissViewController: Signal<(), NoError>
  public let goToDiscovery: Signal<DiscoveryParams, NoError>
  public let goToAppStoreRating: Signal<String, NoError>
  public let backedProjectText: Signal<String, NoError>
  public let goToProject: Signal<(Project, RefTag), NoError>
  public let showRatingAlert: Signal<(), NoError>
  public let showShareSheet: Signal<Project, NoError>
  public let showTwitterShare: Signal<Project, NoError>
  public let showFacebookShare: Signal<Project, NoError>
  public let showGamesNewsletterAlert: Signal<(), NoError>
  public let showGamesNewsletterOptInAlert: Signal<String, NoError>
  public let showRecommendations: Signal<([Project], Models.Category), NoError>
  public let updateUserInEnvironment: Signal<User, NoError>
  public let postUserUpdatedNotification: Signal<NSNotification, NoError>
  public let facebookIsAvailable: Signal<Bool, NoError>
  public let twitterIsAvailable: Signal<Bool, NoError>
}

private func relatedProjects(project: Project, category: Models.Category, apiService: ServiceType) ->
  SignalProducer<[Project], NoError> {

    let base = DiscoveryParams.lens.perPage .~ 3 <> DiscoveryParams.lens.backed .~ false

    let recommendedParams = DiscoveryParams.defaults |> base
      <> DiscoveryParams.lens.recommended .~ true

    let similarToParams = DiscoveryParams.defaults |> base
      <> DiscoveryParams.lens.similarTo .~ project

    let staffPickParams = DiscoveryParams.defaults |> base
      <> DiscoveryParams.lens.staffPicks .~ true
      <> DiscoveryParams.lens.category .~ category

    let recommendedProjects = apiService.fetchDiscovery(params: recommendedParams)
      .retry(2)
      .map { $0.projects }
      .uncollect()

    let similarToProjects = apiService.fetchDiscovery(params: similarToParams)
      .retry(2)
      .map { $0.projects }
      .uncollect()

    let staffPickProjects = apiService.fetchDiscovery(params: staffPickParams)
      .retry(2)
      .map { $0.projects }
      .uncollect()

    return SignalProducer.concat(recommendedProjects, similarToProjects, staffPickProjects)
      .uniqueValues { $0.id }
      .demoteErrors()
      .take(3)
      .collect()
}
#endif
