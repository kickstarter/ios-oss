import KsApi
import Prelude
import ReactiveSwift
import Result

public protocol ProjectPamphletViewModelInputs {
  /// Call with the project given to the view controller.
  func configureWith(projectOrParam: Either<Project, Param>, refTag: RefTag?)

  /// Call when the view loads.
  func viewDidLoad()

  func viewDidAppear(animated: Bool)

  /// Call when the view will appear, and pass the animated parameter.
  func viewWillAppear(animated: Bool)
}

public protocol ProjectPamphletViewModelOutputs {
  /// Emits a project that should be used to configure all children view controllers.
  var configureChildViewControllersWithProject: Signal<(Project, RefTag?), NoError> { get }

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

  // swiftlint:disable:next function_body_length
  public init() {
    let projectOrParam = Signal.combineLatest(
      self.projectOrParamProperty.signal.skipNil(),
      self.viewDidLoadProperty.signal
      )
      .map(first)

    let projectOrParamAndIndex = Signal.combineLatest(
      projectOrParam,
      self.viewDidAppearAnimated.signal.scan(0, { accum, _ in accum + 1 })
      )

    let freshProject = projectOrParamAndIndex
      .map { p, idx in (p.left, p.ifLeft({ Param.id($0.id) }, ifRight: id), idx) }
      .switchMap { project, param, idx -> SignalProducer<Project, NoError> in

        AppEnvironment.current.apiService.fetchProject(param: param)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .demoteErrors()
    }

    let project = Signal.merge(
      projectOrParam.map { $0.left }.skipNil(),
      freshProject
      )

    let refTag = self.refTagProperty.signal
      .map { $0.map(cleanUp(refTag:)) }

    self.configureChildViewControllersWithProject = Signal.combineLatest(project, refTag)

    self.prefersStatusBarHiddenProperty <~ self.viewWillAppearAnimated.signal.mapConst(true)

    self.setNeedsStatusBarAppearanceUpdate = self.viewWillAppearAnimated.signal.ignoreValues()

    self.setNavigationBarHiddenAnimated = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst((true, false)),
      self.viewWillAppearAnimated.signal.skip(first: 1).map { (true, $0) }
    )

    let cookieRefTag = Signal.combineLatest(
      project.map(cookieRefTagFor(project:)),
      refTag
      )
      .take(first: 1)
      .map { $0 ?? $1 }

    Signal.combineLatest(project, refTag, cookieRefTag)
      .takeWhen(self.viewDidAppearAnimated.signal)
      .take(first: 1)
      .observeValues { project, refTag, cookieRefTag in
        AppEnvironment.current.koala.trackProjectShow(project, refTag: refTag, cookieRefTag: cookieRefTag)
    }

    Signal.combineLatest(cookieRefTag.skipNil(), project)
      .take(first: 1)
      .map(cookieFrom(refTag:project:))
      .skipNil()
      .observeValues { AppEnvironment.current.cookieStorage.setCookie($0) }
  }

  fileprivate let projectOrParamProperty = MutableProperty<Either<Project, Param>?>(nil)
  fileprivate let refTagProperty = MutableProperty<RefTag?>(nil)
  public func configureWith(projectOrParam: Either<Project, Param>, refTag: RefTag?) {
    self.projectOrParamProperty.value = projectOrParam
    self.refTagProperty.value = refTag
  }

  fileprivate let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  fileprivate let viewDidAppearAnimated = MutableProperty(false)
  public func viewDidAppear(animated: Bool) {
    self.viewDidAppearAnimated.value = animated
  }

  fileprivate let viewWillAppearAnimated = MutableProperty(false)
  public func viewWillAppear(animated: Bool) {
    self.viewWillAppearAnimated.value = animated
  }

  public let configureChildViewControllersWithProject: Signal<(Project, RefTag?), NoError>
  fileprivate let prefersStatusBarHiddenProperty = MutableProperty(false)
  public var prefersStatusBarHidden: Bool {
    return self.prefersStatusBarHiddenProperty.value
  }
  public let setNavigationBarHiddenAnimated: Signal<(Bool, Bool), NoError>
  public let setNeedsStatusBarAppearanceUpdate: Signal<(), NoError>

  public var inputs: ProjectPamphletViewModelInputs { return self }
  public var outputs: ProjectPamphletViewModelOutputs { return self }
}

private let cookieSeparator = "?"
private let escapedCookieSeparator = "%3F"

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

  let timestamp = Int(NSDate().timeIntervalSince1970)

  var properties: [HTTPCookiePropertyKey:Any] = [:]
  properties[.name]    = cookieName(project)
  properties[.value]   = "\(refTag.stringTag)\(cookieSeparator)\(timestamp)"
  properties[.domain]  = URL(string: project.urls.web.project)?.host
  properties[.path]    = URL(string: project.urls.web.project)?.path
  properties[.version] = 0
  properties[.expires] = Date(timeIntervalSince1970: project.dates.deadline)

  return HTTPCookie(properties: properties)
}
