import Darwin
import KsApi
import Models
import ReactiveCocoa
import Result
import AVKit

internal protocol PlaylistViewModelType {
  var inputs: PlaylistViewModelInputs { get }
  var outputs: PlaylistViewModelOutputs { get }
}

internal final class PlaylistViewModel : ViewModelType, PlaylistViewModelType, PlaylistViewModelInputs, PlaylistViewModelOutputs {
  typealias Model = Playlist

  // MARK: Inputs

  private let (next, nextObserver) = Signal<(), NoError>.pipe()
  private let (previous, previousObserver) = Signal<(), NoError>.pipe()
  internal func swipeEnded(translation translation: CGPoint) {
    if translation.x < -1_100.0 {
      self.nextObserver.sendNext(())
    } else if translation.x > 1_100.0 {
      self.previousObserver.sendNext(())
    }
  }

  // MARK: Outputs

  internal let project: SignalProducer<Project, NoError>
  internal let categoryName: SignalProducer<String, NoError>
  internal let projectName: SignalProducer<String, NoError>
  internal let backgroundImage: SignalProducer<UIImage?, NoError>

  internal var inputs: PlaylistViewModelInputs { return self }
  internal var outputs: PlaylistViewModelOutputs { return self }

  internal init(initialPlaylist: Playlist, currentProject: Project, env: Environment = AppEnvironment.current) {
    let apiService = env.apiService

    self.project = SignalProducer(signal: next.mergeWith(previous))
      .map { _ in Int(arc4random_uniform(100_000)) }
      .map { seed in DiscoveryParams(staffPicks: true, hasVideo: true, state: .Live, seed: seed) }
      .switchMap { params in apiService.fetchProject(params).demoteErrors() }
      .beginsWith(value: currentProject)

    self.categoryName = self.project.map { $0.category.name }
    self.projectName = self.project.map { $0.name }

    self.backgroundImage = self.project
      .flatMap { $0.video?.high }
      .flatMap(NSURL.init)
      .switchMap(PlaylistViewModel.imageFromVideoUrl)
  }

  private static func imageFromVideoUrl(url: NSURL) -> SignalProducer<UIImage?, NoError> {
    let asset = AVURLAsset(URL: url)
    let generator = AVAssetImageGenerator(asset: asset)
    let requestedTime = CMTimeMakeWithSeconds(30.0, 1)
    let requestedTimeValue = NSValue(CMTime: requestedTime)

    return SignalProducer { observer, disposable in
      generator.generateCGImagesAsynchronouslyForTimes([requestedTimeValue]) { (time, image, actualTime, result, error) -> Void in
        if let image = image {
          observer.sendNext(UIImage(CGImage: image))
          observer.sendCompleted()
        } else {
          observer.sendCompleted()
        }
      }
    }
  }
}
