import Foundation
import KsApi
import ReactiveSwift

protocol VideoFeedViewModelInputs {
  /// Called once the view is ready to load its content.
  func viewDidLoad()
}

protocol VideoFeedViewModelOutputs {
  /// Emits the list of items to render in the feed.
  var items: Signal<[VideoFeedItem], Never> { get }
}

protocol VideoFeedViewModelType {
  var inputs: VideoFeedViewModelInputs { get }
  var outputs: VideoFeedViewModelOutputs { get }
}

final class VideoFeedViewModel: VideoFeedViewModelType, VideoFeedViewModelInputs, VideoFeedViewModelOutputs {
  // MARK: - Outputs

  let items: Signal<[VideoFeedItem], Never>

  // MARK: - Private

  private let (itemsSignal, itemsObserver) = Signal<[VideoFeedItem], Never>.pipe()
  private let viewDidLoadProperty = MutableProperty<Void?>(nil)

  /// The project whose video we repeat in the feed for this spike.
  private let project: Project

  /// Finite batch for now (no pagination in this spike).
  private let batchSize: Int = 20

  init(project: Project) {
    self.project = project
    self.items = self.itemsSignal

    /// When the view loads, build a static list immediately.
    self.viewDidLoadProperty.producer
      .skipNil()
      .startWithValues { [weak self] _ in
        guard let self else { return }
        self.itemsObserver.send(value: self.makeFeedItems(count: self.batchSize))
      }
  }

  // MARK: - Inputs

  func viewDidLoad() {
    /// Triggers the one-time list creation.
    self.viewDidLoadProperty.value = ()
  }

  // MARK: - Data

  private func makeFeedItems(count: Int) -> [VideoFeedItem] {
    /// If there’s no video URL on the project, we can’t show a feed.
    guard let url = videoURL(for: project) else { return [] }

    /// This spike repeats the same project/video across 20 “pages”.
    return (0..<count).map { i in
      VideoFeedItem(
        id: "\(self.project.id)-\(i)",
        videoURL: url,
        title: self.project.name,
        creator: self.project.creator.name,
        statsText: "",
        categoryPillText: "Project We Love",
        secondaryPillText: "3 days left",
        ctaTitle: "View project"
      )
    }
  }

  private func videoURL(for project: Project) -> URL? {
    /// Prefer HLS if available; otherwise fall back to the "high" mp4 URL.
    guard let video = project.video else { return nil }

    if let hls = video.hls, let url = URL(string: hls) {
      return url
    }

    return URL(string: video.high)
  }

  // MARK: - Type

  var inputs: VideoFeedViewModelInputs { self }
  var outputs: VideoFeedViewModelOutputs { self }
}
