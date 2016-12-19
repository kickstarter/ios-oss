import KsApi
import ReactiveSwift
import ReactiveExtensions
import Result
import WebKit

public protocol WebModalViewModelInputs {
  /// Call when the close button is tapped.
  func closeButtonTapped()

  /// Call to configure with a request.
  func configureWith(request: URLRequest)

  /// Call when the webview needs to decide a policy for a navigation action. Returns the decision policy.
  func decidePolicyFor(navigationAction: WKNavigationActionProtocol)
    -> WKNavigationActionPolicy

  /// Call when the view loads.
  func viewDidLoad()
}

public protocol WebModalViewModelOutputs {
  /// Emits when the view controller should be dismissed.
  var dismissViewController: Signal<Void, NoError> { get }

  /// Emits a request that should be loaded into the webview.
  var webViewLoadRequest: Signal<NSURLRequest, NoError> { get }
}

public protocol WebModalViewModelType: WebModalViewModelInputs, WebModalViewModelOutputs {
  var inputs: WebModalViewModelInputs { get }
  var outputs: WebModalViewModelOutputs { get }
}

public final class WebModalViewModel: WebModalViewModelType {

  public init() {
    self.dismissViewController = self.closeButtonTappedProperty.signal

    self.policyDecisionProperty <~ self.policyForNavigationActionProperty.signal.ignoreNil()
      .mapConst(.Allow)

    self.webViewLoadRequest = self.requestProperty.signal.ignoreNil()
      .takeWhen(self.viewDidLoadProperty.signal)
      .map { request in
        AppEnvironment.current.apiService.isPrepared(request: request)
          ? request : AppEnvironment.current.apiService.preparedRequest(forRequest: request)
    }
  }

  fileprivate let closeButtonTappedProperty = MutableProperty()
  public func closeButtonTapped() { self.closeButtonTappedProperty.value = () }

  fileprivate let requestProperty = MutableProperty<URLRequest?>(nil)
  public func configureWith(request: URLRequest) {
    self.requestProperty.value = request
  }

  fileprivate let policyForNavigationActionProperty = MutableProperty<WKNavigationActionProtocol?>(nil)
  fileprivate let policyDecisionProperty = MutableProperty(WKNavigationActionPolicy.Allow)
  public func decidePolicyFor(navigationAction: WKNavigationActionProtocol)
    -> WKNavigationActionPolicy {
      self.policyForNavigationActionProperty.value = navigationAction
      return self.policyDecisionProperty.value
  }

  fileprivate let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() { self.viewDidLoadProperty.value = () }

  public let dismissViewController: Signal<Void, NoError>
  public let webViewLoadRequest: Signal<NSURLRequest, NoError>

  public var inputs: WebModalViewModelInputs { return self }
  public var outputs: WebModalViewModelOutputs { return self }
}
