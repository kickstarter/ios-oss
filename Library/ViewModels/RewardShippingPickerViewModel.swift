import KsApi
import Prelude
import ReactiveCocoa
import Result

public protocol RewardShippingPickerViewModelInputs {
  /// Call when the cancel button is tapped.
  func cancelButtonTapped()

  /// Call with the project, shipping rules and selected shipping rule that is provided to the view.
  func configureWith(project project: Project,
                             shippingRules: [ShippingRule],
                             selectedShippingRule: ShippingRule)

  /// Call when the done button is pressed.
  func doneButtonTapped()

  /// Call when the picker view's `didSelectRow` delegate method is called.
  func pickerView(didSelectRow row: Int)

  /// Call when the view loads.
  func viewDidLoad()

  /// Call when the view appears.
  func viewWillAppear()
}

public protocol RewardShippingPickerViewModelOutputs {
  /// Emits an array of strings to be used as the picker's data source.
  var dataSource: Signal<[String], NoError> { get }

  /// Emits a shipping rule when the delegate should be notified that the user has chosen a shipping rule.
  var notifyDelegateChoseShippingRule: Signal<ShippingRule, NoError> { get }

  /// Emits when the delegate should be notified that the user wants to cancel.
  var notifyDelegateToCancel: Signal<(), NoError> { get }

  /// Emits when a row should be selected in the picker view.
  var selectRow: Signal<Int, NoError> { get }
}

public protocol RewardShippingPickerViewModelType {
  var inputs: RewardShippingPickerViewModelInputs { get }
  var outputs: RewardShippingPickerViewModelOutputs { get }
}

public final class RewardShippingPickerViewModel: RewardShippingPickerViewModelType,
RewardShippingPickerViewModelInputs, RewardShippingPickerViewModelOutputs {

  public init() {
    let projectAndShippingRulesAndSelectedShippingRule = combineLatest(
      self.projectAndShippingRulesAndSelectedShippingRuleProperty.signal.ignoreNil(),
      self.viewDidLoadProperty.signal
      )
      .map(first)

    let projectAndSortedShippingRulesAndSelectedShippingRule = projectAndShippingRulesAndSelectedShippingRule
      .map { project, shippingRules, selectedShippingRule in
        (
          project,
          shippingRules.sort { $0.location.displayableName < $1.location.displayableName },
          selectedShippingRule
        )
    }

    self.selectRow = projectAndSortedShippingRulesAndSelectedShippingRule
      .map { _, shippingRules, selectedShippingRule in
        shippingRules.indexOf(selectedShippingRule) ?? 0
      }
      .takeWhen(self.viewWillAppearProperty.signal)

    self.dataSource = projectAndSortedShippingRulesAndSelectedShippingRule
      .map { project, shippingRules, _ in
        shippingRuleTitles(forProject: project, shippingRules: shippingRules)
    }

    let selectedRow = Signal.merge(self.pickerSelectedRowProperty.signal, self.selectRow)

    self.notifyDelegateChoseShippingRule = combineLatest(
      projectAndSortedShippingRulesAndSelectedShippingRule.map(second),
      selectedRow
      )
      .map { shippingRules, idx in shippingRules[idx] }
      .takeWhen(self.doneButtonTappedProperty.signal)

    self.notifyDelegateToCancel = self.cancelButtonTappedProperty.signal
  }

  private let cancelButtonTappedProperty = MutableProperty()
  public func cancelButtonTapped() {
    self.cancelButtonTappedProperty.value = ()
  }

  private let projectAndShippingRulesAndSelectedShippingRuleProperty
    = MutableProperty<(Project, [ShippingRule], ShippingRule)?>(nil)
  public func configureWith(project project: Project,
                                    shippingRules: [ShippingRule],
                                    selectedShippingRule: ShippingRule) {
    self.projectAndShippingRulesAndSelectedShippingRuleProperty.value
      = (project, shippingRules, selectedShippingRule)
  }

  private let doneButtonTappedProperty = MutableProperty()
  public func doneButtonTapped() {
    self.doneButtonTappedProperty.value = ()
  }

  private let pickerSelectedRowProperty = MutableProperty(-1)
  public func pickerView(didSelectRow row: Int) {
    self.pickerSelectedRowProperty.value = row
  }

  private let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  private let viewWillAppearProperty = MutableProperty()
  public func viewWillAppear() {
    self.viewWillAppearProperty.value = ()
  }

  public let dataSource: Signal<[String], NoError>
  public let notifyDelegateChoseShippingRule: Signal<ShippingRule, NoError>
  public let notifyDelegateToCancel: Signal<(), NoError>
  public let selectRow: Signal<Int, NoError>

  public var inputs: RewardShippingPickerViewModelInputs { return self }
  public var outputs: RewardShippingPickerViewModelOutputs { return self }
}

private func shippingRuleTitles(forProject project: Project, shippingRules: [ShippingRule]) -> [String] {
  return shippingRules
    .map {
      "\($0.location.displayableName) +\(Format.currency(Int($0.cost), country: project.country))"
  }
}
