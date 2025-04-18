import Foundation
import KsApi
import Prelude
import ReactiveSwift

public protocol PledgeManagementDetailsViewModelInputs {
  /// Configure this webview using a `Project`.
  func configure(with backingDetailsURL: URL)

  /// Call when the view loads.
  func viewDidLoad()
}

public protocol PledgeManagementDetailsViewModelOutputs {
  /// Emits a request that should be loaded into the webview.
  var webViewLoadRequest: Signal<URLRequest, Never> { get }
}

public protocol PledgeManagementDetailsViewModelType {
  var inputs: PledgeManagementDetailsViewModelInputs { get }
  var outputs: PledgeManagementDetailsViewModelOutputs { get }
}

public final class PledgeManagementDetailsViewModel: PledgeManagementDetailsViewModelType,
  PledgeManagementDetailsViewModelInputs, PledgeManagementDetailsViewModelOutputs {
  public init() {
    let backingDetailsURL = self.backingDetailsURLProperty.signal
      .skipNil()
      .takeWhen(self.viewDidLoadProperty.signal)

    self.webViewLoadRequest = backingDetailsURL
      .map {
        AppEnvironment.current.apiService.preparedRequest(forURL: $0)
      }
  }

  public var inputs: PledgeManagementDetailsViewModelInputs { return self }
  public var outputs: PledgeManagementDetailsViewModelOutputs { return self }

  public let webViewLoadRequest: Signal<URLRequest, Never>

  private let backingDetailsURLProperty = MutableProperty<URL?>(nil)
  public func configure(with backingDetailsURL: URL) {
    self.backingDetailsURLProperty.value = backingDetailsURL
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }
}
