import Library
import Prelude
import ReactiveCocoa
import Result

internal protocol HelpWebViewModelInputs {
  /// Call to configure with HelpType.
  func configureWith(helpType helpType: HelpType)

  /// Call when the view loads.
  func viewDidLoad()
}

internal protocol HelpWebViewModelOutputs {
  /// Emits a request that should be loaded into the webview.
  var webViewLoadRequest: Signal<NSURLRequest, NoError> { get }
}

internal protocol HelpWebViewModelType {
  var inputs: HelpWebViewModelInputs { get }
  var outputs: HelpWebViewModelOutputs { get }
}

internal final class HelpWebViewModel: HelpWebViewModelType, HelpWebViewModelInputs, HelpWebViewModelOutputs {
  internal init() {
    self.webViewLoadRequest = self.helpTypeProperty.signal.ignoreNil()
      .takeWhen(self.viewDidLoadProperty.signal)
      .map { urlForHelpType($0, baseUrl: AppEnvironment.current.apiService.serverConfig.webBaseUrl) }
      .map { AppEnvironment.current.apiService.preparedRequest(forURL: $0) }
  }

  internal var inputs: HelpWebViewModelInputs { return self }
  internal var outputs: HelpWebViewModelOutputs { return self }

  internal let webViewLoadRequest: Signal<NSURLRequest, NoError>

  private let helpTypeProperty = MutableProperty<HelpType?>(nil)
  func configureWith(helpType helpType: HelpType) {
    self.helpTypeProperty.value = helpType
  }
  private let viewDidLoadProperty = MutableProperty()
  func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }
}

private func urlForHelpType(helpType: HelpType, baseUrl: NSURL) -> NSURL {
  switch helpType {
  case .cookie:
    return baseUrl.URLByAppendingPathComponent("cookies")
  case .faq:
    return baseUrl.URLByAppendingPathComponent("help/faq/kickstarter+basics")
  case .howItWorks:
    return baseUrl.URLByAppendingPathComponent("about")
  case .privacy:
    return baseUrl.URLByAppendingPathComponent("privacy")
  case .terms:
    return baseUrl.URLByAppendingPathComponent("terms-of-use")
  default:
    return baseUrl
  }
}
