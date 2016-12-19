import KsApi
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result

public protocol ProjectActivitySuccessCellViewModelInputs {
  /// Call to set the activity and project.
  func configureWith(activity: Activity, project: Project)
}

public protocol ProjectActivitySuccessCellViewModelOutputs {
  /// Emits the background image URL.
  var backgroundImageURL: Signal<NSURL?, NoError> { get }

  /// Emits the title of the activity.
  var title: Signal<String, NoError> { get }
}

public protocol ProjectActivitySuccessCellViewModelType {
  var inputs: ProjectActivitySuccessCellViewModelInputs { get }
  var outputs: ProjectActivitySuccessCellViewModelOutputs { get }
}

public final class ProjectActivitySuccessCellViewModel: ProjectActivitySuccessCellViewModelType,
ProjectActivitySuccessCellViewModelInputs, ProjectActivitySuccessCellViewModelOutputs {

  public init() {
    let activityAndProject = self.activityAndProjectProperty.signal.skipNil()
    let project = activityAndProject.map(second)

    self.backgroundImageURL = project.map { $0.photo.med }.map(NSURL.init(string:))

    self.title = project.map { project in
      Strings.dashboard_activity_successfully_raised_pledged(
        pledged: Format.currency(project.stats.pledged, country: project.country).nonBreakingSpaced(),
        backers: Strings.general_backer_count_backers(backer_count: project.stats.backersCount)
          .nonBreakingSpaced(),
        deadline: Format.date(secondsInUTC: project.dates.deadline, dateStyle: .LongStyle,
          timeStyle: .NoStyle).nonBreakingSpaced()
      )
    }
  }

  fileprivate let activityAndProjectProperty = MutableProperty<(Activity, Project)?>(nil)
  public func configureWith(activity: Activity, project: Project) {
    self.activityAndProjectProperty.value = (activity, project)
  }

  public let backgroundImageURL: Signal<NSURL?, NoError>
  public let title: Signal<String, NoError>

  public var inputs: ProjectActivitySuccessCellViewModelInputs { return self }
  public var outputs: ProjectActivitySuccessCellViewModelOutputs { return self }
}
