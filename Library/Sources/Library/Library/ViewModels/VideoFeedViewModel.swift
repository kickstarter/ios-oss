import Foundation
import GraphAPI
import KsApi
import ReactiveSwift
import SwiftUI

public protocol VideoFeedViewModelType: AnyObject {
  var items: [VideoFeedItem] { get }
  var fetchedItems: [VideoFeedItem] { get }
  func viewDidLoad()
  func toggleSaved(for item: VideoFeedItem)

  /// Returns the current item for a given ID, falling back to the provided item if not found.
  func item(for id: String, fallback: VideoFeedItem) -> VideoFeedItem

  /// Returns a binding to `isSaved` for the item with the given ID.
  func isSaved(id: String) -> Binding<Bool>
}

@Observable
public final class VideoFeedViewModel: VideoFeedViewModelType {
  // MARK: - Outputs

  /// The current working set of items.
  /// Updated optimistically on watch/unwatch.
  public private(set) var items: [VideoFeedItem] = []

  /// Updated only when a real fetch completes.
  /// Allows `VideoFeedViewController` to know when to reload the collection view.
  public private(set) var fetchedItems: [VideoFeedItem] = []

  public private(set) var isLoading = false
  public private(set) var errorMessage: String?

  /// Watch/Unwatch mutation disposables keyed by project ID.
  /// Used to ignore taps while a request is already in flight for a given item.
  private var pendingWatchRequests: [String: (input: MutableProperty<Bool>, disposable: Disposable)] = [:]

  // MARK: - Inputs

  public init() {}

  public func viewDidLoad() {
    Task {
      await self.fetchVideoFeed()
    }
  }

  /// Returns the current item for a given ID, falling back to the provided item if not found.
  public func item(for id: String, fallback: VideoFeedItem) -> VideoFeedItem {
    self.items.first(where: { $0.id == id }) ?? fallback
  }

  /// Returns a binding to `isSaved` for the item with the given ID.
  public func isSaved(id: String) -> Binding<Bool> {
    Binding(
      get: { self.items.first(where: { $0.id == id })?.isSaved ?? false },
      set: { _ in } // mutations go through toggleSaved
    )
  }

  /// Toggles the watched state for a given project.
  /// Ignores taps while a request is already in flight.
  /// Optimistically updates `isSaved`. Reverts on failure.
  public func toggleSaved(for item: VideoFeedItem) {
    guard let index = self.items.firstIndex(where: { $0.id == item.id }) else { return }

    guard self.pendingWatchRequests[item.projectId] == nil else { return }

    let projectId = item.projectId
    let wasSaved = self.items[index].isSaved

    /// Optimistic update.
    self.items[index].isSaved = !wasSaved

    let producer = wasSaved
      ? AppEnvironment.current.apiService.unwatchProject(input: .init(id: projectId))
      : AppEnvironment.current.apiService.watchProject(input: .init(id: projectId))

    let disposable = producer
      .startWithResult { [weak self] result in
        guard let self, let index = self.items.firstIndex(where: { $0.id == projectId }) else { return }

        if case .failure = result {
          /// Revert optimistic update on failure.
          self.items[index].isSaved = wasSaved
        }

        self.pendingWatchRequests.removeValue(forKey: projectId)
      }

    self.pendingWatchRequests[projectId] = (input: MutableProperty(!wasSaved), disposable: disposable)
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

      self.fetchedItems = nodes.map(VideoFeedItem.init)
      self.items = self.fetchedItems
      self.isLoading = false
    } catch {
      self.isLoading = false
      self.errorMessage = error.localizedDescription
    }
  }
}
