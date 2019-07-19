import KsApi
import Prelude
import ReactiveSwift

public protocol DeprecatedRewardShippingPickerViewModelInputs {
  /// Call when the cancel button is tapped.
  func cancelButtonTapped()

  /// Call with the project, shipping rules and selected shipping rule that is provided to the view.
  func configureWith(
    project: Project,
    shippingRules: [ShippingRule],
    selectedShippingRule: ShippingRule
  )

  /// Call when the done button is pressed.
  func doneButtonTapped()

  /// Call when the picker view's `didSelectRow` delegate method is called.
  func pickerView(didSelectRow row: Int)

  /// Call when the view loads.
  func viewDidLoad()

  /// Call when the view appears.
  func viewWillAppear()
}

public protocol DeprecatedRewardShippingPickerViewModelOutputs {
  /// Emits an array of strings to be used as the picker's data source.
  var dataSource: Signal<[String], Never> { get }

  /// Emits an accessibility hint for the done button.
  var doneButtonAccessibilityHint: Signal<String, Never> { get }

  /// Emits a shipping rule when the delegate should be notified that the user has chosen a shipping rule.
  var notifyDelegateChoseShippingRule: Signal<ShippingRule, Never> { get }

  /// Emits when the delegate should be notified that the user wants to cancel.
  var notifyDelegateToCancel: Signal<(), Never> { get }

  /// Emits when a row should be selected in the picker view.
  var selectRow: Signal<Int, Never> { get }
}

public protocol DeprecatedRewardShippingPickerViewModelType {
  var inputs: DeprecatedRewardShippingPickerViewModelInputs { get }
  var outputs: DeprecatedRewardShippingPickerViewModelOutputs { get }
}

public final class DeprecatedRewardShippingPickerViewModel: DeprecatedRewardShippingPickerViewModelType,
  DeprecatedRewardShippingPickerViewModelInputs, DeprecatedRewardShippingPickerViewModelOutputs {
  public init() {
    let projectAndShippingRulesAndSelectedShippingRule = Signal.combineLatest(
      self.projectAndShippingRulesAndSelectedShippingRuleProperty.signal.skipNil(),
      self.viewDidLoadProperty.signal
    )
    .map(first)

    let projectAndSortedShippingRulesAndSelectedShippingRule = projectAndShippingRulesAndSelectedShippingRule
      .map { project, shippingRules, selectedShippingRule in
        (
          project,
          shippingRules.sorted { $0.location.displayableName < $1.location.displayableName },
          selectedShippingRule
        )
      }

    self.selectRow = projectAndSortedShippingRulesAndSelectedShippingRule
      .map { _, shippingRules, selectedShippingRule in
        shippingRules.firstIndex(of: selectedShippingRule) ?? 0
      }
      .takeWhen(self.viewWillAppearProperty.signal)

    self.dataSource = projectAndSortedShippingRulesAndSelectedShippingRule
      .map { project, shippingRules, _ in
        shippingRuleTitles(forProject: project, shippingRules: shippingRules)
      }

    let selectedRow = Signal.merge(self.pickerSelectedRowProperty.signal, self.selectRow)

    let currentShippingRule = Signal.combineLatest(
      projectAndSortedShippingRulesAndSelectedShippingRule.map(second),
      selectedRow
    )
    .map { shippingRules, idx in shippingRules[idx] }

    self.notifyDelegateChoseShippingRule = currentShippingRule
      .takeWhen(self.doneButtonTappedProperty.signal)

    self.notifyDelegateToCancel = self.cancelButtonTappedProperty.signal

    self.doneButtonAccessibilityHint = currentShippingRule
      .map { shippingRule in
        Strings.Chooses_location_for_shipping(location: shippingRule.location.displayableName)
      }
  }

  fileprivate let cancelButtonTappedProperty = MutableProperty(())
  public func cancelButtonTapped() {
    self.cancelButtonTappedProperty.value = ()
  }

  fileprivate let projectAndShippingRulesAndSelectedShippingRuleProperty
    = MutableProperty<(Project, [ShippingRule], ShippingRule)?>(nil)
  public func configureWith(
    project: Project,
    shippingRules: [ShippingRule],
    selectedShippingRule: ShippingRule
  ) {
    self.projectAndShippingRulesAndSelectedShippingRuleProperty.value
      = (project, shippingRules, selectedShippingRule)
  }

  fileprivate let doneButtonTappedProperty = MutableProperty(())
  public func doneButtonTapped() {
    self.doneButtonTappedProperty.value = ()
  }

  fileprivate let pickerSelectedRowProperty = MutableProperty(-1)
  public func pickerView(didSelectRow row: Int) {
    self.pickerSelectedRowProperty.value = row
  }

  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  fileprivate let viewWillAppearProperty = MutableProperty(())
  public func viewWillAppear() {
    self.viewWillAppearProperty.value = ()
  }

  public let dataSource: Signal<[String], Never>
  public let doneButtonAccessibilityHint: Signal<String, Never>
  public let notifyDelegateChoseShippingRule: Signal<ShippingRule, Never>
  public let notifyDelegateToCancel: Signal<(), Never>
  public let selectRow: Signal<Int, Never>

  public var inputs: DeprecatedRewardShippingPickerViewModelInputs { return self }
  public var outputs: DeprecatedRewardShippingPickerViewModelOutputs { return self }
}

private func shippingRuleTitles(forProject project: Project, shippingRules: [ShippingRule]) -> [String] {
  return shippingRules
    .map {
      "\($0.location.localizedName) +\(Format.currency(Int($0.cost), country: project.country))"
    }
}
