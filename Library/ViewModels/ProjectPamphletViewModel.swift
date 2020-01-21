import KsApi
import Prelude
import ReactiveSwift

public typealias BackingData = (Project, User?)

public protocol ProjectPamphletViewModelInputs {
  /// Call with the project given to the view controller.
  func configureWith(projectOrParam: Either<Project, Param>, refTag: RefTag?)

  /// Call when the view loads.
  func viewDidLoad()

  /// Call after the view loads and passes the initial TopConstraint constant.
  func initial(topConstraint: CGFloat)

  /// Call when the Thank you page is dismissed after finishing backing the project
  func didBackProject()

  /// Call when the ManagePledgeViewController finished updating/cancelling a pledge with an optional message
  func managePledgeViewControllerFinished(with message: String?)

  /// Call when the pledge CTA button is tapped
  func pledgeCTAButtonTapped(with state: PledgeStateCTAType)

  /// Call when pledgeRetryButton is tapped.
  func pledgeRetryButtonTapped()

  /// Call when the view did appear, and pass the animated parameter.
  func viewDidAppear(animated: Bool)

  /// Call when the view will appear, and pass the animated parameter.
  func viewWillAppear(animated: Bool)

  /// Call when the view will transition to a new trait collection.
  func willTransition(toNewCollection collection: UITraitCollection)
}

public protocol ProjectPamphletViewModelOutputs {
  /// Emits a project that should be used to configure all children view controllers.
  var configureChildViewControllersWithProject: Signal<(Project, RefTag?), Never> { get }

  /// Emits a (project, isLoading) tuple used to configure the pledge CTA view
  var configurePledgeCTAView: Signal<(Either<Project, ErrorEnvelope>, Bool), Never> { get }

  var dismissManagePledgeAndShowMessageBannerWithMessage: Signal<String, Never> { get }

  var goToDeprecatedManagePledge: Signal<PledgeData, Never> { get }

  var goToDeprecatedViewBacking: Signal<BackingData, Never> { get }

  var goToManagePledge: Signal<Project, Never> { get }

  /// Emits a project and refTag to be used to navigate to the reward selection screen.
  var goToRewards: Signal<(Project, RefTag?), Never> { get }

  /// Emits two booleans that determine if the navigation bar should be hidden, and if it should be animated.
  var setNavigationBarHiddenAnimated: Signal<(Bool, Bool), Never> { get }

  /// Emits when the `setNeedsStatusBarAppearanceUpdate` method should be called on the view.
  var setNeedsStatusBarAppearanceUpdate: Signal<(), Never> { get }

  /// Emits a float to update topLayoutConstraints constant.
  var topLayoutConstraintConstant: Signal<CGFloat, Never> { get }
}

public protocol ProjectPamphletViewModelType {
  var inputs: ProjectPamphletViewModelInputs { get }
  var outputs: ProjectPamphletViewModelOutputs { get }
}

public final class ProjectPamphletViewModel: ProjectPamphletViewModelType, ProjectPamphletViewModelInputs,
  ProjectPamphletViewModelOutputs {
  public init() {
    let isLoading = MutableProperty(false)

    let freshProjectAndRefTagEvent = self.configDataProperty.signal.skipNil()
      .takePairWhen(Signal.merge(
        self.viewDidLoadProperty.signal.mapConst(true),
        self.didBackProjectProperty.signal.ignoreValues().mapConst(false),
        self.managePledgeViewControllerFinishedWithMessageProperty.signal.ignoreValues().mapConst(false),
        self.pledgeRetryButtonTappedProperty.signal.mapConst(false)
      ))
      .map(unpack)
      .switchMap { projectOrParam, refTag, shouldPrefix in

        fetchProject(projectOrParam: projectOrParam, shouldPrefix: shouldPrefix)
          .on(
            starting: { isLoading.value = true },
            terminated: { isLoading.value = false }
          )
          .map { project in
            (project, refTag.map(cleanUp(refTag:)))
          }
          .materialize()
      }

    let freshProjectAndRefTag = freshProjectAndRefTagEvent.values()

    let project = freshProjectAndRefTag
      .map(first)
    let refTag = freshProjectAndRefTag
      .map(second)

    let projectAndBacking = project
      .filter { $0.personalization.isBacking ?? false }
      .filterMap { project -> (Project, Backing)? in
        guard let backing = project.personalization.backing else {
          return nil
        }

        return (project, backing)
      }

    let ctaButtonTappedWithType = self.pledgeCTAButtonTappedProperty.signal
      .skipNil()

    let shouldGoToRewards = ctaButtonTappedWithType
      .filter { [.pledge, .viewRewards, .viewYourRewards, .seeTheRewards, .viewTheRewards].contains($0) }
      .ignoreValues()
      .filter(userCanSeeNativeCheckout)

    let shouldGoToDeprecatedManagePledge = ctaButtonTappedWithType
      .filter { $0 == .manage }
      .ignoreValues()
      .filter(featureNativeCheckoutPledgeViewIsEnabled >>> isFalse)

    let shouldGoToDeprecatedViewBacking = ctaButtonTappedWithType
      .filter { $0 == .viewBacking }
      .ignoreValues()
      .filter(featureNativeCheckoutPledgeViewIsEnabled >>> isFalse)

    let shouldGoToManagePledge = ctaButtonTappedWithType
      .filter { $0 == .viewBacking || $0 == .manage }
      .ignoreValues()
      .filter(featureNativeCheckoutPledgeViewIsEnabled)

    self.goToRewards = freshProjectAndRefTag
      .takeWhen(shouldGoToRewards)

    self.goToManagePledge = projectAndBacking
      .takeWhen(shouldGoToManagePledge)
      .map(first)

    self.goToDeprecatedManagePledge = Signal.combineLatest(projectAndBacking, refTag)
      .takeWhen(shouldGoToDeprecatedManagePledge)
      .map(unpack)
      .map { project, backing, refTag in
        PledgeData(project: project, reward: reward(from: backing, inProject: project), refTag: refTag)
      }

    self.goToDeprecatedViewBacking = projectAndBacking
      .takeWhen(shouldGoToDeprecatedViewBacking)
      .map { project, _ in
        BackingData(project, AppEnvironment.current.currentUser)
      }

    let projectCTA: Signal<Either<Project, ErrorEnvelope>, Never> = project
      .map { .left($0) }

    let projectError: Signal<Either<Project, ErrorEnvelope>, Never> = freshProjectAndRefTagEvent.errors()
      .map { .right($0) }

    self.configurePledgeCTAView = Signal.combineLatest(
      Signal.merge(projectCTA, projectError),
      isLoading.signal
    )
    .filter { _ in userCanSeeNativeCheckout() }

    self.configureChildViewControllersWithProject = freshProjectAndRefTag
      .map { project, refTag in (project, refTag) }

    self.setNeedsStatusBarAppearanceUpdate = Signal.merge(
      self.viewWillAppearAnimated.signal.ignoreValues(),
      self.willTransitionToCollectionProperty.signal.ignoreValues()
    )

    self.setNavigationBarHiddenAnimated = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst((true, false)),
      self.viewWillAppearAnimated.signal.skip(first: 1).map { (true, $0) }
    )

    self.topLayoutConstraintConstant = self.initialTopConstraintProperty.signal.skipNil()
      .takePairWhen(self.willTransitionToCollectionProperty.signal.skipNil())
      .map(layoutConstraintConstant(initialTopConstraint:traitCollection:))

    self.dismissManagePledgeAndShowMessageBannerWithMessage
      = self.managePledgeViewControllerFinishedWithMessageProperty.signal
      .skipNil()

    let cookieRefTag = freshProjectAndRefTag
      .map { project, refTag in
        cookieRefTagFor(project: project) ?? refTag
      }
      .take(first: 1)

    Signal.zip(
      freshProjectAndRefTag.skip(first: 1),
      self.viewDidAppearAnimated.signal.ignoreValues()
    )
    .map(unpack)
    .map { project, refTag, _ in
      let cookieRefTag = cookieRefTagFor(project: project) ?? refTag

      return (project: project, refTag: refTag, cookieRefTag: cookieRefTag)
    }
    .observeValues { project, refTag, cookieRefTag in
      AppEnvironment.current.koala.trackProjectViewed(
        project,
        refTag: refTag,
        cookieRefTag: cookieRefTag
      )
    }

    Signal.combineLatest(cookieRefTag.skipNil(), freshProjectAndRefTag.map(first))
      .take(first: 1)
      .map(cookieFrom(refTag:project:))
      .skipNil()
      .observeValues { AppEnvironment.current.cookieStorage.setCookie($0) }
  }

  private let configDataProperty = MutableProperty<(Either<Project, Param>, RefTag?)?>(nil)
  public func configureWith(projectOrParam: Either<Project, Param>, refTag: RefTag?) {
    self.configDataProperty.value = (projectOrParam, refTag)
  }

  private let didBackProjectProperty = MutableProperty<Void>(())
  public func didBackProject() {
    self.didBackProjectProperty.value = ()
  }

  private let managePledgeViewControllerFinishedWithMessageProperty = MutableProperty<String?>(nil)
  public func managePledgeViewControllerFinished(with message: String?) {
    self.managePledgeViewControllerFinishedWithMessageProperty.value = message
  }

  private let pledgeCTAButtonTappedProperty = MutableProperty<PledgeStateCTAType?>(nil)
  public func pledgeCTAButtonTapped(with state: PledgeStateCTAType) {
    self.pledgeCTAButtonTappedProperty.value = state
  }

  private let pledgeRetryButtonTappedProperty = MutableProperty(())
  public func pledgeRetryButtonTapped() {
    self.pledgeRetryButtonTappedProperty.value = ()
  }

  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  fileprivate let initialTopConstraintProperty = MutableProperty<CGFloat?>(nil)
  public func initial(topConstraint: CGFloat) {
    self.initialTopConstraintProperty.value = topConstraint
  }

  fileprivate let viewDidAppearAnimated = MutableProperty(false)
  public func viewDidAppear(animated: Bool) {
    self.viewDidAppearAnimated.value = animated
  }

  fileprivate let viewWillAppearAnimated = MutableProperty(false)
  public func viewWillAppear(animated: Bool) {
    self.viewWillAppearAnimated.value = animated
  }

  fileprivate let willTransitionToCollectionProperty =
    MutableProperty<UITraitCollection?>(nil)
  public func willTransition(toNewCollection collection: UITraitCollection) {
    self.willTransitionToCollectionProperty.value = collection
  }

  public let configureChildViewControllersWithProject: Signal<(Project, RefTag?), Never>
  public let configurePledgeCTAView: Signal<(Either<Project, ErrorEnvelope>, Bool), Never>
  public let dismissManagePledgeAndShowMessageBannerWithMessage: Signal<String, Never>
  public let goToDeprecatedManagePledge: Signal<PledgeData, Never>
  public let goToDeprecatedViewBacking: Signal<BackingData, Never>
  public let goToManagePledge: Signal<Project, Never>
  public let goToRewards: Signal<(Project, RefTag?), Never>
  public let setNavigationBarHiddenAnimated: Signal<(Bool, Bool), Never>
  public let setNeedsStatusBarAppearanceUpdate: Signal<(), Never>
  public let topLayoutConstraintConstant: Signal<CGFloat, Never>

  public var inputs: ProjectPamphletViewModelInputs { return self }
  public var outputs: ProjectPamphletViewModelOutputs { return self }
}

private let cookieSeparator = "?"
private let escapedCookieSeparator = "%3F"

private func layoutConstraintConstant(
  initialTopConstraint: CGFloat,
  traitCollection: UITraitCollection
) -> CGFloat {
  guard !traitCollection.isRegularRegular else {
    return 0.0
  }

  return traitCollection.isVerticallyCompact ? 0.0 : initialTopConstraint
}

// Extracts the ref tag stored in cookies for a particular project. Returns `nil` if no such cookie has
// been previously set.
private func cookieRefTagFor(project: Project) -> RefTag? {
  return AppEnvironment.current.cookieStorage.cookies?
    .filter { cookie in cookie.name == cookieName(project) }
    .first
    .map(refTagName(fromCookie:))
    .flatMap(RefTag.init(code:))
}

// Derives the name of the ref cookie from the project.
private func cookieName(_ project: Project) -> String {
  return "ref_\(project.id)"
}

// Tries to extract the name of the ref tag from a cookie. It has to do double work in case the cookie
// is accidentally encoded with a `%3F` instead of a `?`.
private func refTagName(fromCookie cookie: HTTPCookie) -> String {
  return cleanUp(refTagString: cookie.value)
}

// Tries to remove cruft from a ref tag.
private func cleanUp(refTag: RefTag) -> RefTag {
  return RefTag(code: cleanUp(refTagString: refTag.stringTag))
}

// Tries to remove cruft from a ref tag string.
private func cleanUp(refTagString: String) -> String {
  let secondPass = refTagString.components(separatedBy: escapedCookieSeparator)
  if let name = secondPass.first, secondPass.count == 2 {
    return String(name)
  }

  let firstPass = refTagString.components(separatedBy: cookieSeparator)
  if let name = firstPass.first, firstPass.count == 2 {
    return String(name)
  }

  return refTagString
}

// Constructs a cookie from a ref tag and project.
private func cookieFrom(refTag: RefTag, project: Project) -> HTTPCookie? {
  let timestamp = Int(AppEnvironment.current.scheduler.currentDate.timeIntervalSince1970)

  var properties: [HTTPCookiePropertyKey: Any] = [:]
  properties[.name] = cookieName(project)
  properties[.value] = "\(refTag.stringTag)\(cookieSeparator)\(timestamp)"
  properties[.domain] = URL(string: project.urls.web.project)?.host
  properties[.path] = URL(string: project.urls.web.project)?.path
  properties[.version] = 0
  properties[.expires] = AppEnvironment.current.dateType
    .init(timeIntervalSince1970: project.dates.deadline).date

  return HTTPCookie(properties: properties)
}

private func fetchProject(projectOrParam: Either<Project, Param>, shouldPrefix: Bool)
  -> SignalProducer<Project, ErrorEnvelope> {
  let param = projectOrParam.ifLeft({ Param.id($0.id) }, ifRight: id)

  let projectProducer = AppEnvironment.current.apiService.fetchProject(param: param)
    .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)

  if let project = projectOrParam.left, shouldPrefix {
    return projectProducer.prefix(value: project)
  }

  return projectProducer
}
