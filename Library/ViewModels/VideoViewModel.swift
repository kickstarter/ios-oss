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

  /// Call when the view did appear.
  func viewDidAppear()

  /// Call when the view did disappear.
  func viewDidDisappear(animated animated: Bool)

  /// Call when the view did load.
  func viewDidLoad()

  /// Call when the view will disappear.
  func viewWillDisappear()
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

  /// Emits a boolean to determine whether or not the play button should be hidden.
  var playButtonHidden: Signal<Bool, NoError> { get }

  /// Emits a boolean to determine whether or not the project image should be hidden.
  var projectImageHidden: Signal<Bool, NoError> { get }

  /// Emits with the project image url to be displayed.
  var projectImageURL: Signal<NSURL?, NoError> { get }

  /// Emits when should seek video back to beginning.
  var seekToBeginning: Signal<Void, NoError> { get }

  /// Emits a boolean to determine whether or not the video player should be hidden.
  var videoViewHidden: Signal<Bool, NoError> { get }
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

    let viewIsVisible = Signal.merge(
      self.viewDidAppearProperty.signal.mapConst(true),
      self.viewWillDisappearProperty.signal.mapConst(false)
    )

    let duration = self.durationProperty.signal.ignoreNil().skipRepeats()
    let rateCurrentTime = self.rateCurrentTimeProperty.signal.ignoreNil().skipRepeats(==)

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
      .filter { $0.video != nil }
      .takeWhen(self.playButtonTappedProperty.signal)
      .map { NSURL(string: $0.video?.high ?? "") }
      .ignoreNil()
      .skipRepeats()

    self.playVideo = self.playButtonTappedProperty.signal

    self.pauseVideo = self.playVideo
      .takeWhen(self.viewWillDisappearProperty.signal)

    let elementsHiddenOnPlayback = Signal.merge(
      self.playVideo.mapConst(true),
      reachedEndOfVideo.mapConst(false)
      )
      .skipRepeats()

    self.projectImageHidden = Signal.merge(elementsHiddenOnPlayback, project.mapConst(false))
      .skipRepeats()

    self.playButtonHidden = Signal.merge(project.map { $0.video == nil }, elementsHiddenOnPlayback)
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

    self.videoViewHidden = self.projectImageHidden.map { !$0 }

    project
      .takeWhen(videoCompleted)
      .observeNext { AppEnvironment.current.koala.trackVideoCompleted(forProject: $0) }

    combineLatest(project, viewIsVisible)
      .takeWhen(videoPaused)
      .filter { _, isVisible in isVisible }
      .map(first)
      .observeNext { AppEnvironment.current.koala.trackVideoPaused(forProject: $0) }

    project
      .takeWhen(videoResumed)
      .observeNext { AppEnvironment.current.koala.trackVideoResume(forProject: $0) }

    project
      .takeWhen(videoStarted)
      .observeNext { AppEnvironment.current.koala.trackVideoStart(forProject: $0) }
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
  private let viewDidAppearProperty = MutableProperty()
  public func viewDidAppear() {
    self.viewDidAppearProperty.value = ()
  }
  private let viewDidDisappearProperty = MutableProperty(false)
  public func viewDidDisappear(animated animated: Bool) {
    self.viewDidDisappearProperty.value = animated
  }
  private let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }
  private let viewWillDisappearProperty = MutableProperty()
  public func viewWillDisappear() {
    self.viewWillDisappearProperty.value = ()
  }

  public let addCompletionObserver: Signal<CMTime, NoError>
  public let configurePlayerWithURL: Signal<NSURL, NoError>
  public let incrementVideoCompletion: Signal<VoidEnvelope, NoError>
  public let incrementVideoStart: Signal<VoidEnvelope, NoError>
  public let pauseVideo: Signal<Void, NoError>
  public let playVideo: Signal<Void, NoError>
  public var playButtonHidden: Signal<Bool, NoError>
  public var projectImageHidden: Signal<Bool, NoError>
  public let projectImageURL: Signal<NSURL?, NoError>
  public let seekToBeginning: Signal<Void, NoError>
  public var videoViewHidden: Signal<Bool, NoError>

  public var inputs: VideoViewModelInputs { return self }
  public var outputs: VideoViewModelOutputs { return self }
}
