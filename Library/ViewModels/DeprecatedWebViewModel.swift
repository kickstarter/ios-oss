import ReactiveSwift
import Result

public protocol DeprecatedWebViewModelInputs {
  /// Call when the view loads.
  func viewDidLoad()

  /// Call when the webview encounters an error.
  func webViewDidFail(withError error: NSError?)

  /// Call when the webview finishes loading.
  func webViewDidFinishLoad()

  /// Call when the webview begins loading.
  func webViewDidStartLoad()
}

public protocol DeprecatedWebViewModelOutputs {
  var loadingOverlayIsHiddenAndAnimate: Signal<(isHidden: Bool, animate: Bool), NoError> { get }
}

public protocol DeprecatedWebViewModelType {
  var inputs: DeprecatedWebViewModelInputs { get }
  var outputs: DeprecatedWebViewModelOutputs { get }
}

public final class DeprecatedWebViewModel: DeprecatedWebViewModelType, DeprecatedWebViewModelInputs,
DeprecatedWebViewModelOutputs {

  public init() {
    self.loadingOverlayIsHiddenAndAnimate = Signal.merge(
      // Hide when first starting out
      self.viewDidLoadProperty.signal.mapConst((true, false)),

      // Show loading when a request starts
      self.webViewDidStartLoadProperty.signal.mapConst((false, true)),

      // Hide loading when a request ends
      self.webViewDidFinishLoadProperty.signal.mapConst((true, true)),

      // Hide loading if the web view fails with a non-102 error code (102 is the interrupted error that
      // occurs anytime we cancel a request).
      self.webViewDidFailErrorProperty.signal
        .filter { $0?.code != 102 }
        .mapConst((true, true))
      )
      .skipRepeats(==)
  }

  fileprivate let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  fileprivate let webViewDidFailErrorProperty = MutableProperty<NSError?>(nil)
  public func webViewDidFail(withError error: NSError?) {
    self.webViewDidFailErrorProperty.value = error
  }

  fileprivate let webViewDidFinishLoadProperty = MutableProperty()
  public func webViewDidFinishLoad() {
    self.webViewDidFinishLoadProperty.value = ()
  }

  fileprivate let webViewDidStartLoadProperty = MutableProperty()
  public func webViewDidStartLoad() {
    self.webViewDidStartLoadProperty.value = ()
  }

  public let loadingOverlayIsHiddenAndAnimate: Signal<(isHidden: Bool, animate: Bool), NoError>

  public var inputs: DeprecatedWebViewModelInputs { return self }
  public var outputs: DeprecatedWebViewModelOutputs { return self }
}
