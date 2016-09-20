import KsApi
import Prelude
import ReactiveCocoa
import Result

public protocol ProjectMagazineViewModelInputs {
  /// Call when the back project button is tapped.
  func backProjectButtonTapped()

  /// Call with the project given to the view controller.
  func configureWith(projectOrParam projectOrParam: Either<Project, Param>, refTag: RefTag?)

  /// Call when the description should be expanded in the campaign tab.
  func expandDescription()

  /// Call when the manage pledge butotn is tapped.
  func managePledgeButtonTapped()

  /// Call when the campaign tab should be shown.
  func showCampaignTab()

  /// Call when the rewards tab should be shown.
  func showRewardsTab()

  /// Call when the star button is tapped.
  func starButtonTapped()

  /// Call when the NSNotification for user session ending has been posted.
  func userSessionEnded()

  /// Call when the NSNotification for user session starting has been posteed.
  func userSessionStarted()

  /// Call when the view loads.
  func viewDidLoad()

  /// Call when the view pledge button is tapped.
  func viewPledgeButtonTapped()
}

public protocol ProjectMagazineViewModelOutputs {
  /// Emits a boolean that determines if the "back project" button is hidden.
  var backProjectButtonHidden: Signal<Bool, NoError> { get }

  /// Emits a boolean that determines if the bottom share button should be hidden
  var bottomShareButtonHidden: Signal<Bool, NoError> { get }

  /// Emits a project that should be used to configure all children view controllers.
  var configureChildViewControllersWithProject: Signal<Project, NoError> { get }

  /// Emits a boolean that determines if the description view is hidden.
  var descriptionViewHidden: Signal<Bool, NoError> { get }

  /// Emits when the checkout screen should be shown to the user.
  var goToCheckout: Signal<(Project, NSURLRequest), NoError> { get }

  /// Emits when the login tout should be shown to the user.
  var goToLoginTout: Signal<(), NoError> { get }

  /// Emits when the backing screen should be shown to the user.
  var goToViewPledge: Signal<(Project, User), NoError> { get }

  /// Emits a boolean that determines if the "manage pledge" button is hidden.
  var managePledgeButtonHidden: Signal<Bool, NoError> { get }

  /// Emits when we should notify the description controller to expand.
  var notifyDescriptionToExpand: Signal<(), NoError> { get }

  /// Emits when the project has loaded.
  var project: Signal<Project, NoError> { get }

  /// Emits a boolean that determines if the rewards biew is hidden.
  var rewardsViewHidden: Signal<Bool, NoError> { get }

  /// Emits when the project has been successfully starred and a prompt should be shown to the user.
  var showProjectStarredPrompt: Signal<String, NoError> { get }

  /// Emits the accessibility hint for the star button.
  var starButtonAccessibilityHint: Signal<String, NoError> { get }

  /// Emits a boolean that determines if the star button is selected.
  var starButtonSelected: Signal<Bool, NoError> { get }

  /// Emits when the footer/header views should be transfered to the description controller.
  var transferFooterAndHeaderToDescriptionController: Signal<(), NoError> { get }

  /// Emits when the footer/header views should be transfered to the rewards controller.
  var transferFooterAndHeaderToRewardsController: Signal<(), NoError> { get }

  /// Emits a boolean that determines if the "view pledge" button is hidden.
  var viewPledgeButtonHidden: Signal<Bool, NoError> { get }
}

public protocol ProjectMagazineViewModelType {
  var inputs: ProjectMagazineViewModelInputs { get }
  var outputs: ProjectMagazineViewModelOutputs { get }
}

public final class ProjectMagazineViewModel: ProjectMagazineViewModelType, ProjectMagazineViewModelInputs,
ProjectMagazineViewModelOutputs {

  // swiftlint:disable function_body_length
  public init() {
    let currentUser = Signal.merge([
      self.viewDidLoadProperty.signal,
      self.userSessionStartedProperty.signal,
      self.userSessionEndedProperty.signal
      ])
      .map { AppEnvironment.current.currentUser }
      .skipRepeats(==)

    let loggedInUserTappedStar = currentUser
      .takeWhen(self.starButtonTappedProperty.signal)
      .filter(isNotNil)
      .ignoreValues()

    let loggedOutUserTappedStar = currentUser
      .takeWhen(self.starButtonTappedProperty.signal)
      .filter(isNil)
      .ignoreValues()

    // Emits only when a user logs in after having tapped the star while logged out.
    let userLoginAfterTappingStar = combineLatest(
      self.userSessionStartedProperty.signal,
      loggedOutUserTappedStar
      )
      .ignoreValues()
      .take(1)

    self.project = self.projectOrParamProperty.signal.ignoreNil()
      .takeWhen(self.viewDidLoadProperty.signal)
      .map { p in (p.left, p.ifLeft({ Param.id($0.id) }, ifRight: id)) }
      .switchMap { project, param -> SignalProducer<Project, NoError> in
        let fetchedProject = AppEnvironment.current.apiService.fetchProject(param: param)
          .delay(AppEnvironment.current.apiDelayInterval, onScheduler: AppEnvironment.current.scheduler)
          .demoteErrors()

        return project.map { fetchedProject.prefix(value: $0) } ?? fetchedProject
    }

    let starToggleLens = Project.lens.personalization.isStarred %~ { !($0 ?? false) }

    let projectOnStarToggle = self.project
      .takeWhen(.merge(loggedInUserTappedStar, userLoginAfterTappingStar))
      .scan(nil) { accum, project -> Project? in (accum ?? project) |> starToggleLens }
      .ignoreNil()

    let projectOnStarToggleAndSuccess = projectOnStarToggle
      .switchMap { project in
        AppEnvironment.current.apiService.toggleStar(project)
          .delay(AppEnvironment.current.apiDelayInterval, onScheduler: AppEnvironment.current.scheduler)
          .map { ($0.project, success: true) }
          .flatMapError { _ in .init(value: (project, success: false)) }
    }
    let projectOnStarToggleSuccess = projectOnStarToggleAndSuccess
      .filter(second)
      .map(first)

    let revertStarToggle = projectOnStarToggle
      .takeWhen(projectOnStarToggleAndSuccess.filter(negate • second))
      .map(starToggleLens)

    let managePledge = self.project
      .takeWhen(self.managePledgeButtonTappedProperty.signal)
      .map { project in
        NSURL(string: project.urls.web.project)
          .flatMap { optionalize($0.URLByAppendingPathComponent("pledge/edit")) }
          .map(NSURLRequest.init(URL:))
      }
      .ignoreNil()

    let backProject = self.project
      .takeWhen(self.backProjectButtonTappedProperty.signal)
      .map { project in
        NSURL(string: project.urls.web.project)
          .flatMap { optionalize($0.URLByAppendingPathComponent("pledge/new")) }
          .map(NSURLRequest.init(URL:))
      }
      .ignoreNil()

    self.goToCheckout = self.project
      .takePairWhen(Signal.merge(managePledge, backProject))

    self.goToLoginTout = loggedOutUserTappedStar

    self.configureChildViewControllersWithProject = self.project

    self.showProjectStarredPrompt = projectOnStarToggleSuccess
      .filter { $0.personalization.isStarred == true && !$0.endsIn48Hours }
      .map { _ in Strings.project_star_confirmation() }

    self.descriptionViewHidden = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst(false),
      self.showCampaignTabProperty.signal.mapConst(false),
      self.showRewardsTabProperty.signal.mapConst(true)
      )
      .skipRepeats()

    self.rewardsViewHidden = self.descriptionViewHidden.map(negate)

    self.transferFooterAndHeaderToDescriptionController = self.descriptionViewHidden
      .filter(isFalse)
      .ignoreValues()

    self.transferFooterAndHeaderToRewardsController = self.rewardsViewHidden
      .filter(isFalse)
      .ignoreValues()

    self.notifyDescriptionToExpand = self.expandDescriptionProperty.signal

    let project = Signal
      .merge(self.project, projectOnStarToggle, projectOnStarToggleSuccess, revertStarToggle)

    self.starButtonSelected = project
      .map { $0.personalization.isStarred == true }
      .skipRepeats()

    self.starButtonAccessibilityHint = self.starButtonSelected
      .map { starred in
        starred
          ? Strings.Unstars_project()
          : Strings.Stars_projects()
    }

    self.backProjectButtonHidden = project
      .map(backProjectButtonIsHidden(forProject:))
      .skipRepeats()

    self.managePledgeButtonHidden = project
      .map(managePledgeButtonIsHidden(forProject:))
      .skipRepeats()

    self.bottomShareButtonHidden = project
      .map(shareButtonIsHidden(forProject:))
      .skipRepeats()

    self.viewPledgeButtonHidden = project
      .map(viewPledgeButtonIsHidden(forProject:))
      .skipRepeats()

    let cookieRefTag = combineLatest(
      project.map(cookieRefTagFor(project:)),
      self.refTagProperty.signal
      )
      .take(1)
      .map { $0 ?? $1 }

    combineLatest(project, self.refTagProperty.signal, cookieRefTag)
      .take(1)
      .observeNext { project, refTag, cookieRefTag in
        AppEnvironment.current.koala.trackProjectShow(project, refTag: refTag, cookieRefTag: cookieRefTag)
    }

    self.goToViewPledge = combineLatest(project, currentUser.ignoreNil())
      .takeWhen(self.viewPledgeButtonTappedProperty.signal)

    projectOnStarToggleSuccess
      .observeNext { AppEnvironment.current.koala.trackProjectStar($0) }

    combineLatest(cookieRefTag.ignoreNil(), project)
      .take(1)
      .map(cookieFrom(refTag:project:))
      .ignoreNil()
      .observeNext { AppEnvironment.current.cookieStorage.setCookie($0) }
  }
  // swiftlint:enable function_body_length

  private let projectOrParamProperty = MutableProperty<Either<Project, Param>?>(nil)
  private let refTagProperty = MutableProperty<RefTag?>(nil)
  public func configureWith(projectOrParam projectOrParam: Either<Project, Param>, refTag: RefTag?) {
    self.projectOrParamProperty.value = projectOrParam
    self.refTagProperty.value = refTag
  }

  private let expandDescriptionProperty = MutableProperty()
  public func expandDescription() {
    self.expandDescriptionProperty.value = ()
  }

  private let backProjectButtonTappedProperty = MutableProperty()
  public func backProjectButtonTapped() {
    self.backProjectButtonTappedProperty.value = ()
  }

  private let showCampaignTabProperty = MutableProperty()
  public func showCampaignTab() {
    self.showCampaignTabProperty.value = ()
  }

  private let showRewardsTabProperty = MutableProperty()
  public func showRewardsTab() {
    self.showRewardsTabProperty.value = ()
  }

  private let starButtonTappedProperty = MutableProperty()
  public func starButtonTapped() {
    self.starButtonTappedProperty.value = ()
  }

  private let userSessionEndedProperty = MutableProperty()
  public func userSessionEnded() {
    self.userSessionEndedProperty.value = ()
  }

  private let userSessionStartedProperty = MutableProperty()
  public func userSessionStarted() {
    self.userSessionStartedProperty.value = ()
  }

  private let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  private let viewPledgeButtonTappedProperty = MutableProperty()
  public func viewPledgeButtonTapped() {
    self.viewPledgeButtonTappedProperty.value = ()
  }

  private let managePledgeButtonTappedProperty = MutableProperty()
  public func managePledgeButtonTapped() {
    self.managePledgeButtonTappedProperty.value = ()
  }

  public let backProjectButtonHidden: Signal<Bool, NoError>
  public let bottomShareButtonHidden: Signal<Bool, NoError>
  public let configureChildViewControllersWithProject: Signal<Project, NoError>
  public let descriptionViewHidden: Signal<Bool, NoError>
  public let goToCheckout: Signal<(Project, NSURLRequest), NoError>
  public let goToLoginTout: Signal<(), NoError>
  public let goToViewPledge: Signal<(Project, User), NoError>
  public let managePledgeButtonHidden: Signal<Bool, NoError>
  public let notifyDescriptionToExpand: Signal<(), NoError>
  public let project: Signal<Project, NoError>
  public let rewardsViewHidden: Signal<Bool, NoError>
  public let showProjectStarredPrompt: Signal<String, NoError>
  public let starButtonAccessibilityHint: Signal<String, NoError>
  public let starButtonSelected: Signal<Bool, NoError>
  public let transferFooterAndHeaderToDescriptionController: Signal<(), NoError>
  public let transferFooterAndHeaderToRewardsController: Signal<(), NoError>
  public let viewPledgeButtonHidden: Signal<Bool, NoError>

  public var inputs: ProjectMagazineViewModelInputs { return self }
  public var outputs: ProjectMagazineViewModelOutputs { return self }
}

private let cookieSeparator = Character("?")

// Extracts the ref tag stored in cookies for a particular project. Returns `nil` if no such cookie has
// been previously set.
private func cookieRefTagFor(project project: Project) -> RefTag? {

  return AppEnvironment.current.cookieStorage.cookies?
    .filter { cookie in cookie.name == cookieName(project) }
    .first
    .flatMap { cookie in cookie.value.characters.split(cookieSeparator).first }
    .flatMap(String.init)
    .flatMap(RefTag.init(code:))
}

// Derives the name of the ref cookie from the project.
private func cookieName(project: Project) -> String {
  return "ref_\(project.id)"
}

// Constructs a cookie from a ref tag and project.
private func cookieFrom(refTag refTag: RefTag, project: Project) -> NSHTTPCookie? {

  let timestamp = Int(NSDate().timeIntervalSince1970)

  var properties: [String:AnyObject] = [:]
  properties[NSHTTPCookieName]    = cookieName(project)
  properties[NSHTTPCookieValue]   = "\(refTag.stringTag)\(cookieSeparator)\(timestamp)"
  properties[NSHTTPCookieDomain]  = NSURL(string: project.urls.web.project)?.host
  properties[NSHTTPCookiePath]    = NSURL(string: project.urls.web.project)?.path
  properties[NSHTTPCookieVersion] = 0
  properties[NSHTTPCookieExpires] = NSDate(timeIntervalSince1970: project.dates.deadline)

  return NSHTTPCookie(properties: properties)
}

private func backProjectButtonIsHidden(forProject project: Project) -> Bool {
  return project.state != .live || project.personalization.isBacking == true
}

private func managePledgeButtonIsHidden(forProject project: Project) -> Bool {
  return project.state != .live || project.personalization.isBacking != true
}

private func viewPledgeButtonIsHidden(forProject project: Project) -> Bool {
  return project.state == .live || project.personalization.isBacking != true
}

private func shareButtonIsHidden(forProject project: Project) -> Bool {
  return
    !backProjectButtonIsHidden(forProject: project)
      || !managePledgeButtonIsHidden(forProject: project)
      || !viewPledgeButtonIsHidden(forProject: project)
}
