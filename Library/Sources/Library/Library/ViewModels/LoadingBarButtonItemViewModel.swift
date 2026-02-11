import Foundation
import ReactiveSwift

public protocol LoadingBarButtonItemViewModelOutputs {
  var activityIndicatorIsLoading: Signal<Bool, Never> { get }
  var titleButtonIsEnabled: Signal<Bool, Never> { get }
  var titleButtonIsHidden: Signal<Bool, Never> { get }
  var titleButtonText: Signal<String, Never> { get }
}

public protocol LoadingBarButtonItemViewModelInputs {
  func setIsEnabled(isEnabled: Bool)
  func setTitle(title: String)
  func setAnimating(isAnimating: Bool)
}

public protocol LoadingBarButtonItemViewModelType {
  var inputs: LoadingBarButtonItemViewModelInputs { get }
  var outputs: LoadingBarButtonItemViewModelOutputs { get }
}

public final class LoadingBarButtonItemViewModel: LoadingBarButtonItemViewModelType,
  LoadingBarButtonItemViewModelInputs, LoadingBarButtonItemViewModelOutputs {
  public init() {
    self.activityIndicatorIsLoading = self.isAnimatingProperty.signal
    self.titleButtonIsEnabled = self.isEnabledProperty.signal
    self.titleButtonIsHidden = self.isAnimatingProperty.signal
    self.titleButtonText = self.titleProperty.signal.skipNil()
  }

  private var isEnabledProperty = MutableProperty(false)
  public func setIsEnabled(isEnabled: Bool) {
    self.isEnabledProperty.value = isEnabled
  }

  private var titleProperty = MutableProperty<String?>(nil)
  public func setTitle(title: String) {
    self.titleProperty.value = title
  }

  private var isAnimatingProperty = MutableProperty(false)
  public func setAnimating(isAnimating: Bool) {
    self.isAnimatingProperty.value = isAnimating
  }

  public let activityIndicatorIsLoading: Signal<Bool, Never>
  public let titleButtonIsEnabled: Signal<Bool, Never>
  public let titleButtonIsHidden: Signal<Bool, Never>
  public let titleButtonText: Signal<String, Never>

  public var inputs: LoadingBarButtonItemViewModelInputs {
    return self
  }

  public var outputs: LoadingBarButtonItemViewModelOutputs {
    return self
  }
}
