import KsApi
import Prelude
import ReactiveCocoa
import ReactiveExtensions
import Result

public protocol ActivitySampleProjectCellViewModelInputs {
  /// Call to configure cell with activity value.
  func configureWith(activity activity: Activity)

  /// Call when the see all activity button is tapped.
  func seeAllActivityTapped()
}

public protocol ActivitySampleProjectCellViewModelOutputs {
  /// Emits the cell accessibility hint for voiceover.
  var cellAccessibilityHint: Signal<String, NoError> { get }

  /// Emits when should go to activities screen.
  var goToActivity: Signal<Void, NoError> { get }

  /// Emits the project image url to be displayed.
  var projectImageURL: Signal<NSURL?, NoError> { get }

  /// Emits the project subtitle message to be displayed.
  var projectSubtitleText: Signal<String, NoError> { get }

  /// Emits the project name title to be displayed.
  var projectTitleText: Signal<String, NoError> { get }
}

public protocol ActivitySampleProjectCellViewModelType {
  var inputs: ActivitySampleProjectCellViewModelInputs { get }
  var outputs: ActivitySampleProjectCellViewModelOutputs { get }
}

public final class ActivitySampleProjectCellViewModel: ActivitySampleProjectCellViewModelInputs,
  ActivitySampleProjectCellViewModelOutputs, ActivitySampleProjectCellViewModelType {

  public init() {
    let activity = self.activityProperty.signal.ignoreNil()

    self.cellAccessibilityHint = activity
      .map { $0.category == .update ? Strings.Opens_update() : Strings.Opens_project() }

    self.goToActivity = self.seeAllActivityTappedProperty.signal

    self.projectImageURL = activity
      .map { ($0.project?.photo.med).flatMap(NSURL.init) }

    self.projectTitleText = activity
      .map { $0.project?.name }.ignoreNil()

    self.projectSubtitleText = activity
      .map { activity in
        switch activity.category {
        case .cancellation:
          return Strings.activity_funding_canceled()
        case .failure:
          return Strings.activity_project_was_not_successfully_funded()
        case .launch:
          return Strings.activity_user_name_launched_project(user_name: activity.user?.name ?? "")
        case .success:
          return Strings.activity_successfully_funded()
        case .update:
          return Strings.activity_posted_update_number_title(
            update_number: Format.wholeNumber(activity.update?.sequence ?? 0),
            update_title: activity.update?.title ?? "")
        default:
          return ""
        }
    }
  }

  private let activityProperty = MutableProperty<Activity?>(nil)
  public func configureWith(activity activity: Activity) {
    self.activityProperty.value = activity
  }

  private let seeAllActivityTappedProperty = MutableProperty()
  public func seeAllActivityTapped() {
    self.seeAllActivityTappedProperty.value = ()
  }

  public let cellAccessibilityHint: Signal<String, NoError>
  public let goToActivity: Signal<Void, NoError>
  public let projectImageURL: Signal<NSURL?, NoError>
  public let projectSubtitleText: Signal<String, NoError>
  public let projectTitleText: Signal<String, NoError>

  public var inputs: ActivitySampleProjectCellViewModelInputs { return self }
  public var outputs: ActivitySampleProjectCellViewModelOutputs { return self }
}
