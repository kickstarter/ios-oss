import class AVFoundation.AVAsset
import func AVFoundation.CMTimeMakeWithSeconds
import func Darwin.arc4random_uniform
import UIKit
import struct KsApi.DiscoveryParams
import struct Models.Project
import struct Prelude.SomeError
import class ReactiveCocoa.Signal
import struct ReactiveCocoa.SignalProducer
import protocol ReactiveCocoa.DateSchedulerType
import enum Result.NoError
import protocol Library.ViewModelType
import struct Library.Environment
import struct Library.AppEnvironment
import protocol Library.AssetImageGeneratorType

internal protocol PlaylistViewModelType {
  var inputs: PlaylistViewModelInputs { get }
  var outputs: PlaylistViewModelOutputs { get }
}

internal final class PlaylistViewModel: ViewModelType, PlaylistViewModelType, PlaylistViewModelInputs,
PlaylistViewModelOutputs {
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

  internal init(initialPlaylist: Playlist,
                currentProject: Project,
                env: Environment = AppEnvironment.current) {
    let apiService = env.apiService

    self.project = SignalProducer(signal: next.mergeWith(previous))
      .map { _ in Int(arc4random_uniform(100_000)) }
      .map { seed in DiscoveryParams(staffPicks: true, hasVideo: true, state: .Live, seed: seed) }
      .switchMap { params in apiService.fetchProject(params).demoteErrors() }
      .beginsWith(value: currentProject)
      .replayLazily(1)

    self.categoryName = self.project.map { $0.category.name }
    self.projectName = self.project.map { $0.name }

    self.backgroundImage = self.project
      .map { $0.video?.high }
      .ignoreNil()
      .map { NSURL(string: $0) }
      .ignoreNil()
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
    scheduler: DateSchedulerType = AppEnvironment.current.scheduler) -> SignalProducer<UIImage?, NoError> {

    let requestedTime = CMTimeMakeWithSeconds(30.0, 1)
    let requestedTimeValue = NSValue(CMTime: requestedTime)

    let image = SignalProducer<UIImage?, NoError> { observer, disposable in
      generator.generateCGImagesAsynchronouslyForTimes([requestedTimeValue]) { (_, image, _, _, _) in

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
