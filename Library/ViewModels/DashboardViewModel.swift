import KsApi
import Prelude
import ReactiveCocoa
import ReactiveExtensions
import Result

public protocol DashboardViewModelInputs {
  /// Call when the project context is tapped.
  func projectContextTapped(project: Project)

  /// Call when the view did load.
  func viewDidLoad()
}

public protocol DashboardViewModelOutputs {
  /// Emits the project and ref tag when should go to project page.
  var goToProject: Signal<(Project, RefTag), NoError > { get }

  /// Emits the currently selected project to display.
  var project: Signal<Project, NoError> { get }

  /// Emits the list of created projects to display.
  var projects: Signal<[Project], NoError> { get }
}

public protocol DashboardViewModelType {
  var inputs: DashboardViewModelInputs { get }
  var outputs: DashboardViewModelOutputs { get }
}

public final class DashboardViewModel: DashboardViewModelInputs, DashboardViewModelOutputs,
  DashboardViewModelType {

  public init() {

    self.projects = self.viewDidLoadProperty.signal
      .switchMap {
        AppEnvironment.current.apiService.fetchProjects(member: true)
          .demoteErrors()
      }
      .map { $0.projects }

    let project = self.projects.map { $0.first }.ignoreNil()

    self.project = project

    self.goToProject = self.projectContextTappedProperty.signal.ignoreNil()
      .map { ($0, RefTag.dashboard) }
  }

  private let projectContextTappedProperty = MutableProperty<Project?>(nil)
  public func projectContextTapped(project: Project) {
    projectContextTappedProperty.value = project
  }

  private let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    viewDidLoadProperty.value = ()
  }

  public let goToProject: Signal<(Project, RefTag), NoError>
  public let project: Signal<Project, NoError>
  public let projects: Signal<[Project], NoError>

  public var inputs: DashboardViewModelInputs { return self }
  public var outputs: DashboardViewModelOutputs { return self }
}
