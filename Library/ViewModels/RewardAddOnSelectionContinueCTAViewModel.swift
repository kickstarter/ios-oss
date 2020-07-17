import KsApi
import Prelude
import ReactiveSwift

public typealias RewardAddOnSelectionContinueCTAViewData = (
  selectedQuantity: Int,
  isValid: Bool
)

public protocol RewardAddOnSelectionContinueCTAViewModelInputs {
  func configure(with data: RewardAddOnSelectionContinueCTAViewData)
}

public protocol RewardAddOnSelectionContinueCTAViewModelOutputs {
  var buttonStyle: Signal<ButtonStyleType, Never> { get }
  var buttonTitle: Signal<String, Never> { get }
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

    self.buttonStyle = isValid.map { $0 ? .green : .black }
    self.buttonTitle = selectedQuantity.map { quantity in
      if quantity > 0 {
        return localizedString(
          key: "Continue_with_quantity_add_ons",
          defaultValue: "Continue with %{quantity} add-ons",
          count: quantity,
          substitutions: ["quantity": Format.wholeNumber(quantity)]
        )
      }

      return localizedString(key: "Skip_add_ons", defaultValue: "Skip add-ons")
    }
  }

  private let configDataProperty = MutableProperty<RewardAddOnSelectionContinueCTAViewData?>(nil)
  public func configure(with data: RewardAddOnSelectionContinueCTAViewData) {
    self.configDataProperty.value = data
  }

  public let buttonStyle: Signal<ButtonStyleType, Never>
  public let buttonTitle: Signal<String, Never>

  public var inputs: RewardAddOnSelectionContinueCTAViewModelInputs { return self }
  public var outputs: RewardAddOnSelectionContinueCTAViewModelOutputs { return self }
}
