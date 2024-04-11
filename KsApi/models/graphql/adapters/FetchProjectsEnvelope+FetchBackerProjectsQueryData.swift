import Foundation
import ReactiveSwift

extension FetchProjectsEnvelope {
  static func fetchProjectsEnvelope(from data: GraphAPI.FetchMyBackedProjectsQuery.Data)
    -> SignalProducer<FetchProjectsEnvelope, ErrorEnvelope> {
    guard let projects = data.me?.backedProjects?.nodes?.compactMap({ node -> Project? in
      if let fragment = node?.fragments.projectFragment {
        return Project.project(from: fragment, currentUserChosenCurrency: nil)
      }
      return nil
    }) else {
      return SignalProducer(error: ErrorEnvelope.couldNotParseJSON)
    }

    let envelope = FetchProjectsEnvelope(
      type: .backed,
      projects: projects,
      cursor: data.me?.backedProjects?.pageInfo.endCursor,
      hasNextPage: data.me?.backedProjects?.pageInfo.hasNextPage ?? false,
      totalCount: data.me?.backingsCount ?? 0
    )

    return SignalProducer(value: envelope)
  }

  static func fetchProjectsEnvelope(from data: GraphAPI.FetchMySavedProjectsQuery.Data)
    -> SignalProducer<FetchProjectsEnvelope, ErrorEnvelope> {
    guard let projects = data.me?.savedProjects?.nodes?.compactMap({ node -> Project? in
      if let fragment = node?.fragments.projectFragment {
        return Project.project(from: fragment, currentUserChosenCurrency: nil)
      }
      return nil
    }) else {
      return SignalProducer(error: ErrorEnvelope.couldNotParseJSON)
    }

    let envelope = FetchProjectsEnvelope(
      type: .saved,
      projects: projects,
      cursor: data.me?.savedProjects?.pageInfo.endCursor,
      hasNextPage: data.me?.savedProjects?.pageInfo.hasNextPage ?? false,
      totalCount: data.me?.savedProjects?.totalCount ?? 0
    )

    return SignalProducer(value: envelope)
  }
}
