import Models
import Library
import ReactiveCocoa
import Result
import Foundation

internal protocol ProjectViewModelInputs {
  /// Call when the view will appear.
  func viewWillAppear()

  /// Call with the project that the view controller was initialized with.
  func project(project: Project)

  /// Call with the (optional) reftag that the view controller was initailized with.
  func refTag(refTag: RefTag?)

  /// Call when the NSNotification for user session starting has been posteed.
  func userSessionStarted()

  /// Call when the NSNotification for user session ending has been posted.
  func userSessionEnded()

  /// Call when the star button is tapped.
  func starButtonTapped()
}

internal protocol ProjectViewModelOutputs {
  /// Emits a project immediately when the view appears, and then again when a fresh project has been loaded
  /// from the API.
  var project: Signal<Project, NoError> { get }

  /// Emits when the login tout should be shown to the user.
  var showLoginTout: Signal<(), NoError> { get }

  /// Emits when the project has been successfully starred and a prompt should be shown to the user.
  var showProjectStarredPrompt: Signal<(), NoError> { get }
}

internal protocol ProjectViewModelType {
  var inputs: ProjectViewModelInputs { get }
  var outputs: ProjectViewModelOutputs { get }
}

internal final class ProjectViewModel: ProjectViewModelType, ProjectViewModelInputs,
ProjectViewModelOutputs {
  typealias Model = Project

  private let viewWillAppearProperty = MutableProperty(())
  internal func viewWillAppear() {
    self.viewWillAppearProperty.value = ()
  }

  private let projectProperty = MutableProperty<Project?>(nil)
  internal func project(project: Project) {
    self.projectProperty.value = project
  }

  private let refTagProperty = MutableProperty<RefTag?>(nil)
  internal func refTag(refTag: RefTag?) {
    self.refTagProperty.value = refTag
  }

  private let userSessionStartedProperty = MutableProperty(())
  func userSessionStarted() {
    self.userSessionStartedProperty.value = ()
  }

  private let userSessionEndedProperty = MutableProperty(())
  func userSessionEnded() {
    self.userSessionEndedProperty.value = ()
  }

  private let starButtonTappedProperty = MutableProperty(())
  internal func starButtonTapped() {
    self.starButtonTappedProperty.value = ()
  }

  internal let project: Signal<Project, NoError>
  internal let showLoginTout: Signal<(), NoError>
  internal let showProjectStarredPrompt: Signal<(), NoError>

  internal var inputs: ProjectViewModelInputs { return self }
  internal var outputs: ProjectViewModelOutputs { return self }

  // swiftlint:disable function_body_length
  internal init() {
    let project = self.projectProperty.signal.ignoreNil()

    let currentUser = Signal.merge([
        self.viewWillAppearProperty.signal,
        self.userSessionStartedProperty.signal,
        self.userSessionEndedProperty.signal
      ])
      .map { AppEnvironment.current.currentUser }
      .skipRepeats(==)

    let loggedInUserTappedStar = currentUser
      .takeWhen(self.starButtonTappedProperty.signal)
      .filter { $0 != nil }
      .ignoreValues()

    let loggedOutUserTappedStar = currentUser
      .takeWhen(self.starButtonTappedProperty.signal)
      .filter { $0 == nil }
      .ignoreValues()

    // Emits only when a user logs in after having tapped the star while logged out.
    let userLoginAfterTappingStar = combineLatest(
      self.userSessionStartedProperty.signal,
      loggedOutUserTappedStar
      )
      .ignoreValues()
      .take(1)

    let refreshedProject = project.take(1)
      .flatMap { p in
        AppEnvironment.current.apiService.fetchProject(p)
          .demoteErrors()
          .beginsWith(value: p)
    }

    let projectOnStarToggle = project
      .takeWhen(Signal.merge([loggedInUserTappedStar, userLoginAfterTappingStar]))
      .switchMap { project in
        AppEnvironment.current.apiService.toggleStar(project)
          .demoteErrors()
    }

    self.project = Signal.merge([refreshedProject, projectOnStarToggle])

    self.showProjectStarredPrompt = projectOnStarToggle
      .filter { $0.personalization.isStarred == true && !$0.endsIn48Hours }
      .ignoreValues()

    self.showLoginTout = loggedOutUserTappedStar

    let cookieRefTag = combineLatest(project, self.refTagProperty.signal)
      .map { (project, refTag) in
        refTagFromCookieStorage(AppEnvironment.current.cookieStorage, project: project) ?? refTag
      }

    combineLatest(self.viewWillAppearProperty.signal, project, self.refTagProperty.signal, cookieRefTag)
      .take(1)
      .observeNext { (_, project, refTag, cookieRefTag) in
        AppEnvironment.current.koala.trackProjectShow(project, refTag: refTag, cookieRefTag: cookieRefTag)
    }

    projectOnStarToggle.observeNext { project in
      AppEnvironment.current.koala.trackProjectStar(project)
    }

    combineLatest(self.viewWillAppearProperty.signal, cookieRefTag.ignoreNil(), project)
      .take(1)
      .map { (_, refTag, project) in cookieFromRefTag(refTag, project: project) }
      .ignoreNil()
      .observeNext { AppEnvironment.current.cookieStorage.setCookie($0) }
  }
  // swiftlint:enable function_body_length
}

private let cookieSeparator = Character("?")

// Extracts the ref tag stored in cookies for a particular project. Returns `nil` if no such cookie has
// been previously set.
private func refTagFromCookieStorage(storage: NSHTTPCookieStorageType, project: Project) -> RefTag? {

  return storage.cookies?
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
private func cookieFromRefTag(refTag: RefTag, project: Project) -> NSHTTPCookie? {

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
