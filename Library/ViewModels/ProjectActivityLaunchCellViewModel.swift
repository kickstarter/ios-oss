import KsApi
import Prelude
import ReactiveCocoa
import ReactiveExtensions
import Result

public protocol ProjectActivityLaunchCellViewModelInputs {
  /// Call to set the activity.
  func configureWith(activity activity: Activity)
}

public protocol ProjectActivityLaunchCellViewModelOutputs {
  /// Emits the background image URL.
  var backgroundImageURL: Signal<NSURL?, NoError> { get }

  /// Emits the project's goal.
  var goal: Signal<String, NoError> { get }

  /// Emits the project's launch date.
  var launchDate: Signal<String, NoError> { get }

  /// Emits the title of the activity.
  var title: Signal<String, NoError> { get }
}

public protocol ProjectActivityLaunchCellViewModelType {
  var inputs: ProjectActivityLaunchCellViewModelInputs { get }
  var outputs: ProjectActivityLaunchCellViewModelOutputs { get }
}

public final class ProjectActivityLaunchCellViewModel: ProjectActivityLaunchCellViewModelType,
ProjectActivityLaunchCellViewModelInputs, ProjectActivityLaunchCellViewModelOutputs {

  public init() {
    let activity = self.activityProperty.signal.ignoreNil()
    let project = activity.map { $0.project }.ignoreNil()

    self.backgroundImageURL = project.map { $0.photo.med }.map(NSURL.init(string:))

    self.goal = project.map { project in
      Format.currency(project.stats.goal, country: project.country)
    }

    self.launchDate = project.map { project in
      Format.date(secondsInUTC: project.dates.launchedAt, dateStyle: .MediumStyle, timeStyle: .NoStyle)
    }

    self.title = project.map { project in
      Strings.activity_project_state_change_creator_launched_a_project(
        creator_name: creatorFrom(project: project),
        project_name: project.name
      )
    }
  }

  private let activityProperty = MutableProperty<Activity?>(nil)
  public func configureWith(activity activity: Activity) {
    self.activityProperty.value = activity
  }

  public let backgroundImageURL: Signal<NSURL?, NoError>
  public let goal: Signal<String, NoError>
  public let launchDate: Signal<String, NoError>
  public let title: Signal<String, NoError>

  public var inputs: ProjectActivityLaunchCellViewModelInputs { return self }
  public var outputs: ProjectActivityLaunchCellViewModelOutputs { return self }
}

private func creatorFrom(project project: Project) -> String {
  return AppEnvironment.current.currentUser == project.creator ?
    Strings.activity_creator_you() : project.creator.name
}
