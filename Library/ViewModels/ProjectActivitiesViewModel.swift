import KsApi
import Prelude
import ReactiveCocoa
import ReactiveExtensions
import Result

public protocol ProjectActivitiesViewModelInputs {
  /// Call to set project.
  func configureWith(project: Project)

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
  }

  private let projectProperty = MutableProperty<Project?>(nil)
  public func configureWith(project: Project) { self.projectProperty.value = project }

  private let refreshProperty = MutableProperty()
  public func refresh() { self.refreshProperty.value = () }

  private let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() { self.viewDidLoadProperty.value = () }

  private let willDisplayRowProperty = MutableProperty<(row: Int, totalRows: Int)?>(nil)
  public func willDisplayRow(row: Int, outOf totalRows: Int) {
    self.willDisplayRowProperty.value = (row, totalRows)
  }

  public let activitiesAndProject: Signal<([Activity], Project), NoError>
  public let isRefreshing: Signal<Bool, NoError>
  public let showEmptyState: Signal<Bool, NoError>

  public var inputs: ProjectActivitiesViewModelInputs { return self }
  public var outputs: ProjectActivitiesViewModelOutputs { return self }
}
