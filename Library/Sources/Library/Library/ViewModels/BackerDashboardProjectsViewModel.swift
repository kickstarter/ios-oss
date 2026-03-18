import Foundation
import GraphAPI
import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public enum ProfileProjectsType: Decodable {
  case backed
  case saved

  var trackingString: String {
    switch self {
    case .backed: return "backed"
    case .saved: return "saved"
    }
  }
}

public protocol BackerDashboardProjectsViewModelInputs {
  /// Call to configure with the ProfileProjectsType to display.
  func configureWith(projectsType: ProfileProjectsType)

  /// Call when the user has updated.
  func currentUserUpdated()

  /// Call when a project cell is tapped.
  func projectTapped(_ project: Project)

  /// Call when pull-to-refresh is invoked.
  func refresh()

  /// Call when the view loads.
  func viewDidLoad()

  /// Call when the view did appear.
  func viewDidAppear(_ animated: Bool)

  /// Call when a new row is displayed.
  func willDisplayRow(_ row: Int, outOf totalRows: Int)
}

public protocol BackerDashboardProjectsViewModelOutputs {
  /// Emits a boolean that determines if the empty state is visible and a ProfileProjectsType.
  var emptyStateIsVisible: Signal<(Bool, ProfileProjectsType), Never> { get }

  /// Emits the project, projects, and ref tag when should go to project page.
  var goToProject: Signal<(Project, RefTag), Never> { get }

  /// Emits when the pull-to-refresh control is refreshing or not.
  var isRefreshing: Signal<Bool, Never> { get }

  /// Emits `true` when the next page is loading.
  var isLoadingNextPage: Signal<Bool, Never> { get }

  /// Emits a list of projects for the tableview datasource.
  var projects: Signal<[ProjectCardProperties], Never> { get }
}

public protocol BackerDashboardProjectsViewModelType {
  var inputs: BackerDashboardProjectsViewModelInputs { get }
  var outputs: BackerDashboardProjectsViewModelOutputs { get }
}

public final class BackerDashboardProjectsViewModel: BackerDashboardProjectsViewModelType,
  BackerDashboardProjectsViewModelInputs, BackerDashboardProjectsViewModelOutputs {
  public init() {
    let projectsType = self.configureWithProjectsTypeAndSortProperty.signal.skipNil()

    let userUpdated = Signal.merge(
      self.viewDidAppearProperty.signal.ignoreValues(),
      self.currentUserUpdatedProperty.signal
    )

    let userUpdatedProjectCount = projectsType.takeWhen(userUpdated)
      .map { type -> Int in
        switch type {
        case .backed: return AppEnvironment.current.currentUser?.stats.backedProjectsCount ?? 0
        case .saved: return AppEnvironment.current.currentUser?.stats.starredProjectsCount ?? 0
        }
      }
      .skipRepeats { $0 == $1 }

    let requestFirstPageWith = projectsType
      .takeWhen(
        Signal.merge(
          userUpdatedProjectCount.ignoreValues(),
          self.refreshProperty.signal
        )
      )

    let isCloseToBottom = self.willDisplayRowProperty.signal.skipNil()
      .map { row, total in total > 5 && row >= total - 3 }
      .skipRepeats()
      .filter(isTrue)

    let isCloseToBottomWith = projectsType.takeWhen(isCloseToBottom)

    // MARK: Paginate backed projects

    let requestFirstPageBackedProjects = requestFirstPageWith
      .filter { $0 == .backed }

    let backedProjectsIsCloseToBottom = isCloseToBottomWith
      .filter { $0 == .backed }
      .ignoreValues()

    let isLoadingBackedProjects: Signal<Bool, Never>
    let backedProjectFragments: Signal<[ProjectCardFragment], Never>
    (backedProjectFragments, isLoadingBackedProjects, _, _) = paginate(
      requestFirstPageWith: requestFirstPageBackedProjects,
      requestNextPageWhen: backedProjectsIsCloseToBottom,
      clearOnNewRequest: false,
      skipRepeats: false,
      valuesFromEnvelope: { (data: GraphAPI.FetchMyBackedProjectsQuery.Data) -> [ProjectCardFragment] in
        data.projects?.nodes?.compactMap { $0?.fragments.projectCardFragment } ?? []
      },
      cursorFromEnvelope: { (data: GraphAPI.FetchMyBackedProjectsQuery.Data) -> String? in
        if let pageInfo = data.projects?.pageInfo, pageInfo.hasNextPage {
          return pageInfo.endCursor
        }
        return nil
      },
      requestFromParams: { _ in
        AppEnvironment.current.apiService.fetchBackedProjects(cursor: nil, limit: 20)
      },
      requestFromCursor: { cursor in
        AppEnvironment.current.apiService.fetchBackedProjects(cursor: cursor, limit: 20)
      }
    )

    // MARK: Paginate saved projects

    let requestFirstPageSavedProjects = requestFirstPageWith
      .filter { $0 == .saved }

    let savedProjectsIsCloseToBottom = isCloseToBottomWith
      .filter { $0 == .saved }
      .ignoreValues()

    let isLoadingSavedProjects: Signal<Bool, Never>
    let savedProjectFragments: Signal<[ProjectCardFragment], Never>
    (savedProjectFragments, isLoadingSavedProjects, _, _) = paginate(
      requestFirstPageWith: requestFirstPageSavedProjects,
      requestNextPageWhen: savedProjectsIsCloseToBottom,
      clearOnNewRequest: false,
      skipRepeats: false,
      valuesFromEnvelope: { (data: GraphAPI.FetchMySavedProjectsQuery.Data) -> [ProjectCardFragment] in
        data.projects?.nodes?.compactMap { $0?.fragments.projectCardFragment } ?? []
      },
      cursorFromEnvelope: { (data: GraphAPI.FetchMySavedProjectsQuery.Data) -> String? in
        if let pageInfo = data.projects?.pageInfo, pageInfo.hasNextPage {
          return pageInfo.endCursor
        }
        return nil
      },
      requestFromParams: { _ in
        AppEnvironment.current.apiService.fetchSavedProjects(cursor: nil, limit: 20)
      },
      requestFromCursor: { cursor in
        AppEnvironment.current.apiService.fetchSavedProjects(cursor: cursor, limit: 20)
      }
    )

    // MARK: Recombine backed and saved projects

    let isLoading = Signal.merge(isLoadingSavedProjects, isLoadingBackedProjects)

    self.projects = Signal.merge(backedProjectFragments, savedProjectFragments)
      .map { fragments in
        fragments.compactMap { fragment in
          ProjectCardProperties(fragment)
        }
      }

    let latestLoadingWasRefresh = Signal.merge(
      userUpdatedProjectCount.mapConst(true),
      isCloseToBottom.mapConst(false),
      self.refreshProperty.signal.mapConst(true)
    )

    self.isRefreshing = Signal.combineLatest(isLoading, latestLoadingWasRefresh)
      .map { isLoading, latestLoadingWasRefresh in
        isLoading && latestLoadingWasRefresh
      }
      .skipRepeats()

    self.isLoadingNextPage = Signal.combineLatest(isLoading, latestLoadingWasRefresh)
      .map { isLoading, latestLoadingWasRefresh in
        isLoading && !latestLoadingWasRefresh
      }
      .skipRepeats()

    self.emptyStateIsVisible = Signal.combineLatest(projectsType, self.projects)
      .map { type, projects in
        (projects.isEmpty, type)
      }

    self.goToProject = projectsType
      .takePairWhen(self.projectTappedProperty.signal.skipNil())
      .map { projectsType, project in
        let ref = (projectsType == .backed) ? RefTag.profileBacked : RefTag.profileSaved
        return (project, ref)
      }

    // Tracking

    Signal.combineLatest(self.projectTappedProperty.signal, projectsType)
      .observeValues { project, profilesProjectType in
        guard let project = project else { return }
        let sectionContext: KSRAnalytics.SectionContext = profilesProjectType == .backed ?
          .backed : .watched

        AppEnvironment.current.ksrAnalytics.trackProjectCardClicked(
          page: .profile,
          project: project,
          location: .accountMenu,
          section: sectionContext
        )
      }
  }

  private let configureWithProjectsTypeAndSortProperty =
    MutableProperty<ProfileProjectsType?>(nil)
  public func configureWith(projectsType: ProfileProjectsType) {
    self.configureWithProjectsTypeAndSortProperty.value = projectsType
  }

  private let currentUserUpdatedProperty = MutableProperty(())
  public func currentUserUpdated() {
    self.currentUserUpdatedProperty.value = ()
  }

  private let projectTappedProperty = MutableProperty<Project?>(nil)
  public func projectTapped(_ project: Project) {
    self.projectTappedProperty.value = project
  }

  private let refreshProperty = MutableProperty(())
  public func refresh() {
    self.refreshProperty.value = ()
  }

  private let viewDidAppearProperty = MutableProperty(false)
  public func viewDidAppear(_ animated: Bool) {
    self.viewDidAppearProperty.value = animated
  }

  private let willDisplayRowProperty = MutableProperty<(row: Int, total: Int)?>(nil)
  public func willDisplayRow(_ row: Int, outOf totalRows: Int) {
    self.willDisplayRowProperty.value = (row, totalRows)
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let emptyStateIsVisible: Signal<(Bool, ProfileProjectsType), Never>
  public let goToProject: Signal<(Project, RefTag), Never>
  public let isRefreshing: Signal<Bool, Never>
  public let isLoadingNextPage: Signal<Bool, Never>
  public let projects: Signal<[ProjectCardProperties], Never>

  public var inputs: BackerDashboardProjectsViewModelInputs { return self }
  public var outputs: BackerDashboardProjectsViewModelOutputs { return self }
}
