import KsApi
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result

public enum ProjectActivitiesGoTo {
  case backing(Project, User)
  case comments(Project?, Update?)
  case project(Project)
  case sendMessage(Backing, Koala.MessageDialogContext)
  case sendReply(Project, Update?, Comment)
  case update(Project, Update)
}

public protocol ProjectActivitiesViewModelInputs {
  /// Call when a cell containing an activity and project is tapped.
  func activityAndProjectCellTapped(activity: Activity, project: Project)

  /// Call to set project.
  func configureWith(_ project: Project)

  /// Call when the backing cell's backing button is pressed.
  func projectActivityBackingCellGoToBacking(project: Project, user: User)

  /// Call when the backing cell's send message button is pressed.
  func projectActivityBackingCellGoToSendMessage(project: Project, backing: Backing)

  /// Call when the comment cell's backing button is pressed.
  func projectActivityCommentCellGoToBacking(project: Project, user: User)

  /// Call when the comment cell's reply button is pressed.
  func projectActivityCommentCellGoToSendReply(project: Project, update: Update?, comment: Comment)

  /// Call when pull-to-refresh is invoked.
  func refresh()

  /// Call when the view loads.
  func viewDidLoad()

  /**
   Call from the controller's `tableView:willDisplayCell:forRowAtIndexPath` method.

   - parameter row:       The 0-based index of the row displaying.
   - parameter totalRows: The total number of rows in the table view.
   */
  func willDisplayRow(_ row: Int, outOf totalRows: Int)
}

public protocol ProjectActivitiesViewModelOutputs {
  /// Emits when another screen should be loaded.
  var goTo: Signal<ProjectActivitiesGoTo, NoError> { get }

  /// Emits a boolean that indicates whether the view is refreshing.
  var isRefreshing: Signal<Bool, NoError> { get }

  /// Emits project activity data.
  var projectActivityData: Signal<ProjectActivityData, NoError> { get }

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
    let project = self.projectProperty.signal.skipNil()

    let isCloseToBottom = self.willDisplayRowProperty.signal.skipNil()
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
    let pageCount: Signal<Int, NoError>
    (activities, self.isRefreshing, pageCount) = paginate(
      requestFirstPageWith: requestFirstPage,
      requestNextPageWhen: isCloseToBottom,
      clearOnNewRequest: false,
      valuesFromEnvelope: { $0.activities },
      cursorFromEnvelope: { $0.urls.api.moreActivities },
      requestFromParams: { AppEnvironment.current.apiService.fetchProjectActivities(forProject: $0) },
      requestFromCursor: { AppEnvironment.current.apiService.fetchProjectActivities(paginationUrl: $0) }
    )

    self.projectActivityData = combineLatest(activities, project)
      .map { activities, project in
        ProjectActivityData(
          activities: activities,
          project: project,
          groupedDates: !AppEnvironment.current.isVoiceOverRunning())
      }

    self.showEmptyState = activities
      .map { $0.isEmpty }
      .skipRepeats()

    let cellTappedGoTo = self.activityAndProjectCellTappedProperty.signal.skipNil()
      .flatMap { activity, project -> SignalProducer<(ProjectActivitiesGoTo), NoError> in
        switch activity.category {
        case .backing, .backingAmount, .backingCanceled, .backingReward:
          guard let user = activity.user else { return .empty }
          return .init(value: .backing(project, user))
        case .commentProject:
          return .init(value: .comments(project, nil))
        case .commentPost:
          return .init(value: .comments(nil, activity.update))
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
      self.projectActivityBackingCellGoToBackingProperty.signal.skipNil()
        .map { project, user in ProjectActivitiesGoTo.backing(project, user) }

    let projectActivityBackingCellGoToSendMessage =
      self.projectActivityBackingCellGoToSendMessageProperty.signal.skipNil()
        .map { project, backing in
          ProjectActivitiesGoTo.sendMessage(backing, Koala.MessageDialogContext.creatorActivity)
    }

    let projectActivityCommentCellGoToBacking =
      self.projectActivityCommentCellGoToBackingProperty.signal.skipNil()
        .map { project, user in ProjectActivitiesGoTo.backing(project, user) }

    let projectActivityCommentCellGoToSendReply =
      self.projectActivityCommentCellGoToSendReplyProperty.signal.skipNil()
        .map { project, update, comment in ProjectActivitiesGoTo.sendReply(project, update, comment) }

    self.goTo = Signal.merge(
      cellTappedGoTo,
      projectActivityBackingCellGoToBacking,
      projectActivityBackingCellGoToSendMessage,
      projectActivityCommentCellGoToBacking,
      projectActivityCommentCellGoToSendReply
    )

    project
      .takeWhen(self.viewDidLoadProperty.signal)
      .take(1)
      .observeValues { AppEnvironment.current.koala.trackViewedProjectActivity(project: $0) }

    project
      .takeWhen(pageCount.skip(1).filter { $0 == 1 })
      .observeValues { AppEnvironment.current.koala.trackLoadedNewerProjectActivity(project: $0) }

    project
      .takePairWhen(pageCount.skip(1).filter { $0 > 1 })
      .observeValues { project, pageCount in
        AppEnvironment.current.koala.trackLoadedOlderProjectActivity(project: project, page: pageCount)
    }
  }
  // swiftlint:enable function_body_length

  fileprivate let activityAndProjectCellTappedProperty = MutableProperty<(Activity, Project)?>(nil)
  public func activityAndProjectCellTapped(activity: Activity, project: Project) {
    self.activityAndProjectCellTappedProperty.value = (activity, project)
  }

  fileprivate let projectProperty = MutableProperty<Project?>(nil)
  public func configureWith(_ project: Project) { self.projectProperty.value = project }

  fileprivate let projectActivityBackingCellGoToBackingProperty = MutableProperty<(Project, User)?>(nil)
  public func projectActivityBackingCellGoToBacking(project: Project, user: User) {
    self.projectActivityBackingCellGoToBackingProperty.value = (project, user)
  }

  fileprivate let projectActivityBackingCellGoToSendMessageProperty = MutableProperty<(Project, Backing)?>(nil)
  public func projectActivityBackingCellGoToSendMessage(project: Project, backing: Backing) {
    self.projectActivityBackingCellGoToSendMessageProperty.value = (project, backing)
  }

  fileprivate let projectActivityCommentCellGoToBackingProperty = MutableProperty<(Project, User)?>(nil)
  public func projectActivityCommentCellGoToBacking(project: Project, user: User) {
    self.projectActivityCommentCellGoToBackingProperty.value = (project, user)
  }

  fileprivate let projectActivityCommentCellGoToSendReplyProperty
    = MutableProperty<(Project, Update?, Comment)?>(nil)
  public func projectActivityCommentCellGoToSendReply(project: Project,
                                                              update: Update?,
                                                              comment: Comment) {
    self.projectActivityCommentCellGoToSendReplyProperty.value = (project, update, comment)
  }

  fileprivate let refreshProperty = MutableProperty()
  public func refresh() { self.refreshProperty.value = () }

  fileprivate let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() { self.viewDidLoadProperty.value = () }

  fileprivate let willDisplayRowProperty = MutableProperty<(row: Int, totalRows: Int)?>(nil)
  public func willDisplayRow(_ row: Int, outOf totalRows: Int) {
    self.willDisplayRowProperty.value = (row, totalRows)
  }

  public let goTo: Signal<ProjectActivitiesGoTo, NoError>
  public let isRefreshing: Signal<Bool, NoError>
  public let projectActivityData: Signal<ProjectActivityData, NoError>
  public let showEmptyState: Signal<Bool, NoError>

  public var inputs: ProjectActivitiesViewModelInputs { return self }
  public var outputs: ProjectActivitiesViewModelOutputs { return self }
}
