import Foundation
import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol ProjectActivitySuccessCellViewModelInputs {
  /// Call to set the activity and project.
  func configureWith(activity: Activity, project: Project)
}

public protocol ProjectActivitySuccessCellViewModelOutputs {
  /// Emits the background image URL.
  var backgroundImageURL: Signal<URL?, Never> { get }

  /// Emits the title of the activity.
  var title: Signal<String, Never> { get }
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

    self.backgroundImageURL = project.map { $0.photo.med }.map(URL.init(string:))

    self.title = project.map { project in
      Strings.dashboard_activity_successfully_raised_pledged(
        pledged: Format.currency(project.stats.pledged, country: project.country).nonBreakingSpaced(),
        backers: Strings.general_backer_count_backers(backer_count: project.stats.backersCount)
          .nonBreakingSpaced(),
        deadline: Format.date(
          secondsInUTC: project.dates.deadline, dateStyle: .long,
          timeStyle: .none
        ).nonBreakingSpaced()
      )
    }
  }

  fileprivate let activityAndProjectProperty = MutableProperty<(Activity, Project)?>(nil)
  public func configureWith(activity: Activity, project: Project) {
    self.activityAndProjectProperty.value = (activity, project)
  }

  public let backgroundImageURL: Signal<URL?, Never>
  public let title: Signal<String, Never>

  public var inputs: ProjectActivitySuccessCellViewModelInputs { return self }
  public var outputs: ProjectActivitySuccessCellViewModelOutputs { return self }
}
