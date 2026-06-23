import Foundation
import GraphAPI
import KsApi
import ReactiveSwift
import SwiftUI

public protocol VideoFeedViewModelType: AnyObject {
  /// Current active set of video items shown in the feed.
  var items: [VideoFeedItem] { get }
  /// Updated only on a completed fetch. Used to trigger collection view reloads.
  var fetchedItems: [VideoFeedItem] { get }
  /// Set when a logged-out user taps save. Triggers the login flow.
  var loginIntent: LoginIntent? { get }
  /// True once the first fetch completes successfully.
  var isInitialLoadComplete: Bool { get }
  /// Project ID of the most recent failed save. Triggers the error toast on the selected cell.
  var saveFailedItemId: String? { get }

  /// Kicks off the initial feed fetch.
  func viewDidLoad()
  /// Syncs save state from the project page cache on return to the feed.
  func viewWillAppear()
  /// Fires any save the user tapped before logging in.
  func userSessionStarted()
  /// Optimistically toggles the saved state for a project.
  func toggleSaved(for item: VideoFeedItem)
  /// Returns a binding to the saved state for the given project ID.
  func isSaved(projectId: String) -> Binding<Bool>
  /// Clears the pending login intent after the login flow is presented.
  func clearLoginIntent()
  /// Clears the save error after the toast has been shown.
  func clearSaveFailedItemId()
  /// Tracks a swipe to a new video, then fires an impression for the incoming video.
  func trackPageViewed(atIndex index: Int)
  /// Tracks a CTA tap in the video feed (play, pause, save, share).
  func trackCTAClicked(ctaContext: KSRAnalytics.CTAContext, item: VideoFeedItem)
  /// Tracks progress bar scrubs in the video feed.
  func trackProgressBarTapped(item: VideoFeedItem, positionInSession: Int, percentageWatched: Float)
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

  /// Set to the project ID of an item whose save/unsave request failed.
  /// Observed by `VideoFeedViewController` to trigger the error toast on the correct cell.
  public private(set) var saveFailedItemId: String? = nil

  /// Store the item id when a logged-out user taps save. Finishes executing on `userSessionStarted` if login succeeded.
  private var pendingSaveItemId: String? = nil

  /// Tracks in-flight watch/unwatch requests.
  private var pendingWatchRequests: [String: Disposable] = [:]

  private var lastPageIndex: Int = 0

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
    guard let cache = AppEnvironment.current.cache[KSCache.ksr_projectSaved] as? [Int: Bool] else { return }

    for index in self.items.indices {
      if let id = decompose(id: self.items[index].projectId), let cached = cache[id] {
        let wasSaved = self.items[index].isSaved

        self.items[index].isSaved = cached

        /// Update the count if the save state changed on the project page.
        if cached != wasSaved {
          self.items[index].watchesCount += cached ? 1 : -1
        }
      }
    }
  }

  /// Called after login completes. Fires any save that was deferred due to a pending login.
  public func userSessionStarted() {
    guard let pendingId = self.pendingSaveItemId, AppEnvironment.current.currentUser != nil,
          let item = self.items.first(where: { $0.id == pendingId }) else {
      self.pendingSaveItemId = nil
      return
    }

    self.pendingSaveItemId = nil
    self.toggleSaved(for: item)
  }

  /// Returns a binding to `isSaved` for the item with the given ID.
  /// If the user is logged out, save the intended id to save and show login instead.
  public func isSaved(projectId: String) -> Binding<Bool> {
    Binding(
      get: { self.items.first(where: { $0.id == projectId })?.isSaved ?? false },
      set: { [weak self] _ in
        guard let self, let item = self.items.first(where: { $0.id == projectId }) else { return }

        guard AppEnvironment.current.currentUser != nil else {
          self.pendingSaveItemId = item.id
          self.showLogin()

          return
        }

        self.toggleSaved(for: item)
      }
    )
  }

  /// Toggles the watched state for a given project.
  /// Ignores taps while a request is already in flight.
  /// Optimistically updates `isSaved` and `watchesCount` (Reverts both on failure).
  public func toggleSaved(for item: VideoFeedItem) {
    guard let index = self.items.firstIndex(where: { $0.id == item.id }) else { return }
    guard self.pendingWatchRequests[item.projectId] == nil else { return }

    let projectId = item.projectId
    let wasSaved = self.items[index].isSaved

    /// Optimistic update.
    if wasSaved {
      self.items[index].isSaved = false
      self.items[index].watchesCount -= 1
    } else {
      self.items[index].isSaved = true
      self.items[index].watchesCount += 1
    }

    AppEnvironment.current.ksrAnalytics.trackVideoFeedCTAClicked(
      ctaContext: .videoFeedSave,
      videoId: item.id,
      projectId: item.projectId
    )

    let producer = wasSaved
      ? AppEnvironment.current.apiService.unwatchProject(input: .init(id: projectId))
      : AppEnvironment.current.apiService.watchProject(input: .init(id: projectId))

    let disposable = producer
      .observe(on: QueueScheduler.main)
      .startWithResult { [weak self] result in
        guard let self, let index = self.items.firstIndex(where: { $0.id == projectId }) else { return }

        if case .failure = result {
          /// Revert optimistic update on failure and surface the error toast.
          self.items[index].isSaved = wasSaved
          self.saveFailedItemId = projectId
        }

        self.pendingWatchRequests.removeValue(forKey: projectId)
      }

    self.pendingWatchRequests[projectId] = disposable
  }

  public func clearLoginIntent() {
    self.loginIntent = nil
  }

  public func clearSaveFailedItemId() {
    self.saveFailedItemId = nil
  }

  public func trackPageViewed(atIndex index: Int) {
    guard index < self.items.count else { return }

    let incoming = self.items[index]
    let outgoing = self.items[self.lastPageIndex]

    AppEnvironment.current.ksrAnalytics.trackVideoFeedSwipe(
      videoId: incoming.id,
      projectId: incoming.projectId,
      positionInSession: index,
      fromVideoId: outgoing.id,
      totalWatchTimeMs: 0,
      totalVideoDurationMs: 0
    )

    AppEnvironment.current.ksrAnalytics.trackVideoFeedImpression(
      videoId: incoming.id,
      projectId: incoming.projectId,
      positionInSession: index
    )

    self.lastPageIndex = index
  }

  public func trackCTAClicked(ctaContext: KSRAnalytics.CTAContext, item: VideoFeedItem) {
    AppEnvironment.current.ksrAnalytics.trackVideoFeedCTAClicked(
      ctaContext: ctaContext,
      videoId: item.id,
      projectId: item.projectId
    )
  }

  public func trackProgressBarTapped(item: VideoFeedItem, positionInSession: Int, percentageWatched: Float) {
    AppEnvironment.current.ksrAnalytics.trackVideoFeedProgressBarTapped(
      videoId: item.id,
      projectId: item.projectId,
      positionInSession: positionInSession,
      percentageWatched: percentageWatched
    )
  }

  // MARK: - Private

  /// Triggers the login flow. Called when a logged-out user tries to save a project.
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

      AppEnvironment.current.ksrAnalytics.trackVideoFeedImpression(
        videoId: self.items[0].id,
        projectId: self.items[0].projectId,
        positionInSession: 0
      )
    } catch {
      self.isLoading = false
      self.errorMessage = error.localizedDescription
    }
  }
}
