import KsApi
import Prelude
import Result
import ReactiveSwift
import ReactiveExtensions

public protocol DashboardProjectsDrawerViewModelInputs {
  /// Call when the view has completed animating in.
  func animateInCompleted()

  /// Call when the view has completed animating out.
  func animateOutCompleted()

  /// Call when the background is tapped to dismiss the drawer.
  func backgroundTapped()

  /// Call to configure the datasource with projects.
  func configureWith(data: [ProjectsDrawerData])

  /// Call when a project cell is tapped with the project.
  func projectCellTapped(_ project: Project)

  /// Call when the view loads.
  func viewDidLoad()
}

public protocol DashboardProjectsDrawerViewModelOutputs {
  /// Emits when to shift screen reader focus on first project cell.
  var focusScreenReaderOnFirstProject: Signal<(), NoError> { get }

  /// Emits projects to display in tableview.
  var projectsDrawerData: Signal<[ProjectsDrawerData], NoError> { get }

  /// Emits to notify delegate to close the drawer on background tap.
  var notifyDelegateToCloseDrawer: Signal<(), NoError> { get }

  /// Emits to notify delegate when view controller completed animating out.
  var notifyDelegateDidAnimateOut: Signal<(), NoError> { get }

  /// Emits to notify delegate when project cell was tapped with project.
  var notifyDelegateProjectCellTapped: Signal<Project, NoError> { get }
}

public protocol DashboardProjectsDrawerViewModelType {
  var inputs: DashboardProjectsDrawerViewModelInputs { get }
  var outputs: DashboardProjectsDrawerViewModelOutputs { get }
}

public final class DashboardProjectsDrawerViewModel: DashboardProjectsDrawerViewModelType,
DashboardProjectsDrawerViewModelInputs, DashboardProjectsDrawerViewModelOutputs {

  public init() {
    self.projectsDrawerData = self.projectsDrawerDataProperty.signal.skipNil()
      .takeWhen(self.viewDidLoadProperty.signal)

    self.notifyDelegateToCloseDrawer = self.backgroundTappedProperty.signal

    self.notifyDelegateProjectCellTapped = self.projectCellTappedProperty.signal.skipNil()

    self.notifyDelegateDidAnimateOut = self.animateOutCompletedProperty.signal

    self.focusScreenReaderOnFirstProject = self.animateInCompletedProperty.signal
  }

  public var inputs: DashboardProjectsDrawerViewModelInputs { return self }
  public var outputs: DashboardProjectsDrawerViewModelOutputs { return self }

  public let focusScreenReaderOnFirstProject: Signal<(), NoError>
  public let projectsDrawerData: Signal<[ProjectsDrawerData], NoError>
  public let notifyDelegateDidAnimateOut: Signal<(), NoError>
  public var notifyDelegateToCloseDrawer: Signal<(), NoError>
  public let notifyDelegateProjectCellTapped: Signal<Project, NoError>

  fileprivate let animateInCompletedProperty = MutableProperty()
  public func animateInCompleted() {
    self.animateInCompletedProperty.value = ()
  }
  fileprivate let animateOutCompletedProperty = MutableProperty()
  public func animateOutCompleted() {
    self.animateOutCompletedProperty.value = ()
  }
  fileprivate let backgroundTappedProperty = MutableProperty()
  public func backgroundTapped() {
    self.backgroundTappedProperty.value = ()
  }
  fileprivate let projectsDrawerDataProperty = MutableProperty<[ProjectsDrawerData]?>(nil)
  public func configureWith(data: [ProjectsDrawerData]) {
    self.projectsDrawerDataProperty.value = data
  }
  fileprivate let projectCellTappedProperty = MutableProperty<Project?>(nil)
  public func projectCellTapped(_ project: Project) {
    self.projectCellTappedProperty.value = project
  }
  fileprivate let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }
}
