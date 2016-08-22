import Argo
import KsApi
import ReactiveCocoa
import ReactiveExtensions
import Result

internal struct CheckoutData {
  internal let intent: CheckoutIntent
  internal let project: Project
  internal let reward: Reward?
}

internal struct RequestData {
  internal let request: NSURLRequest
  internal let navigation: Navigation?
  internal let shouldStartLoad: Bool
  internal let webViewNavigationType: UIWebViewNavigationType
}

public protocol CheckoutViewModelInputs {
  /// Call to set the project, reward, and why the user is checking out.
  func configureWith(project project: Project, reward: Reward?, intent: CheckoutIntent)

  /// Call when the webview decides whether to load a request.
  func shouldStartLoad(withRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool

  /// Call when a user session has started.
  func userSessionStarted()

  /// Call when the view loads.
  func viewDidLoad()
}

public protocol CheckoutViewModelOutputs {
  /// Emits when the login tout should be closed.
  var closeLoginTout: Signal<Void, NoError> { get }

  /// Emits when the login tout should be opened.
  var openLoginTout: Signal<Void, NoError> { get }

  /// Emits when the thanks screen should be loaded.
  var goToThanks: Signal<Project, NoError> { get }

  /// Emits when the view controller should be popped.
  var popViewController: Signal<Void, NoError> { get }

  /// Emits a request that should be loaded into the webview.
  var webViewLoadRequest: Signal<NSURLRequest, NoError> { get }
}

public protocol CheckoutViewModelType: CheckoutViewModelInputs, CheckoutViewModelOutputs {
  var inputs: CheckoutViewModelInputs { get }
  var outputs: CheckoutViewModelOutputs { get }
}

public final class CheckoutViewModel: CheckoutViewModelType {
  // swiftlint:disable function_body_length
  public init() {
    let checkoutData = self.checkoutDataProperty.signal.ignoreNil()
    let userSessionStarted = self.userSessionStartedProperty.signal

    let initialRequest = checkoutData
      .takeWhen(self.viewDidLoadProperty.signal)
      .map(buildInitialRequest)
      .ignoreNil()

    let requestData = self.shouldStartLoadProperty.signal.ignoreNil()
      .map { request, navigationType -> RequestData in
        let navigation = Navigation.match(request)

        let shouldStartLoad = isNavigationLoadedByWebView(navigation: navigation)
          && AppEnvironment.current.apiService.isPrepared(request: request)

        return RequestData(request: request,
          navigation: navigation,
          shouldStartLoad: shouldStartLoad,
          webViewNavigationType: navigationType)
    }

    let allowedRequests = requestData
      .filter { requestData in
        // Allow through requests that the web view can load once they're prepared.
        !requestData.shouldStartLoad && isNavigationLoadedByWebView(navigation: requestData.navigation)
      }
      .map { $0.request }

    let retryAfterSessionStartedRequest = requestData
      .combinePrevious()
      .takeWhen(userSessionStarted)
      .map { previous, _ in previous.request }

    let thanksRequest = requestData
      .filter { requestData in
        if let navigation = requestData.navigation,
          case .project(_, .checkout(_, .thanks), _) = navigation { return true }
        return false
      }
      .ignoreValues()

    self.closeLoginTout = userSessionStarted

    self.goToThanks = checkoutData
      .map { $0.project }
      .takeWhen(thanksRequest)

    self.openLoginTout = requestData
      .filter { $0.navigation == .signup }
      .ignoreValues()

    self.popViewController = requestData
      .filter { requestData in
        if let navigation = requestData.navigation,
          case .project(_, .root, _) = navigation { return true }
        return false
      }
      .ignoreValues()

    self.shouldStartLoadResponseProperty <~ requestData
      .map { $0.shouldStartLoad }

    self.webViewLoadRequest = Signal.merge(
      allowedRequests,
      initialRequest,
      retryAfterSessionStartedRequest
      )
      .map { AppEnvironment.current.apiService.preparedRequest(forRequest: $0) }
  }
  // swiftlint:enable function_body_length

  private let checkoutDataProperty = MutableProperty<(CheckoutData)?>(nil)
  public func configureWith(project project: Project, reward: Reward?, intent: CheckoutIntent) {
    self.checkoutDataProperty.value = CheckoutData(intent: intent, project: project, reward: reward)
  }

  private let shouldStartLoadProperty = MutableProperty<(NSURLRequest, UIWebViewNavigationType)?>(nil)
  private let shouldStartLoadResponseProperty = MutableProperty(false)
  public func shouldStartLoad(withRequest request: NSURLRequest,
                                          navigationType: UIWebViewNavigationType) -> Bool {
    self.shouldStartLoadProperty.value = (request, navigationType)
    return self.shouldStartLoadResponseProperty.value
  }

  private let userSessionStartedProperty = MutableProperty()
  public func userSessionStarted() {
    self.userSessionStartedProperty.value = ()
  }

  private let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() { self.viewDidLoadProperty.value = () }

  public let closeLoginTout: Signal<Void, NoError>
  public let openLoginTout: Signal<Void, NoError>
  public let goToThanks: Signal<Project, NoError>
  public let popViewController: Signal<Void, NoError>
  public let webViewLoadRequest: Signal<NSURLRequest, NoError>

  public var inputs: CheckoutViewModelInputs { return self }
  public var outputs: CheckoutViewModelOutputs { return self }
}

private func buildInitialRequest(checkoutData: CheckoutData) -> NSURLRequest? {
  guard let baseURL = NSURL(string: checkoutData.project.urls.web.project) else { return nil }
  var pathToAppend: String
  switch checkoutData.intent {
  case .manage:
    pathToAppend = "pledge/edit"
  case .new:
    pathToAppend = "pledge/new"
  }
  return NSURLRequest(URL: baseURL.URLByAppendingPathComponent(pathToAppend))
}

private func isNavigationLoadedByWebView(navigation navigation: Navigation?) -> Bool {
  guard let nav = navigation else { return false }
  switch nav {
  case
    .checkout(_, .payments(.root)),
    .checkout(_, .payments(.new)),
    .checkout(_, .payments(.useStoredCard)),
    .project(_, .pledge(.destroy), _),
    .project(_, .pledge(.edit), _),
    .project(_, .pledge(.new), _),
    .project(_, .pledge(.root), _):
    return true
  default:
    return false
  }
}
