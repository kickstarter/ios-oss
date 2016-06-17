import KsApi
import ReactiveCocoa
import ReactiveExtensions
import Result

public protocol DashboardContextCellViewModelInputs {
  /// Call to configure cell with project value.
  func configureWith(project project: Project)
}

public protocol DashboardContextCellViewModelOutputs {
  /// Emits the number of backers to display.
  var backersCount: Signal<String, NoError> { get }

  /// Emits the project deadline to display.
  var deadline: Signal<String, NoError> { get }

  /// Emits the amount pledged to display.
  var pledged: Signal<String, NoError> { get }

  /// Emits the project's image URL to display.
  var projectImageURL: Signal<NSURL?, NoError> { get }
}

public protocol DashboardContextCellViewModelType {
  var inputs: DashboardContextCellViewModelInputs { get }
  var outputs: DashboardContextCellViewModelOutputs { get }
}

public final class DashboardContextCellViewModel: DashboardContextCellViewModelInputs,
  DashboardContextCellViewModelOutputs, DashboardContextCellViewModelType {

  public init() {
    let project = self.projectProperty.signal.ignoreNil()

    self.backersCount = project.map { Format.wholeNumber($0.stats.backersCount) }

    self.deadline = project.map { String($0.dates.deadline) }

    self.pledged = project.map { Format.currency($0.stats.pledged, country: $0.country) }

    self.projectImageURL = project.map { NSURL(string: $0.photo.full) }
  }

  private let projectProperty = MutableProperty<Project?>(nil)
  public func configureWith(project project: Project) {
    self.projectProperty.value = project
  }

  public let backersCount: Signal<String, NoError>
  public let deadline: Signal<String, NoError>
  public let pledged: Signal<String, NoError>
  public let projectImageURL: Signal<NSURL?, NoError>

  public var inputs: DashboardContextCellViewModelInputs { return self }
  public var outputs: DashboardContextCellViewModelOutputs { return self }
}
