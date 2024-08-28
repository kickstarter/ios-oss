import KsApi
import Prelude
import ReactiveSwift

public typealias RewardAddOnSelectionContinueCTAViewData = (
  selectedQuantity: Int,
  isValid: Bool,
  isLoading: Bool,
  pledgeAmount: Int? // Only shows if passed in.
)

public protocol RewardAddOnSelectionContinueCTAViewModelInputs {
  func configure(with data: RewardAddOnSelectionContinueCTAViewData)
}

public protocol RewardAddOnSelectionContinueCTAViewModelOutputs {
  var buttonEnabled: Signal<Bool, Never> { get }
  var buttonTitle: Signal<String, Never> { get }
  var isLoading: Signal<Bool, Never> { get }
  var pledgeAmountHidden: Signal<Bool, Never> { get }
  var pledgeAmountText: Signal<String, Never> { get }
}

public protocol RewardAddOnSelectionContinueCTAViewModelType {
  var inputs: RewardAddOnSelectionContinueCTAViewModelInputs { get }
  var outputs: RewardAddOnSelectionContinueCTAViewModelOutputs { get }
}

public final class RewardAddOnSelectionContinueCTAViewModel: RewardAddOnSelectionContinueCTAViewModelType,
  RewardAddOnSelectionContinueCTAViewModelInputs, RewardAddOnSelectionContinueCTAViewModelOutputs {
  public init() {
    let selectedQuantity = self.configDataProperty.signal.skipNil().map(\.selectedQuantity)
    let isValid = self.configDataProperty.signal.skipNil().map(\.isValid)
    let isLoading = self.configDataProperty.signal.skipNil().map(\.isLoading)
    let pledgeAmount = self.configDataProperty.signal.skipNil().map(\.pledgeAmount)

    self.pledgeAmountText = pledgeAmount.skipNil().map { "\($0)" }

    self.pledgeAmountHidden = pledgeAmount.map(isNil)

    self.buttonTitle = selectedQuantity.map { quantity in
      if quantity > 0 {
        return Strings.Continue_with_quantity_count_add_ons(quantity_count: quantity)
      }

      // If bonus support is available, use "Continue" instead of "Skip"
      if featureNoShippingAtCheckout() {
        return Strings.Continue()
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
  public let pledgeAmountHidden: Signal<Bool, Never>
  public let pledgeAmountText: Signal<String, Never>

  public var inputs: RewardAddOnSelectionContinueCTAViewModelInputs { return self }
  public var outputs: RewardAddOnSelectionContinueCTAViewModelOutputs { return self }
}
