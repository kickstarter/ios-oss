import Foundation
import ReactiveSwift

public struct SearchProject: Equatable {
  public let cell: any BackerDashboardProjectCellProject
  public let analytics: any ProjectAnalyticsProperties
}

public func == (lhs: SearchProject, rhs: SearchProject) -> Bool {
  return lhs.cell.id == rhs.cell.id
}

public struct SearchEnvelope {
  public let projects: [SearchProject]
  public let count: Int
  public let moreProjectsCursor: String?
}

extension SearchEnvelope {
  static func from(data: GraphAPI.SearchQueryQuery.Data) -> SearchEnvelope? {
    let projects = data.projects?.nodes?
      .compactMap { (node: GraphAPI.SearchQueryQuery.Data.Project.Node?) -> SearchProject? in
        guard let cell = node?.fragments.searchCellProjectFragment,
              let analytics = node?.fragments.projectAnalyticsFragment else {
          return nil
        }

        return SearchProject(cell: cell, analytics: analytics)
      }

    let hasMore = data.projects?.pageInfo.hasNextPage ?? false

    return SearchEnvelope(
      projects: projects ?? [],
      count: data.projects?.totalCount ?? 0,
      moreProjectsCursor: hasMore ? data.projects?.pageInfo.endCursor : nil
    )
  }

  static func envelopeProducer(
    from data: GraphAPI.SearchQueryQuery.Data
  ) -> SignalProducer<SearchEnvelope, ErrorEnvelope> {
    guard let envelope = SearchEnvelope.from(data: data) else { return .empty }

    return SignalProducer(value: envelope)
  }
}
