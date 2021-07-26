import Foundation
import ReactiveSwift

extension GraphMutationWatchProjectResponseEnvelope {
  /**
   Map `GraphAPI.WatchProjectMutation.Data` to a `GraphMutationWatchProjectResponseEnvelope`, otherwise return `nil`
   */
  static func from(_ data: GraphAPI.WatchProjectMutation.Data) -> GraphMutationWatchProjectResponseEnvelope? {
    guard let projectFromData = data.watchProject?.project else {
      return nil
    }
    let project = WatchProject.Project(
      id: projectFromData.id,
      isWatched: projectFromData.isWatched
    )

    return GraphMutationWatchProjectResponseEnvelope(watchProject: WatchProject(project: project))
  }

  /**
   Return a signal producer containing `GraphMutationWatchProjectResponseEnvelope` or `ErrorEnvelope`
   */
  static func producer(from data: GraphAPI.WatchProjectMutation
    .Data) -> SignalProducer<GraphMutationWatchProjectResponseEnvelope, ErrorEnvelope> {
    guard let envelope = GraphMutationWatchProjectResponseEnvelope.from(data) else {
      return SignalProducer(error: ErrorEnvelope.couldNotParseJSON)
    }

    return SignalProducer(value: envelope)
  }
}
