import Foundation

extension WatchProjectResponseEnvelope {
  internal static let watchTemplate = WatchProjectResponseEnvelope(
    watchProject: .init(
      project: .init(id: "UHJvamVjdC0xMzEzNzE3MDgy", isWatched: true, watchesCount: 10)
    )
  )

  internal static let unwatchTemplate = WatchProjectResponseEnvelope(
    watchProject: .init(
      project: .init(id: "UHJvamVjdC0xMzEzNzE3MDgy", isWatched: true, watchesCount: 9)
    )
  )
}
