import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift
import WebKit

public protocol SurveyResponseViewModelInputs {
  /// Call when the close button is tapped.
  func closeButtonTapped()

  /// Call to configure with a survey url.
  func configureWith(surveyUrl: String)

  /// Call when the webview needs to decide a policy for a navigation action. Returns the decision policy.
  func decidePolicyFor(navigationAction: WKNavigationActionData) -> WKNavigationActionPolicy

  /// Call when the user session starts.
  func userSessionStarted()

  /// Call when the view loads.
  func viewDidLoad()
}

public protocol SurveyResponseViewModelOutputs {
  /// Emits when the view controller should be dismissed.
  var dismissViewController: Signal<Void, Never> { get }

  /// Emits a project and ref tag that should be used to present a project controller.
  var goToProject: Signal<(Param, RefTag?), Never> { get }

  var goToUpdate: Signal<(Project, Update), Never> { get }

  /// Emits a project param that should be used to present the manage pledge view controller
  var goToPledge: Signal<Param, Never> { get }

  /// Emits a login intent that should be used to log in.
  var goToLoginSignup: Signal<LoginIntent, Never> { get }

  /// Emits a title, if any, that should be shown in the top bar.
  /// `nil` should reset the view to have no title.
  var title: Signal<String?, Never> { get }

  /// Emits a request that should be loaded by the webview.
  var webViewLoadRequest: Signal<URLRequest, Never> { get }
}

public protocol SurveyResponseViewModelType: SurveyResponseViewModelInputs, SurveyResponseViewModelOutputs {
  var inputs: SurveyResponseViewModelInputs { get }
  var outputs: SurveyResponseViewModelOutputs { get }
}

public final class SurveyResponseViewModel: SurveyResponseViewModelType {
  public init() {
    let initialIsLoggedIn = self.viewDidLoadProperty.signal.compactMap {
      AppEnvironment.current.currentUser != nil
    }

    self.goToLoginSignup = initialIsLoggedIn.filter(isFalse).map { _ in
      LoginIntent.generic
    }

    let isLoggedIn = Signal.merge(
      initialIsLoggedIn,
      self.userSessionStartedProperty.signal.mapConst(true)
    )

    // Wait until user is logged in before handling survey response.
    let surveyResponse = Signal.combineLatest(
      self.initialSurveyProperty.signal.skipNil(),
      self.viewDidLoadProperty.signal,
      isLoggedIn.filter(isTrue)
    )
    .map(first)

    let initialRequest = surveyResponse
      .map { surveyUrlString -> URLRequest? in
        guard let url = URL(string: surveyUrlString) else { return nil }
        return URLRequest(url: url)
      }
      .skipNil()

    let newNavigationAction = self.policyForNavigationActionProperty.signal.skipNil()

    let newRequest = newNavigationAction.map { action in action.request }

    self.title = Signal.merge(initialRequest, newRequest)
      .compactMap { request in
        if isSurvey(request: request) {
          // Only update the title based on the main survey url.
          return request.url
        }
        return nil
      }
      .map { (surveyUrl: URL) -> String? in
        // The pledge management flow has its own url, so show a title for this url.
        // The other urls shown in this dashboard are not unique (navigating between
        // the pages they load doesn't change the url), so show no title instead.
        if surveyUrl.lastPathComponent == "redeem" {
          return Strings.Pledge_manager()
        } else {
          return nil
        }
      }

    let newSurveyRequest = newRequest
      .filter { request in
        isUnpreparedSurvey(request: request)
      }

    self.dismissViewController = self.closeButtonTappedProperty.signal

    self.goToProject = newRequest
      .map { request -> (Param, RefTag?)? in
        if case let (.project(param, .root, refInfo, _))? = Navigation.match(request) {
          return (param, refInfo?.refTag)
        }
        return nil
      }
      .skipNil()

    self.goToPledge = newRequest
      .map { request -> (Param)? in
        if case let (.project(param, .pledge, refInfo, _))? = Navigation.match(request) {
          return param
        }
        return nil
      }
      .skipNil()

    self.goToUpdate = newRequest
      .map { (request: URLRequest) -> (Param, Int)? in
        if case let (.project(param, .update(id, _), _, _))? = Navigation.match(request) {
          return (param, id)
        }
        return nil
      }
      .skipNil()
      .switchMap { (param: Param, updateId: Int) in
        AppEnvironment.current.apiService.fetchProject(param: param)
          .demoteErrors()
          .map { project -> (Param, Project, Int) in
            (param, project, updateId)
          }
      }
      .switchMap { (param: Param, project: Project, updateId: Int) in
        AppEnvironment.current.apiService.fetchUpdate(updateId: updateId, projectParam: param)
          .demoteErrors()
          .map { update -> (Project, Update) in
            (project, update)
          }
      }

    self.policyDecisionProperty <~ newNavigationAction
      .map { action in
        if isStripeNavigationAction(action) {
          return true
        }

        let request = action.request

        if !AppEnvironment.current.apiService.isPrepared(request: request) {
          return false
        }

        return isSurvey(request: request)
      }
      .map { $0 ? .allow : .cancel }

    self.webViewLoadRequest = Signal.merge(
      initialRequest,
      newSurveyRequest
    )
    .map { request in AppEnvironment.current.apiService.preparedRequest(forRequest: request) }
  }

  fileprivate let closeButtonTappedProperty = MutableProperty(())
  public func closeButtonTapped() { self.closeButtonTappedProperty.value = () }

  fileprivate let policyForNavigationActionProperty = MutableProperty<WKNavigationActionData?>(nil)
  fileprivate let policyDecisionProperty = MutableProperty(WKNavigationActionPolicy.allow)
  public func decidePolicyFor(navigationAction: WKNavigationActionData) -> WKNavigationActionPolicy {
    self.policyForNavigationActionProperty.value = navigationAction
    return self.policyDecisionProperty.value
  }

  fileprivate let initialSurveyProperty = MutableProperty<String?>(nil)
  public func configureWith(surveyUrl: String) {
    self.initialSurveyProperty.value = surveyUrl
  }

  fileprivate let userSessionStartedProperty = MutableProperty(())
  public func userSessionStarted() {
    self.userSessionStartedProperty.value = ()
  }

  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() { self.viewDidLoadProperty.value = () }

  public let dismissViewController: Signal<Void, Never>
  public let goToProject: Signal<(Param, RefTag?), Never>
  public let goToUpdate: Signal<(Project, Update), Never>
  public let goToPledge: Signal<Param, Never>
  public let webViewLoadRequest: Signal<URLRequest, Never>
  public let goToLoginSignup: Signal<LoginIntent, Never>
  public let title: Signal<String?, Never>

  public var inputs: SurveyResponseViewModelInputs { return self }
  public var outputs: SurveyResponseViewModelOutputs { return self }
}

private func isUnpreparedSurvey(request: URLRequest) -> Bool {
  guard !AppEnvironment.current.apiService.isPrepared(request: request) else { return false }
  return isSurvey(request: request)
}

private func isSurvey(request: URLRequest) -> Bool {
  guard case (.project(_, .surveyWebview, _, _))? = Navigation.match(request) else { return false }
  return true
}

// Returns true if either the url host or the target frame's security origin
// is of the form *.stripe.com, *.stripe.network, or *.stripecdn.com.
private func isStripeNavigationAction(_ actionData: WKNavigationActionData) -> Bool {
  if let host = actionData.request.url?.host, isStripeHost(host) {
    return true
  }
  if let securityOriginHost = actionData.navigationAction.targetFrame?.securityOrigin.host,
     isStripeHost(securityOriginHost) {
    return true
  }
  return false
}

private func isStripeHost(_ host: String) -> Bool {
  let stripeDomains = ["stripe.com", "stripe.network", "stripecdn.com"]

  let withoutSubdomain = host.lowercased().split(separator: ".").suffix(2).joined(separator: ".")
  return stripeDomains.contains(withoutSubdomain)
}
