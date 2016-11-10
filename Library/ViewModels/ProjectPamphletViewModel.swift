import KsApi
import Prelude
import ReactiveCocoa
import Result

public protocol ProjectPamphletViewModelInputs {
  /// Call with the project given to the view controller.
  func configureWith(projectOrParam projectOrParam: Either<Project, Param>, refTag: RefTag?)

  /// Call when the view loads.
  func viewDidLoad()

  func viewDidAppear(animated animated: Bool)

  /// Call when the view will appear, and pass the animated parameter.
  func viewWillAppear(animated animated: Bool)
}

public protocol ProjectPamphletViewModelOutputs {
  /// Emits a project that should be used to configure all children view controllers.
  var configureChildViewControllersWithProject: Signal<Project, NoError> { get }

  /// Return this value from the view's `prefersStatusBarHidden` method.
  var prefersStatusBarHidden: Bool { get }

  /// Emits two booleans that determine if the navigation bar should be hidden, and if it should be animated.
  var setNavigationBarHiddenAnimated: Signal<(Bool, Bool), NoError> { get }

  /// Emits when the `setNeedsStatusBarAppearanceUpdate` method should be called on the view.
  var setNeedsStatusBarAppearanceUpdate: Signal<(), NoError> { get }
}

public protocol ProjectPamphletViewModelType {
  var inputs: ProjectPamphletViewModelInputs { get }
  var outputs: ProjectPamphletViewModelOutputs { get }
}

public final class ProjectPamphletViewModel: ProjectPamphletViewModelType, ProjectPamphletViewModelInputs,
ProjectPamphletViewModelOutputs {

  public init() {
    let projectOrParam = combineLatest(
      self.projectOrParamProperty.signal.ignoreNil(),
      self.viewDidLoadProperty.signal
      )
      .map(first)

    let project = projectOrParam
      .map { p in (p.left, p.ifLeft({ Param.id($0.id) }, ifRight: id)) }
      .switchMap { project, param -> SignalProducer<Project, NoError> in
        AppEnvironment.current.apiService.fetchProject(param: param)
          .delay(AppEnvironment.current.apiDelayInterval, onScheduler: AppEnvironment.current.scheduler)
          .demoteErrors()
          .wrapInOptional()
          .prefix(value: project)
          .ignoreNil()
    }

    self.configureChildViewControllersWithProject = project

    self.prefersStatusBarHiddenProperty <~ self.viewWillAppearAnimated.signal.mapConst(true)

    self.setNeedsStatusBarAppearanceUpdate = self.viewWillAppearAnimated.signal.ignoreValues()

    self.setNavigationBarHiddenAnimated = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst((true, false)),
      self.viewWillAppearAnimated.signal.skip(1).map { (true, $0) }
    )

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

    combineLatest(cookieRefTag.ignoreNil(), project)
      .take(1)
      .map(cookieFrom(refTag:project:))
      .ignoreNil()
      .observeNext { AppEnvironment.current.cookieStorage.setCookie($0) }
  }

  private let projectOrParamProperty = MutableProperty<Either<Project, Param>?>(nil)
  private let refTagProperty = MutableProperty<RefTag?>(nil)
  public func configureWith(projectOrParam projectOrParam: Either<Project, Param>, refTag: RefTag?) {
    self.projectOrParamProperty.value = projectOrParam
    self.refTagProperty.value = refTag
  }

  private let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  private let viewDidAppearAnimated = MutableProperty(false)
  public func viewDidAppear(animated animated: Bool) {
    self.viewDidAppearAnimated.value = animated
  }

  private let viewWillAppearAnimated = MutableProperty(false)
  public func viewWillAppear(animated animated: Bool) {
    self.viewWillAppearAnimated.value = animated
  }

  public let configureChildViewControllersWithProject: Signal<Project, NoError>
  private let prefersStatusBarHiddenProperty = MutableProperty(false)
  public var prefersStatusBarHidden: Bool {
    return self.prefersStatusBarHiddenProperty.value
  }
  public let setNavigationBarHiddenAnimated: Signal<(Bool, Bool), NoError>
  public let setNeedsStatusBarAppearanceUpdate: Signal<(), NoError>

  public var inputs: ProjectPamphletViewModelInputs { return self }
  public var outputs: ProjectPamphletViewModelOutputs { return self }
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
