import Combine
import Foundation
import KsApi
import Library

extension Project: Identifiable {}

internal class PaginationExampleViewModel: ObservableObject {
  struct ProjectData: Identifiable, Hashable {
    let id: Int
    let title: String
  }

  var paginator: Paginator<DiscoveryEnvelope, Project, String, ErrorEnvelope, DiscoveryParams>

  @Published var projects: [ProjectData] = []
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

    self.paginator.$results.receive(on: RunLoop.main).map(\.values).map { projects in
      projects.map { ProjectData(id: $0.id, title: $0.name) }
    }.assign(to: &self.$projects)

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

  func didRefresh() async {
    self.paginator.requestFirstPage(withParams: self.searchParams)
    _ = await self.paginator.nextResult()
  }

  func didLoadNextPage() async {
    self.paginator.requestNextPage()
    _ = await self.paginator.nextResult()
  }
}
