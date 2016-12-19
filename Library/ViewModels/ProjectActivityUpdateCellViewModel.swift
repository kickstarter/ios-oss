import KsApi
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result

public protocol ProjectActivityUpdateCellViewModelInputs {
  /// Call to set the activity and project.
  func configureWith(activity: Activity, project: Project)
}

public protocol ProjectActivityUpdateCellViewModelOutputs {
  /// Emits the update's author and sequence.
  var activityTitle: Signal<String, NoError> { get }

  /// Emits the update's body.
  var body: Signal<String, NoError> { get }

  /// Emits the cell's accessibility label.
  var cellAccessibilityLabel: Signal<String, NoError> { get }

  /// Emits the cell's accessibility value.
  var cellAccessibilityValue: Signal<String, NoError> { get }

  /// Emits the number of comments.
  var commentsCount: Signal<String, NoError> { get }

  /// Emits the number of likes.
  var likesCount: Signal<String, NoError> { get }

  /// Emits the title of the update.
  var updateTitle: Signal<String, NoError> { get }
}

public protocol ProjectActivityUpdateCellViewModelType {
  var inputs: ProjectActivityUpdateCellViewModelInputs { get }
  var outputs: ProjectActivityUpdateCellViewModelOutputs { get }
}

public final class ProjectActivityUpdateCellViewModel: ProjectActivityUpdateCellViewModelType,
ProjectActivityUpdateCellViewModelInputs, ProjectActivityUpdateCellViewModelOutputs {
  public init() {
    let activityAndProject = self.activityAndProjectProperty.signal.skipNil()
    let activity = activityAndProject.map(first)

    self.activityTitle = activity.map(updateNumber(activity:))

    self.body = activity.map { activity in
      guard let update = activity.update else { return "" }
      return update.body?.htmlStripped()?.truncated(maxLength: 300) ?? ""
    }

    self.cellAccessibilityLabel = activity.map { activity in
      return updateNumber(activity: activity).htmlStripped() ?? ""
    }

    self.cellAccessibilityValue = activity.map(title(activity:))

    self.commentsCount = activity.map { activity in
      guard let update = activity.update else { return "" }
      guard let commentsCount = update.commentsCount else { return "" }
      return Format.wholeNumber(commentsCount)
    }

    self.likesCount = activity.map { activity in
      guard let update = activity.update else { return "" }
      guard let likesCount = update.likesCount else { return "" }
      return Format.wholeNumber(likesCount)
    }

    self.updateTitle = activity.map(title(activity:))
  }

  fileprivate let activityAndProjectProperty = MutableProperty<(Activity, Project)?>(nil)
  public func configureWith(activity: Activity, project: Project) {
    self.activityAndProjectProperty.value = (activity, project)
  }

  public let activityTitle: Signal<String, NoError>
  public let body: Signal<String, NoError>
  public let cellAccessibilityLabel: Signal<String, NoError>
  public let cellAccessibilityValue: Signal<String, NoError>
  public let commentsCount: Signal<String, NoError>
  public let likesCount: Signal<String, NoError>
  public let updateTitle: Signal<String, NoError>

  public var inputs: ProjectActivityUpdateCellViewModelInputs { return self }
  public var outputs: ProjectActivityUpdateCellViewModelOutputs { return self }
}

private func updateNumber(activity: Activity) -> String {
  guard let update = activity.update else { return "" }
  return Strings.dashboard_activity_update_number_posted_time_count_days_ago(
    space: "\u{00a0}",
    update_number: Format.wholeNumber(update.sequence ?? 0),
    time_count_days_ago: update.publishedAt.map { Format.relative(secondsInUTC: $0) } ?? ""
  )
}

private func title(activity: Activity) -> String {
  guard let update = activity.update else { return "" }
  return update.title
}
