import Foundation
import ReactiveSwift
import Result

protocol LoadingBarButtonItemViewModelOutputs {
  var activityIndicatorIsLoading: Signal<Bool, NoError> { get }
  var titleButtonIsEnabled: Signal<Bool, NoError> { get }
  var titleButtonIsHidden: Signal<Bool, NoError> { get }
  var titleButtonText: Signal<String, NoError> { get }
}

protocol LoadingBarButtonItemViewModelInputs {
  func setIsEnabled(isEnabled: Bool)
  func setTitle(title: String)
  func setAnimating(isAnimating: Bool)
}

protocol LoadingBarButtonItemViewModelType {
  var inputs: LoadingBarButtonItemViewModelInputs { get }
  var outputs: LoadingBarButtonItemViewModelOutputs { get }
}

struct LoadingBarButtonItemViewModel: LoadingBarButtonItemViewModelType,
LoadingBarButtonItemViewModelInputs, LoadingBarButtonItemViewModelOutputs {

  public init() {
    self.activityIndicatorIsLoading = self.isAnimatingProperty.signal
    self.titleButtonIsEnabled = self.isEnabledProperty.signal
    self.titleButtonIsHidden = self.isAnimatingProperty.signal
    self.titleButtonText = self.titleProperty.signal.skipNil()
  }

  private var isEnabledProperty = MutableProperty(false)
  func setIsEnabled(isEnabled: Bool) {
    self.isEnabledProperty.value = isEnabled
  }

  private var titleProperty = MutableProperty<String?>(nil)
  func setTitle(title: String) {
    self.titleProperty.value = title
  }

  private var isAnimatingProperty = MutableProperty(false)
  func setAnimating(isAnimating: Bool) {
    self.isAnimatingProperty.value = isAnimating
  }

  public let activityIndicatorIsLoading: Signal<Bool, NoError>
  public let titleButtonIsEnabled: Signal<Bool, NoError>
  public let titleButtonIsHidden: Signal<Bool, NoError>
  public let titleButtonText: Signal<String, NoError>

  var inputs: LoadingBarButtonItemViewModelInputs {
    return self
  }

  var outputs: LoadingBarButtonItemViewModelOutputs {
    return self
  }
}
