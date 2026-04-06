import Foundation

@Observable
final class VideoFeedViewModel {
  // MARK: - Outputs

  private(set) var items: [VideoFeedItem] = []

  // MARK: - Inputs

  func viewDidLoad() {
    self.items = (0..<20).map { i in
      VideoFeedItem(
        id: "Project-\(i)",
        title: "Campaign Video \(i)"
      )
    }
  }
}
