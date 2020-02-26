import ReactiveSwift
import UIKit

public protocol LandingPageViewModelInputs {
  func ctaButtonTapped()
  func viewDidLoad()
}

public protocol LandingPageViewModelOutputs {
  var dismissViewController: Signal<(), Never> { get }
  var landingPageCards: Signal<[UIView], Never> { get }
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
      .on(value: { _ in
        AppEnvironment.current.ubiquitousStore.hasSeenLandingPage = true
        AppEnvironment.current.userDefaults.hasSeenLandingPage = true
      })
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
  public let landingPageCards: Signal<[UIView], Never>

  public var inputs: LandingPageViewModelInputs { return self }
  public var outputs: LandingPageViewModelOutputs { return self }
}

private func cards() -> [UIView]? {
  return nil
}
