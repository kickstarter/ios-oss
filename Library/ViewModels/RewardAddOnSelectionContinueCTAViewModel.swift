import KsApi
import Prelude
import ReactiveSwift

public typealias RewardAddOnSelectionContinueCTAViewData = (
  selectedQuantity: Int,
  isValid: Bool,
  isLoading: Bool
)

public protocol RewardAddOnSelectionContinueCTAViewModelInputs {
  func configure(with data: RewardAddOnSelectionContinueCTAViewData)
}

public protocol RewardAddOnSelectionContinueCTAViewModelOutputs {
  var buttonEnabled: Signal<Bool, Never> { get }
  var buttonTitle: Signal<String, Never> { get }
  var isLoading: Signal<Bool, Never> { get }
}

public protocol RewardAddOnSelectionContinueCTAViewModelType {
  var inputs: RewardAddOnSelectionContinueCTAViewModelInputs { get }
  var outputs: RewardAddOnSelectionContinueCTAViewModelOutputs { get }
}

public final class RewardAddOnSelectionContinueCTAViewModel: RewardAddOnSelectionContinueCTAViewModelType,
  RewardAddOnSelectionContinueCTAViewModelInputs, RewardAddOnSelectionContinueCTAViewModelOutputs {
  public init() {
    let selectedQuantity = self.configDataProperty.signal.skipNil().map(first)
    let isValid = self.configDataProperty.signal.skipNil().map(second)
    let isLoading = self.configDataProperty.signal.skipNil().map(third)

    self.buttonTitle = selectedQuantity.map { quantity in
      if quantity > 0 {
        return Strings.Continue_with_quantity_count_add_ons(quantity_count: quantity)
      }

      return Strings.Skip_add_ons()
    }

    self.buttonEnabled = isValid

    self.isLoading = Signal.combineLatest(
      isLoading,
      self.buttonTitle
    )
    .map(first)
  }

  private let configDataProperty = MutableProperty<RewardAddOnSelectionContinueCTAViewData?>(nil)
  public func configure(with data: RewardAddOnSelectionContinueCTAViewData) {
    self.configDataProperty.value = data
  }

  public let buttonEnabled: Signal<Bool, Never>
  public let buttonTitle: Signal<String, Never>
  public let isLoading: Signal<Bool, Never>

  public var inputs: RewardAddOnSelectionContinueCTAViewModelInputs { return self }
  public var outputs: RewardAddOnSelectionContinueCTAViewModelOutputs { return self }
}
