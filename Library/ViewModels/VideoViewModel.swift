import AVFoundation
import KsApi
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result

private let playRate = 1.0
private let pauseRate = 0.0

public protocol VideoViewModelInputs {
  /// Call to configure cell with project value.
  func configureWith(project: Project)

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
  func viewDidDisappear(animated: Bool)

  /// Call when the view did load.
  func viewDidLoad()

  /// Call when the view will disappear.
  func viewWillDisappear()
}

public protocol VideoViewModelOutputs {
  /// Emits when should add a boundary observer for the 85% completion time.
  var addCompletionObserver: Signal<CMTime, NoError> { get }

  /// Emits with the video url to be played.
  var configurePlayerWithURL: Signal<URL, NoError> { get }

  /// Emits for testing when the video complete stat is incremented.
  var incrementVideoCompletion: Signal<VoidEnvelope, NoError> { get }

  /// Emits for testing when the video start stat is incremented.
  var incrementVideoStart: Signal<VoidEnvelope, NoError> { get }

  var notifyDelegateThatVideoDidFinish: Signal<(), NoError> { get }
  var notifyDelegateThatVideoDidStart: Signal<(), NoError> { get }

  /// Emits alpha value for play button and video overlay for transitioning.
  var opacityForViews: Signal<CGFloat, NoError> { get }

  /// Emits when the video should be paused.
  var pauseVideo: Signal<Void, NoError> { get }

  /// Emits when the video should be played.
  var playVideo: Signal<Void, NoError> { get }

  /// Emits a boolean to determine whether or not the play button should be hidden.
  var playButtonHidden: Signal<Bool, NoError> { get }

  /// Emits a boolean to determine whether or not the project image should be hidden.
  var projectImageHidden: Signal<Bool, NoError> { get }

  /// Emits with the project image url to be displayed.
  var projectImageURL: Signal<URL?, NoError> { get }

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

    public init() {

    let project = Signal.combineLatest(
      self.projectProperty.signal.skipNil(),
      self.viewDidLoadProperty.signal
    )
    .map(first)

    let viewIsVisible = Signal.merge(
      self.viewDidAppearProperty.signal.mapConst(true),
      self.viewWillDisappearProperty.signal.mapConst(false)
    )

    let duration = self.durationProperty.signal.skipNil().skipRepeats()
    let rateCurrentTime = self.rateCurrentTimeProperty.signal.skipNil().skipRepeats(==)

    let completionThreshold = duration
      .map { 0.85 * CMTimeGetSeconds($0) }

    let reachedEndOfVideo = Signal.combineLatest(rateCurrentTime, duration)
      .filter { rateCurrentTime, duration in rateCurrentTime.1 == duration }

    let videoCompletedOnScrub = Signal.combineLatest(rateCurrentTime, completionThreshold)
      .filter { rateCurrentTime, completionThreshold in
        let currentTimeSeconds = CMTimeGetSeconds(rateCurrentTime.1)
        return currentTimeSeconds >= completionThreshold
      }
      .take(first: 1)
      .ignoreValues()

    let videoCompleted = Signal.merge(videoCompletedOnScrub, self.crossedCompletionThresholdProperty.signal)
      .take(first: 1)

    let videoPaused = Signal.combineLatest(rateCurrentTime, duration)
      .skip(first: 1)
      .filter { rateCurrentTime, duration in rateCurrentTime.0 == pauseRate && rateCurrentTime.1 != duration }

    let videoResumed = rateCurrentTime
      .filter { rate, currentTime in currentTime > kCMTimeZero && rate == playRate }

    let videoStarted = rateCurrentTime
      .filter { rate, currentTime in currentTime == kCMTimeZero && rate == playRate }
      .take(first: 1)

    self.addCompletionObserver = completionThreshold.map { CMTimeMakeWithSeconds($0, 1) }

    self.configurePlayerWithURL = project
      .filter { $0.video != nil }
      .takeWhen(self.playButtonTappedProperty.signal)
      .map { URL(string: $0.video?.hls ?? $0.video?.high ?? "") }
      .skipNil()
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

    self.playButtonHidden = Signal.merge(
      project.map { $0.video == nil },
      elementsHiddenOnPlayback
      )
      .skipRepeats()

    self.projectImageURL = project.map { URL(string: $0.photo.full) }.skipRepeats(==)

    self.seekToBeginning = reachedEndOfVideo.ignoreValues()

    self.incrementVideoCompletion = Signal.combineLatest(project, videoCompleted)
      .map(first)
      .switchMap {
        AppEnvironment.current.apiService.incrementVideoCompletion(forProject: $0)
          .demoteErrors()
    }

    self.incrementVideoStart = Signal.combineLatest(project, videoStarted)
      .map(first)
      .switchMap {
        AppEnvironment.current.apiService.incrementVideoStart(forProject: $0)
          .demoteErrors()
      }

    self.videoViewHidden = self.projectImageHidden.map(negate)

    self.notifyDelegateThatVideoDidFinish = reachedEndOfVideo.ignoreValues()
    self.notifyDelegateThatVideoDidStart = self.playButtonTappedProperty.signal

    self.opacityForViews = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst(0.0),
      self.playButtonHidden.filter(isFalse)
        .takeWhen(self.viewDidAppearProperty.signal)
        .mapConst(1.0)
    )

    project
      .takeWhen(videoCompleted)
      .observeValues { AppEnvironment.current.koala.trackVideoCompleted(forProject: $0) }

    Signal.combineLatest(project, viewIsVisible)
      .takeWhen(videoPaused)
      .filter { _, isVisible in isVisible }
      .map(first)
      .observeValues { AppEnvironment.current.koala.trackVideoPaused(forProject: $0) }

    project
      .takeWhen(videoResumed)
      .observeValues { AppEnvironment.current.koala.trackVideoResume(forProject: $0) }

    project
      .takeWhen(videoStarted)
      .observeValues { AppEnvironment.current.koala.trackVideoStart(forProject: $0) }
  }

  fileprivate let crossedCompletionThresholdProperty = MutableProperty(())
  public func crossedCompletionThreshold() {
    self.crossedCompletionThresholdProperty.value = ()
  }
  fileprivate let durationProperty = MutableProperty<CMTime?>(nil)
  public func durationChanged(toNew duration: CMTime) {
    self.durationProperty.value = duration
  }
  fileprivate let playButtonTappedProperty = MutableProperty(())
  public func playButtonTapped() {
    self.playButtonTappedProperty.value = ()
  }
  fileprivate let projectProperty = MutableProperty<Project?>(nil)
  public func configureWith(project: Project) {
    self.projectProperty.value = project
  }
  fileprivate let rateCurrentTimeProperty = MutableProperty<(Double, CMTime)?>(nil)
  public func rateChanged(toNew rate: Double, atTime currentTime: CMTime) {
    self.rateCurrentTimeProperty.value = (rate, currentTime)
  }
  fileprivate let viewDidAppearProperty = MutableProperty(())
  public func viewDidAppear() {
    self.viewDidAppearProperty.value = ()
  }
  fileprivate let viewDidDisappearProperty = MutableProperty(false)
  public func viewDidDisappear(animated: Bool) {
    self.viewDidDisappearProperty.value = animated
  }
  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }
  fileprivate let viewWillDisappearProperty = MutableProperty(())
  public func viewWillDisappear() {
    self.viewWillDisappearProperty.value = ()
  }

  public let addCompletionObserver: Signal<CMTime, NoError>
  public let configurePlayerWithURL: Signal<URL, NoError>
  public let incrementVideoCompletion: Signal<VoidEnvelope, NoError>
  public let incrementVideoStart: Signal<VoidEnvelope, NoError>
  public let notifyDelegateThatVideoDidFinish: Signal<(), NoError>
  public let notifyDelegateThatVideoDidStart: Signal<(), NoError>
  public let opacityForViews: Signal<CGFloat, NoError>
  public let pauseVideo: Signal<Void, NoError>
  public let playVideo: Signal<Void, NoError>
  public var playButtonHidden: Signal<Bool, NoError>
  public var projectImageHidden: Signal<Bool, NoError>
  public let projectImageURL: Signal<URL?, NoError>
  public let seekToBeginning: Signal<Void, NoError>
  public var videoViewHidden: Signal<Bool, NoError>

  public var inputs: VideoViewModelInputs { return self }
  public var outputs: VideoViewModelOutputs { return self }
}
