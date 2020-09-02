import Foundation
import ReactiveSwift

public protocol RewardCellViewModelInputs {
  func configure(with data: RewardCardViewData)
  func prepareForReuse()
}

public protocol RewardCellViewModelOutputs {
  var backerLabelHidden: Signal<Bool, Never> { get }
  var scrollScrollViewToTop: Signal<Void, Never> { get }
}

public protocol RewardCellViewModelType {
  var inputs: RewardCellViewModelInputs { get }
  var outputs: RewardCellViewModelOutputs { get }
}

public final class RewardCellViewModel: RewardCellViewModelType, RewardCellViewModelInputs,
  RewardCellViewModelOutputs {
  public init() {
    self.scrollScrollViewToTop = self.prepareForReuseProperty.signal
    self.backerLabelHidden = self.configDataProperty.signal.skipNil()
      .map { project, reward, _ in
        userIsBacking(reward: reward, inProject: project)
      }
      .negate()
  }

  private let configDataProperty = MutableProperty<RewardCardViewData?>(nil)
  public func configure(with data: RewardCardViewData) {
    self.configDataProperty.value = data
  }

  private let prepareForReuseProperty = MutableProperty(())
  public func prepareForReuse() {
    self.prepareForReuseProperty.value = ()
  }

  public let backerLabelHidden: Signal<Bool, Never>
  public let scrollScrollViewToTop: Signal<Void, Never>

  public var inputs: RewardCellViewModelInputs { return self }
  public var outputs: RewardCellViewModelOutputs { return self }
}
