import KsApi
import Prelude
import Result
import ReactiveSwift
import ReactiveExtensions

public protocol DashboardTitleViewViewModelInputs {
  /// Call to update the data for the title.
  func updateData(_ data: DashboardTitleViewData)

  /// Call when title button is tapped.
  func titleButtonTapped()
}

public protocol DashboardTitleViewViewModelOutputs {
  /// Emits whether should hide arrow icon.
  var hideArrow: Signal<Bool, NoError> { get }

  /// Emits when the delegate should show/hide the projects drawer when the title is tapped.
  var notifyDelegateShowHideProjectsDrawer: Signal<(), NoError> { get }

  /// Emits a11y label for title view.
  var titleAccessibilityLabel: Signal<String, NoError> { get }

  /// Emits a11y hint for title view.
  var titleAccessibilityHint: Signal<String, NoError> { get }

  /// Emits whether title should be tappable.
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

    self.titleText = self.currentProjectIndexProperty.signal.skipNil()
      .map { Strings.dashboard_switcher_project_number(current_project_index: "\($0 + 1)") }

    let isArrowHidden = self.updateDrawerStateHideArrowProperty.signal.skipNil().map(second)

    self.titleButtonIsEnabled = isArrowHidden.map(negate).skipRepeats()

    self.hideArrow = isArrowHidden

    self.updateArrowState = self.updateDrawerStateHideArrowProperty.signal.skipNil()
      .filter { _, hideArrow in !hideArrow }
      .map(first)

    self.notifyDelegateShowHideProjectsDrawer = self.titleButtonTappedProperty.signal

    self.titleAccessibilityLabel = self.titleText
      .takeWhen(isArrowHidden.filter(isFalse))
      .map { Strings.tabbar_dashboard() + ", " + $0 }

    self.titleAccessibilityHint = self.updateArrowState
      .map {
        switch $0 {
        case .open:
          return Strings.dashboard_switcher_accessibility_label_closes_list_of_projects()
        case .closed:
          return Strings.dashboard_switcher_accessibility_label_opens_list_of_projects()
        }
    }
  }

  public var inputs: DashboardTitleViewViewModelInputs { return self }
  public var outputs: DashboardTitleViewViewModelOutputs { return self }

  public let updateArrowState: Signal<DrawerState, NoError>
  public let hideArrow: Signal<Bool, NoError>
  public let notifyDelegateShowHideProjectsDrawer: Signal<(), NoError>
  public let titleAccessibilityLabel: Signal<String, NoError>
  public let titleAccessibilityHint: Signal<String, NoError>
  public let titleText: Signal<String, NoError>
  public let titleButtonIsEnabled: Signal<Bool, NoError>

  fileprivate let currentProjectIndexProperty = MutableProperty<Int?>(nil)
  fileprivate let updateDrawerStateHideArrowProperty = MutableProperty<(DrawerState, Bool)?>(nil)
  public func updateData(_ data: DashboardTitleViewData) {
    self.currentProjectIndexProperty.value = data.currentProjectIndex
    self.updateDrawerStateHideArrowProperty.value = (data.drawerState, data.isArrowHidden)
  }
  fileprivate let titleButtonTappedProperty = MutableProperty(())
  public func titleButtonTapped() {
    titleButtonTappedProperty.value = ()
  }
}
