import Foundation
import GraphAPI
import KsApi
import ReactiveSwift
import SwiftUI

public protocol VideoFeedViewModelType: AnyObject {
  var items: [VideoFeedItem] { get }
  var fetchedItems: [VideoFeedItem] { get }
  var loginIntent: LoginIntent? { get }
  var isInitialLoadComplete: Bool { get }
  func viewDidLoad()
  func viewWillAppear()
  func toggleSaved(for item: VideoFeedItem)
  func isSaved(id: String) -> Binding<Bool>
  func clearLoginIntent()
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
  public private(set) var loginIntent: LoginIntent? = nil
  public private(set) var isInitialLoadComplete: Bool = false

  /// Tracks in-flight watch/unwatch requests.
  private var pendingWatchRequests: [String: Disposable] = [:]

  // MARK: - Init

  public init() {}

  // MARK: - Inputs

  public func viewDidLoad() {
    Task { @MainActor in
      await self.fetchVideoFeed()
    }
  }

  /// Called each time the feed reappears.
  /// Reconciles the save button's state for when users save projects from a presented project page (when tapping the CTA).
  public func viewWillAppear() {
    guard let cache = AppEnvironment.current.cache[KSCache.ksr_projectSaved] as? [Int: Bool] else {
      return
    }

    for index in self.items.indices {
      if let id = decompose(id: self.items[index].projectId), let cached = cache[id] {
        self.items[index].isSaved = cached
      }
    }
  }

  /// Returns a binding to `isSaved` for the item with the given ID.
  /// If the user is logged out, show login instead of toggling saved.
  public func isSaved(id: String) -> Binding<Bool> {
    Binding(
      get: { self.items.first(where: { $0.id == id })?.isSaved ?? false },
      set: { [weak self] _ in
        guard let self, let item = self.items.first(where: { $0.id == id }) else { return }

        guard AppEnvironment.current.currentUser != nil else {
          self.showLogin()
          return
        }

        self.toggleSaved(for: item)
      }
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
      .observe(on: QueueScheduler.main)
      .startWithResult { [weak self] result in
        guard let self, let index = self.items.firstIndex(where: { $0.id == projectId }) else { return }

        if case .failure = result {
          /// Revert optimistic update on failure.
          self.items[index].isSaved = wasSaved
        }

        self.pendingWatchRequests.removeValue(forKey: projectId)
      }

    self.pendingWatchRequests[projectId] = disposable
  }

  public func clearLoginIntent() {
    self.loginIntent = nil
  }

  // MARK: - Private

  /// Triggers the login flow. Called  when a logged-out user tries to save a project.
  private func showLogin() {
    self.loginIntent = .videoFeed
  }

  @MainActor
  func fetchVideoFeed() async {
    guard !self.isLoading else { return }

    self.isLoading = true
    self.errorMessage = nil

    do {
      let result = try await AppEnvironment.current.apiService.fetch(
        query: VideoFeedQuery(first: 30, after: .none, categoryId: .none)
      )

      let nodes = result?.videoFeed?.nodes?.compactMap { $0 } ?? []

      guard !nodes.isEmpty else {
        self.isLoading = false
        self.errorMessage = Strings.Something_went_wrong_please_try_again()
        return
      }

      /// Set isInitialLoadComplete before fetchedItems so the fetchedItems observer
      /// sees the correct value when it fires.
      self.isInitialLoadComplete = true
      self.fetchedItems = nodes.map(VideoFeedItem.init)
      self.items = self.fetchedItems
      self.isLoading = false
    } catch {
      self.isLoading = false
      self.errorMessage = error.localizedDescription
    }
  }
}
