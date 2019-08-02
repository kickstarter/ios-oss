import KsApi
import Prelude
import ReactiveSwift
public protocol ProjectPamphletViewModelInputs {
  /// Call when "Back this project" is tapped
  func backThisProjectTapped()

  /// Call with the project given to the view controller.
  func configureWith(projectOrParam: Either<Project, Param>, refTag: RefTag?)

  /// Call when the view loads.
  func viewDidLoad()

  /// Call after the view loads and passes the initial TopConstraint constant.
  func initial(topConstraint: CGFloat)

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
  var configurePledgeCTAView: Signal<(Project, Bool), Never> { get }

  /// Emits a project and refTag to be used to navigate to the reward selection screen.
  var goToRewards: Signal<(Project, RefTag?), Never> { get }

  /// Emits a project and refTag to be used to navigate to the deprecated reward selection screen.
  var goToDeprecatedRewards: Signal<(Project, RefTag?), Never> { get }

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

    let freshProjectAndRefTag = self.configDataProperty.signal.skipNil()
      .takePairWhen(Signal.merge(
        self.viewDidLoadProperty.signal.mapConst(true),
        self.viewDidAppearAnimated.signal.filter(isTrue).mapConst(false)
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
      }

    let goToRewards = freshProjectAndRefTag
      .takeWhen(self.backThisProjectTappedProperty.signal)
      .map { project, refTag in
        (project, refTag)
      }

    self.goToRewards = goToRewards
      .filter { _ in featureNativeCheckoutPledgeViewEnabled() }

    self.goToDeprecatedRewards = goToRewards
      .filter { _ in !featureNativeCheckoutPledgeViewEnabled() }

    let project = freshProjectAndRefTag
      .map(first)

    self.configurePledgeCTAView = Signal.combineLatest(
      project,
      isLoading.signal
    )
    .filter { _ in featureNativeCheckoutEnabled() }

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

    let cookieRefTag = freshProjectAndRefTag
      .map { project, refTag in
        cookieRefTagFor(project: project) ?? refTag
      }
      .take(first: 1)

    Signal.combineLatest(
      freshProjectAndRefTag,
      cookieRefTag,
      self.viewDidAppearAnimated.signal.ignoreValues()
    )
    .map { (project: $0.0, refTag: $0.1, cookieRefTag: $1, _: $2) }
    .take(first: 1)
    .observeValues { project, refTag, cookieRefTag, _ in
      AppEnvironment.current.koala.trackProjectShow(
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

  private let backThisProjectTappedProperty = MutableProperty(())
  public func backThisProjectTapped() {
    self.backThisProjectTappedProperty.value = ()
  }

  private let configDataProperty = MutableProperty<(Either<Project, Param>, RefTag?)?>(nil)
  public func configureWith(projectOrParam: Either<Project, Param>, refTag: RefTag?) {
    self.configDataProperty.value = (projectOrParam, refTag)
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
  public let configurePledgeCTAView: Signal<(Project, Bool), Never>
  public let goToDeprecatedRewards: Signal<(Project, RefTag?), Never>
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
  -> SignalProducer<Project, Never> {
  let param = projectOrParam.ifLeft({ Param.id($0.id) }, ifRight: id)

  let projectProducer = AppEnvironment.current.apiService.fetchProject(param: param)
    .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
    .demoteErrors()

  if let project = projectOrParam.left, shouldPrefix {
    return projectProducer.prefix(value: project)
  }

  return projectProducer
}
