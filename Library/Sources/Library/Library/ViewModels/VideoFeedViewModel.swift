import Foundation
import GraphAPI
import KsApi

@Observable
public final class VideoFeedViewModel {
  // MARK: - Outputs

  public private(set) var items: [VideoFeedItem] = []
  public private(set) var isLoading = false
  public private(set) var errorMessage: String?

  // MARK: - Inputs

  public init() {}

  public func viewDidLoad() {
    Task {
      await self.fetchVideoFeed()
    }
  }

  /// Toggles the watched (saved)  state for a given project and
  /// Updaties the items array on success so all cells reflect the correct state regardless of scroll position.
  public func toggleSaved(for item: VideoFeedItem) {
    guard let index = self.items.firstIndex(of: item) else { return }

    let wasSaved = item.isSaved
    let projectId = item.projectId

    /// Optimistic update into the items array directly.
    self.items[index].isSaved = !wasSaved

    let producer = wasSaved
      ? AppEnvironment.current.apiService.unwatchProject(input: .init(id: projectId))
      : AppEnvironment.current.apiService.watchProject(input: .init(id: projectId))

    producer
      .startWithResult { [weak self] (result: Result<WatchProjectResponseEnvelope, ErrorEnvelope>) in
        guard let self, let index = self.items.firstIndex(where: { $0.id == item.id }) else { return }

        switch result {
        case .success:
          break
        case .failure:
          /// Revert optimistic update on failure.
          self.items[index].isSaved = wasSaved
        }
      }
  }

  // MARK: - Private

  func fetchVideoFeed() async {
    guard !self.isLoading else { return }

    self.isLoading = true
    self.errorMessage = nil

    do {
      let result = try await AppEnvironment.current.apiService.fetch(
        query: VideoFeedQuery(first: 30, after: .none, categoryId: .none)
      )

      let nodes = result?.videoFeed?.nodes?.compactMap { $0 } ?? []

      self.items = nodes.map(VideoFeedItem.init)
      self.isLoading = false
    } catch {
      self.isLoading = false
      self.errorMessage = error.localizedDescription
    }
  }
}
