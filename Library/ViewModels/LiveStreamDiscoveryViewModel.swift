import KsApi
import LiveStream
import Prelude
import ReactiveSwift
import Result

public protocol LiveStreamDiscoveryViewModelInputs {
  /// Call when the app will enter the foreground after being backgrounded
  func appWillEnterForeground()

  /// Call from parent controller when this view is shown to the user.
  func isActive(_ active: Bool)

  /// Call when a live stream cell is tapped.
  func tapped(liveStreamEvent: LiveStreamEvent)

  /// Call when the view loads.
  func viewDidLoad()

  /// Call when the viewWillAppear
  func viewWillAppear()
}

public protocol LiveStreamDiscoveryViewModelOutputs {
  /// Emits when we should navigate to the live stream container.
  var goToLiveStreamContainer: Signal<(Project, LiveStreamEvent), NoError> { get }

  /// Emits when we should navigate to the live stream countdown.
  var goToLiveStreamCountdown: Signal<(Project, LiveStreamEvent), NoError> { get }

  /// Emits when we should load data into the data source.
  var loadDataSource: Signal<[LiveStreamEvent], NoError> { get }

  /// Emits when an alert should be shown to the user.
  var showAlert: Signal<String, NoError> { get }
}

public protocol LiveStreamDiscoveryViewModelType {
  var inputs: LiveStreamDiscoveryViewModelInputs { get }
  var outputs: LiveStreamDiscoveryViewModelOutputs { get }
}

public final class LiveStreamDiscoveryViewModel: LiveStreamDiscoveryViewModelType,
LiveStreamDiscoveryViewModelInputs, LiveStreamDiscoveryViewModelOutputs {

  public init() {
    let projectAndTappedLiveStreamEvent = self.tappedLiveStreamEventProperty.signal
      .skipNil()
      .switchMap { freshProjectAndLiveStream(fromLiveStreamEvent: $0).materialize() }

    self.goToLiveStreamContainer = projectAndTappedLiveStreamEvent
      .values()
      .filter { _, event in event.liveNow || event.hasReplay }

    self.goToLiveStreamCountdown = projectAndTappedLiveStreamEvent
      .values()
      .filter { _, event in !event.liveNow && !event.hasReplay }

    self.showAlert = projectAndTappedLiveStreamEvent.errors()
      .mapConst(Strings.Couldnt_open_live_stream_Try_again_later())

    let didNavigateBack = self.viewWillAppearProperty.signal.skip(first: 1)

    let refreshes = Signal.merge(
      didNavigateBack.ignoreValues(),
      appWillEnterForegroundProperty.signal,
      self.viewDidLoadProperty.signal
    )

    let freshLiveStreamEvents = Signal.combineLatest(
      self.isActiveProperty.signal,
      refreshes
      )
      .map(first)
      .filter(isTrue)
      .switchMap { _ in
        AppEnvironment.current.liveStreamService.fetchEvents()
          .demoteErrors()
    }

    self.loadDataSource = Signal.merge(
      self.isActiveProperty.signal.filter(isFalse).mapConst([]),
      freshLiveStreamEvents
    )

    self.isActiveProperty.signal
      .filter(isTrue)
      .observeValues { _ in
        AppEnvironment.current.koala.trackLiveStreamDiscovery()
    }
  }

  private let appWillEnterForegroundProperty = MutableProperty(())
  public func appWillEnterForeground() {
    self.appWillEnterForegroundProperty.value = ()
  }

  private let isActiveProperty = MutableProperty(false)
  public func isActive(_ active: Bool) {
    self.isActiveProperty.value = active
  }

  private let tappedLiveStreamEventProperty = MutableProperty<LiveStreamEvent?>(nil)
  public func tapped(liveStreamEvent: LiveStreamEvent) {
    self.tappedLiveStreamEventProperty.value = liveStreamEvent
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  private let viewWillAppearProperty = MutableProperty(())
  public func viewWillAppear() {
    self.viewWillAppearProperty.value = ()
  }

  public let goToLiveStreamContainer: Signal<(Project, LiveStreamEvent), NoError>
  public let goToLiveStreamCountdown: Signal<(Project, LiveStreamEvent), NoError>
  public let loadDataSource: Signal<[LiveStreamEvent], NoError>
  public let showAlert: Signal<String, NoError>

  public var inputs: LiveStreamDiscoveryViewModelInputs { return self }
  public var outputs: LiveStreamDiscoveryViewModelOutputs { return self }
}

private func freshProjectAndLiveStream(fromLiveStreamEvent event: LiveStreamEvent)
  -> SignalProducer<(Project, LiveStreamEvent), SomeError> {

    guard let id = event.project.id else { return .empty }

    return AppEnvironment.current.apiService.fetchProject(param: .id(id))
      .mapError { _ in SomeError() }
      .map { ($0, event) }
}
