import ReactiveSwift
import UIKit

public protocol LandingPageViewModelInputs {
  func viewDidLoad()
}

public protocol LandingPageViewModelOutputs {
  var landingPageCards: Signal<[UIView], Never> { get }
}

public protocol LandingPageViewModelType {
  var inputs: LandingPageViewModelInputs { get }
  var outputs: LandingPageViewModelOutputs { get }
}

final public class LandingPageViewModel: LandingPageViewModelType, LandingPageViewModelInputs,
LandingPageViewModelOutputs {

  public init() {
    self.landingPageCards = self.viewDidLoadSignal
    .map(cards)
    .skipNil()
  }

  private let (viewDidLoadSignal, viewDidLoadObserver) = Signal<(), Never>.pipe()
  public func viewDidLoad() {
    self.viewDidLoadObserver.send(value: ())
  }

  public let landingPageCards: Signal<[UIView], Never>

  public var inputs: LandingPageViewModelInputs { return self }
  public var outputs: LandingPageViewModelOutputs { return self }
}

private func cards() -> [UIView]? {
  return nil
}
