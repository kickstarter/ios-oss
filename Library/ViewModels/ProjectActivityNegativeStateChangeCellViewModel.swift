import KsApi
import Prelude
import ReactiveCocoa
import ReactiveExtensions
import Result

public protocol ProjectActivityNegativeStateChangeCellViewModelInputs {
  /// Call to set the activity.
  func configureWith(activity activity: Activity)
}

public protocol ProjectActivityNegativeStateChangeCellViewModelOutputs {
  /// Emits the background image URL.
  var backgroundImageURL: Signal<NSURL?, NoError> { get }

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
    let activity = self.activityProperty.signal.ignoreNil()
    let project = activity.map { $0.project }.ignoreNil()

    self.backgroundImageURL = project.map { $0.photo.med }.map(NSURL.init(string:))

    self.title = activity.map { activity in
        switch activity.category {
        case .cancellation:
          return Strings.activity_project_state_change_project_was_cancelled_by_creator(
            project_name: activity.project?.name ?? ""
          )
        case .failure:
          return Strings.activity_project_state_change_project_was_not_successfully_funded(
            project_name: activity.project?.name ?? ""
          )
        case .suspension:
          return Strings.activity_project_state_change_project_was_suspended(
            project_name: activity.project?.name ?? ""
          )
        default:
          assertionFailure("Unrecognized activity: \(activity).")
          return ""
        }
    }
  }

  private let activityProperty = MutableProperty<Activity?>(nil)
  public func configureWith(activity activity: Activity) {
    self.activityProperty.value = activity
  }

  public let backgroundImageURL: Signal<NSURL?, NoError>
  public let title: Signal<String, NoError>

  public var inputs: ProjectActivityNegativeStateChangeCellViewModelInputs { return self }
  public var outputs: ProjectActivityNegativeStateChangeCellViewModelOutputs { return self }
}
// swiftlint:enable type_name
