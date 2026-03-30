import Foundation

@Observable
final class VideoFeedViewModel {
  // MARK: - Outputs

  private(set) var items: [VideoFeedItem] = [] {
    didSet {
      self.onItemsChanged?(self.items)
    }
  }

  // MARK: - Callbacks

  var onItemsChanged: (([VideoFeedItem]) -> Void)?

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
