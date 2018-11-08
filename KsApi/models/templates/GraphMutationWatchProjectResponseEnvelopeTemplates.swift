import Foundation

extension GraphMutationWatchProjectResponseEnvelope {
  internal static let watchTemplate = GraphMutationWatchProjectResponseEnvelope(
    watchProject: .init(
      project: .init(id: "UHJvamVjdC0xMzEzNzE3MDgy", isWatched: true)
    )
  )

  internal static let unwatchTemplate = GraphMutationWatchProjectResponseEnvelope(
    watchProject: .init(
      project: .init(id: "UHJvamVjdC0xMzEzNzE3MDgy", isWatched: true)
    )
  )
}
