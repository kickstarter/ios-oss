import Foundation

extension WatchProjectResponseEnvelope {
  internal static let watchTemplate = WatchProjectResponseEnvelope(
    watchProject: .init(
      project: .init(id: "UHJvamVjdC0xMzEzNzE3MDgy", isWatched: true)
    )
  )

  internal static let unwatchTemplate = WatchProjectResponseEnvelope(
    watchProject: .init(
      project: .init(id: "UHJvamVjdC0xMzEzNzE3MDgy", isWatched: true)
    )
  )
}
