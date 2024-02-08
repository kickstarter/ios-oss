import Combine
import Foundation
import KsApi
import Library

extension Project: Identifiable {}

internal class PaginationExampleViewModel: ObservableObject {
  var paginator: Paginator<DiscoveryEnvelope, Project, String, ErrorEnvelope, DiscoveryParams>

  @Published var projectIdsAndTitles: [(Int, String)] = []
  @Published var showProgressView: Bool = true
  @Published var statusText: String = ""

  init() {
    self.paginator = Paginator(
      valuesFromEnvelope: {
        $0.projects
      },
      cursorFromEnvelope: {
        $0.urls.api.moreProjects
      },
      requestFromParams: {
        AppEnvironment.current.apiService.fetchDiscovery_combine(params: $0)
      },
      requestFromCursor: {
        AppEnvironment.current.apiService.fetchDiscovery_combine(paginationUrl: $0)
      }
    )

    self.paginator.$values.map { projects in
      projects.map { ($0.id, $0.name) }
    }.assign(to: &$projectIdsAndTitles)

    let canLoadMore = self.paginator.$state.map { state in
      state == .someLoaded || state == .unloaded
    }

    Publishers.CombineLatest(self.paginator.$isLoading, canLoadMore)
      .map { isLoading, canLoadMore in
        isLoading || canLoadMore
      }.assign(to: &$showProgressView)

    self.paginator.$state.map { [weak self] state in
      switch state {
      case .error:
        let errorText = self?.paginator.error?.errorMessages.first ?? "Unknown error"
        return "Error: \(errorText)"
      case .unloaded:
        return "Waiting to load"
      case .someLoaded:
        let count = self?.paginator.values.count ?? 0
        return "Got \(count) results; more are available"
      case .allLoaded:
        return "Loaded all results"
      case .empty:
        return "No results"
      }
    }
    .assign(to: &$statusText)
  }

  var searchParams: DiscoveryParams {
    var params = DiscoveryParams.defaults
    params.staffPicks = true
    params.sort = .magic
    return params
  }

  func didShowProgressView() {
    if self.paginator.isLoading {
      return
    }

    if self.paginator.state == .someLoaded {
      self.paginator.requestNextPage()
    } else if self.paginator.state == .unloaded {
      self.paginator.requestFirstPage(withParams: self.searchParams)
    }
  }

  func didRefresh() {
    self.paginator.requestFirstPage(withParams: self.searchParams)
  }
}
