import KsApi
import Library
import Prelude
import UIKit

internal protocol ProfileProjectsViewControllerDelegate: class {
  /// Called when the table view's scrollViewDidEndDecelerating method is called.
  func profileProjectsDidEndDecelerating(_ scrollView: UIScrollView)

  /// Called when the table view's scrollViewDidEndDragging method is called.
  func profileProjectsDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)

  /// Called when the table view's scrollViewDidScroll method is called.
  func profileProjectsDidScroll(_ scrollView: UIScrollView)

  /// Called when a project cell is tapped.
  func profileProjectsGoToProject(_ project: Project, projects: [Project], reftag: RefTag)
}

internal final class ProfileProjectsViewController: UITableViewController {

  private let viewModel: ProfileProjectsViewModelType = ProfileProjectsViewModel()
  private let dataSource = ProfileProjectsDataSource()

  internal weak var delegate: ProfileProjectsViewControllerDelegate?

  internal func configureWith(projectsType: ProfileProjectsType) {
    self.viewModel.inputs.configureWith(type: projectsType)
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.dataSource = dataSource

    self.tableView.register(nib: .ProfileEmptyStateCell)
    self.tableView.register(nib: .ProfileProjectCell)

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.viewModel.inputs.viewWillAppear(animated)
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.emptyStateIsVisible
      .observeForUI()
      .observeValues { [weak self] isVisible, type in
        self?.dataSource.emptyState(visible: isVisible, type: type)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.projects
      .observeForUI()
      .observeValues { [weak self] in
        self?.dataSource.load(projects: $0)
        self?.tableView.reloadData()
    }
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableControllerStyle()

    _ = self.navigationController?.navigationBar
      ?|> baseNavigationBarStyle
  }

  internal override func scrollViewDidScroll(_ scrollView: UIScrollView) {
    self.delegate?.profileProjectsDidScroll(scrollView)
  }

  internal override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    self.delegate?.profileProjectsDidEndDecelerating(scrollView)
  }

  internal override func scrollViewDidEndDragging(_ scrollView: UIScrollView,
                                                  willDecelerate decelerate: Bool) {
    self.delegate?.profileProjectsDidEndDragging(scrollView, willDecelerate: decelerate)
  }
}
