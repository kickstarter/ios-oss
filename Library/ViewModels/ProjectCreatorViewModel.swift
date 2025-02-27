import KsApi
import Prelude
import ReactiveSwift
import WebKit

public protocol ProjectCreatorViewModelInputs {
  /// Call with the project given to the view.
  func configureWith(project: Project)

  /// Call with the navigation action given to the webview's delegate method. Returns the policy that can
  /// be returned from the delegate method.
  func decidePolicy(forNavigationAction action: WKNavigationActionData) -> WKNavigationActionPolicy

  /// Call when the view loads.
  func viewDidLoad()
}

public protocol ProjectCreatorViewModelOutputs {
  /// Emits when we should return to project page.
  var goBackToProject: Signal<(), Never> { get }

  /// Emits when the LoginToutViewController should be presented.
  var goToLoginTout: Signal<LoginIntent, Never> { get }

  /// Emits when we should navigate to the message dialog.
  var goToMessageDialog: Signal<(MessageSubject, KSRAnalytics.MessageDialogContext), Never> { get }

  /// Emits when we should open a safari browser with the URL.
  var goToSafariBrowser: Signal<URL, Never> { get }

  /// Emits a request that should be loaded into the web view.
  var loadWebViewRequest: Signal<URLRequest, Never> { get }
}

public protocol ProjectCreatorViewModelType {
  var inputs: ProjectCreatorViewModelInputs { get }
  var outputs: ProjectCreatorViewModelOutputs { get }
}

public final class ProjectCreatorViewModel: ProjectCreatorViewModelType, ProjectCreatorViewModelInputs,
  ProjectCreatorViewModelOutputs {
  public init() {
    let navigationAction = self.navigationAction.signal.skipNil()
    let project = Signal.combineLatest(self.projectProperty.signal.skipNil(), self.viewDidLoadProperty.signal)
      .map(first)

    let messageCreatorRequest = navigationAction
      .filter { $0.navigationType == .linkActivated }
      .filter { isMessageCreator(request: $0.request) }
      .map { $0.request }

    self.loadWebViewRequest = project.map {
      URL(string: $0.urls.web.project)?.appendingPathComponent("creator_bio")
    }
    .skipNil()
    .map { AppEnvironment.current.apiService.preparedRequest(forURL: $0) }

    self.decidedPolicy <~ navigationAction
      .map { $0.navigationType == .other ? .allow : .cancel }

    self.goToLoginTout = messageCreatorRequest.ignoreValues()
      .filter { AppEnvironment.current.currentUser == nil }
      .map { .messageCreator }

    self.goToMessageDialog = project
      .takeWhen(messageCreatorRequest)
      .filter { _ in AppEnvironment.current.currentUser != nil }
      .map { (MessageSubject.project(id: $0.id, name: $0.name), .projectPage) }

    self.goBackToProject = Signal.combineLatest(project, navigationAction)
      .filter { $1.navigationType == .linkActivated }
      .filter { project, navigation in
        project.urls.web.project == navigation.request.url?.absoluteString
      }
      .ignoreValues()

    self.goToSafariBrowser = Signal.combineLatest(project, navigationAction)
      .filter { $1.navigationType == .linkActivated }
      .filter { !isMessageCreator(request: $1.request) }
      .filter { project, navigation in
        project.urls.web.project != navigation.request.url?.absoluteString
      }
      .map { $1.request.url }
      .skipNil()
  }

  fileprivate let projectProperty = MutableProperty<Project?>(nil)
  public func configureWith(project: Project) {
    self.projectProperty.value = project
  }

  fileprivate let navigationAction = MutableProperty<WKNavigationActionData?>(nil)
  fileprivate let decidedPolicy = MutableProperty(WKNavigationActionPolicy.cancel)
  public func decidePolicy(forNavigationAction action: WKNavigationActionData) -> WKNavigationActionPolicy {
    self.navigationAction.value = action
    return self.decidedPolicy.value
  }

  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let goBackToProject: Signal<(), Never>
  public let goToLoginTout: Signal<LoginIntent, Never>
  public let goToMessageDialog: Signal<(MessageSubject, KSRAnalytics.MessageDialogContext), Never>
  public let goToSafariBrowser: Signal<URL, Never>
  public let loadWebViewRequest: Signal<URLRequest, Never>

  public var inputs: ProjectCreatorViewModelInputs { return self }
  public var outputs: ProjectCreatorViewModelOutputs { return self }
}

private func isMessageCreator(request: URLRequest) -> Bool {
  if let nav = Navigation.match(request), case .project(_, .messageCreator, _) = nav { return true }
  return false
}
