@preconcurrency import Apollo
import Foundation
import GraphAPI
import KsApi
import Library

@MainActor
public protocol NextGenProjectSearchType {
  func searchProjects(matching term: String) async throws -> [NextGenSearchResult]
}

/// Calls Apollo via our minimal async/await wrapper.
@MainActor
public struct NextGenProjectSearchService: NextGenProjectSearchType {
  private let apollo: AsyncApolloClient

  public init(apollo: AsyncApolloClient) {
    self.apollo = apollo
  }

  public func searchProjects(matching query: String) async throws -> [NextGenSearchResult] {
    let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)

    guard !trimmedQuery.isEmpty else { return [] }

    let params = DiscoveryParams.withQuery(
      trimmedQuery,
      sort: .newest,
      category: nil,
      state: .live,
      percentRaised: .bucket_0,
      location: Location.none,
      amountRaised: .bucket_0,
      goal: .bucket_0,
      toggles: SearchFilterToggles(
        recommended: false,
        savedProjects: false,
        projectsWeLove: false,
        following: false
      )
    )

    let result = try await self.apollo.fetch(GraphAPI.SearchQuery.from(discoveryParams: params))

    let nodes = result.data?.projects?.nodes ?? []

    return nodes.compactMap { node -> NextGenSearchResult? in
      guard let name = node?.name else { return nil }

      return NextGenSearchResult(id: UUID(), name: name)
    }
  }
}
