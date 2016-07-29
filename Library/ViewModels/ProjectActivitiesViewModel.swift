import KsApi
import Prelude
import ReactiveCocoa
import ReactiveExtensions
import Result

public enum ProjectActivitiesGoTo {
  case backing(Project, User)
  case comments(Project, Update?)
  case project(Project)
  case sendMessage(Project, Backing)
  case sendReplyOnProject(Project, Comment)
  case sendReplyOnUpdate(Update, Comment)
  case update(Project, Update)
}

public protocol ProjectActivitiesViewModelInputs {
  /// Call when a cell containing an activity and project is tapped.
  func activityAndProjectCellTapped(activity activity: Activity, project: Project)

  /// Call to set project.
  func configureWith(project: Project)

  /// Call when the backing cell's backing button is pressed.
  func projectActivityBackingCellGoToBacking(project project: Project, user: User)

  /// Call when the backing cell's send message button is pressed.
  func projectActivityBackingCellGoToSendMessage(project project: Project, backing: Backing)

  /// Call when the comment cell's backing button is pressed.
  func projectActivityCommentCellGoToBacking(project project: Project, user: User)

  /// Call when the comment cell's reply button is pressed for a project comment.
  func projectActivityCommentCellGoToSendReplyOnProject(project project: Project, comment: Comment)

  /// Call when the comment cell's reply button is pressed for a project update.
  func projectActivityCommentCellGoToSendReplyOnUpdate(update update: Update, comment: Comment)

  /// Call when pull-to-refresh is invoked.
  func refresh()

  /// Call when the view loads.
  func viewDidLoad()

  /**
   Call from the controller's `tableView:willDisplayCell:forRowAtIndexPath` method.

   - parameter row:       The 0-based index of the row displaying.
   - parameter totalRows: The total number of rows in the table view.
   */
  func willDisplayRow(row: Int, outOf totalRows: Int)
}

public protocol ProjectActivitiesViewModelOutputs {
  /// Emits a an array of activities and project that should be displayed.
  var activitiesAndProject: Signal<([Activity], Project), NoError> { get }

  /// Emits when another screen should be loaded.
  var goTo: Signal<ProjectActivitiesGoTo, NoError> { get }

  /// Emits a boolean that indicates whether the view is refreshing.
  var isRefreshing: Signal<Bool, NoError> { get }

  /// Emits `true` when the empty state should be shown, and `false` when it should be hidden.
  var showEmptyState: Signal<Bool, NoError> { get }
}

public protocol ProjectActivitiesViewModelType {
  var inputs: ProjectActivitiesViewModelInputs { get }
  var outputs: ProjectActivitiesViewModelOutputs { get }
}

public final class ProjectActivitiesViewModel: ProjectActivitiesViewModelType,
  ProjectActivitiesViewModelInputs, ProjectActivitiesViewModelOutputs {

  // swiftlint:disable function_body_length
  public init() {
    let project = self.projectProperty.signal.ignoreNil()

    let isCloseToBottom = self.willDisplayRowProperty.signal.ignoreNil()
      .map { row, total in row >= total - 3 }
      .skipRepeats()
      .filter(isTrue)
      .ignoreValues()

    let requestFirstPage = project
      .takeWhen(
        .merge(
          self.viewDidLoadProperty.signal,
          self.refreshProperty.signal
        )
    )

    let activities: Signal<[Activity], NoError>
    (activities, self.isRefreshing, _) = paginate(
      requestFirstPageWith: requestFirstPage,
      requestNextPageWhen: isCloseToBottom,
      clearOnNewRequest: false,
      valuesFromEnvelope: { $0.activities },
      cursorFromEnvelope: { $0.urls.api.moreActivities },
      requestFromParams: { AppEnvironment.current.apiService.fetchProjectActivities(forProject: $0) },
      requestFromCursor: { AppEnvironment.current.apiService.fetchProjectActivities(paginationUrl: $0) }
    )

    self.activitiesAndProject = combineLatest(activities, project)

    self.showEmptyState = activities
      .map { $0.isEmpty }
      .skipRepeats()

    let cellTappedGoTo = self.activityAndProjectCellTappedProperty.signal.ignoreNil()
      .flatMap { activity, project -> SignalProducer<(ProjectActivitiesGoTo), NoError> in
        switch activity.category {
        case .backing, .backingAmount, .backingCanceled, .backingReward:
          guard let user = activity.user else { return .empty }
          return .init(value: .backing(project, user))
        case .commentPost, .commentProject:
          return .init(value: .comments(project, activity.update))
        case .launch, .success, .cancellation, .failure, .suspension:
          return .init(value: .project(project))
        case .update:
          guard let update = activity.update else { return .empty }
          return .init(value: .update(project, update))
        case .backingDropped, .follow, .funding, .watch, .unknown:
          assertionFailure("Unsupported activity: \(activity)")
          return .empty
        }
    }

    let projectActivityBackingCellGoToBacking =
      self.projectActivityBackingCellGoToBackingProperty.signal.ignoreNil()
        .map { project, user in ProjectActivitiesGoTo.backing(project, user) }

    let projectActivityBackingCellGoToSendMessage =
      self.projectActivityBackingCellGoToSendMessageProperty.signal.ignoreNil()
        .map { project, backing in ProjectActivitiesGoTo.sendMessage(project, backing) }

    let projectActivityCommentCellGoToBacking =
      self.projectActivityCommentCellGoToBackingProperty.signal.ignoreNil()
        .map { project, user in ProjectActivitiesGoTo.backing(project, user) }

    let projectActivityCommentCellGoToSendReplyOnProject =
      self.projectActivityCommentCellGoToSendReplyOnProject.signal.ignoreNil()
        .map { project, comment in ProjectActivitiesGoTo.sendReplyOnProject(project, comment) }

    let projectActivityCommentCellGoToSendReplyOnUpdate =
      self.projectActivityCommentCellGoToSendReplyOnUpdate.signal.ignoreNil()
        .map { update, comment in ProjectActivitiesGoTo.sendReplyOnUpdate(update, comment) }

    self.goTo = Signal.merge(
      cellTappedGoTo,
      projectActivityBackingCellGoToBacking,
      projectActivityBackingCellGoToSendMessage,
      projectActivityCommentCellGoToBacking,
      projectActivityCommentCellGoToSendReplyOnProject,
      projectActivityCommentCellGoToSendReplyOnUpdate
    )
  }
  // swiftlint:enable function_body_length

  private let activityAndProjectCellTappedProperty = MutableProperty<(Activity, Project)?>(nil)
  public func activityAndProjectCellTapped(activity activity: Activity, project: Project) {
    self.activityAndProjectCellTappedProperty.value = (activity, project)
  }

  private let projectProperty = MutableProperty<Project?>(nil)
  public func configureWith(project: Project) { self.projectProperty.value = project }

  private let projectActivityBackingCellGoToBackingProperty = MutableProperty<(Project, User)?>(nil)
  public func projectActivityBackingCellGoToBacking(project project: Project, user: User) {
    self.projectActivityBackingCellGoToBackingProperty.value = (project, user)
  }

  private let projectActivityBackingCellGoToSendMessageProperty = MutableProperty<(Project, Backing)?>(nil)
  public func projectActivityBackingCellGoToSendMessage(project project: Project, backing: Backing) {
    self.projectActivityBackingCellGoToSendMessageProperty.value = (project, backing)
  }

  private let projectActivityCommentCellGoToBackingProperty = MutableProperty<(Project, User)?>(nil)
  public func projectActivityCommentCellGoToBacking(project project: Project, user: User) {
    self.projectActivityCommentCellGoToBackingProperty.value = (project, user)
  }

  private let projectActivityCommentCellGoToSendReplyOnProject = MutableProperty<(Project, Comment)?>(nil)
  public func projectActivityCommentCellGoToSendReplyOnProject(project project: Project, comment: Comment) {
    self.projectActivityCommentCellGoToSendReplyOnProject.value = (project, comment)
  }

  private let projectActivityCommentCellGoToSendReplyOnUpdate = MutableProperty<(Update, Comment)?>(nil)
  public func projectActivityCommentCellGoToSendReplyOnUpdate(update update: Update, comment: Comment) {
    self.projectActivityCommentCellGoToSendReplyOnUpdate.value = (update, comment)
  }

  private let refreshProperty = MutableProperty()
  public func refresh() { self.refreshProperty.value = () }

  private let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() { self.viewDidLoadProperty.value = () }

  private let willDisplayRowProperty = MutableProperty<(row: Int, totalRows: Int)?>(nil)
  public func willDisplayRow(row: Int, outOf totalRows: Int) {
    self.willDisplayRowProperty.value = (row, totalRows)
  }

  public let activitiesAndProject: Signal<([Activity], Project), NoError>
  public let goTo: Signal<ProjectActivitiesGoTo, NoError>
  public let isRefreshing: Signal<Bool, NoError>
  public let showEmptyState: Signal<Bool, NoError>

  public var inputs: ProjectActivitiesViewModelInputs { return self }
  public var outputs: ProjectActivitiesViewModelOutputs { return self }
}
