import KsApi
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result

public protocol ProjectActivityNegativeStateChangeCellViewModelInputs {
  /// Call to set the activity and project.
  func configureWith(activity: Activity, project: Project)
}

public protocol ProjectActivityNegativeStateChangeCellViewModelOutputs {
  /// Emits the title of the activity.
  var title: Signal<String, NoError> { get }
}

public protocol ProjectActivityNegativeStateChangeCellViewModelType {
  var inputs: ProjectActivityNegativeStateChangeCellViewModelInputs { get }
  var outputs: ProjectActivityNegativeStateChangeCellViewModelOutputs { get }
}

// swiftlint:disable type_name
public final class ProjectActivityNegativeStateChangeCellViewModel:
ProjectActivityNegativeStateChangeCellViewModelType, ProjectActivityNegativeStateChangeCellViewModelInputs,
ProjectActivityNegativeStateChangeCellViewModelOutputs {

  public init() {
    let activityAndProject = self.activityAndProjectProperty.signal.ignoreNil()

    self.title = activityAndProject.map { activity, project in
        switch activity.category {
        case .cancellation:
          return Strings.dashboard_activity_project_name_was_canceled(
            project_name: project.name ?? "",
            cancellation_date: Format.date(secondsInUTC: activity.createdAt, dateStyle: .LongStyle,
              timeStyle: .NoStyle).nonBreakingSpaced()
          )
        case .failure:
          return Strings.dashboard_activity_project_name_was_unsuccessful(
            project_name: project.name ?? "",
            unsuccessful_date: Format.date(secondsInUTC: activity.createdAt, dateStyle: .LongStyle,
              timeStyle: .NoStyle).nonBreakingSpaced()
          )
        case .suspension:
          return Strings.dashboard_activity_project_name_was_suspended(
            project_name: project.name ?? "",
            suspension_date: Format.date(secondsInUTC: activity.createdAt, dateStyle: .LongStyle,
              timeStyle: .NoStyle).nonBreakingSpaced()
          )
        default:
          assertionFailure("Unrecognized activity: \(activity).")
          return ""
        }
    }
  }

  fileprivate let activityAndProjectProperty = MutableProperty<(Activity, Project)?>(nil)
  public func configureWith(activity: Activity, project: Project) {
    self.activityAndProjectProperty.value = (activity, project)
  }

  public let title: Signal<String, NoError>

  public var inputs: ProjectActivityNegativeStateChangeCellViewModelInputs { return self }
  public var outputs: ProjectActivityNegativeStateChangeCellViewModelOutputs { return self }
}
// swiftlint:enable type_name
