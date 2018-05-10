import Library
import Prelude
import ReactiveSwift
import Result

internal protocol HelpWebViewModelInputs {
  /// Call to configure with HelpType.
  func configureWith(helpType: HelpType)

  /// Call when the view loads.
  func viewDidLoad()
}

internal protocol HelpWebViewModelOutputs {
  /// Emits a request that should be loaded into the webview.
  var webViewLoadRequest: Signal<URLRequest, NoError> { get }
}

internal protocol HelpWebViewModelType {
  var inputs: HelpWebViewModelInputs { get }
  var outputs: HelpWebViewModelOutputs { get }
}

internal final class HelpWebViewModel: HelpWebViewModelType, HelpWebViewModelInputs, HelpWebViewModelOutputs {
  internal init() {
    self.webViewLoadRequest = self.helpTypeProperty.signal.skipNil()
      .takeWhen(self.viewDidLoadProperty.signal)
      .map { urlForHelpType($0, baseUrl: AppEnvironment.current.apiService.serverConfig.webBaseUrl) }
      .skipNil()
      .map { AppEnvironment.current.apiService.preparedRequest(forURL: $0) }
  }

  internal var inputs: HelpWebViewModelInputs { return self }
  internal var outputs: HelpWebViewModelOutputs { return self }

  internal let webViewLoadRequest: Signal<URLRequest, NoError>

  fileprivate let helpTypeProperty = MutableProperty<HelpType?>(nil)
  func configureWith(helpType: HelpType) {
    self.helpTypeProperty.value = helpType
  }
  fileprivate let viewDidLoadProperty = MutableProperty(())
  func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }
}

private func urlForHelpType(_ helpType: HelpType, baseUrl: URL) -> URL? {
  switch helpType {
  case .cookie:
    return baseUrl.appendingPathComponent("cookies")
  case .contact:
    return nil
  case .helpCenter:
    return AppEnvironment.current.apiService.serverConfig.helpCenterUrl
  case .howItWorks:
    return baseUrl.appendingPathComponent("about")
  case .privacy:
    return baseUrl.appendingPathComponent("privacy")
  case .terms:
    return baseUrl.appendingPathComponent("terms-of-use")
  case .trust:
    return baseUrl.appendingPathComponent("trust")
  }
}
