import KsApi
import Prelude
import ReactiveCocoa
import ReactiveExtensions
import Result

public protocol ProjectActivityCommentCellViewModelInputs {
  /// Call when the backing button is pressed.
  func backingButtonPressed()

  /// Call to set the activity and project.
  func configureWith(activity activity: Activity, project: Project)

  /// Call when the comment button is pressed.
  func replyButtonPressed()
}

public protocol ProjectActivityCommentCellViewModelOutputs {
  /// Emits the author's image URL.
  var authorImageURL: Signal<NSURL?, NoError> { get }

  /// Emits the body of the comment.
  var body: Signal<String, NoError> { get }

  /// Emits the cell's accessibility label.
  var cellAccessibilityLabel: Signal<String, NoError> { get }

  /// Emits the cell's accessibility value.
  var cellAccessibilityValue: Signal<String, NoError> { get }

  /// Go to the backing info screen.
  var notifyDelegateGoToBacking: Signal<(Project, User), NoError> { get }

  /// Go to the project comment screen.
  var notifyDelegateGoToSendReplyOnProject: Signal<(Project, Comment), NoError> { get }

  /// Go to the update comment screen.
  var notifyDelegateGoToSendReplyOnUpdate: Signal<(Update, Comment), NoError> { get }

  /// Emits the activity's title.
  var title: Signal<String, NoError> { get }
}

public protocol ProjectActivityCommentCellViewModelType {
  var inputs: ProjectActivityCommentCellViewModelInputs { get }
  var outputs: ProjectActivityCommentCellViewModelOutputs { get }
}

public final class ProjectActivityCommentCellViewModel: ProjectActivityCommentCellViewModelType,
ProjectActivityCommentCellViewModelInputs, ProjectActivityCommentCellViewModelOutputs {

  public init() {
    let activityAndProject = self.activityAndProjectProperty.signal.ignoreNil()
    let activity = activityAndProject.map(first)

    self.authorImageURL = activity.map { ($0.user?.avatar.medium).flatMap(NSURL.init) }

    self.body = activity.map { $0.comment?.body ?? "" }

    self.notifyDelegateGoToBacking = activityAndProject
      .takeWhen(self.backingButtonPressedProperty.signal)
      .map { activity, project -> (Project, User)? in
        guard let user = activity.user else { return nil }
        return (project, user)
      }
      .ignoreNil()

    self.notifyDelegateGoToSendReplyOnProject = activityAndProject
      .takeWhen(self.replyButtonPressedProperty.signal)
      .filter { activity, project in activity.category == .commentProject }
      .flatMap { activity, project -> SignalProducer<(Project, Comment), NoError> in
        guard let comment = activity.comment else { return .empty }
        return .init(value: (project, comment))
      }

    self.notifyDelegateGoToSendReplyOnUpdate = activity
      .takeWhen(self.replyButtonPressedProperty.signal)
      .filter { $0.category == .commentPost }
      .flatMap { activity -> SignalProducer<(Update, Comment), NoError> in
        guard let update = activity.update, comment = activity.comment else { return .empty }
        return .init(value: (update, comment))
      }

    let projectTitle = activity
      .filter { $0.category == .commentProject }
      .map(commentOnProjectTitle(activity:))

    let updateTitle = activity
      .filter { $0.category == .commentPost }
      .map(commentOnUpdateTitle(activity:))

    self.title = Signal.merge(projectTitle, updateTitle)

    self.cellAccessibilityLabel = self.title.map { title in title.htmlStripped() ?? "" }

    self.cellAccessibilityValue = self.body
  }

  private let backingButtonPressedProperty = MutableProperty()
  public func backingButtonPressed() {
    self.backingButtonPressedProperty.value = ()
  }

  private let replyButtonPressedProperty = MutableProperty()
  public func replyButtonPressed() {
    self.replyButtonPressedProperty.value = ()
  }

  private let activityAndProjectProperty = MutableProperty<(Activity, Project)?>(nil)
  public func configureWith(activity activity: Activity, project: Project) {
    self.activityAndProjectProperty.value = (activity, project)
  }

  public let authorImageURL: Signal<NSURL?, NoError>
  public let body: Signal<String, NoError>
  public let cellAccessibilityLabel: Signal<String, NoError>
  public let cellAccessibilityValue: Signal<String, NoError>
  public let notifyDelegateGoToBacking: Signal<(Project, User), NoError>
  public let notifyDelegateGoToSendReplyOnProject: Signal<(Project, Comment), NoError>
  public let notifyDelegateGoToSendReplyOnUpdate: Signal<(Update, Comment), NoError>
  public let title: Signal<String, NoError>

  public var inputs: ProjectActivityCommentCellViewModelInputs { return self }
  public var outputs: ProjectActivityCommentCellViewModelOutputs { return self }
}

private func commentOnProjectTitle(activity activity: Activity) -> String {
  guard let user = activity.user else { return "" }

  return AppEnvironment.current.currentUser == user ?
    Strings.dashboard_activity_you_commented_on_your_project() :
    Strings.dashboard_activity_user_name_commented_on_your_project(user_name: user.name)
}

private func commentOnUpdateTitle(activity activity: Activity) -> String {
  guard let update = activity.update, user = activity.user else { return "" }

  if AppEnvironment.current.currentUser == user {
    return Strings.dashboard_activity_you_commented_on_update_number(
      space: "\u{00a0}",
      update_number: String(update.sequence)
    )
  } else {
    return Strings.dashboard_activity_user_name_commented_on_update_number(
      user_name: user.name,
      space: "\u{00a0}",
      update_number: String(update.sequence)
    )
  }
}
