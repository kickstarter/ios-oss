import KsApi
import Prelude
import ReactiveCocoa
import ReactiveExtensions
import Result

public protocol ProjectActivityUpdateCellViewModelInputs {
  /// Call to set the activity.
  func configureWith(activity activity: Activity)
}

public protocol ProjectActivityUpdateCellViewModelOutputs {
  /// Emits the update's author and sequence.
  var activityTitle: Signal<String?, NoError> { get }

  /// Emits a boolean indicating whether the author label is hidden.
  var authorIsHidden: Signal<Bool, NoError> { get }

  /// Emits the author's image URL.
  var authorImageURL: Signal<NSURL?, NoError> { get }

  /// Emits the author's name.
  var authorName: Signal<String?, NoError> { get }

  /// Emits the title of the update.
  var updateTitle: Signal<String?, NoError> { get }
}

public protocol ProjectActivityUpdateCellViewModelType {
  var inputs: ProjectActivityUpdateCellViewModelInputs { get }
  var outputs: ProjectActivityUpdateCellViewModelOutputs { get }
}

public final class ProjectActivityUpdateCellViewModel: ProjectActivityUpdateCellViewModelType,
ProjectActivityUpdateCellViewModelInputs, ProjectActivityUpdateCellViewModelOutputs {
  public init() {
    let activity = self.activityProperty.signal.ignoreNil()

    let authorAndTitle = activity
      .map { activity in
        (
          author: activity.update.flatMap(authorFrom(update:)),
          title: activity.update.map(titleFrom(update:))
        )
    }

    self.authorIsHidden = activity
      .map { activity in
        if let update = activity.update {
          return !currentUserIsAuthor(update: update)
        }
        return true
    }

    self.authorName = authorAndTitle.map { $0.author }
    self.activityTitle = authorAndTitle.map { $0.title }

    self.authorImageURL = activity
      .map { ($0.user?.avatar.medium).flatMap(NSURL.init) }

    self.updateTitle = activity.map { $0.update?.title }
  }

  private let activityProperty = MutableProperty<Activity?>(nil)
  public func configureWith(activity activity: Activity) {
    self.activityProperty.value = activity
  }

  public let activityTitle: Signal<String?, NoError>
  public let authorImageURL: Signal<NSURL?, NoError>
  public let authorIsHidden: Signal<Bool, NoError>
  public let authorName: Signal<String?, NoError>
  public let updateTitle: Signal<String?, NoError>

  public var inputs: ProjectActivityUpdateCellViewModelInputs { return self }
  public var outputs: ProjectActivityUpdateCellViewModelOutputs { return self }
}

private func authorFrom(update update: Update) -> String? {
  return currentUserIsAuthor(update: update) ?
    Strings.activity_creator_you() : update.user?.name
}

private func currentUserIsAuthor(update update: Update) -> Bool {
  return AppEnvironment.current.currentUser == update.user
}

private func titleFrom(update update: Update) -> String {
  return Strings.activity_creator_actions_user_name_posted_update_number(
    user_name: authorFrom(update: update) ?? "",
    update_number: Format.wholeNumber(update.sequence ?? 0)
  )
}
