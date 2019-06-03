import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol DashboardProjectsDrawerCellViewModelInputs {
  /// Call when configuring cell with Project and order of creation
  func configureWith(project: Project, indexNum: Int, isChecked: Bool)
}

public protocol DashboardProjectsDrawerCellViewModelOutputs {
  /// Emits label for accessibility.
  var cellAccessibilityLabel: Signal<String, Never> { get }

  /// Emits value for accessibility.
  var cellAccessibilityValue: Signal<String, Never> { get }

  /// Emits whether should show checkmark or not.
  var isCheckmarkHidden: Signal<Bool, Never> { get }

  /// Emits with project name label text.
  var projectNameText: Signal<String, Never> { get }

  /// Emits with project number label text.
  var projectNumberText: Signal<String, Never> { get }
}

public protocol DashboardProjectsDrawerCellViewModelType {
  var inputs: DashboardProjectsDrawerCellViewModelInputs { get }
  var outputs: DashboardProjectsDrawerCellViewModelOutputs { get }
}

public final class DashboardProjectsDrawerCellViewModel: DashboardProjectsDrawerCellViewModelType,
  DashboardProjectsDrawerCellViewModelInputs, DashboardProjectsDrawerCellViewModelOutputs {
  public init() {
    self.projectNameText = self.projectProperty.signal.skipNil().map { $0.name }

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

  public let cellAccessibilityLabel: Signal<String, Never>
  public let cellAccessibilityValue: Signal<String, Never>
  public let projectNameText: Signal<String, Never>
  public let projectNumberText: Signal<String, Never>
  public let isCheckmarkHidden: Signal<Bool, Never>

  fileprivate let projectProperty = MutableProperty<Project?>(nil)
  fileprivate let orderNumProperty = MutableProperty<Int>(0)
  fileprivate let isCheckedProperty = MutableProperty<Bool>(false)
  public func configureWith(project: Project, indexNum: Int, isChecked: Bool) {
    self.projectProperty.value = project
    self.orderNumProperty.value = indexNum
    self.isCheckedProperty.value = isChecked
  }
}
