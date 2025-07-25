import Foundation
import GraphAPI
import ReactiveSwift

extension WatchProjectResponseEnvelope {
  /**
   Map `GraphAPI.WatchProjectMutation.Data` to a `WatchProjectResponseEnvelope`, otherwise return `nil`
   */
  static func from(_ data: GraphAPI.WatchProjectMutation.Data) -> WatchProjectResponseEnvelope? {
    guard let projectFromData = data.watchProject?.project else {
      return nil
    }
    let project = WatchProject.Project(
      id: projectFromData.id,
      isWatched: projectFromData.isWatched,
      watchesCount: projectFromData.watchesCount ?? 0
    )

    return WatchProjectResponseEnvelope(watchProject: WatchProject(project: project))
  }

  /**
   Return a signal producer containing `WatchProjectResponseEnvelope` or `ErrorEnvelope`
   */
  static func producer(
    from data: GraphAPI.WatchProjectMutation
      .Data
  ) -> SignalProducer<WatchProjectResponseEnvelope, ErrorEnvelope> {
    guard let envelope = WatchProjectResponseEnvelope.from(data) else {
      return SignalProducer(error: ErrorEnvelope.couldNotParseJSON)
    }

    return SignalProducer(value: envelope)
  }
}
