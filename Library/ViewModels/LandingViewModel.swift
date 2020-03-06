import Foundation
import ReactiveSwift

public protocol LandingViewModelInputs {
  func getStartedButtonTapped()
}

public protocol LandingViewModelOutputs {
  var goToCategorySelection: Signal<Void, Never> { get }
}

public protocol LandingViewModelType {
  var inputs: LandingViewModelInputs { get }
  var outputs: LandingViewModelOutputs { get }
}

public final class LandingViewModel: LandingViewModelType, LandingViewModelInputs, LandingViewModelOutputs {
  public init() {
    self.goToCategorySelection = self.getStartedButtonTappedProperty.signal
  }

  private let getStartedButtonTappedProperty = MutableProperty(())
  public func getStartedButtonTapped() {
    self.getStartedButtonTappedProperty.value = ()
  }

  public let goToCategorySelection: Signal<Void, Never>

  public var inputs: LandingViewModelInputs { return self }
  public var outputs: LandingViewModelOutputs { return self }
}
