import KsApi
import Library
import Prelude

import Library
import LiveStream
import ReactiveSwift
import Result

public protocol LiveStreamDiscoveryViewModelInputs {
  func tapped(liveStreamEvent: LiveStreamEvent)
  func viewDidLoad()
}

public protocol LiveStreamDiscoveryViewModelOutputs {
  var goToLiveStreamContainer: Signal<(Project, Project.LiveStream, LiveStreamEvent), NoError> { get }
  var goToLiveStreamCountdown: Signal<(Project, Project.LiveStream, LiveStreamEvent), NoError> { get }
  var loadDataSource: Signal<[LiveStreamEvent], NoError> { get }
}

public protocol LiveStreamDiscoveryViewModelType {
  var inputs: LiveStreamDiscoveryViewModelInputs { get }
  var outputs: LiveStreamDiscoveryViewModelOutputs { get }
}

public final class LiveStreamDiscoveryViewModel: LiveStreamDiscoveryViewModelType, LiveStreamDiscoveryViewModelInputs, LiveStreamDiscoveryViewModelOutputs {

  public init() {

    let projectAndTappedLiveStreamEvent = self.tappedLiveStreamEventProperty.signal.skipNil()
      .switchMap { event -> SignalProducer<(Project, Project.LiveStream, LiveStreamEvent), NoError> in
        guard let id = event.project.id else { return .empty }
        return AppEnvironment.current.apiService.fetchProject(param: .id(id))
          .map { projectAndLiveStreamAndEvent(forProject: $0, liveStreamEvent: event) }
          .skipNil()
          .demoteErrors()
    }

    self.goToLiveStreamContainer = projectAndTappedLiveStreamEvent
      .filter { _, _, event in event.liveNow }
    self.goToLiveStreamCountdown = projectAndTappedLiveStreamEvent
      .filter { _, _, event in !event.liveNow }

    self.loadDataSource = self.viewDidLoadProperty.signal
      .flatMap {
        AppEnvironment.current.liveStreamService.fetchEvents()
          .demoteErrors()
    }
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

private func projectAndLiveStreamAndEvent(forProject project: Project, liveStreamEvent: LiveStreamEvent)
  -> (Project, Project.LiveStream, LiveStreamEvent)? {

    guard let stream = project.liveStreams.first(where: { $0.id == liveStreamEvent.id }) else { return nil }
    return (project, stream, liveStreamEvent)
}

internal final class LiveStreamDiscoveryViewController: UITableViewController {

  private let dataSource = LiveStreamDiscoveryDataSource()
  private let viewModel: LiveStreamDiscoveryViewModelType = LiveStreamDiscoveryViewModel()

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.dataSource = self.dataSource

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableControllerStyle(estimatedRowHeight: 300.0)
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.loadDataSource
      .observeForUI()
      .observeValues { [weak self] in
        self?.dataSource.load(liveStreams: $0)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.goToLiveStreamCountdown
      .observeForControllerAction()
      .observeValues { [weak self] project, stream, event in
        self?.goToLiveStreamCountdown(project: project, stream: stream, liveStreamEvent: event)
    }

    self.viewModel.outputs.goToLiveStreamContainer
      .observeForControllerAction()
      .observeValues { [weak self] project, stream, event in
        self?.goToLiveStreamContainer(project: project, stream: stream, liveStreamEvent: event)
    }
  }

  private func goToLiveStreamContainer(project: Project, stream: Project.LiveStream, liveStreamEvent: LiveStreamEvent) {
    let vc = LiveStreamContainerViewController.configuredWith(project: project, liveStream: stream, event: liveStreamEvent)
    let nav = UINavigationController.init(navigationBarClass: ClearNavigationBar.self, toolbarClass: nil)
    nav.viewControllers = [vc]
    self.present(nav, animated: true, completion: nil)
  }

  private func goToLiveStreamCountdown(project: Project, stream: Project.LiveStream, liveStreamEvent: LiveStreamEvent) {
    let vc = LiveStreamCountdownViewController.configuredWith(project: project, liveStream: stream)
    let nav = UINavigationController.init(navigationBarClass: ClearNavigationBar.self, toolbarClass: nil)
    nav.viewControllers = [vc]
    self.present(nav, animated: true, completion: nil)
  }

  internal override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let liveStreamEvent = self.dataSource[indexPath] as? LiveStreamEvent {
      self.viewModel.inputs.tapped(liveStreamEvent: liveStreamEvent)
    }
  }
}
