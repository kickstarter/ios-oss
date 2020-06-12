import ReactiveSwift
import UIKit

public protocol LandingPageViewModelInputs {
  func ctaButtonTapped()
  func viewDidLoad()
}

public protocol LandingPageViewModelOutputs {
  var dismissViewController: Signal<(), Never> { get }
  var landingPageCards: Signal<[LandingPageCardType], Never> { get }
  var numberOfPages: Signal<Int, Never> { get }
}

public protocol LandingPageViewModelType {
  var inputs: LandingPageViewModelInputs { get }
  var outputs: LandingPageViewModelOutputs { get }
}

public final class LandingPageViewModel: LandingPageViewModelType, LandingPageViewModelInputs,
  LandingPageViewModelOutputs {
  public init() {
    self.landingPageCards = self.viewDidLoadSignal
      .map(cards)
      .skipNil()

    self.dismissViewController = self.ctaButtonTappedSignal

    self.numberOfPages = self.landingPageCards
      .map(\.count)

    self.viewDidLoadSignal
      .observeValues { _ in
        AppEnvironment.current.userDefaults.hasSeenLandingPage = true
      }

    // Tracking

    self.ctaButtonTappedSignal
      .observeValues {
        let optimizelyProps = optimizelyProperties() ?? [:]

        AppEnvironment.current.koala
          .trackOnboardingGetStartedButtonClicked(optimizelyProperties: optimizelyProps)

        AppEnvironment.current.optimizelyClient?.track(eventName: "Get Started Button Clicked")
      }
  }

  private let (ctaButtonTappedSignal, ctaButtonTappedObserver) = Signal<(), Never>.pipe()
  public func ctaButtonTapped() {
    self.ctaButtonTappedObserver.send(value: ())
  }

  private let (viewDidLoadSignal, viewDidLoadObserver) = Signal<(), Never>.pipe()
  public func viewDidLoad() {
    self.viewDidLoadObserver.send(value: ())
  }

  public let dismissViewController: Signal<(), Never>
  public let landingPageCards: Signal<[LandingPageCardType], Never>
  public let numberOfPages: Signal<Int, Never>

  public var inputs: LandingPageViewModelInputs { return self }
  public var outputs: LandingPageViewModelOutputs { return self }
}

private func cards() -> [LandingPageCardType]? {
  let optimizelyVariant = AppEnvironment.current.optimizelyClient?
    .variant(for: OptimizelyExperiment.Key.nativeOnboarding)

  guard let variant = optimizelyVariant else {
    return nil
  }

  switch variant {
  case .variant1:
    return LandingPageCardType.statsCards
  case .variant2:
    return LandingPageCardType.howToCards
  case .control:
    return nil
  }
}
