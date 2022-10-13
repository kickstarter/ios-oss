import Foundation
import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol ProjectActivityLaunchCellViewModelInputs {
  /// Call to set the activity and project.
  func configureWith(activity: Activity, project: Project)
}

public protocol ProjectActivityLaunchCellViewModelOutputs {
  /// Emits the background image URL.
  var backgroundImageURL: Signal<URL?, Never> { get }

  /// Emits the title of the activity.
  var title: Signal<String, Never> { get }
}

public protocol ProjectActivityLaunchCellViewModelType {
  var inputs: ProjectActivityLaunchCellViewModelInputs { get }
  var outputs: ProjectActivityLaunchCellViewModelOutputs { get }
}

public final class ProjectActivityLaunchCellViewModel: ProjectActivityLaunchCellViewModelType,
  ProjectActivityLaunchCellViewModelInputs, ProjectActivityLaunchCellViewModelOutputs {
  public init() {
    let activityAndProject = self.activityAndProjectProperty.signal.skipNil()
    let project = activityAndProject.map(second)

    self.backgroundImageURL = project.map { $0.photo.med }.map(URL.init(string:))

    self.title = project.map { project in
      Strings.dashboard_activity_project_name_launched(
        project_name: project.name,
        launch_date: Format.date(
          secondsInUTC: project.dates.launchedAt,
          dateStyle: .long, timeStyle: .none
        ).nonBreakingSpaced(),
        goal: Format.currency(project.stats.goal, country: project.country).nonBreakingSpaced()
      )
    }
  }

  fileprivate let activityAndProjectProperty = MutableProperty<(Activity, Project)?>(nil)
  public func configureWith(activity: Activity, project: Project) {
    self.activityAndProjectProperty.value = (activity, project)
  }

  public let backgroundImageURL: Signal<URL?, Never>
  public let title: Signal<String, Never>

  public var inputs: ProjectActivityLaunchCellViewModelInputs { return self }
  public var outputs: ProjectActivityLaunchCellViewModelOutputs { return self }
}
