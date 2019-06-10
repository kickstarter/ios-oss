import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol ProjectActivityUpdateCellViewModelInputs {
  /// Call to set the activity and project.
  func configureWith(activity: Activity, project: Project)
}

public protocol ProjectActivityUpdateCellViewModelOutputs {
  /// Emits the update's author and sequence.
  var activityTitle: Signal<String, Never> { get }

  /// Emits the update's body.
  var body: Signal<String, Never> { get }

  /// Emits the cell's accessibility label.
  var cellAccessibilityLabel: Signal<String, Never> { get }

  /// Emits the cell's accessibility value.
  var cellAccessibilityValue: Signal<String, Never> { get }

  /// Emits the number of comments.
  var commentsCount: Signal<String, Never> { get }

  /// Emits the number of likes.
  var likesCount: Signal<String, Never> { get }

  /// Emits the title of the update.
  var updateTitle: Signal<String, Never> { get }
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
      updateNumber(activity: activity).htmlStripped() ?? ""
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

  public let activityTitle: Signal<String, Never>
  public let body: Signal<String, Never>
  public let cellAccessibilityLabel: Signal<String, Never>
  public let cellAccessibilityValue: Signal<String, Never>
  public let commentsCount: Signal<String, Never>
  public let likesCount: Signal<String, Never>
  public let updateTitle: Signal<String, Never>

  public var inputs: ProjectActivityUpdateCellViewModelInputs { return self }
  public var outputs: ProjectActivityUpdateCellViewModelOutputs { return self }
}

private func updateNumber(activity: Activity) -> String {
  guard let update = activity.update else { return "" }
  return Strings.dashboard_activity_update_number_posted_time_count_days_ago(
    space: "\u{00a0}",
    update_number: Format.wholeNumber(update.sequence),
    time_count_days_ago: update.publishedAt.map { Format.relative(secondsInUTC: $0) } ?? ""
  )
}

private func title(activity: Activity) -> String {
  guard let update = activity.update else { return "" }
  return update.title
}
