import ReactiveSwift
import UIKit

public protocol LandingPageViewModelInputs {
  func viewDidLoad()
}

public protocol LandingPageViewModelOutputs {
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

    self.numberOfPages = self.landingPageCards
      .map(\.count)
  }

  private let (viewDidLoadSignal, viewDidLoadObserver) = Signal<(), Never>.pipe()
  public func viewDidLoad() {
    self.viewDidLoadObserver.send(value: ())
  }

  public let landingPageCards: Signal<[LandingPageCardType], Never>
  public let numberOfPages: Signal<Int, Never>

  public var inputs: LandingPageViewModelInputs { return self }
  public var outputs: LandingPageViewModelOutputs { return self }
}

private func cards() -> [LandingPageCardType]? {
  let userAttributes = optimizelyUserAttributes(
    with: AppEnvironment.current.currentUser,
    project: nil,
    refTag: nil
  )

  let optimizelyVariant = AppEnvironment.current.optimizelyClient?
    .variant(
      for: OptimizelyExperiment.Key.nativeOnboarding,
      userId: deviceIdentifier(uuid: UUID()),
      isAdmin: AppEnvironment.current.currentUser?.isAdmin ?? false,
      userAttributes: userAttributes
    )

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
