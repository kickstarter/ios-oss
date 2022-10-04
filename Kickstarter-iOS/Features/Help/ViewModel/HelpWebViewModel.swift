import Foundation
import Library
import Prelude
import ReactiveSwift

internal protocol HelpWebViewModelInputs {
  /// Call to configure with HelpType.
  func configureWith(helpType: HelpType)

  /// Call when the view loads.
  func viewDidLoad()
}

internal protocol HelpWebViewModelOutputs {
  /// Emits a request that should be loaded into the webview.
  var webViewLoadRequest: Signal<URLRequest, Never> { get }
}

internal protocol HelpWebViewModelType {
  var inputs: HelpWebViewModelInputs { get }
  var outputs: HelpWebViewModelOutputs { get }
}

internal final class HelpWebViewModel: HelpWebViewModelType, HelpWebViewModelInputs, HelpWebViewModelOutputs {
  internal init() {
    self.webViewLoadRequest = self.helpTypeProperty.signal.skipNil()
      .takeWhen(self.viewDidLoadProperty.signal)
      .map { $0.url(withBaseUrl: AppEnvironment.current.apiService.serverConfig.webBaseUrl) }
      .skipNil()
      .map { AppEnvironment.current.apiService.preparedRequest(forURL: $0) }
  }

  internal var inputs: HelpWebViewModelInputs { return self }
  internal var outputs: HelpWebViewModelOutputs { return self }

  internal let webViewLoadRequest: Signal<URLRequest, Never>

  fileprivate let helpTypeProperty = MutableProperty<HelpType?>(nil)
  func configureWith(helpType: HelpType) {
    self.helpTypeProperty.value = helpType
  }

  fileprivate let viewDidLoadProperty = MutableProperty(())
  func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }
}
