import KsApi
import Prelude
import Result
import ReactiveCocoa
import ReactiveExtensions

public protocol DashboardTitleViewViewModelInputs {
  /// Call to update the data for the title.
  func updateData(data: DashboardTitleViewData)

  /// Call when title is tapped.
  func titleTapped()
}

public protocol DashboardTitleViewViewModelOutputs {
  /// Emits whether should hide arrow icon.
  var hideArrow: Signal<Bool, NoError> { get }

  /// Emits when the delegate should show/hide the projects drawer when the title is tapped.
  var notifyDelegateShowHideProjectsDrawer: Signal<(), NoError> { get }

  /// Emits when title button should be enabled.
  var titleButtonIsEnabled: Signal<Bool, NoError> { get }

  /// Emits the text for the title view.
  var titleText: Signal<String, NoError> { get }

  /// Emits to update arrow icon to open or closed state.
  var updateArrowState: Signal<DrawerState, NoError> { get }
}

public protocol DashboardTitleViewViewModelType {
  var inputs: DashboardTitleViewViewModelInputs { get }
  var outputs: DashboardTitleViewViewModelOutputs { get }
}

public final class DashboardTitleViewViewModel: DashboardTitleViewViewModelType,
  DashboardTitleViewViewModelInputs, DashboardTitleViewViewModelOutputs {
  public init() {

    self.titleText = self.currentProjectIndexProperty.signal.ignoreNil()
      .map { Strings.dashboard_switcher_project_number(current_project_index: "\($0 + 1)") }

    let isArrowHidden = self.updateDrawerStateHideArrowProperty.signal.ignoreNil().map(second)

    self.titleButtonIsEnabled = isArrowHidden.map(negate).skipRepeats()

    self.hideArrow = isArrowHidden

    self.updateArrowState = self.updateDrawerStateHideArrowProperty.signal.ignoreNil()
      .filter { _, hideArrow in !hideArrow }
      .map(first)

    self.notifyDelegateShowHideProjectsDrawer = self.titleTappedProperty.signal
  }

  public var inputs: DashboardTitleViewViewModelInputs { return self }
  public var outputs: DashboardTitleViewViewModelOutputs { return self }

  public let updateArrowState: Signal<DrawerState, NoError>
  public let hideArrow: Signal<Bool, NoError>
  public let notifyDelegateShowHideProjectsDrawer: Signal<(), NoError>
  public let titleText: Signal<String, NoError>
  public let titleButtonIsEnabled: Signal<Bool, NoError>

  private let currentProjectIndexProperty = MutableProperty<Int?>(nil)
  private let updateDrawerStateHideArrowProperty = MutableProperty<(DrawerState, Bool)?>(nil)
  public func updateData(data: DashboardTitleViewData) {
    self.currentProjectIndexProperty.value = data.currentProjectIndex
    self.updateDrawerStateHideArrowProperty.value = (data.drawerState, data.isArrowHidden)
  }
  private let titleTappedProperty = MutableProperty()
  public func titleTapped() {
    titleTappedProperty.value = ()
  }
}
