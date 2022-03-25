import KsApi
import Library
import Prelude
import UIKit

internal final class BackerDashboardProjectsViewController: UITableViewController {
  private var userUpdatedObserver: Any?
  fileprivate let viewModel: BackerDashboardProjectsViewModelType = BackerDashboardProjectsViewModel()
  fileprivate let dataSource = BackerDashboardProjectsDataSource()

  internal static func configuredWith(projectsType: ProfileProjectsType, sort: DiscoveryParams.Sort)
    -> BackerDashboardProjectsViewController {
    let vc = BackerDashboardProjectsViewController()
    vc.viewModel.inputs.configureWith(projectsType: projectsType, sort: sort)
    return vc
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.dataSource = self.dataSource

    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
    self.refreshControl = refreshControl

    self.tableView.register(nib: .BackerDashboardEmptyStateCell)
    self.tableView.register(nib: .BackerDashboardProjectCell)

    self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: Styles.grid(2)))

    self.userUpdatedObserver = NotificationCenter
      .default
      .addObserver(forName: Notification.Name.ksr_userUpdated, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.currentUserUpdated()
      }

    self.viewModel.inputs.viewDidLoad()
  }

  deinit {
    self.userUpdatedObserver.doIfSome(NotificationCenter.default.removeObserver)
  }

  internal override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.viewModel.inputs.viewWillAppear(animated)
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.isRefreshing
      .observeForUI()
      .observeValues { [weak self] isRefreshing in
        if isRefreshing {
          self?.refreshControl?.beginRefreshing()
        } else {
          self?.refreshControl?.endRefreshing()
        }
      }

    self.viewModel.outputs.emptyStateIsVisible
      .observeForUI()
      .observeValues { [weak self] isVisible, type in
        self?.dataSource.emptyState(visible: isVisible, projectsType: type)
        self?.tableView.reloadData()
      }

    self.viewModel.outputs.projects
      .observeForUI()
      .observeValues { [weak self] in
        self?.dataSource.load(projects: $0)
        self?.tableView.reloadData()
      }

    self.viewModel.outputs.goToProject
      .observeForControllerAction()
      .observeValues { [weak self] project, projects, reftag in
        self?.goTo(project: project, initialPlaylist: projects, refTag: reftag)
      }
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableControllerStyle()
  }

  internal override func tableView(
    _: UITableView,
    willDisplay _: UITableViewCell,
    forRowAt indexPath: IndexPath
  ) {
    self.viewModel.inputs.willDisplayRow(
      self.dataSource.itemIndexAt(indexPath),
      outOf: self.dataSource.numberOfItems()
    )
  }

  internal override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let project = self.dataSource[indexPath] as? Project else {
      return
    }

    self.viewModel.inputs.projectTapped(project)
  }

  private func goTo(project: Project, initialPlaylist _: [Project], refTag: RefTag) {
    let projectParam = Either<Project, Param>(left: project)
    let vc = ProjectPageViewController.configuredWith(
      projectOrParam: projectParam,
      refTag: refTag
    )

    let nav = NavigationController(rootViewController: vc)
    nav.modalPresentationStyle = self.traitCollection.userInterfaceIdiom == .pad ? .fullScreen : .formSheet

    self.present(nav, animated: true, completion: nil)
  }

  @objc private func refresh() {
    self.viewModel.inputs.refresh()
  }
}
