import Foundation
import KsApi
import Library
import Models
import Prelude
import ReactiveCocoa
import ReactiveExtensions
import Result

internal protocol ProfileViewModelInputs {
  /// Call when a project cell is pressed.
  func projectPressed(project: Project)

  /// Call when pull-to-refresh is invoked.
  func refresh()

  /// Call when the view will apear.
  func viewWillAppear()

  /// Call when a new row is displayed.
  func willDisplayRow(row: Int, outOf totalRows: Int)
}

internal protocol ProfileViewModelOutputs {
  /// Emits the user data that should be displayed.
  var user: Signal<User, NoError> { get }

  /// Emits a list of backed projects that should be displayed.
  var backedProjects: Signal<[Project], NoError> { get }

  /// Emits when the pull-to-refresh control should end refreshing.
  var endRefreshing: Signal<Void, NoError> { get }

  /// Emits the project and ref tag when should go to project page.
  var goToProject: Signal<(Project, RefTag), NoError > { get }

  /// Emits a boolean that determines if the non-backer empty state is visible.
  var showEmptyState: Signal<Bool, NoError> { get }
}

internal protocol ProfileViewModelType {
  var inputs: ProfileViewModelInputs { get }
  var outputs: ProfileViewModelOutputs { get }
}

internal final class ProfileViewModel: ProfileViewModelType, ProfileViewModelInputs, ProfileViewModelOutputs {
  init() {
    let requestFirstPageWith = Signal.merge(viewWillAppearProperty.signal.take(1), refreshProperty.signal)
      .map {
        DiscoveryParams.defaults
          |> DiscoveryParams.lens.backed *~ true
          <> DiscoveryParams.lens.sort *~ .EndingSoon
    }

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
      requestFromCursor: { AppEnvironment.current.apiService.fetchDiscovery(paginationUrl: $0)})

    self.endRefreshing = isLoading.filter(isFalse).ignoreValues()

    self.user = viewWillAppearProperty.signal
      .switchMap {
        AppEnvironment.current.apiService.fetchUserSelf()
          .beginsWith(values: [AppEnvironment.current.currentUser].compact())
          .demoteErrors()
    }

    self.showEmptyState = backedProjects.map { $0.isEmpty }

    self.goToProject = projectPressedProperty.signal.ignoreNil()
      .map { ($0, RefTag.users) }

    self.viewWillAppearProperty.signal
      .observeNext { AppEnvironment.current.koala.trackProfileView() }
  }

  private let projectPressedProperty = MutableProperty<Project?>(nil)
  internal func projectPressed(project: Project) {
    projectPressedProperty.value = project
  }

  private let refreshProperty = MutableProperty()
  internal func refresh() {
    self.refreshProperty.value = ()
  }

  private let viewWillAppearProperty = MutableProperty()
  internal func viewWillAppear() {
    self.viewWillAppearProperty.value = ()
  }

  private let willDisplayRowProperty = MutableProperty<(row: Int, total: Int)?>(nil)
  internal func willDisplayRow(row: Int, outOf totalRows: Int) {
    self.willDisplayRowProperty.value = (row, totalRows)
  }

  internal let user: Signal<User, NoError>
  internal let backedProjects: Signal<[Project], NoError>
  internal let endRefreshing: Signal<Void, NoError>
  internal let goToProject: Signal<(Project, RefTag), NoError>
  internal let showEmptyState: Signal<Bool, NoError>

  internal var inputs: ProfileViewModelInputs { return self }
  internal var outputs: ProfileViewModelOutputs { return self }
}
