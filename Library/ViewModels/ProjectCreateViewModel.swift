import KsApi
import Prelude
import ReactiveSwift
import Result
import WebKit

public protocol ProjectCreatorViewModelInputs {
  /// Call with the project given to the view.
  func configureWith(project: Project)

  /// Call with the navigation action given to the webview's delegate method. Returns the policy that can
  /// be returned from the delegate method.
  func decidePolicy(forNavigationAction action: WKNavigationActionProtocol) -> WKNavigationActionPolicy

  /// Call when the view loads.
  func viewDidLoad()
}

public protocol ProjectCreatorViewModelOutputs {
  /// Emits when we should navigate to the message dialog.
  var goToMessageDialog: Signal<(MessageSubject, Koala.MessageDialogContext), NoError> { get }

  /// Emits when we should open a safari browser with the URL.
  var goToSafariBrowser: Signal<NSURL, NoError> { get }

  /// Emits a request that should be loaded into the web view.
  var loadWebViewRequest: Signal<NSURLRequest, NoError> { get }
}

public protocol ProjectCreatorViewModelType {
  var inputs: ProjectCreatorViewModelInputs { get }
  var outputs: ProjectCreatorViewModelOutputs { get }
}

public final class ProjectCreatorViewModel: ProjectCreatorViewModelType, ProjectCreatorViewModelInputs,
ProjectCreatorViewModelOutputs {

  public init() {
    let navigationAction = self.navigationAction.signal.ignoreNil()
    let project = combineLatest(self.projectProperty.signal.ignoreNil(), self.viewDidLoadProperty.signal)
      .map(first)

    let messageCreatorRequest = navigationAction
      .filter { $0.navigationType == .LinkActivated }
      .filter { isMessageCreator(request: $0.request) }
      .map { $0.request }

    self.loadWebViewRequest = project.map {
      URL(string: $0.urls.web.project)?.URLByAppendingPathComponent("creator_bio")
      }
      .ignoreNil()
      .map { AppEnvironment.current.apiService.preparedRequest(forURL: $0) }

    self.decidedPolicy <~ navigationAction
      .map { $0.navigationType == .Other ? .Allow : .Cancel }

    self.goToMessageDialog = project
      .takeWhen(messageCreatorRequest)
      .map { (MessageSubject.project($0), .projectPage) }

    self.goToSafariBrowser = navigationAction
      .filter { $0.navigationType == .LinkActivated }
      .filter { !isMessageCreator(request: $0.request) }
      .map { $0.request.URL }
      .ignoreNil()

    project
      .takeWhen(self.goToSafariBrowser)
      .observeNext {
        AppEnvironment.current.koala.trackOpenedExternalLink(project: $0, context: .projectCreator)
    }
  }

  fileprivate let projectProperty = MutableProperty<Project?>(nil)
  public func configureWith(project: Project) {
    self.projectProperty.value = project
  }

  fileprivate let navigationAction = MutableProperty<WKNavigationActionProtocol?>(nil)
  fileprivate let decidedPolicy = MutableProperty(WKNavigationActionPolicy.Cancel)
  public func decidePolicy(forNavigationAction action: WKNavigationActionProtocol)
    -> WKNavigationActionPolicy {
    self.navigationAction.value = action
    return self.decidedPolicy.value
  }

  fileprivate let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let goToMessageDialog: Signal<(MessageSubject, Koala.MessageDialogContext), NoError>
  public let goToSafariBrowser: Signal<NSURL, NoError>
  public let loadWebViewRequest: Signal<NSURLRequest, NoError>

  public var inputs: ProjectCreatorViewModelInputs { return self }
  public var outputs: ProjectCreatorViewModelOutputs { return self }
}

private func isMessageCreator(request: URLRequest) -> Bool {
  if let nav = Navigation.match(request), case .project(_, .messageCreator, _) = nav { return true }
  return false
}
