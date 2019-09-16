import Foundation
import ReactiveSwift

public protocol RewardCellViewModelOutputs {
  var scrollScrollViewToTop: Signal<Void, Never> { get }
}

public protocol RewardCellViewModelInputs {
  func prepareForReuse()
}

public protocol RewardCellViewModelType {
  var inputs: RewardCellViewModelInputs { get }
  var outputs: RewardCellViewModelOutputs { get }
}

public final class RewardCellViewModel: RewardCellViewModelType, RewardCellViewModelInputs,
  RewardCellViewModelOutputs {
  public init() {
    self.scrollScrollViewToTop = self.prepareForReuseProperty.signal
  }

  private let prepareForReuseProperty = MutableProperty(())
  public func prepareForReuse() {
    self.prepareForReuseProperty.value = ()
  }

  public let scrollScrollViewToTop: Signal<Void, Never>

  public var inputs: RewardCellViewModelInputs { return self }
  public var outputs: RewardCellViewModelOutputs { return self }
}
