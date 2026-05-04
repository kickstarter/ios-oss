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

  // MARK: - Private

  func fetchVideoFeed() async {
    guard !self.isLoading else { return }

    self.isLoading = true
    self.errorMessage = nil

    do {
      let result = try await AppEnvironment.current.apiService.fetch(
        query: VideoFeedQuery(first: 20, after: .none, categoryId: .none)
      )
      let nodes = result?.videoFeed?.nodes?.compactMap { $0 } ?? []

      guard let first = nodes.first else {
        self.isLoading = false
        return
      }

      /// Hardcoded list of 20 video items for testing. will be replaced with real video feed data
      self.items = Array(repeating: VideoFeedItem(node: first), count: 20)
      self.isLoading = false
    } catch {
      self.isLoading = false
      self.errorMessage = error.localizedDescription
    }
  }
}
