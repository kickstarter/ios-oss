import Foundation
import ReactiveSwift

public protocol LandingViewModelInputs {
  func getStartedButtonTapped()
  func viewDidLoad()
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
    self.viewDidLoadProperty.signal.observeValues {
      AppEnvironment.current.userDefaults.hasSeenCategoryPersonalizationFlow = true
    }

    self.goToCategorySelection = self.getStartedButtonTappedProperty.signal

    // Tracking

    self.getStartedButtonTappedProperty.signal
      .observeValues {
        let optimizelyProps = optimizelyProperties() ?? [:]

        AppEnvironment.current.koala
          .trackOnboardingGetStartedButtonClicked(optimizelyProperties: optimizelyProps)

        AppEnvironment.current.optimizelyClient?.track(eventName: "Get Started Button Clicked")
      }
  }

  private let getStartedButtonTappedProperty = MutableProperty(())
  public func getStartedButtonTapped() {
    self.getStartedButtonTappedProperty.value = ()
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let goToCategorySelection: Signal<Void, Never>

  public var inputs: LandingViewModelInputs { return self }
  public var outputs: LandingViewModelOutputs { return self }
}
