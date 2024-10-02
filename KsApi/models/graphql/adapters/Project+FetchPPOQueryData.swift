import Combine
import Foundation

extension Project {
  static func projectProducer(
    from data: GraphAPI.FetchPledgedProjectsQuery.Data.PledgeProjectsOverview.Pledge.Edge.Node
  ) -> AnyPublisher<Project, ErrorEnvelope> {
    guard let project = Project.project(from: data) else {
      return Fail(outputType: Project.self, failure: ErrorEnvelope.couldNotParseJSON).eraseToAnyPublisher()
    }

    return Just(project).setFailureType(to: ErrorEnvelope.self).eraseToAnyPublisher()
  }

  static func project(
    from data: GraphAPI.FetchPledgedProjectsQuery.Data.PledgeProjectsOverview.Pledge.Edge
      .Node
  ) -> Project? {
    guard let fragment = data.fragments.ppoCardFragment
      .backing?.fragments.ppoBackingFragment
      .project?.fragments.projectFragment,
      let project = Project.project(from: fragment, currentUserChosenCurrency: nil)
    else {
      return nil
    }
    return project
  }
}
