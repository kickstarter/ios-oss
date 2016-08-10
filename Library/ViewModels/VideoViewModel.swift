import AVFoundation
import KsApi
import Prelude
import ReactiveCocoa
import ReactiveExtensions
import Result

private let playRate = 1.0
private let pauseRate = 0.0

public protocol VideoViewModelInputs {
  /// Call to configure cell with project value.
  func configureWith(project project: Project)

  /// Call when the video playback crosses the completion threshold.
  func crossedCompletionThreshold()

  /// Call with duration when video duration changes.
  func durationChanged(toNew duration: CMTime)

  /// Call when the play button is tapped.
  func playButtonTapped()

  /// Call with rate and current time when playback rate changes.
  func rateChanged(toNew rate: Double, atTime currentTime: CMTime)

  /// Call when the view did disappear.
  func viewDidDisappear(animated animated: Bool)

  /// Call when the view did load.
  func viewDidLoad()
}

public protocol VideoViewModelOutputs {
  /// Emits when should add a boundary observer for the 85% completion time.
  var addCompletionObserver: Signal<CMTime, NoError> { get }

  /// Emits with the video url to be played.
  var configurePlayerWithURL: Signal<NSURL, NoError> { get }

  /// Emits for testing when the video complete stat is incremented.
  var incrementVideoCompletion: Signal<VoidEnvelope, NoError> { get }

  /// Emits for testing when the video start stat is incremented.
  var incrementVideoStart: Signal<VoidEnvelope, NoError> { get }

  /// Emits when the video should be paused.
  var pauseVideo: Signal<Void, NoError> { get }

  /// Emits when the video should be played.
  var playVideo: Signal<Void, NoError> { get }

  /// Emits a boolean to determine whether or not the project image and play button should be hidden.
  var projectImagePlayButtonHidden: Signal<Bool, NoError> { get }

  /// Emits with the project image url to be displayed.
  var projectImageURL: Signal<NSURL?, NoError> { get }

  /// Emits when should seek video back to beginning.
  var seekToBeginning: Signal<Void, NoError> { get }
}

public protocol VideoViewModelType {
  var inputs: VideoViewModelInputs { get }
  var outputs: VideoViewModelOutputs { get }
}

public final class VideoViewModel: VideoViewModelInputs, VideoViewModelOutputs, VideoViewModelType {

  // swiftlint:disable function_body_length
  public init() {

    let project = combineLatest(
      self.projectProperty.signal.ignoreNil(),
      self.viewDidLoadProperty.signal
    )
    .map(first)

    let duration = self.durationProperty.signal.ignoreNil()
    let rateCurrentTime = self.rateCurrentTimeProperty.signal.ignoreNil().skip(1)

    let completionThreshold = duration
      .map { 0.85 * CMTimeGetSeconds($0) }

    let reachedEndOfVideo = combineLatest(rateCurrentTime, duration)
      .filter { rateCurrentTime, duration in rateCurrentTime.1 == duration }

    let videoCompletedOnScrub = combineLatest(rateCurrentTime, completionThreshold)
      .filter { rateCurrentTime, completionThreshold in
        let currentTimeSeconds = CMTimeGetSeconds(rateCurrentTime.1)
        return currentTimeSeconds >= completionThreshold
      }
      .take(1)
      .ignoreValues()

    let videoCompleted = Signal.merge(videoCompletedOnScrub, self.crossedCompletionThresholdProperty.signal)
      .take(1)

    let videoPaused = combineLatest(rateCurrentTime, duration)
      .filter { rateCurrentTime, duration in rateCurrentTime.0 == pauseRate && rateCurrentTime.1 != duration }

    let videoResumed = rateCurrentTime
      .filter { rate, currentTime in currentTime > kCMTimeZero && rate == playRate }

    let videoStarted = rateCurrentTime
      .filter { rate, currentTime in currentTime == kCMTimeZero && rate == playRate }
      .take(1)

    self.addCompletionObserver = completionThreshold.map { CMTimeMakeWithSeconds($0, 1) }

    self.configurePlayerWithURL = project
      .map { NSURL(string: $0.video?.high ?? "") }
      .ignoreNil()
      .skipRepeats()

    self.pauseVideo = self.viewDidDisappearProperty.signal.ignoreValues()

    self.playVideo = self.playButtonTappedProperty.signal

    self.projectImagePlayButtonHidden = Signal.merge(
      self.playVideo.mapConst(true),
      reachedEndOfVideo.mapConst(false)
      )
      .skipRepeats()

    self.projectImageURL = project.map { NSURL(string: $0.photo.full) }.skipRepeats(==)

    self.seekToBeginning = reachedEndOfVideo.ignoreValues()

    self.incrementVideoCompletion = combineLatest(project, videoCompleted)
      .map(first)
      .switchMap {
        AppEnvironment.current.apiService.incrementVideoCompletion(forProject: $0)
          .demoteErrors()
    }

    self.incrementVideoStart = combineLatest(project, videoStarted)
      .map(first)
      .switchMap {
        AppEnvironment.current.apiService.incrementVideoStart(forProject: $0)
          .demoteErrors()
      }

    project
      .takeWhen(videoCompleted)
      .observeNext { AppEnvironment.current.koala.trackVideoCompleted(forProject: $0) }

    project
      .takeWhen(videoPaused)
      .observeNext { AppEnvironment.current.koala.trackVideoPaused(forProject: $0) }

    project
      .takeWhen(videoResumed)
      .observeNext { AppEnvironment.current.koala.trackVideoResume(forProject: $0) }

    project
      .takeWhen(videoStarted)
      .observeNext {
        AppEnvironment.current.koala.trackVideoStart(forProject: $0)
    }
  }
  // swiftlint:enable function_body_length

  private let crossedCompletionThresholdProperty = MutableProperty()
  public func crossedCompletionThreshold() {
    self.crossedCompletionThresholdProperty.value = ()
  }
  private let durationProperty = MutableProperty<CMTime?>(nil)
  public func durationChanged(toNew duration: CMTime) {
    self.durationProperty.value = duration
  }
  private let playButtonTappedProperty = MutableProperty()
  public func playButtonTapped() {
    self.playButtonTappedProperty.value = ()
  }
  private let projectProperty = MutableProperty<Project?>(nil)
  public func configureWith(project project: Project) {
    self.projectProperty.value = project
  }
  private let rateCurrentTimeProperty = MutableProperty<(Double, CMTime)?>(nil)
  public func rateChanged(toNew rate: Double, atTime currentTime: CMTime) {
    self.rateCurrentTimeProperty.value = (rate, currentTime)
  }
  private let viewDidDisappearProperty = MutableProperty(false)
  public func viewDidDisappear(animated animated: Bool) {
    self.viewDidDisappearProperty.value = animated
  }
  private let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let addCompletionObserver: Signal<CMTime, NoError>
  public let configurePlayerWithURL: Signal<NSURL, NoError>
  public let incrementVideoCompletion: Signal<VoidEnvelope, NoError>
  public let incrementVideoStart: Signal<VoidEnvelope, NoError>
  public let pauseVideo: Signal<Void, NoError>
  public let playVideo: Signal<Void, NoError>
  public let projectImagePlayButtonHidden: Signal<Bool, NoError>
  public let projectImageURL: Signal<NSURL?, NoError>
  public let seekToBeginning: Signal<Void, NoError>

  public var inputs: VideoViewModelInputs { return self }
  public var outputs: VideoViewModelOutputs { return self }
}
