import KsApi
import Prelude
import ReactiveSwift
import Result
import WebKit

public protocol ProjectUpdatesViewModelInputs {
  /// Call with the project given to the view.
  func configureWith(project: Project)

  /// Call with the navigation action given to the webview's delegate method. Returns the policy that can
  /// be returned from the delegate method.
  func decidePolicy(forNavigationAction action: WKNavigationActionData) -> WKNavigationActionPolicy

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

  // swiftlint:disable:next function_body_length
  public init() {
    let navigationAction = self.navigationAction.signal.skipNil()

    let project = combineLatest(self.projectProperty.signal.skipNil(), self.viewDidLoadProperty.signal)
      .map(first)

    let initialUpdatesIndexLoadRequest = project.map { URL(string: $0.urls.web.updates ?? "") }.skipNil()

    let anotherIndexRequest = navigationAction
      .filter { $0.navigationType == .LinkActivated && isUpdatesRequest(request: $0.request) }
      .map { $0.request.URL }
      .skipNil()

    let goToCommentsRequest = navigationAction
      .filter { isGoToCommentsRequest(request: $0.request) }
      .map { projectUpdateParams(fromRequest: $0.request) }
      .skipNil()

    let goToUpdateRequest = navigationAction
      .filter { isGoToUpdateRequest(request: $0.request) }
      .map { projectUpdateParams(fromRequest: $0.request) }
      .skipNil()
      .switchMap { projectParam, updateId in
        AppEnvironment.current.apiService.fetchUpdate(updateId: updateId, projectParam: projectParam)
          .demoteErrors()
      }

    self.decidedPolicy <~ navigationAction
      .map { action in
        action.navigationType == .Other || action.targetFrame?.mainFrame == .Some(false)
          ? .Allow
          : .Cancel
    }

    self.goToSafariBrowser = navigationAction
      .filter {
        $0.navigationType == .LinkActivated &&
        !isGoToCommentsRequest(request: $0.request) &&
        !isGoToUpdateRequest(request: $0.request) &&
        !isUpdatesRequest(request: $0.request)
      }
      .map { $0.request.URL }
      .skipNil()

    self.goToUpdate = project.takePairWhen(goToUpdateRequest)

    self.goToUpdateComments = goToCommentsRequest
      .switchMap { projectParam, updateId in
        AppEnvironment.current.apiService.fetchUpdate(updateId: updateId, projectParam: projectParam)
        .demoteErrors()
    }

    self.webViewLoadRequest = Signal.merge(initialUpdatesIndexLoadRequest, anotherIndexRequest)
      .map { AppEnvironment.current.apiService.preparedRequest(forURL: $0) }

    project
      .takeWhen(self.goToSafariBrowser)
      .observeValues {
        AppEnvironment.current.koala.trackOpenedExternalLink(project: $0, context: .projectUpdates)
    }
  }

  fileprivate let projectProperty = MutableProperty<Project?>(nil)
  public func configureWith(project: Project) {
    self.projectProperty.value = project
  }
  fileprivate let navigationAction = MutableProperty<WKNavigationActionData?>(nil)
  fileprivate let decidedPolicy = MutableProperty(WKNavigationActionPolicy.Cancel)
  public func decidePolicy(forNavigationAction action: WKNavigationActionData)
    -> WKNavigationActionPolicy {
      self.navigationAction.value = action
      return self.decidedPolicy.value
  }
  fileprivate let viewDidLoadProperty = MutableProperty()
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

private func isGoToCommentsRequest(request: URLRequest) -> Bool {
  if let nav = Navigation.match(request), case .project(_, .update(_, .comments), _) = nav { return true }
  return false
}

private func isGoToUpdateRequest(request: URLRequest) -> Bool {
  if let nav = Navigation.match(request), case .project(_, .update(_, .root), _) = nav { return true }
  return false
}

private func isUpdatesRequest(request: URLRequest) -> Bool {
  if let nav = Navigation.match(request), case .project(_, .updates, _) = nav { return true }
  return false
}
