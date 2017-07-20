import KsApi
import Prelude
import ReactiveSwift
import Result
import WebKit

public protocol ProjectDescriptionViewModelInputs {
  /// Call with the project given to the view.
  func configureWith(project: Project)

  /// Call when the webview needs to decide a policy for a navigation action. Returns the decision policy.
  func decidePolicyFor(navigationAction: WKNavigationActionData)

  /// Call when the view loads.
  func viewDidLoad()

  /// Call when the webview finishes navigating.
  func webViewDidFinishNavigation()

  /// Call when the webview starts navigating to a page.
  func webViewDidStartProvisionalNavigation()
}

public protocol ProjectDescriptionViewModelOutputs {
  /// Can be returned from the web view's policy decision delegate method.
  var decidedPolicyForNavigationAction: WKNavigationActionPolicy { get }

  /// Emits when we should go back to the project.
  var goBackToProject: Signal<(), NoError> { get }

  /// Emits when we should navigate to the message dialog.
  var goToMessageDialog: Signal<(MessageSubject, Koala.MessageDialogContext), NoError> { get }

  /// Emits when we should open a safari browser with the URL.
  var goToSafariBrowser: Signal<URL, NoError> { get }

  /// Emits when a web request is loading.
  var isLoading: Signal<Bool, NoError> { get }

  /// Emits a url request that should be loaded into the webview.
  var loadWebViewRequest: Signal<URLRequest, NoError> { get }
}

public protocol ProjectDescriptionViewModelType {
  var inputs: ProjectDescriptionViewModelInputs { get }
  var outputs: ProjectDescriptionViewModelOutputs { get }
}

public final class ProjectDescriptionViewModel: ProjectDescriptionViewModelType,
ProjectDescriptionViewModelInputs, ProjectDescriptionViewModelOutputs {

  public init() {
    let project = Signal.combineLatest(self.projectProperty.signal.skipNil(), self.viewDidLoadProperty.signal)
      .map(first)
    let navigationAction = self.policyForNavigationActionProperty.signal.skipNil()
    let navigationActionLink = navigationAction
      .filter { $0.navigationType == .linkActivated }
    let navigation = navigationActionLink
      .map { Navigation.match($0.request) }

    let projectDescriptionRequest = project
      .map {
        URL(string: $0.urls.web.project)?.appendingPathComponent("description")
      }
      .skipNil()

    self.isLoading = Signal
      .merge(
        self.viewDidLoadProperty.signal.map(const(true)),
        self.webViewDidStartProvisionalNavigationProperty.signal.map(const(true)),
        self.webViewDidFinishNavigationProperty.signal.map(const(false))
      )
      .skipRepeats()

    self.loadWebViewRequest = projectDescriptionRequest
      .map { AppEnvironment.current.apiService.preparedRequest(forURL: $0) }

    self.policyDecisionProperty <~ navigationAction
      .map { action in allowed(navigationAction: action) ? .allow : .cancel }

    let possiblyGoToMessageDialog = Signal.combineLatest(project, navigation)
      .map { (project, navigation) -> (MessageSubject, Koala.MessageDialogContext)? in
        guard navigation.map(isMessageCreator(navigation:)) == true else { return nil }
        return (MessageSubject.project(project), Koala.MessageDialogContext.projectPage)
      }

    self.goToMessageDialog = possiblyGoToMessageDialog.skipNil()

    let possiblyGoBackToProject = Signal.combineLatest(project, navigation)
      .map { (project, navigation) -> Project? in
        guard
          case let (.project(param, .root, _))? = navigation,
          String(project.id) == param.slug || project.slug == param.slug
          else { return nil }

        return project
    }

    self.goBackToProject = possiblyGoBackToProject.skipNil().ignoreValues()

    self.goToSafariBrowser = Signal.zip(
      navigationActionLink, possiblyGoToMessageDialog, possiblyGoBackToProject
      )
      .filter { $1 == nil && $2 == nil }
      .filter { navigationAction, _, _ in navigationAction.navigationType == .linkActivated }
      .map { navigationAction, _, _ in navigationAction.request.url }
      .skipNil()

    project
      .takeWhen(self.goToSafariBrowser)
      .observeValues {
        AppEnvironment.current.koala.trackOpenedExternalLink(project: $0, context: .projectDescription)
    }
  }

  fileprivate let projectProperty = MutableProperty<Project?>(nil)
  public func configureWith(project: Project) {
    self.projectProperty.value = project
  }

  fileprivate let policyForNavigationActionProperty = MutableProperty<WKNavigationActionData?>(nil)
  public func decidePolicyFor(navigationAction: WKNavigationActionData) {
    self.policyForNavigationActionProperty.value = navigationAction
  }

  fileprivate let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  fileprivate let policyDecisionProperty = MutableProperty(WKNavigationActionPolicy.allow)
  public var decidedPolicyForNavigationAction: WKNavigationActionPolicy {
    return self.policyDecisionProperty.value
  }

  fileprivate let webViewDidFinishNavigationProperty = MutableProperty()
  public func webViewDidFinishNavigation() {
    self.webViewDidFinishNavigationProperty.value = ()
  }

  fileprivate let webViewDidStartProvisionalNavigationProperty = MutableProperty()
  public func webViewDidStartProvisionalNavigation() {
    self.webViewDidStartProvisionalNavigationProperty.value = ()
  }

  public let goBackToProject: Signal<(), NoError>
  public let goToMessageDialog: Signal<(MessageSubject, Koala.MessageDialogContext), NoError>
  public let goToSafariBrowser: Signal<URL, NoError>
  public let isLoading: Signal<Bool, NoError>
  public let loadWebViewRequest: Signal<URLRequest, NoError>

  public var inputs: ProjectDescriptionViewModelInputs { return self }
  public var outputs: ProjectDescriptionViewModelOutputs { return self }
}

private func isMessageCreator(navigation: Navigation) -> Bool {
  guard case .project(_, .messageCreator, _) = navigation else { return false }
  return true
}

private func allowed(navigationAction action: WKNavigationActionData) -> Bool {
  return action.request.url?.path.contains("/description") == .some(true)
    || action.targetFrame?.mainFrame == .some(false)
}
