import FirebaseCrashlytics
import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift
import WebKit

// All requests that can be intercepted from the web view and opened natively
// should be defined in this enum.
public enum PledgeManagerNativeNatigationRequest: Equatable {
  case goToProject(param: Param, refTag: RefTag?)
  case goToUpdate(param: Param, updateId: Int)
  case goToPledge(param: Param)
}

public protocol PledgeManagerWebViewModelInputs {
  /// Call when the close button is tapped.
  func closeButtonTapped()

  /// Call to configure with a survey url.
  func configureWith(url: String)

  /// Call when the webview needs to decide a policy for a navigation action. Returns the decision policy.
  func decidePolicyFor(navigationAction: WKNavigationActionData) -> WKNavigationActionPolicy

  /// Call when view model should handle fetching the necessary data and trigger `goToUpdate`.
  func fetchUpdateVCData(param: Param, updateId: Int)

  /// Call when the user session starts.
  func userSessionStarted()

  /// Call when the view loads.
  func viewDidLoad()
}

public protocol PledgeManagerWebViewModelOutputs {
  /// Emits when the view controller should be dismissed.
  var dismissViewController: Signal<Void, Never> { get }

  /// Emits native navigation request for the view controller to handle.
  var goToNativeScreen: Signal<PledgeManagerNativeNatigationRequest, Never> { get }

  /// Emits a project and update that should be used to present the update view controller.
  var presentUpdateVC: Signal<(Project, Update), Never> { get }

  /// Emits a login intent that should be used to log in.
  var goToLoginSignup: Signal<LoginIntent, Never> { get }

  /// Emits a title, if any, that should be shown in the top bar.
  /// `nil` should reset the view to have no title.
  var title: Signal<String?, Never> { get }

  /// Emits a request that should be loaded by the webview.
  var webViewLoadRequest: Signal<URLRequest, Never> { get }
}

public protocol PledgeManagerWebViewModelType: PledgeManagerWebViewModelInputs,
  PledgeManagerWebViewModelOutputs {
  var inputs: PledgeManagerWebViewModelInputs { get }
  var outputs: PledgeManagerWebViewModelOutputs { get }
}

public final class PledgeManagerWebViewModel: PledgeManagerWebViewModelType {
  // swiftlint:disable:next function_body_length
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
      self.initialUrlProperty.signal.skipNil(),
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
        if isSupportedRequest(request: request) {
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

    let newUnpreparedRequest = newRequest
      .filter { request in
        isUnpreparedSupportedRequest(request: request)
      }

    self.dismissViewController = self.closeButtonTappedProperty.signal

    self.goToNativeScreen = newRequest
      .map(nativeNavigationRequestForURLRequest)
      .skipNil()

    self.presentUpdateVC = self.fetchUpdateVCDataProperty.signal.skipNil()
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

        // A supported request will be prepared by logic elsewhere in the class and loaded into
        // the web view from there. Never allow the unprepared version of these to render.
        let request = action.request
        if isSupportedRequest(request: request) {
          return AppEnvironment.current.apiService.isPrepared(request: request)
        }

        // If the corresponding native navigation request exists,
        // this request will be handled elsewhere.
        if nativeNavigationRequestForURLRequest(request) != nil {
          return false
        }

        // Log unrecognized urls.
        if let error = errorForUnrecognizedUrl(request: request) {
          Crashlytics.crashlytics().record(error: error)
        }

        // Never show unsupported kickstarter navigation requests, since these
        // can get the user into bad/weird states.
        if isKickstarterRequest(request) {
          return false
        }

        return featureBypassPledgeManagerDecisionPolicyEnabled()
      }
      .map { $0 ? .allow : .cancel }

    self.webViewLoadRequest = Signal.merge(
      initialRequest,
      newUnpreparedRequest
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

  fileprivate let initialUrlProperty = MutableProperty<String?>(nil)
  public func configureWith(url: String) {
    self.initialUrlProperty.value = url
  }

  fileprivate let fetchUpdateVCDataProperty = MutableProperty<(Param, Int)?>(nil)
  public func fetchUpdateVCData(param: Param, updateId: Int) {
    self.fetchUpdateVCDataProperty.value = (param, updateId)
  }

  fileprivate let userSessionStartedProperty = MutableProperty(())
  public func userSessionStarted() {
    self.userSessionStartedProperty.value = ()
  }

  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() { self.viewDidLoadProperty.value = () }

  public let dismissViewController: Signal<Void, Never>
  public let goToNativeScreen: Signal<PledgeManagerNativeNatigationRequest, Never>
  public let presentUpdateVC: Signal<(Project, Update), Never>
  public let webViewLoadRequest: Signal<URLRequest, Never>
  public let goToLoginSignup: Signal<LoginIntent, Never>
  public let title: Signal<String?, Never>

  public var inputs: PledgeManagerWebViewModelInputs { return self }
  public var outputs: PledgeManagerWebViewModelOutputs { return self }
}

// All navigation requests returned by this function should be passed along to
// the view controller so it can open their native views. Any request that
// doesn't have a corresponding native request will either be displayed in the
// webview or be discarded.
private func nativeNavigationRequestForURLRequest(_ request: URLRequest)
  -> PledgeManagerNativeNatigationRequest? {
  switch Navigation.match(request) {
  case let (.project(param, .root, refInfo, _))?:
    return .goToProject(param: param, refTag: refInfo?.refTag)
  case let (.project(param, .pledge, _, _))?:
    return .goToPledge(param: param)
  case let (.project(param, .update(id, _), _, _))?:
    return .goToUpdate(param: param, updateId: id)
  default: return nil
  }
}

private func isKickstarterRequest(_ request: URLRequest) -> Bool {
  guard let host = request.url?.host() else { return false }
  return host == AppEnvironment.current.apiService.serverConfig.webBaseUrl.host()
}

private func isUnpreparedSupportedRequest(request: URLRequest) -> Bool {
  guard !AppEnvironment.current.apiService.isPrepared(request: request) else { return false }
  return isSupportedRequest(request: request)
}

private func isSupportedRequest(request: URLRequest) -> Bool {
  guard case (.project(_, .pledgeManagerWebview, _, _))? = Navigation.match(request) else { return false }
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

private func errorForUnrecognizedUrl(request: URLRequest) -> NSError? {
  let errorDomain = "Kickstarter.PledgeManagerWebView"
  enum ErrorCode: Int {
    case unhandledKickstarterUrl = 1
    case unrecognizedUrl = 2
  }

  // If there's no url present, don't log an error. The "about:blank" happens
  // every time the web view loads, so logging these would be too noisy.
  guard let url = request.url, url.absoluteString != "about:blank" else {
    return nil
  }

  if isKickstarterRequest(request) {
    return NSError(
      domain: errorDomain,
      code: ErrorCode.unhandledKickstarterUrl.rawValue,
      userInfo: [
        NSLocalizedDescriptionKey: "Found unhandled kickstarter url"
      ]
    )
  }

  return NSError(
    domain: errorDomain,
    code: ErrorCode.unrecognizedUrl.rawValue,
    userInfo: [
      NSLocalizedDescriptionKey: "Found unrecongnized url request with host: \(url.host() ?? "Unknown")"
    ]
  )
}
