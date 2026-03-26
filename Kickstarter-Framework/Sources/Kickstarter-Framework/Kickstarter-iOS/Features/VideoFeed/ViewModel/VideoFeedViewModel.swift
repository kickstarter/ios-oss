import Foundation
import ReactiveSwift

protocol VideoFeedViewModelInputs {
  func viewDidLoad()
}

protocol VideoFeedViewModelOutputs {
  var items: Signal<[VideoFeedItem], Never> { get }
}

protocol VideoFeedViewModelType {
  var inputs: VideoFeedViewModelInputs { get }
  var outputs: VideoFeedViewModelOutputs { get }
}

final class VideoFeedViewModel: VideoFeedViewModelType, VideoFeedViewModelInputs,
  VideoFeedViewModelOutputs {
  init() {
    self.items = self.viewDidLoadProperty.signal
      .map {
        (0..<20).map { i in
          VideoFeedItem(
            id: "Project-\(i)",
            title: "Campaign Video \(i)"
          )
        }
      }
  }

  // MARK: - Inputs

  private let viewDidLoadProperty = MutableProperty(())
  func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  // MARK: - Outputs

  let items: Signal<[VideoFeedItem], Never>

  var inputs: VideoFeedViewModelInputs { self }
  var outputs: VideoFeedViewModelOutputs { self }
}
