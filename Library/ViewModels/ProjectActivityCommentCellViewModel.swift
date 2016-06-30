import KsApi
import Prelude
import ReactiveCocoa
import ReactiveExtensions
import Result

public protocol ProjectActivityCommentCellViewModelInputs {
  /// Call when the backing info button is pressed.
  func backingInfoButtonPressed()

  /// Call when the comment button is pressed.
  func commentButtonPressed()

  /// Call to set the activity.
  func configureWith(activity activity: Activity)
}

public protocol ProjectActivityCommentCellViewModelOutputs {
  /// Emits the author's image URL.
  var authorImageURL: Signal<NSURL?, NoError> { get }

  /// Emits the body of the comment.
  var body: Signal<String, NoError> { get }

  /// Go to the backing info screen.
  var goToBackingInfo: Signal<(Project, User), NoError> { get }

  /// Go to the project comment screen.
  var goToProjectComment: Signal<(Project, String), NoError> { get }

  /// Go to the update comment screen.
  var goToUpdateComment: Signal<(Update, String), NoError> { get }

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
    let activity = self.activityProperty.signal.ignoreNil()

    self.authorImageURL = activity.map { ($0.user?.avatar.medium).flatMap(NSURL.init) }

    self.body = activity.map { $0.comment?.body ?? "" }

    self.goToBackingInfo = activity
      .takeWhen(self.backingInfoButtonPressedProperty.signal)
      .map { activity -> (Project, User)? in
        guard let project = activity.project, user = activity.user else { return nil }
        return (project, user)
      }
      .ignoreNil()

    self.goToProjectComment = activity
      .takeWhen(self.commentButtonPressedProperty.signal)
      .filter { $0.category == .commentProject }
      .flatMap { activity -> SignalProducer<(Project, String), NoError> in
        guard let project = activity.project, user = activity.user else { return .empty }
        return .init(value: (project, user.name))
      }

    self.goToUpdateComment = activity
      .takeWhen(self.commentButtonPressedProperty.signal)
      .filter { $0.category == .commentPost }
      .flatMap { activity -> SignalProducer<(Update, String), NoError> in
        guard let update = activity.update, user = activity.user else { return .empty }
        return .init(value: (update, user.name))
      }

    let projectTitle = activity
      .filter { $0.category == .commentProject }
      .map(commentOnProjectTitle(forActivity:))

    let updateTitle = activity
      .filter { $0.category == .commentPost }
      .map(commentOnUpdateTitle(forActivity:))

    self.title = Signal.merge(projectTitle, updateTitle)
  }

  private let backingInfoButtonPressedProperty = MutableProperty()
  public func backingInfoButtonPressed() {
    self.backingInfoButtonPressedProperty.value = ()
  }

  private let commentButtonPressedProperty = MutableProperty()
  public func commentButtonPressed() {
    self.commentButtonPressedProperty.value = ()
  }

  private let activityProperty = MutableProperty<Activity?>(nil)
  public func configureWith(activity activity: Activity) {
    self.activityProperty.value = activity
  }

  public let authorImageURL: Signal<NSURL?, NoError>
  public let body: Signal<String, NoError>
  public let goToBackingInfo: Signal<(Project, User), NoError>
  public let goToProjectComment: Signal<(Project, String), NoError>
  public let goToUpdateComment: Signal<(Update, String), NoError>
  public let title: Signal<String, NoError>

  public var inputs: ProjectActivityCommentCellViewModelInputs { return self }
  public var outputs: ProjectActivityCommentCellViewModelOutputs { return self }
}

private func commentOnProjectTitle(forActivity activity: Activity) -> String {
  guard let user = activity.user else { return "" }

  return AppEnvironment.current.currentUser == user ?
    Strings.activity_creator_actions_you_commented_on_your_project() :
    Strings.activity_creator_actions_user_name_commented_on_your_project(user_name: user.name)
}

private func commentOnUpdateTitle(forActivity activity: Activity) -> String {
  guard let update = activity.update, user = activity.user else { return "" }

  if AppEnvironment.current.currentUser == user {
    return Strings.activity_creator_actions_you_commented_on_update_number(
      update_number: String(update.sequence)
    )
  } else {
    return Strings.activity_creator_actions_user_name_commented_on_update_number(
      user_name: user.name,
      update_number: String(update.sequence)
    )
  }
}
