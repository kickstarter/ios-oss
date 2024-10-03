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
      totalFromEnvelope: { _ in nil },
      requestFromParams: {
        AppEnvironment.current.apiService.fetchDiscovery_combine(params: $0)
      },
      requestFromCursor: {
        AppEnvironment.current.apiService.fetchDiscovery_combine(paginationUrl: $0)
      }
    )

    self.paginator.$results.map(\.values).map { projects in
      projects.map { ($0.id, $0.name) }
    }.assign(to: &self.$projectIdsAndTitles)

    Publishers.CombineLatest(
      self.paginator.$results.map(\.isLoading),
      self.paginator.$results.map(\.canLoadMore)
    )
    .map { isLoading, canLoadMore in
      isLoading || canLoadMore
    }.assign(to: &self.$showProgressView)

    self.paginator.$results.map { state in
      switch state {
      case let .error(error):
        let errorText = error.errorMessages.first ?? "Unknown error"
        return "Error: \(errorText)"
      case .unloaded:
        return "Waiting to load"
      case .loading:
        return "Loading"
      case let .someLoaded(values, _, _, _):
        return "Got \(values.count) results; more are available"
      case .allLoaded:
        return "Loaded all results"
      case .empty:
        return "No results"
      }
    }
    .assign(to: &self.$statusText)
  }

  var searchParams: DiscoveryParams {
    var params = DiscoveryParams.defaults
    params.staffPicks = true
    params.sort = .magic
    return params
  }

  func didShowProgressView() {
    if self.paginator.results.isLoading {
      return
    }

    if self.paginator.results.canLoadMore {
      self.paginator.requestNextPage()
    } else if case .unloaded = self.paginator.results {
      self.paginator.requestFirstPage(withParams: self.searchParams)
    }
  }

  func didRefresh() {
    self.paginator.requestFirstPage(withParams: self.searchParams)
  }
}
