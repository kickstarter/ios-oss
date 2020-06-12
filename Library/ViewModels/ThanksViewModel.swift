import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public typealias ThanksPageData = (
  project: Project, reward: Reward,
  checkoutData: Koala.CheckoutPropertiesData?
)

public protocol ThanksViewModelInputs {
  /// Call to configure the VM
  func configure(with data: ThanksPageData)

  /// Call when close button is tapped
  func closeButtonTapped()

  /// Call when category cell is tapped
  func categoryCellTapped(_ category: KsApi.Category)

  /// Call when project cell is tapped
  func projectTapped(_ project: Project)

  /// Call when signup button is tapped on games newsletter alert
  func gamesNewsletterSignupButtonTapped()

  /// Call when the current user has been updated in the environment
  func userUpdated()

  /// Call when the view controller view did load
  func viewDidLoad()
}

public protocol ThanksViewModelOutputs {
  /// Emits backed project subheader text to display
  var backedProjectText: Signal<NSAttributedString, Never> { get }

  /// Emits when view controller should dismiss
  var dismissToRootViewControllerAndPostNotification: Signal<Notification, Never> { get }

  /// Emits DiscoveryParams when should go to Discovery
  var goToDiscovery: Signal<DiscoveryParams, Never> { get }

  /// Emits project when should go to Project page
  var goToProject: Signal<(Project, [Project], RefTag), Never> { get }

  /// Emits when a user pledges a project for the first time.
  var postContextualNotification: Signal<(), Never> { get }

  /// Emits when a user updated notification should be posted
  var postUserUpdatedNotification: Signal<Notification, Never> { get }

  /// Emits when should show games newsletter alert
  var showGamesNewsletterAlert: Signal<(), Never> { get }

  /// Emits newsletter title when should show games newsletter opt-in alert
  var showGamesNewsletterOptInAlert: Signal<String, Never> { get }

  /// Emits when should show rating alert
  var showRatingAlert: Signal<(), Never> { get }

  /// Emits array of projects and a category when should show recommendations
  var showRecommendations: Signal<([Project], KsApi.Category, OptimizelyExperiment.Variant), Never> { get }

  /// Emits a User that can be used to replace the current user in the environment
  var updateUserInEnvironment: Signal<User, Never> { get }
}

public protocol ThanksViewModelType {
  var inputs: ThanksViewModelInputs { get }
  var outputs: ThanksViewModelOutputs { get }
}

public final class ThanksViewModel: ThanksViewModelType, ThanksViewModelInputs, ThanksViewModelOutputs {
  public init() {
    let project = self.configureWithDataProperty.signal
      .skipNil()
      .map(first)

    self.backedProjectText = project.map {
      let string = Strings.You_have_successfully_backed_project_html(
        project_name: $0.name
      )

      return string.simpleHtmlAttributedString(font: UIFont.ksr_subhead(), bold: UIFont.ksr_subhead().bolded)
        ?? NSAttributedString(string: "")
    }
    .takeWhen(self.viewDidLoadProperty.signal)

    let shouldShowGamesAlert = project
      .map { project in
        project.category.rootId == KsApi.Category.gamesId &&
          !(AppEnvironment.current.currentUser?.newsletters.games ?? false) &&
          !AppEnvironment.current.userDefaults.hasSeenGamesNewsletterPrompt
      }

    self.showGamesNewsletterAlert = shouldShowGamesAlert
      .filter(isTrue)
      .takeWhen(self.viewDidLoadProperty.signal)
      .ignoreValues()

    self.showGamesNewsletterOptInAlert = self.gamesNewsletterSignupButtonTappedProperty.signal
      .filter { AppEnvironment.current.countryCode == "DE" }
      .map(Strings.profile_settings_newsletter_games)

    self.showRatingAlert = shouldShowGamesAlert
      .filter {
        $0 == false &&
          !AppEnvironment.current.userDefaults.hasSeenAppRating &&
          AppEnvironment.current.config?.iTunesLink != nil && shouldShowPledgeDialog() == false
      }
      .takeWhen(self.viewDidLoadProperty.signal)
      .ignoreValues()
      .on(value: { AppEnvironment.current.userDefaults.hasSeenAppRating = true })

    self.dismissToRootViewControllerAndPostNotification = self.closeButtonTappedProperty.signal
      .mapConst(Notification(name: .ksr_projectBacked))

    self.goToDiscovery = self.categoryCellTappedProperty.signal.skipNil()
      .map {
        DiscoveryParams.defaults |> DiscoveryParams.lens.category .~ $0
      }

    let rootCategory: Signal<KsApi.Category, Never> = project
      .map { toBase64($0.category) }
      .flatMap {
        AppEnvironment.current.apiService.fetchGraphCategory(query: categoryBy(id: $0))
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .map { (categoryEnvelope: KsApi.CategoryEnvelope) -> KsApi.Category
            in categoryEnvelope.node.parent ?? categoryEnvelope.node
          }
          .demoteErrors()
      }

    let projects = Signal.combineLatest(project, rootCategory)
      .flatMap { relatedProjects(toProject: $0.0, inCategory: $0.1) }
      .filter { projects in !projects.isEmpty }

    self.showRecommendations = Signal.zip(projects, rootCategory).map { projects, category in
      let variant = OptimizelyExperiment.nativeProjectCardsExperimentVariant()

      return (projects, category, variant)
    }

    self.goToProject = self.showRecommendations
      .map(first)
      .takePairWhen(self.projectTappedProperty.signal.skipNil())
      .map { projects, project in (project, projects, RefTag.thanks) }

    self.updateUserInEnvironment = self.gamesNewsletterSignupButtonTappedProperty.signal
      .map { AppEnvironment.current.currentUser ?? nil }
      .skipNil()
      .switchMap { user in
        AppEnvironment.current.apiService.updateUserSelf(user |> \.newsletters.games .~ true)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .demoteErrors()
      }

    self.postContextualNotification = self.viewDidLoadProperty.signal
      .filter { shouldShowPledgeDialog() }

    self.postUserUpdatedNotification = self.userUpdatedProperty.signal
      .mapConst(Notification(name: .ksr_userUpdated))

    self.showGamesNewsletterAlert
      .observeValues { AppEnvironment.current.userDefaults.hasSeenGamesNewsletterPrompt = true }

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
      .takeWhen(self.showRatingAlert)
      .observeValues { project in
        AppEnvironment.current.koala.trackTriggeredAppStoreRatingDialog(project: project)
      }

    self.projectTappedProperty.signal.skipNil().map { project in
      (project, recommendedParams)
    }.observeValues { project, params in
      let optyProperties = optimizelyProperties() ?? [:]

      AppEnvironment.current.koala.trackProjectCardClicked(
        project: project,
        params: params,
        location: .thanks,
        optimizelyProperties: optyProperties
      )

      AppEnvironment.current.optimizelyClient?.track(eventName: "Project Card Clicked")
    }

    Signal.combineLatest(
      self.configureWithDataProperty.signal.skipNil(),
      self.viewDidLoadProperty.signal.ignoreValues()
    )
    .map(first)
    .observeValues { AppEnvironment.current.koala.trackThanksPageViewed(
      project: $0.project,
      reward: $0.reward,
      checkoutData: $0.checkoutData
    ) }
  }

  // MARK: - ThanksViewModelType

  public var inputs: ThanksViewModelInputs { return self }
  public var outputs: ThanksViewModelOutputs { return self }

  // MARK: - ThanksViewModelInputs

  fileprivate let configureWithDataProperty = MutableProperty<ThanksPageData?>(nil)
  public func configure(with data: ThanksPageData) {
    self.configureWithDataProperty.value = data
  }

  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  fileprivate let closeButtonTappedProperty = MutableProperty(())
  public func closeButtonTapped() {
    self.closeButtonTappedProperty.value = ()
  }

  fileprivate let categoryCellTappedProperty = MutableProperty<KsApi.Category?>(nil)
  public func categoryCellTapped(_ category: KsApi.Category) {
    self.categoryCellTappedProperty.value = category
  }

  fileprivate let projectProperty = MutableProperty<Project?>(nil)
  public func project(_ project: Project) {
    self.projectProperty.value = project
  }

  fileprivate let projectTappedProperty = MutableProperty<Project?>(nil)
  public func projectTapped(_ project: Project) {
    self.projectTappedProperty.value = project
  }

  fileprivate let gamesNewsletterSignupButtonTappedProperty = MutableProperty(())
  public func gamesNewsletterSignupButtonTapped() {
    self.gamesNewsletterSignupButtonTappedProperty.value = ()
  }

  fileprivate let userUpdatedProperty = MutableProperty(())
  public func userUpdated() {
    self.userUpdatedProperty.value = ()
  }

  // MARK: - ThanksViewModelOutputs

  public let dismissToRootViewControllerAndPostNotification: Signal<Notification, Never>
  public let goToDiscovery: Signal<DiscoveryParams, Never>
  public let backedProjectText: Signal<NSAttributedString, Never>
  public let goToProject: Signal<(Project, [Project], RefTag), Never>
  public let postContextualNotification: Signal<(), Never>
  public let postUserUpdatedNotification: Signal<Notification, Never>
  public let showRatingAlert: Signal<(), Never>
  public let showGamesNewsletterAlert: Signal<(), Never>
  public let showGamesNewsletterOptInAlert: Signal<String, Never>
  public let showRecommendations: Signal<([Project], KsApi.Category, OptimizelyExperiment.Variant), Never>
  public let updateUserInEnvironment: Signal<User, Never>
}

/*
 This is a work around that fixes the incompatibility between the types of category id returned by
 the server (Int) and the type we need to send when requesting category by id
 through GraphQL (base64 encoded String). This will be removed once we start consuming GraphQL to fetch
 Discovery projects.

 */
private func toBase64(_ category: Project.Category) -> String {
  let id = category.parentId ?? category.id
  let decodedId = Category.decode(id: "\(id)")
  return decodedId.toBase64()
}

private func relatedProjects(
  toProject project: Project,
  inCategory category: KsApi.Category
) ->
  SignalProducer<[Project], Never> {
  let base = DiscoveryParams.lens.perPage .~ 3 <> DiscoveryParams.lens.backed .~ false

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

private func shouldShowPledgeDialog() -> Bool {
  return PushNotificationDialog.canShowDialog(for: .pledge) &&
    AppEnvironment.current.currentUser?.stats.backedProjectsCount == 0
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

private let recommendedParams = DiscoveryParams.defaults
  |> DiscoveryParams.lens.backed .~ false
  |> DiscoveryParams.lens.perPage .~ 6
  |> DiscoveryParams.lens.recommended .~ true
