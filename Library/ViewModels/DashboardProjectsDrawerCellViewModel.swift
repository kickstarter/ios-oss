import KsApi
import Prelude
import Result
import ReactiveCocoa
import ReactiveExtensions

public protocol DashboardProjectsDrawerCellViewModelInputs {
  /// Call when configuring cell with Project and order of creation
  func configureWith(project project: Project, indexNum: Int, isChecked: Bool)
}

public protocol DashboardProjectsDrawerCellViewModelOutputs {
  /// Emits label for accessibility.
  var cellAccessibilityLabel: Signal<String, NoError> { get }

  /// Emits value for accessibility.
  var cellAccessibilityValue: Signal<String, NoError> { get }

  /// Emits whether should show checkmark or not.
  var isCheckmarkHidden: Signal<Bool, NoError> { get }

  /// Emits with project name label text.
  var projectNameText: Signal<String, NoError> { get }

  /// Emits with project number label text.
  var projectNumberText: Signal<String, NoError> { get }
}

public protocol DashboardProjectsDrawerCellViewModelType {
  var inputs: DashboardProjectsDrawerCellViewModelInputs { get }
  var outputs: DashboardProjectsDrawerCellViewModelOutputs { get }
}

public final class DashboardProjectsDrawerCellViewModel: DashboardProjectsDrawerCellViewModelType,
  DashboardProjectsDrawerCellViewModelInputs, DashboardProjectsDrawerCellViewModelOutputs {

  public init() {
    self.projectNameText = self.projectProperty.signal.ignoreNil().map { $0.name }

    self.projectNumberText = self.orderNumProperty.signal.map {
      Strings.dashboard_switcher_project_number(current_project_index: "\($0 + 1)")
    }

    let isChecked = self.isCheckedProperty.signal
    self.isCheckmarkHidden = isChecked.map(negate)

    self.cellAccessibilityLabel = self.projectNameText
    self.cellAccessibilityValue = isChecked.map { $0 ? "Selected" : "Unselected" }
  }

  public var inputs: DashboardProjectsDrawerCellViewModelInputs { return self }
  public var outputs: DashboardProjectsDrawerCellViewModelOutputs { return self }

  public let cellAccessibilityLabel: Signal<String, NoError>
  public let cellAccessibilityValue: Signal<String, NoError>
  public let projectNameText: Signal<String, NoError>
  public let projectNumberText: Signal<String, NoError>
  public let isCheckmarkHidden: Signal<Bool, NoError>

  private let projectProperty = MutableProperty<Project?>(nil)
  private let orderNumProperty = MutableProperty<Int>(0)
  private let isCheckedProperty = MutableProperty<Bool>(false)
  public func configureWith(project project: Project, indexNum: Int, isChecked: Bool) {
    self.projectProperty.value = project
    self.orderNumProperty.value = indexNum
    self.isCheckedProperty.value = isChecked
  }
}
