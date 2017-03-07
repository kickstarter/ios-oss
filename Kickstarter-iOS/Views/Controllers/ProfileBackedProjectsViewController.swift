import KsApi
import Library
import Prelude
import UIKit

internal protocol ProfileBackedProjectsViewControllerDelegate: class {
  func profileBackedProjectsDidEndDecelerating(_ scrollView: UIScrollView)
  func profileBackedProjectsDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
  func profileBackedProjectsDidScroll(_ scrollView: UIScrollView)
}

internal final class ProfileBackedProjectsViewController: UITableViewController {

  private let viewModel: ProfileProjectsViewModelType = ProfileProjectsViewModel()
  private let dataSource = ProfileBackedProjectsDataSource()

  internal weak var delegate: ProfileBackedProjectsViewControllerDelegate?

  internal func configureWith(projectsType: ProfileProjectsType) {
    self.viewModel.inputs.configureWith(type: projectsType)
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.dataSource = dataSource

    self.tableView.register(nib: .ProfileEmptyStateCell)

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.emptyStateIsVisible
      .observeForUI()
      .observeValues { [weak self] isVisible, message in
        self?.dataSource.emptyState(visible: isVisible, message: message, showIcon: false)
        self?.tableView.reloadData()
    }
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableControllerStyle()
      |> UIViewController.lens.title %~ { _ in Strings.Follow_friends() }

    _ = self.navigationController?.navigationBar
      ?|> baseNavigationBarStyle
  }

  internal override func scrollViewDidScroll(_ scrollView: UIScrollView) {
    self.delegate?.profileBackedProjectsDidScroll(scrollView)
  }

  internal override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    self.delegate?.profileBackedProjectsDidEndDecelerating(scrollView)
  }

  internal override func scrollViewDidEndDragging(_ scrollView: UIScrollView,
                                                  willDecelerate decelerate: Bool) {
    self.delegate?.profileBackedProjectsDidEndDragging(scrollView, willDecelerate: decelerate)
  }
}
