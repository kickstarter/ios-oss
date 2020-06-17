import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public enum ProjectActivitiesGoTo {
  case backing(ManagePledgeViewParamConfigData)
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
  func projectActivityBackingCellGoToBacking(project: Project, backing: Backing)

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
  var goTo: Signal<ProjectActivitiesGoTo, Never> { get }

  /// Emits a boolean that indicates whether the view is refreshing.
  var isRefreshing: Signal<Bool, Never> { get }

  /// Emits project activity data.
  var projectActivityData: Signal<ProjectActivityData, Never> { get }

  /// Emits `true` when the empty state should be shown, and `false` when it should be hidden.
  var showEmptyState: Signal<Bool, Never> { get }
}

public protocol ProjectActivitiesViewModelType {
  var inputs: ProjectActivitiesViewModelInputs { get }
  var outputs: ProjectActivitiesViewModelOutputs { get }
}

public final class ProjectActivitiesViewModel: ProjectActivitiesViewModelType,
  ProjectActivitiesViewModelInputs, ProjectActivitiesViewModelOutputs {
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

    let activities: Signal<[Activity], Never>
    let pageCount: Signal<Int, Never>
    (activities, self.isRefreshing, pageCount) = paginate(
      requestFirstPageWith: requestFirstPage,
      requestNextPageWhen: isCloseToBottom,
      clearOnNewRequest: false,
      valuesFromEnvelope: { $0.activities },
      cursorFromEnvelope: { $0.urls.api.moreActivities },
      requestFromParams: { AppEnvironment.current.apiService.fetchProjectActivities(forProject: $0) },
      requestFromCursor: { AppEnvironment.current.apiService.fetchProjectActivities(paginationUrl: $0) }
    )

    self.projectActivityData = Signal.combineLatest(activities, project)
      .map { activities, project in
        ProjectActivityData(
          activities: activities,
          project: project,
          groupedDates: !AppEnvironment.current.isVoiceOverRunning()
        )
      }

    self.showEmptyState = activities
      .map { $0.isEmpty }
      .skipRepeats()

    let cellTappedGoTo = self.activityAndProjectCellTappedProperty.signal.skipNil()
      .flatMap { activity, project -> SignalProducer<ProjectActivitiesGoTo, Never> in
        switch activity.category {
        case .backing, .backingAmount, .backingCanceled, .backingReward:
          guard let params = backingParams(project: project, activity: activity) else { return .empty }
          return .init(value: params)
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

    let projectActivityBackingCellGoToBacking = self.projectActivityBackingCellGoToBackingProperty.signal
      .skipNil()
      .filterMap(backingParams(project:backing:))

    let projectActivityBackingCellGoToSendMessage =
      self.projectActivityBackingCellGoToSendMessageProperty.signal.skipNil()
        .map { _, backing in
          ProjectActivitiesGoTo.sendMessage(backing, Koala.MessageDialogContext.creatorActivity)
        }

    let projectActivityCommentCellGoToBacking =
      self.projectActivityCommentCellGoToBackingProperty.signal.skipNil()
        .switchMap { project, user in
          AppEnvironment.current.apiService.fetchBacking(forProject: project, forUser: user)
            .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
            .map { backing in (project, backing) }
            .materialize()
        }
        .values()
        .filterMap(backingParams(project:backing:))

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
      .take(first: 1)
      .observeValues { AppEnvironment.current.koala.trackViewedProjectActivity(project: $0) }

    project
      .takeWhen(pageCount.skip(first: 1).filter { $0 == 1 })
      .observeValues { AppEnvironment.current.koala.trackLoadedNewerProjectActivity(project: $0) }

    project
      .takePairWhen(pageCount.skip(first: 1).filter { $0 > 1 })
      .observeValues { project, pageCount in
        AppEnvironment.current.koala.trackLoadedOlderProjectActivity(project: project, page: pageCount)
      }
  }

  private let activityAndProjectCellTappedProperty = MutableProperty<(Activity, Project)?>(nil)
  public func activityAndProjectCellTapped(activity: Activity, project: Project) {
    self.activityAndProjectCellTappedProperty.value = (activity, project)
  }

  private let projectProperty = MutableProperty<Project?>(nil)
  public func configureWith(_ project: Project) { self.projectProperty.value = project }

  private let projectActivityBackingCellGoToBackingProperty = MutableProperty<(Project, Backing)?>(nil)
  public func projectActivityBackingCellGoToBacking(project: Project, backing: Backing) {
    self.projectActivityBackingCellGoToBackingProperty.value = (project, backing)
  }

  private let projectActivityBackingCellGoToSendMessageProperty = MutableProperty<(Project, Backing)?>(nil)
  public func projectActivityBackingCellGoToSendMessage(project: Project, backing: Backing) {
    self.projectActivityBackingCellGoToSendMessageProperty.value = (project, backing)
  }

  private let projectActivityCommentCellGoToBackingProperty = MutableProperty<(Project, User)?>(nil)
  public func projectActivityCommentCellGoToBacking(project: Project, user: User) {
    self.projectActivityCommentCellGoToBackingProperty.value = (project, user)
  }

  private let projectActivityCommentCellGoToSendReplyProperty
    = MutableProperty<(Project, Update?, Comment)?>(nil)
  public func projectActivityCommentCellGoToSendReply(
    project: Project,
    update: Update?,
    comment: Comment
  ) {
    self.projectActivityCommentCellGoToSendReplyProperty.value = (project, update, comment)
  }

  private let refreshProperty = MutableProperty(())
  public func refresh() { self.refreshProperty.value = () }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() { self.viewDidLoadProperty.value = () }

  private let willDisplayRowProperty = MutableProperty<(row: Int, totalRows: Int)?>(nil)
  public func willDisplayRow(_ row: Int, outOf totalRows: Int) {
    self.willDisplayRowProperty.value = (row, totalRows)
  }

  public let goTo: Signal<ProjectActivitiesGoTo, Never>
  public let isRefreshing: Signal<Bool, Never>
  public let projectActivityData: Signal<ProjectActivityData, Never>
  public let showEmptyState: Signal<Bool, Never>

  public var inputs: ProjectActivitiesViewModelInputs { return self }
  public var outputs: ProjectActivitiesViewModelOutputs { return self }
}

private func backingParams(project: Project, activity: Activity) -> ProjectActivitiesGoTo? {
  let backingId = activity.memberData.backing?.id

  return ProjectActivitiesGoTo.backing(
    (projectParam: Param.slug(project.slug), backingParam: backingId.flatMap(Param.id))
  )
}

private func backingParams(project: Project, backing: Backing) -> ProjectActivitiesGoTo? {
  return ProjectActivitiesGoTo.backing(
    (projectParam: Param.slug(project.slug), backingParam: Param.id(backing.id))
  )
}
