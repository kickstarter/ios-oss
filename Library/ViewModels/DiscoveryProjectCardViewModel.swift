import Foundation
import ReactiveSwift

public protocol DiscoveryProjectCardViewModelInputs {
//  func configure(with value: DiscoveryCell)
}

public protocol DiscoveryProjectCardViewModelOutputs {
  var goalMetIconHidden: Signal<Bool, Never> { get }
  var projectNameLabelText: Signal<String, Never> { get }
  var projectBlurbLabelText: Signal<String, Never> { get }
  var backerCountLabelText: Signal<String, Never> { get }
  var backerLabelText: Signal<String, Never> { get }
  var percentFundedLabelText: Signal<String, Never> { get }
}

public protocol DiscoveryProjectCardViewModelType {
  var inputs: DiscoveryProjectCardViewModelInputs { get }
  var outputs: DiscoveryProjectCardViewModelOutputs { get }
}

public final class DiscoveryProjectCardViewModel: DiscoveryProjectCardViewModelType,
  DiscoveryProjectCardViewModelInputs, DiscoveryProjectCardViewModelOutputs {
  public init() {

  }

  public var inputs: DiscoveryProjectCardViewModelInputs { return self }
  public var outputs: DiscoveryProjectCardViewModelOutputs { return self }
}
