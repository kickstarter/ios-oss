import Foundation
import KsApi
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result

public protocol ProfileViewModelInputs {
  /// Call when a project cell is tapped.
  func projectTapped(_ project: Project)

  /// Call when pull-to-refresh is invoked.
  func refresh()

  /// Call when settings is tapped.
  func settingsButtonTapped()

  /// Call when the view will appear.
  func viewWillAppear(_ animated: Bool)

  /// Call when a new row is displayed.
  func willDisplayRow(_ row: Int, outOf totalRows: Int)
}

public protocol ProfileViewModelOutputs {
  /// Emits the user data that should be displayed.
  var user: Signal<User, NoError> { get }

  /// Emits a list of backed projects that should be displayed.
  var backedProjects: Signal<[Project], NoError> { get }

  /// Emits when the pull-to-refresh control is refreshing or not.
  var isRefreshing: Signal<Bool, NoError> { get }

  /// Emits the project and ref tag when should go to project page.
  var goToProject: Signal<(Project, [Project], RefTag), NoError > { get }

  /// Emits when settings should be shown.
  var goToSettings: Signal<Void, NoError> { get }

  /// Emits a boolean that determines if the non-backer empty state is visible.
  var showEmptyState: Signal<Bool, NoError> { get }
}

public protocol ProfileViewModelType {
  var inputs: ProfileViewModelInputs { get }
  var outputs: ProfileViewModelOutputs { get }
}

public final class ProfileViewModel: ProfileViewModelType, ProfileViewModelInputs, ProfileViewModelOutputs {
  public init() {
    let requestFirstPageWith = Signal.merge(
      viewWillAppearProperty.signal.filter(isFalse).ignoreValues(),
      refreshProperty.signal
      ).mapConst(
        DiscoveryParams.defaults
          |> DiscoveryParams.lens.backed .~ true
          |> DiscoveryParams.lens.sort .~ .endingSoon
    )

    let requestNextPageWhen = self.willDisplayRowProperty.signal.ignoreNil()
      .map { row, total in row >= total - 3 }
      .skipRepeats()
      .filter(isTrue)
      .ignoreValues()

    let isLoading: Signal<Bool, NoError>
    (self.backedProjects, isLoading, _) = paginate(
      requestFirstPageWith: requestFirstPageWith,
      requestNextPageWhen: requestNextPageWhen,
      clearOnNewRequest: false,
      valuesFromEnvelope: { $0.projects },
      cursorFromEnvelope: { $0.urls.api.moreProjects },
      requestFromParams: { AppEnvironment.current.apiService.fetchDiscovery(params: $0) },
      requestFromCursor: { AppEnvironment.current.apiService.fetchDiscovery(paginationUrl: $0) })

    self.isRefreshing = isLoading

    self.user = viewWillAppearProperty.signal
      .switchMap { _ in
        AppEnvironment.current.apiService.fetchUserSelf()
          .prefix(SignalProducer(values: [AppEnvironment.current.currentUser].compact()))
          .demoteErrors()
    }

    self.showEmptyState = backedProjects.map { $0.isEmpty }

    self.goToSettings = settingsButtonTappedProperty.signal

    self.goToProject = self.backedProjects
      .takePairWhen(self.projectTappedProperty.signal.ignoreNil())
      .map { projects, project in (project, projects, RefTag.profileBacked) }

    self.viewWillAppearProperty.signal.filter(isFalse)
      .observeNext { _ in AppEnvironment.current.koala.trackProfileView() }
  }

  fileprivate let projectTappedProperty = MutableProperty<Project?>(nil)
  public func projectTapped(_ project: Project) {
    projectTappedProperty.value = project
  }

  fileprivate let refreshProperty = MutableProperty()
  public func refresh() {
    self.refreshProperty.value = ()
  }

  fileprivate let settingsButtonTappedProperty = MutableProperty()
  public func settingsButtonTapped() {
    self.settingsButtonTappedProperty.value = ()
  }

  fileprivate let viewWillAppearProperty = MutableProperty(false)
  public func viewWillAppear(_ animated: Bool) {
    self.viewWillAppearProperty.value = animated
  }

  fileprivate let willDisplayRowProperty = MutableProperty<(row: Int, total: Int)?>(nil)
  public func willDisplayRow(_ row: Int, outOf totalRows: Int) {
    self.willDisplayRowProperty.value = (row, totalRows)
  }

  public let user: Signal<User, NoError>
  public let backedProjects: Signal<[Project], NoError>
  public let isRefreshing: Signal<Bool, NoError>
  public let goToProject: Signal<(Project, [Project], RefTag), NoError>
  public let goToSettings: Signal<Void, NoError>
  public let showEmptyState: Signal<Bool, NoError>

  public var inputs: ProfileViewModelInputs { return self }
  public var outputs: ProfileViewModelOutputs { return self }
}
