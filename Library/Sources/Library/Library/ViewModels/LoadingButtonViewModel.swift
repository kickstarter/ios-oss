import Prelude
import ReactiveSwift

public protocol LoadingButtonViewModelInputs {
  func isLoading(_ isLoading: Bool)
}

public protocol LoadingButtonViewModelOutputs {
  var isUserInteractionEnabled: Signal<Bool, Never> { get }
  var startLoading: Signal<Void, Never> { get }
  var stopLoading: Signal<Void, Never> { get }
}

public protocol LoadingButtonViewModelType {
  var inputs: LoadingButtonViewModelInputs { get }
  var outputs: LoadingButtonViewModelOutputs { get }
}

public final class LoadingButtonViewModel:
  LoadingButtonViewModelType,
  LoadingButtonViewModelInputs,
  LoadingButtonViewModelOutputs {
  public init() {
    let isLoading = self.isLoadingProperty.signal
      .skipNil()

    self.isUserInteractionEnabled = isLoading
      .negate()

    self.startLoading = isLoading
      .filter(isTrue)
      .ignoreValues()

    self.stopLoading = isLoading
      .filter(isFalse)
      .ignoreValues()
  }

  private let isLoadingProperty = MutableProperty<Bool?>(nil)
  public func isLoading(_ isLoading: Bool) {
    self.isLoadingProperty.value = isLoading
  }

  public let isUserInteractionEnabled: Signal<Bool, Never>
  public let startLoading: Signal<Void, Never>
  public let stopLoading: Signal<Void, Never>

  public var inputs: LoadingButtonViewModelInputs { return self }
  public var outputs: LoadingButtonViewModelOutputs { return self }
}
