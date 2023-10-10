import Foundation
import ReactiveSwift

extension FetchProjectsEnvelope {
  static func fetchProjectsEnvelope(from data: GraphAPI.FetchBackerProjectsQuery.Data)
    -> SignalProducer<FetchProjectsEnvelope, ErrorEnvelope> {
    guard let projects = data.projects?.nodes?.compactMap({ (node) -> Project? in
      if let fragment = node?.fragments.projectFragment {
        return Project.project(from: fragment, currentUserChosenCurrency: nil)
      }
      return nil
    }) else {
      return SignalProducer(error: ErrorEnvelope.couldNotParseJSON)
    }

    let envelope = FetchProjectsEnvelope(
      projects: projects,
      cursor: data.projects?.pageInfo.startCursor,
      hasPreviousPage: data.projects!.pageInfo.hasPreviousPage,
      totalCount: data.projects!.totalCount
    )

    return SignalProducer(value: envelope)
  }
}
