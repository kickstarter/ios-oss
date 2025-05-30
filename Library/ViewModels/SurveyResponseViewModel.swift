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

    let newRequest = self.policyForNavigationActionProperty.signal.skipNil()
      .map { action in action.request }

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

    self.policyDecisionProperty <~ newRequest
      .map { request in
        if isStripeRequest(request) {
          return true
        }

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

// Returns true if the url host is of the form *.stripe.com, *.stripe.network, or *.stripecdn.com.
private func isStripeRequest(_ request: URLRequest) -> Bool {
  let stripeDomains = ["stripe.com", "stripe.network", "stripecdn.com"]

  guard let host = request.url?.host?.lowercased() else { return false }
  let withoutSubdomain = host.split(separator: ".").suffix(2).joined(separator: ".")
  return stripeDomains.contains(withoutSubdomain)
}
