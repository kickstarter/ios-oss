import KsApi
import Prelude
import ReactiveCocoa
import ReactiveExtensions
import Result

public protocol ProjectActivitySuccessCellViewModelInputs {
  /// Call to set the activity.
  func configureWith(activity activity: Activity)
}

public protocol ProjectActivitySuccessCellViewModelOutputs {
  /// Emits the background image URL.
  var backgroundImageURL: Signal<NSURL?, NoError> { get }

  /// Emits the date the project was successfully funded.
  var fundedDate: Signal<String, NoError> { get }

  /// Emits the project's goal.
  var goal: Signal<String, NoError> { get }

  /// Emits the amount pledged to the project.
  var pledged: Signal<String, NoError> { get }

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
    let activity = self.activityProperty.signal.ignoreNil()
    let project = activity.map { $0.project }.ignoreNil()

    self.backgroundImageURL = project.map { $0.photo.med }.map(NSURL.init(string:))

    self.fundedDate = project.map { project in
      Format.date(secondsInUTC: project.dates.deadline, dateStyle: .MediumStyle, timeStyle: .NoStyle)
    }

    self.goal = project.map { project in
      Format.currency(project.stats.goal, country: project.country)
    }

    self.pledged = project.map { project in
      Format.currency(project.stats.pledged, country: project.country)
    }

    self.title = project.map { project in
      Strings.activity_project_state_change_project_was_successfully_funded(project_name: project.name)
    }
  }

  private let activityProperty = MutableProperty<Activity?>(nil)
  public func configureWith(activity activity: Activity) {
    self.activityProperty.value = activity
  }

  public let backgroundImageURL: Signal<NSURL?, NoError>
  public let fundedDate: Signal<String, NoError>
  public let goal: Signal<String, NoError>
  public let pledged: Signal<String, NoError>
  public let title: Signal<String, NoError>

  public var inputs: ProjectActivitySuccessCellViewModelInputs { return self }
  public var outputs: ProjectActivitySuccessCellViewModelOutputs { return self }
}
