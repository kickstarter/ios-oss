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
        title: "Ringo Move - The Ultimate Workout Bottle",
        creator: "Creator Name",
        creatorImageURL: nil,
        statsText: "$50,134 pledged · Join 431 backers",
        categoryPillText: "Project We Love",
        secondaryPillText: "3 days left",
        ctaTitle: "Back this project"
      )
    }
  }
}
