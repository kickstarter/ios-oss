import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol ProjectActivityCommentCellViewModelInputs {
  /// Call when the backing button is pressed.
  func backingButtonPressed()

  /// Call to set the activity and project.
  func configureWith(activity: Activity, project: Project)

  /// Call when the comment button is pressed.
  func replyButtonPressed()
}

public protocol ProjectActivityCommentCellViewModelOutputs {
  /// Emits the author's image URL.
  var authorImageURL: Signal<URL?, Never> { get }

  /// Emits the body of the comment.
  var body: Signal<String, Never> { get }

  /// Emits the cell's accessibility label.
  var cellAccessibilityLabel: Signal<String, Never> { get }

  /// Emits the cell's accessibility value.
  var cellAccessibilityValue: Signal<String, Never> { get }

  /// Go to the backing info screen.
  var notifyDelegateGoToBacking: Signal<(Project, User), Never> { get }

  /// Go to the comment reply dialog for the project/update comment.
  var notifyDelegateGoToSendReply: Signal<(Project, Update?, Comment), Never> { get }

  /// Emits a Bool whether the footer pledge and reply stack view is hidden or not.
  var pledgeFooterIsHidden: Signal<Bool, Never> { get }

  /// Emits the activity's title.
  var title: Signal<String, Never> { get }
}

public protocol ProjectActivityCommentCellViewModelType {
  var inputs: ProjectActivityCommentCellViewModelInputs { get }
  var outputs: ProjectActivityCommentCellViewModelOutputs { get }
}

public final class ProjectActivityCommentCellViewModel: ProjectActivityCommentCellViewModelType,
  ProjectActivityCommentCellViewModelInputs, ProjectActivityCommentCellViewModelOutputs {
  public init() {
    let activityAndProject = self.activityAndProjectProperty.signal.skipNil()
    let activity = activityAndProject.map(first)

    self.authorImageURL = activity.map { ($0.user?.avatar.medium).flatMap(URL.init) }

    self.body = activity.map { $0.comment?.body ?? "" }

    self.notifyDelegateGoToBacking = activityAndProject
      .takeWhen(self.backingButtonPressedProperty.signal)
      .map { activity, project -> (Project, User)? in
        guard let user = activity.user else { return nil }
        return (project, user)
      }
      .skipNil()

    let projectComment = activityAndProject
      .filter { activity, _ in activity.category == .commentProject }
      .flatMap { activity, project -> SignalProducer<(Project, Update?, Comment), Never> in
        guard let comment = activity.comment else { return .empty }
        return .init(value: (project, nil, comment))
      }

    let updateComment = activityAndProject
      .filter { activity, _ in activity.category == .commentPost }
      .flatMap { activity, project -> SignalProducer<(Project, Update?, Comment), Never> in
        guard let update = activity.update, let comment = activity.comment else { return .empty }
        return .init(value: (project, update, comment))
      }

    self.notifyDelegateGoToSendReply = Signal.merge(projectComment, updateComment)
      .takeWhen(self.replyButtonPressedProperty.signal)

    let projectTitle = activity
      .filter { $0.category == .commentProject }
      .map(commentOnProjectTitle(activity:))

    let updateTitle = activity
      .filter { $0.category == .commentPost }
      .map(commentOnUpdateTitle(activity:))

    self.title = Signal.merge(projectTitle, updateTitle)

    self.cellAccessibilityLabel = self.title.map { title in title.htmlStripped() ?? "" }

    self.cellAccessibilityValue = self.body

    self.pledgeFooterIsHidden = activityAndProject
      .map { activity, project in
        activity.user == AppEnvironment.current.currentUser
          && project.creator == AppEnvironment.current.currentUser
      }
  }

  fileprivate let backingButtonPressedProperty = MutableProperty(())
  public func backingButtonPressed() {
    self.backingButtonPressedProperty.value = ()
  }

  fileprivate let replyButtonPressedProperty = MutableProperty(())
  public func replyButtonPressed() {
    self.replyButtonPressedProperty.value = ()
  }

  fileprivate let activityAndProjectProperty = MutableProperty<(Activity, Project)?>(nil)
  public func configureWith(activity: Activity, project: Project) {
    self.activityAndProjectProperty.value = (activity, project)
  }

  public let authorImageURL: Signal<URL?, Never>
  public let body: Signal<String, Never>
  public let cellAccessibilityLabel: Signal<String, Never>
  public let cellAccessibilityValue: Signal<String, Never>
  public let notifyDelegateGoToBacking: Signal<(Project, User), Never>
  public let notifyDelegateGoToSendReply: Signal<(Project, Update?, Comment), Never>
  public let pledgeFooterIsHidden: Signal<Bool, Never>
  public let title: Signal<String, Never>

  public var inputs: ProjectActivityCommentCellViewModelInputs { return self }
  public var outputs: ProjectActivityCommentCellViewModelOutputs { return self }
}

private func commentOnProjectTitle(activity: Activity) -> String {
  guard let user = activity.user else { return "" }

  return AppEnvironment.current.currentUser == user ?
    Strings.dashboard_activity_you_commented_on_your_project() :
    Strings.dashboard_activity_user_name_commented_on_your_project(user_name: user.name)
}

private func commentOnUpdateTitle(activity: Activity) -> String {
  guard let update = activity.update, let user = activity.user else { return "" }

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
