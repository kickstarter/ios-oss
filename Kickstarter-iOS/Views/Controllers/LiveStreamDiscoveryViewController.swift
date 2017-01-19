import KsApi
import Library
import LiveStream
import Prelude

internal final class LiveStreamDiscoveryViewController: UITableViewController {
  private let dataSource = LiveStreamDiscoveryDataSource()
  private let viewModel: LiveStreamDiscoveryViewModelType = LiveStreamDiscoveryViewModel()

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.dataSource = self.dataSource

    self.viewModel.inputs.viewDidLoad()
  }

  internal func isActive(_ active: Bool) {
    self.viewModel.inputs.isActive(active)
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableControllerStyle(estimatedRowHeight: 200.0)
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

  private func goToLiveStreamContainer(project: Project,
                                       stream: Project.LiveStream,
                                       liveStreamEvent: LiveStreamEvent) {
    let vc = LiveStreamContainerViewController.configuredWith(project: project,
                                                              liveStream: stream,
                                                              event: liveStreamEvent)
    let nav = UINavigationController.init(navigationBarClass: ClearNavigationBar.self, toolbarClass: nil)
    _ = nav.view
    nav.viewControllers = [vc]
    self.present(nav, animated: true, completion: nil)
  }

  private func goToLiveStreamCountdown(project: Project,
                                       stream: Project.LiveStream,
                                       liveStreamEvent: LiveStreamEvent) {
    let vc = LiveStreamCountdownViewController.configuredWith(project: project, liveStream: stream)
    let nav = UINavigationController.init(navigationBarClass: ClearNavigationBar.self, toolbarClass: nil)
    _ = nav.view
    nav.viewControllers = [vc]
    self.present(nav, animated: true, completion: nil)
  }

  internal override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let liveStreamEvent = self.dataSource[indexPath] as? LiveStreamEvent {
      self.viewModel.inputs.tapped(liveStreamEvent: liveStreamEvent)
    }
  }
}
