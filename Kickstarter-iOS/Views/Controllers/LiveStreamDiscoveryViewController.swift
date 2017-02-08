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

  /// Call from discovery when this controller becomes active.
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

    NotificationCenter.default.addObserver(
      forName: NSNotification.Name.UIApplicationWillEnterForeground, object: nil,
      queue: nil) { [weak self ]_ in
        guard let _self = self else { return }
        _self.viewModel.inputs.appWillEnterForeground()

    }

    self.viewModel.outputs.loadDataSource
      .observeForUI()
      .observeValues { [weak self] in
        self?.dataSource.load(liveStreams: $0)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.goToLiveStreamCountdown
      .observeForControllerAction()
      .observeValues { [weak self] project, event in
        self?.goToLiveStreamCountdown(project: project, liveStreamEvent: event)
    }

    self.viewModel.outputs.goToLiveStreamContainer
      .observeForControllerAction()
      .observeValues { [weak self] project, event in
        self?.goToLiveStreamContainer(project: project, liveStreamEvent: event)
    }

    self.viewModel.outputs.showAlert
      .observeForUI()
      .observeValues { [weak self] in self?.showAlert(message: $0) }
  }

  internal override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.viewModel.inputs.viewWillAppear()
  }

  internal override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    self.viewModel.inputs.viewDidDisappear()
  }

  internal override func tableView(_ tableView: UITableView,
                                   didEndDisplaying cell: UITableViewCell,
                                   forRowAt indexPath: IndexPath) {

    (cell as? LiveStreamDiscoveryLiveNowCell)?.didEndDisplay()
  }

  private func goToLiveStreamContainer(project: Project,
                                       liveStreamEvent: LiveStreamEvent) {
    let vc = LiveStreamContainerViewController.configuredWith(project: project,
                                                              liveStreamEvent: liveStreamEvent,
                                                              refTag: .liveStreamDiscovery,
                                                              presentedFromProject: false)
    let nav = UINavigationController.init(navigationBarClass: ClearNavigationBar.self, toolbarClass: nil)
    nav.viewControllers = [vc]
    DispatchQueue.main.async {
      self.present(nav, animated: true, completion: nil)
    }
  }

  private func goToLiveStreamCountdown(project: Project,
                                       liveStreamEvent: LiveStreamEvent) {
    let vc = LiveStreamCountdownViewController.configuredWith(project: project,
                                                              liveStreamEvent: liveStreamEvent,
                                                              refTag: .liveStreamDiscovery,
                                                              presentedFromProject: false)
    let nav = UINavigationController.init(navigationBarClass: ClearNavigationBar.self, toolbarClass: nil)
    nav.viewControllers = [vc]
    DispatchQueue.main.async {
      self.present(nav, animated: true, completion: nil)
    }
  }

  private func showAlert(message: String) {
    let vc = UIAlertController.alert("", message: message, handler: nil)
    self.present(vc, animated: true, completion: nil)
  }

  internal override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let liveStreamEvent = self.dataSource[indexPath] as? LiveStreamEvent {
      self.viewModel.inputs.tapped(liveStreamEvent: liveStreamEvent)
    }
  }
}
