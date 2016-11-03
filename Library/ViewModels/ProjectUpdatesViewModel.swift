import KsApi
import Prelude
import ReactiveCocoa
import Result
import WebKit

public protocol ProjectUpdatesViewModelInputs {
  /// Call with the project given to the view.
  func configureWith(project project: Project)

  /// Call with the navigation action given to the webview's delegate method. Returns the policy that can
  /// be returned from the delegate method.
  func decidePolicy(forNavigationAction action: WKNavigationActionProtocol) -> WKNavigationActionPolicy

  /// Call when the view loads.
  func viewDidLoad()
}

public protocol ProjectUpdatesViewModelOutputs {
  /// Emits when we should open a safari browser with the URL.
  var goToSafariBrowser: Signal<NSURL, NoError> { get }

  /// Emits with the project and update when we should go to the update.
  var goToUpdate: Signal<(Project, Update), NoError> { get }

  /// Emits with the project when we should go to the update comments.
  var goToUpdateComments: Signal<Update, NoError> { get }

  /// Emits a request that should be loaded into the web view.
  var webViewLoadRequest: Signal<NSURLRequest, NoError> { get }
}

public protocol ProjectUpdatesViewModelType {
  var inputs: ProjectUpdatesViewModelInputs { get }
  var outputs: ProjectUpdatesViewModelOutputs { get }
}

public final class ProjectUpdatesViewModel: ProjectUpdatesViewModelType, ProjectUpdatesViewModelInputs,
ProjectUpdatesViewModelOutputs {

  public init() {
    let navigationAction = self.navigationAction.signal.ignoreNil()

    let project = combineLatest(self.projectProperty.signal.ignoreNil(), self.viewDidLoadProperty.signal)
      .map(first)

    let initialUpdatesIndexLoadRequest = project.map { NSURL(string: $0.urls.web.updates ?? "") }.ignoreNil()

    let anotherIndexRequest = navigationAction
      .filter { $0.navigationType == .LinkActivated && isUpdatesRequest(request: $0.request) }
      .map { $0.request.URL }
      .ignoreNil()

    let goToCommentsRequest = navigationAction
      .filter { isGoToCommentsRequest(request: $0.request) }
      .map { projectUpdateParams(fromRequest: $0.request) }
      .ignoreNil()

    let goToUpdateRequest = navigationAction
      .filter { isGoToUpdateRequest(request: $0.request) }
      .map { projectUpdateParams(fromRequest: $0.request) }
      .ignoreNil()
      .switchMap { projectParam, updateId in
        AppEnvironment.current.apiService.fetchUpdate(updateId: updateId, projectParam: projectParam)
          .demoteErrors()
      }

    self.decidedPolicy <~ navigationAction
      .map { $0.navigationType == .Other ? .Allow : .Cancel }

    self.goToSafariBrowser = navigationAction
      .filter {
        $0.navigationType == .LinkActivated &&
        !isGoToCommentsRequest(request: $0.request) &&
        !isGoToUpdateRequest(request: $0.request) &&
        !isUpdatesRequest(request: $0.request)
      }
      .map { $0.request.URL }
      .ignoreNil()

    self.goToUpdate = project.takePairWhen(goToUpdateRequest)
      .map { ($0, $1) }

    self.goToUpdateComments = goToCommentsRequest
      .switchMap { projectParam, updateId in
        AppEnvironment.current.apiService.fetchUpdate(updateId: updateId, projectParam: projectParam)
        .demoteErrors()
    }

    self.webViewLoadRequest = Signal.merge(initialUpdatesIndexLoadRequest, anotherIndexRequest)
      .map { AppEnvironment.current.apiService.preparedRequest(forURL: $0) }

    project.takeWhen(self.goToSafariBrowser)
      .observeNext {
        AppEnvironment.current.koala.trackOpenedExternalLink(project: $0, context: .projectUpdates)}
  }

  private let projectProperty = MutableProperty<Project?>(nil)
  public func configureWith(project project: Project) {
    self.projectProperty.value = project
  }
  private let navigationAction = MutableProperty<WKNavigationActionProtocol?>(nil)
  private let decidedPolicy = MutableProperty(WKNavigationActionPolicy.Cancel)
  public func decidePolicy(forNavigationAction action: WKNavigationActionProtocol)
    -> WKNavigationActionPolicy {
      self.navigationAction.value = action
      return self.decidedPolicy.value
  }
  private let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let goToSafariBrowser: Signal<NSURL, NoError>
  public var goToUpdate: Signal<(Project, Update), NoError>
  public var goToUpdateComments: Signal<Update, NoError>
  public let webViewLoadRequest: Signal<NSURLRequest, NoError>

  public var inputs: ProjectUpdatesViewModelInputs { return self }
  public var outputs: ProjectUpdatesViewModelOutputs { return self }
}

// Returns project and update params for update and comments requests.
private func projectUpdateParams(fromRequest request: NSURLRequest) -> (projectParam: Param, updateId: Int)? {
  guard let nav = Navigation.match(request) else { return nil }
  switch nav {
  case .project(_, .update(_, .comments), _):
    return Navigation.Project.updateCommentsWithRequest(request)
  case .project(_, .update(_, .root), _):
    return Navigation.Project.updateWithRequest(request)
  default:
    return nil
  }
}

private func isGoToCommentsRequest(request request: NSURLRequest) -> Bool {
  if let nav = Navigation.match(request), case .project(_, .update(_, .comments), _) = nav { return true }
  return false
}

private func isGoToUpdateRequest(request request: NSURLRequest) -> Bool {
  if let nav = Navigation.match(request), case .project(_, .update(_, .root), _) = nav { return true }
  return false
}

private func isUpdatesRequest(request request: NSURLRequest) -> Bool {
  if let nav = Navigation.match(request), case .project(_, .updates, _) = nav { return true }
  return false
}
