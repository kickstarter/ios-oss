import KsApi
import ReactiveCocoa
import ReactiveExtensions
import Result

public protocol DashboardContextCellViewModelInputs {
  /// Call to configure cell with project value.
  func configureWith(project project: Project)

  /// Call when view project button is tapped.
  func viewProjectTapped()
}

public protocol DashboardContextCellViewModelOutputs {
  /// Emits the project and ref tag when should go to project page.
  var goToProject: Signal<(Project, RefTag), NoError > { get }

  /// Emits the project name to display.
  var projectName: Signal<String, NoError> { get }
}

public protocol DashboardContextCellViewModelType {
  var inputs: DashboardContextCellViewModelInputs { get }
  var outputs: DashboardContextCellViewModelOutputs { get }
}

public final class DashboardContextCellViewModel: DashboardContextCellViewModelInputs,
  DashboardContextCellViewModelOutputs, DashboardContextCellViewModelType {

  public init() {
    let project = self.projectProperty.signal.ignoreNil()

    self.goToProject = project
      .takeWhen(self.viewProjectTappedProperty.signal)
      .map { ($0, RefTag.dashboard) }

    self.projectName = project.map { $0.name }
  }

  private let projectProperty = MutableProperty<Project?>(nil)
  public func configureWith(project project: Project) {
    self.projectProperty.value = project
  }

  private let viewProjectTappedProperty = MutableProperty()
  public func viewProjectTapped() {
    self.viewProjectTappedProperty.value = ()
  }

  public let goToProject: Signal<(Project, RefTag), NoError>
  public let projectName: Signal<String, NoError>

  public var inputs: DashboardContextCellViewModelInputs { return self }
  public var outputs: DashboardContextCellViewModelOutputs { return self }
}
