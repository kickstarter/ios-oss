import Foundation
import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol ActivitySampleProjectCellViewModelInputs {
  /// Call to configure cell with activity value.
  func configureWith(activity: Activity)

  /// Call when the see all activity button is tapped.
  func seeAllActivityTapped()
}

public protocol ActivitySampleProjectCellViewModelOutputs {
  /// Emits the cell accessibility hint for VoiceOver.
  var cellAccessibilityHint: Signal<String, Never> { get }

  /// Emits when should go to activities screen.
  var goToActivity: Signal<Void, Never> { get }

  /// Emits the project image url to be displayed.
  var projectImageURL: Signal<URL?, Never> { get }

  /// Emits the project subtitle message to be displayed.
  var projectSubtitleText: Signal<String, Never> { get }

  /// Emits the project name title to be displayed.
  var projectTitleText: Signal<String, Never> { get }
}

public protocol ActivitySampleProjectCellViewModelType {
  var inputs: ActivitySampleProjectCellViewModelInputs { get }
  var outputs: ActivitySampleProjectCellViewModelOutputs { get }
}

public final class ActivitySampleProjectCellViewModel: ActivitySampleProjectCellViewModelInputs,
  ActivitySampleProjectCellViewModelOutputs, ActivitySampleProjectCellViewModelType {
  public init() {
    let activity = self.activityProperty.signal.skipNil()

    self.cellAccessibilityHint = activity
      .map { $0.category == .update ? Strings.Opens_update() : Strings.Opens_project() }

    self.goToActivity = self.seeAllActivityTappedProperty.signal

    self.projectImageURL = activity
      .map { ($0.project?.photo.med).flatMap(URL.init) }

    self.projectTitleText = activity
      .map { $0.project?.name }.skipNil()

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
            update_title: activity.update?.title ?? ""
          )
        default:
          return ""
        }
      }
  }

  fileprivate let activityProperty = MutableProperty<Activity?>(nil)
  public func configureWith(activity: Activity) {
    self.activityProperty.value = activity
  }

  fileprivate let seeAllActivityTappedProperty = MutableProperty(())
  public func seeAllActivityTapped() {
    self.seeAllActivityTappedProperty.value = ()
  }

  public let cellAccessibilityHint: Signal<String, Never>
  public let goToActivity: Signal<Void, Never>
  public let projectImageURL: Signal<URL?, Never>
  public let projectSubtitleText: Signal<String, Never>
  public let projectTitleText: Signal<String, Never>

  public var inputs: ActivitySampleProjectCellViewModelInputs { return self }
  public var outputs: ActivitySampleProjectCellViewModelOutputs { return self }
}
