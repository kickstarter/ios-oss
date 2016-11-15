import KsApi
import Prelude
import ReactiveCocoa
import Result
import WebKit

public protocol ProjectDescriptionViewModelInputs {
  /// Call with the project given to the view.
  func configureWith(project project: Project)

  /// Call when the webview needs to decide a policy for a navigation action. Returns the decision policy.
  func decidePolicyFor(navigationAction navigationAction: WKNavigationActionData)

  /// Call when the view loads.
  func viewDidLoad()
}

public protocol ProjectDescriptionViewModelOutputs {
  /// Can be returned from the web view's policy decision delegate method.
  var decidedPolicyForNavigationAction: WKNavigationActionPolicy { get }

  /// Emits when we should go back to the project.
  var goBackToProject: Signal<(), NoError> { get }

  /// Emits when we should navigate to the message dialog.
  var goToMessageDialog: Signal<(MessageSubject, Koala.MessageDialogContext), NoError> { get }

  /// Emits when we should open a safari browser with the URL.
  var goToSafariBrowser: Signal<NSURL, NoError> { get }

  /// Emits a url request that should be loaded into the webview.
  var loadWebViewRequest: Signal<NSURLRequest, NoError> { get }
}

public protocol ProjectDescriptionViewModelType {
  var inputs: ProjectDescriptionViewModelInputs { get }
  var outputs: ProjectDescriptionViewModelOutputs { get }
}

public final class ProjectDescriptionViewModel: ProjectDescriptionViewModelType,
ProjectDescriptionViewModelInputs, ProjectDescriptionViewModelOutputs {

  public init() {
    let project = combineLatest(self.projectProperty.signal.ignoreNil(), self.viewDidLoadProperty.signal)
      .map(first)
    let navigationAction = self.policyForNavigationActionProperty.signal.ignoreNil()
    let navigationActionLink = navigationAction
      .filter { $0.navigationType == .LinkActivated }
    let navigation = navigationActionLink
      .map { Navigation.match($0.request) }

    let projectDescriptionRequest = project
      .map {
        NSURL(string: $0.urls.web.project)?.URLByAppendingPathComponent("description")
      }
      .ignoreNil()

    self.loadWebViewRequest = projectDescriptionRequest
      .map { AppEnvironment.current.apiService.preparedRequest(forURL: $0) }

    self.policyDecisionProperty <~ navigationAction
      .map { action in allowed(navigationAction: action) ? .Allow : .Cancel }

    let possiblyGoToMessageDialog = combineLatest(project, navigation)
      .map { (project, navigation) -> (MessageSubject, Koala.MessageDialogContext)? in
        guard navigation.map(isMessageCreator(navigation:)) == true else { return nil }
        return (MessageSubject.project(project), Koala.MessageDialogContext.projectPage)
      }

    self.goToMessageDialog = possiblyGoToMessageDialog.ignoreNil()

    let possiblyGoBackToProject = combineLatest(project, navigation)
      .map { (project, navigation) -> Project? in
        guard
          case let (.project(param, .root, _))? = navigation
          where String(project.id) == param.slug || project.slug == param.slug
          else { return nil }

        return project
    }

    self.goBackToProject = possiblyGoBackToProject.ignoreNil().ignoreValues()

    self.goToSafariBrowser = zip(navigationActionLink, possiblyGoToMessageDialog, possiblyGoBackToProject)
      .filter { $1 == nil && $2 == nil }
      .filter { navigationAction, _, _ in navigationAction.navigationType == .LinkActivated }
      .map { navigationAction, _, _ in navigationAction.request.URL }
      .ignoreNil()

    project
      .takeWhen(self.goToSafariBrowser)
      .observeNext {
        AppEnvironment.current.koala.trackOpenedExternalLink(project: $0, context: .projectDescription)
    }
  }

  private let projectProperty = MutableProperty<Project?>(nil)
  public func configureWith(project project: Project) {
    self.projectProperty.value = project
  }
  private let policyForNavigationActionProperty = MutableProperty<WKNavigationActionData?>(nil)
  public func decidePolicyFor(navigationAction navigationAction: WKNavigationActionData) {
    self.policyForNavigationActionProperty.value = navigationAction
  }

  private let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  private let policyDecisionProperty = MutableProperty(WKNavigationActionPolicy.Allow)
  public var decidedPolicyForNavigationAction: WKNavigationActionPolicy {
    return self.policyDecisionProperty.value
  }
  public let goBackToProject: Signal<(), NoError>
  public let goToMessageDialog: Signal<(MessageSubject, Koala.MessageDialogContext), NoError>
  public let goToSafariBrowser: Signal<NSURL, NoError>
  public let loadWebViewRequest: Signal<NSURLRequest, NoError>

  public var inputs: ProjectDescriptionViewModelInputs { return self }
  public var outputs: ProjectDescriptionViewModelOutputs { return self }
}

private func isMessageCreator(navigation navigation: Navigation) -> Bool {
  guard case .project(_, .messageCreator, _) = navigation else { return false }
  return true
}

private func allowed(navigationAction action: WKNavigationActionData) -> Bool {
  return action.request.URL?.path?.containsString("/description") == .Some(true)
    || action.targetFrame?.mainFrame == .Some(false)
}
