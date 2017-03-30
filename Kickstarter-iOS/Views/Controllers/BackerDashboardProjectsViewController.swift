import KsApi
import Library
import Prelude
import UIKit

internal final class BackerDashboardProjectsViewController: UITableViewController {

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

    self.tableView.dataSource = dataSource

    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    self.refreshControl = refreshControl

    self.tableView.register(nib: .BackerDashboardEmptyStateCell)
    self.tableView.register(nib: .BackerDashboardProjectCell)

    self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: Styles.grid(2)))

    self.viewModel.inputs.viewDidLoad()
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
        self?.updateProjectPlaylist($0)
    }

    self.viewModel.outputs.goToProject
      .observeForControllerAction()
      .observeValues { [weak self] project, projects, reftag in
        self?.goTo(project: project, initialPlaylist: projects, refTag: reftag)
    }

    self.viewModel.outputs.scrollToProjectRow
      .observeForUI()
      .observeValues { [weak self] row in
        guard let _self = self else { return }
        _self.tableView.scrollToRow(at: _self.dataSource.indexPath(for: row),
                                    at: .top,
                                    animated: false)
    }
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableControllerStyle()
  }

  internal override func tableView(_ tableView: UITableView,
                                   willDisplay cell: UITableViewCell,
                                   forRowAt indexPath: IndexPath) {

    self.viewModel.inputs.willDisplayRow(self.dataSource.itemIndexAt(indexPath),
                                         outOf: self.dataSource.numberOfItems())
  }

  internal override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let project = self.dataSource[indexPath] as? Project else {
      return
    }

    self.viewModel.inputs.projectTapped(project)
  }

  private func goTo(project: Project, initialPlaylist: [Project], refTag: RefTag) {
    let vc = ProjectNavigatorViewController.configuredWith(project: project,
                                                           refTag: refTag,
                                                           initialPlaylist: initialPlaylist,
                                                           navigatorDelegate: self)
    self.present(vc, animated: true, completion: nil)
  }

  private func updateProjectPlaylist(_ playlist: [Project]) {
    guard let navigator = self.presentedViewController as? ProjectNavigatorViewController else { return }
    navigator.updatePlaylist(playlist)
  }

  @objc private func refresh() {
    self.viewModel.inputs.refresh()
  }
}

extension BackerDashboardProjectsViewController: ProjectNavigatorDelegate {
  func transitionedToProject(at index: Int) {
    self.viewModel.inputs.transitionedToProject(at: index, outOf: self.dataSource.numberOfItems())
  }
}
