import KsApi
import LiveStream
import Prelude
import ReactiveSwift
import Result

public protocol LiveStreamDiscoveryViewModelInputs {
  /// Call from parent controller when this view is shown to the user.
  func isActive(_ active: Bool)

  /// Call when a live stream cell is tapped.
  func tapped(liveStreamEvent: LiveStreamEvent)

  /// Call when the view loads.
  func viewDidLoad()
}

public protocol LiveStreamDiscoveryViewModelOutputs {
  /// Emits when we should navigate to the live stream container.
  var goToLiveStreamContainer: Signal<(Project, Project.LiveStream, LiveStreamEvent), NoError> { get }

  /// Emits when we should navigate to the live stream countdown.
  var goToLiveStreamCountdown: Signal<(Project, Project.LiveStream, LiveStreamEvent), NoError> { get }

  /// Emits when we should load data into the data source.
  var loadDataSource: Signal<[LiveStreamEvent], NoError> { get }
}

public protocol LiveStreamDiscoveryViewModelType {
  var inputs: LiveStreamDiscoveryViewModelInputs { get }
  var outputs: LiveStreamDiscoveryViewModelOutputs { get }
}

public final class LiveStreamDiscoveryViewModel: LiveStreamDiscoveryViewModelType,
LiveStreamDiscoveryViewModelInputs, LiveStreamDiscoveryViewModelOutputs {

  public init() {
    let projectAndTappedLiveStreamEvent = self.tappedLiveStreamEventProperty.signal.skipNil()
      .switchMap(freshProjectAndStreamAndEvent(fromLiveStreamEvent:))

    self.goToLiveStreamContainer = projectAndTappedLiveStreamEvent
      .filter { _, _, event in event.liveNow || event.hasReplay }

    self.goToLiveStreamCountdown = projectAndTappedLiveStreamEvent
      .filter { _, _, event in !event.liveNow && !event.hasReplay }

    self.loadDataSource = self.isActiveProperty.signal.filter(isTrue)
      .flatMap { _ in
        AppEnvironment.current.liveStreamService.fetchEvents()
          .demoteErrors()
    }
  }

  private let isActiveProperty = MutableProperty(false)
  public func isActive(_ active: Bool) {
    self.isActiveProperty.value = active
  }

  private let tappedLiveStreamEventProperty = MutableProperty<LiveStreamEvent?>(nil)
  public func tapped(liveStreamEvent: LiveStreamEvent) {
    self.tappedLiveStreamEventProperty.value = liveStreamEvent
  }

  private let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let goToLiveStreamContainer: Signal<(Project, Project.LiveStream, LiveStreamEvent), NoError>
  public let goToLiveStreamCountdown: Signal<(Project, Project.LiveStream, LiveStreamEvent), NoError>
  public let loadDataSource: Signal<[LiveStreamEvent], NoError>

  public var inputs: LiveStreamDiscoveryViewModelInputs { return self }
  public var outputs: LiveStreamDiscoveryViewModelOutputs { return self }
}

private func freshProjectAndStreamAndEvent(fromLiveStreamEvent event: LiveStreamEvent)
  -> SignalProducer<(Project, Project.LiveStream, LiveStreamEvent), NoError> {

    guard let id = event.project.id else { return .empty }

    let project = AppEnvironment.current.apiService.fetchProject(param: .id(id))
      .demoteErrors()
    let freshEvent = AppEnvironment.current.liveStreamService.fetchEvent(
      eventId: event.id, uid: AppEnvironment.current.currentUser?.id
      )
      .demoteErrors()

    return SignalProducer.zip(project, freshEvent)
      .map(projectAndLiveStreamAndEvent(forProject:liveStreamEvent:))
      .skipNil()
}

private func projectAndLiveStreamAndEvent(forProject project: Project, liveStreamEvent: LiveStreamEvent)
  -> (Project, Project.LiveStream, LiveStreamEvent)? {

    guard let stream = project.liveStreams?.first(where: { $0.id == liveStreamEvent.id }) else { return nil }
    return (project, stream, liveStreamEvent)
}
