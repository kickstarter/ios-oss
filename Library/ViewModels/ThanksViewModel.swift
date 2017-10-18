import KsApi
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result

public protocol ThanksViewModelInputs {
  /// Call when the view controller view did load
  func viewDidLoad()

  /// Call when close button is tapped
  func closeButtonTapped()

  /// Call when category cell is tapped
  func categoryCellTapped(_ category: KsApi.RootCategoriesEnvelope.Category)

  /// Call with a boolean that determines if facebook is available on this device, i.e.
  /// SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook)
  func facebookIsAvailable(_ available: Bool)

  /// Call to set project
  func project(_ project: Project)

  /// Call when project cell is tapped
  func projectTapped(_ project: Project)

  /// Call when signup button is tapped on games newsletter alert
  func gamesNewsletterSignupButtonTapped()

  /// Call when "rate now" button is tapped on rating alert
  func rateNowButtonTapped()

  /// Call when "remind" button is tapped on rating alert
  func rateRemindLaterButtonTapped()

  /// Call when "no thanks" button is tapped on rating alert
  func rateNoThanksButtonTapped()

  /// Call with a boolean that determines if twitter is available on this device, i.e.
  /// SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter)
  func twitterIsAvailable(_ available: Bool)

  /// Call when the current user has been updated in the environment
  func userUpdated()
}

public protocol ThanksViewModelOutputs {
  /// Emits backed project subheader text to display
  var backedProjectText: Signal<NSAttributedString, NoError> { get }

  /// Emits when view controller should dismiss
  var dismissToRootViewController: Signal<(), NoError> { get }

  /// Emits a bool determining whether or not the facebook button is hidden.
  var facebookButtonIsHidden: Signal<Bool, NoError> { get }

  /// Emits iTunes link when should go to App Store
  var goToAppStoreRating: Signal<String, NoError> { get }

  /// Emits DiscoveryParams when should go to Discovery
  var goToDiscovery: Signal<DiscoveryParams, NoError> { get }

  /// Emits project when should go to Project page
  var goToProject: Signal<(Project, [Project], RefTag), NoError> { get }

  /// Emits when a user updated notification should be posted
  var postUserUpdatedNotification: Signal<Notification, NoError> { get }

  /// Emits when should show games newsletter alert
  var showGamesNewsletterAlert: Signal <(), NoError> { get }

  /// Emits newsletter title when should show games newsletter opt-in alert
  var showGamesNewsletterOptInAlert: Signal <String, NoError> { get }

  /// Emits when should show rating alert
  var showRatingAlert: Signal <(), NoError> { get }

  /// Emits array of projects and a category when should show recommendations
  var showRecommendations: Signal <([Project], KsApi.RootCategoriesEnvelope.Category), NoError> { get }

  /// Emits a bool determining whether or not the twitter button is hidden.
  var twitterButtonIsHidden: Signal<Bool, NoError> { get }

  /// Emits a User that can be used to replace the current user in the environment
  var updateUserInEnvironment: Signal<User, NoError> { get }
}

public protocol ThanksViewModelType {
  var inputs: ThanksViewModelInputs { get }
  var outputs: ThanksViewModelOutputs { get }
}

public final class ThanksViewModel: ThanksViewModelType, ThanksViewModelInputs, ThanksViewModelOutputs {

  public init() {
    let project = self.projectProperty.signal.skipNil()

    self.backedProjectText = project.map {
      let string = Strings.project_checkout_share_you_just_backed_project_share_this_project_html(
        project_name: $0.name
      )

      return string.simpleHtmlAttributedString(font: UIFont.ksr_subhead(), bold: UIFont.ksr_subhead().bolded)
        ?? NSAttributedString(string: "")
      }
      .takeWhen(self.viewDidLoadProperty.signal)

    let shouldShowGamesAlert = project
      .map { project in
        project.category.rootId == KsApi.RootCategoriesEnvelope.Category.gamesId &&
        !(AppEnvironment.current.currentUser?.newsletters.games ?? false) &&
        !AppEnvironment.current.userDefaults.hasSeenGamesNewsletterPrompt
    }

    self.showGamesNewsletterAlert = shouldShowGamesAlert
      .filter(isTrue)
      .takeWhen(self.viewDidLoadProperty.signal)
      .ignoreValues()

    self.showGamesNewsletterOptInAlert = self.gamesNewsletterSignupButtonTappedProperty.signal
      .filter { AppEnvironment.current.countryCode == "DE" }
      .map (Strings.profile_settings_newsletter_games)

    self.showRatingAlert = shouldShowGamesAlert
      .filter {
        $0 == false &&
        !AppEnvironment.current.userDefaults.hasSeenAppRating &&
        AppEnvironment.current.config?.iTunesLink != nil
      }
      .takeWhen(self.viewDidLoadProperty.signal)
      .ignoreValues()
      .on(value: { AppEnvironment.current.userDefaults.hasSeenAppRating = true })

    self.goToAppStoreRating = self.rateNowButtonTappedProperty.signal
      .map { AppEnvironment.current.config?.iTunesLink ?? "" }

    self.dismissToRootViewController = self.closeButtonTappedProperty.signal

    self.goToDiscovery = self.categoryCellTappedProperty.signal.skipNil()
      .map { DiscoveryParams.defaults |> DiscoveryParams.lens.category .~ $0 }

    let rootCategory = project
      .map { $0.category.root?.id }
      .skipNil()
      .flatMap {
        return AppEnvironment.current.apiService.fetchGraphCategory(query: categoryBy(id: $0))
        .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
        .map { (category: KsApi.RootCategoriesEnvelope.Category)
          -> KsApi.RootCategoriesEnvelope.Category in category._parent ?? category }
        .demoteErrors()
    }

    let projects = Signal.combineLatest(project, rootCategory)
      .flatMap(relatedProjects(toProject:inCategory:))
      .filter { projects in !projects.isEmpty }

    self.showRecommendations = Signal.zip(projects, rootCategory)

    self.goToProject = self.showRecommendations
      .map(first)
      .takePairWhen(self.projectTappedProperty.signal.skipNil())
      .map { projects, project in (project, projects, RefTag.thanks) }

    self.updateUserInEnvironment = self.gamesNewsletterSignupButtonTappedProperty.signal
      .map { AppEnvironment.current.currentUser ?? nil }
      .skipNil()
      .switchMap { user in
        AppEnvironment.current.apiService.updateUserSelf(user |> User.lens.newsletters.games .~ true)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .demoteErrors()
    }

    self.postUserUpdatedNotification = self.userUpdatedProperty.signal
      .mapConst(Notification(name: .ksr_userUpdated))

    self.showGamesNewsletterAlert
      .observeValues { AppEnvironment.current.userDefaults.hasSeenGamesNewsletterPrompt = true }

    self.facebookButtonIsHidden = self.facebookIsAvailableProperty.signal.map(negate)
    self.twitterButtonIsHidden = self.twitterIsAvailableProperty.signal.map(negate)

    project
      .takeWhen(self.rateRemindLaterButtonTappedProperty.signal)
      .observeValues { project in
        AppEnvironment.current.userDefaults.hasSeenAppRating = false
        AppEnvironment.current.koala.trackCheckoutFinishAppStoreRatingAlertRemindLater(project: project)
    }

    project
      .takeWhen(self.rateNoThanksButtonTappedProperty.signal)
      .observeValues { project in
        AppEnvironment.current.koala.trackCheckoutFinishAppStoreRatingAlertNoThanks(project: project)
    }

    project
      .takeWhen(self.goToDiscovery)
      .observeValues { project in
        AppEnvironment.current.koala.trackCheckoutFinishJumpToDiscovery(project: project)
    }

    project
      .takeWhen(self.gamesNewsletterSignupButtonTappedProperty.signal)
      .observeValues { project in
        AppEnvironment.current.koala.trackChangeNewsletter(
          newsletterType: .games,
          sendNewsletter: true,
          project: project,
          context: .thanks
        )
    }

    project
      .takeWhen(self.goToAppStoreRating)
      .observeValues { project in
        AppEnvironment.current.koala.trackCheckoutFinishAppStoreRatingAlertRateNow(project: project)
    }

    project
      .takeWhen(self.goToProject)
      .observeValues { project in
        AppEnvironment.current.koala.trackCheckoutFinishJumpToProject(project: project)
    }

    project
      .takeWhen(self.showRatingAlert)
      .observeValues { project in
        AppEnvironment.current.koala.trackTriggeredAppStoreRatingDialog(project: project)
    }
  }

  // MARK: ThanksViewModelType
  public var inputs: ThanksViewModelInputs { return self }
  public var outputs: ThanksViewModelOutputs { return self }

  // MARK: ThanksViewModelInputs
  fileprivate let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    viewDidLoadProperty.value = ()
  }

  fileprivate let closeButtonTappedProperty = MutableProperty()
  public func closeButtonTapped() {
    closeButtonTappedProperty.value = ()
  }

  fileprivate let categoryCellTappedProperty = MutableProperty<KsApi.RootCategoriesEnvelope.Category?>(nil)
  public func categoryCellTapped(_ category: KsApi.RootCategoriesEnvelope.Category) {
    categoryCellTappedProperty.value = category
  }

  fileprivate let projectProperty = MutableProperty<Project?>(nil)
  public func project(_ project: Project) {
    projectProperty.value = project
  }

  fileprivate let projectTappedProperty = MutableProperty<Project?>(nil)
  public func projectTapped(_ project: Project) {
    projectTappedProperty.value = project
  }

  fileprivate let gamesNewsletterSignupButtonTappedProperty = MutableProperty()
  public func gamesNewsletterSignupButtonTapped() {
    gamesNewsletterSignupButtonTappedProperty.value = ()
  }

  fileprivate let facebookIsAvailableProperty = MutableProperty(false)
  public func facebookIsAvailable(_ available: Bool) {
    self.facebookIsAvailableProperty.value = available
  }

  fileprivate let rateNowButtonTappedProperty = MutableProperty()
  public func rateNowButtonTapped() {
    rateNowButtonTappedProperty.value = ()
  }

  fileprivate let rateRemindLaterButtonTappedProperty = MutableProperty()
  public func rateRemindLaterButtonTapped() {
    rateRemindLaterButtonTappedProperty.value = ()
  }

  fileprivate let rateNoThanksButtonTappedProperty = MutableProperty()
  public func rateNoThanksButtonTapped() {
    rateNoThanksButtonTappedProperty.value = ()
  }

  fileprivate let twitterIsAvailableProperty = MutableProperty(false)
  public func twitterIsAvailable(_ available: Bool) {
    self.twitterIsAvailableProperty.value = available
  }

  fileprivate let userUpdatedProperty = MutableProperty()
  public func userUpdated() {
    userUpdatedProperty.value = ()
  }

  // MARK: ThanksViewModelOutputs
  public let dismissToRootViewController: Signal<(), NoError>
  public let goToDiscovery: Signal<DiscoveryParams, NoError>
  public let goToAppStoreRating: Signal<String, NoError>
  public let backedProjectText: Signal<NSAttributedString, NoError>
  public let facebookButtonIsHidden: Signal<Bool, NoError>
  public let goToProject: Signal<(Project, [Project], RefTag), NoError>
  public let showRatingAlert: Signal<(), NoError>
  public let showGamesNewsletterAlert: Signal<(), NoError>
  public let showGamesNewsletterOptInAlert: Signal<String, NoError>
  public let showRecommendations: Signal<([Project], KsApi.RootCategoriesEnvelope.Category), NoError>
  public let updateUserInEnvironment: Signal<User, NoError>
  public let postUserUpdatedNotification: Signal<Notification, NoError>
  public let twitterButtonIsHidden: Signal<Bool, NoError>
}

private func relatedProjects(toProject project: Project,
                             inCategory category: KsApi.RootCategoriesEnvelope.Category) ->
  SignalProducer<[Project], NoError> {

    let base = DiscoveryParams.lens.perPage .~ 3 <> DiscoveryParams.lens.backed .~ false

    let recommendedParams = DiscoveryParams.defaults |> base
      |> DiscoveryParams.lens.perPage .~ 6
      |> DiscoveryParams.lens.recommended .~ true

    let similarToParams = DiscoveryParams.defaults |> base
      |> DiscoveryParams.lens.similarTo .~ project

    let staffPickParams = DiscoveryParams.defaults |> base
      |> DiscoveryParams.lens.staffPicks .~ true
      |> DiscoveryParams.lens.category .~ category

    let recommendedProjects = AppEnvironment.current.apiService.fetchDiscovery(params: recommendedParams)
      .demoteErrors()
      .map { shuffle(projects: $0.projects) }
      .uncollect()

    let similarToProjects = AppEnvironment.current.apiService.fetchDiscovery(params: similarToParams)
      .demoteErrors()
      .map { $0.projects }
      .uncollect()

    let staffPickProjects = AppEnvironment.current.apiService.fetchDiscovery(params: staffPickParams)
      .demoteErrors()
      .map { $0.projects }
      .uncollect()

    return SignalProducer.concat(recommendedProjects, similarToProjects, staffPickProjects)
      .filter { $0.id != project.id }
      .uniqueValues { $0.id }
      .take(first: 3)
      .collect()
}

// Shuffle an array without mutating the input argument.
// Based on the Fisher-Yates shuffle algorithm https://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle.
private func shuffle(projects xs: [Project]) -> [Project] {
  var ys = xs
  let length = ys.count

  if length > 1 {
    for i in 0...length - 1 {
      let j = Int(arc4random_uniform(UInt32(length - 1)))
      let temp = ys[i]
      ys[i] = ys[j]
      ys[j] = temp
    }
    return ys

  } else {
    return xs
  }
}
