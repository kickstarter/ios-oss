import Darwin
import KsApi
import Models
import ReactiveCocoa
import Result
import AVKit
import Prelude

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
      .map(AVAsset.init)
      .map { a in env.assetImageGeneratorType.init(asset: a) }
      .switchMap { PlaylistViewModel.stillImage(generator: $0) }
  }

  /**
   Extracts a still image from a an asset generator. If the extraction takes too long we will emit `nil`.

   - parameter generator: An asset generator to use for the extracting.
   - parameter scheduler: (optional) A scheduler to perform the timeout.

   - returns: A signal producer that emits an image if the extraction can be made and `nil` otherwise.
   */
  private static func stillImage(generator generator: AssetImageGeneratorType,
    scheduler: DateSchedulerType = AppEnvironment.current.debounceScheduler) -> SignalProducer<UIImage?, NoError> {
      
    let requestedTime = CMTimeMakeWithSeconds(30.0, 1)
    let requestedTimeValue = NSValue(CMTime: requestedTime)

    let image = SignalProducer<UIImage?, NoError> { observer, disposable in
      generator.generateCGImagesAsynchronouslyForTimes([requestedTimeValue]) { (time, image, actualTime, result, error) -> Void in

        guard !disposable.disposed else { return }

        if let image = image {
          observer.sendNext(blackAndWhite(image))
          observer.sendCompleted()
        } else {
          observer.sendNext(nil)
          observer.sendCompleted()
        }
      }
    }

    return image.promoteErrors(SomeError.self)
      .timeoutWithError(SomeError(), afterInterval: 5.0, onScheduler: scheduler)
      .flatMapError { _ in SignalProducer(value: nil) }
  }

  /**
   Applies a black-and-white filter to an image.

   - parameter image: Any CGImage.

   - returns: A black-and-white UIImage. If the fitler fails, this function will return `nil`.
   */
  private static func blackAndWhite(image: CGImage) -> UIImage? {

    let params = [kCIInputImageKey: CIImage(CGImage: image)]
    return CIFilter(name: "CIPhotoEffectMono", withInputParameters: params)
      .flatMap { $0.outputImage }
      .map { UIImage(CIImage: $0) }
  }
}
