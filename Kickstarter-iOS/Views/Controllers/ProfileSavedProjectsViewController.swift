import KsApi
import Library
import Prelude
import UIKit

internal protocol ProfileSavedProjectsViewControllerDelegate: class {
  func profileSavedProjectsDidEndDecelerating(_ scrollView: UIScrollView)
  func profileSavedProjectsDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
  func profileSavedProjectsDidScroll(_ scrollView: UIScrollView)
}

internal final class ProfileSavedProjectsViewController: UITableViewController {

  private let viewModel: ProfileProjectsViewModelType = ProfileProjectsViewModel()
  private let dataSource = ProfileSavedProjectsDataSource()

  internal weak var delegate: ProfileSavedProjectsViewControllerDelegate?

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
        self?.dataSource.emptyState(visible: isVisible, message: message, showIcon: true)
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
    self.delegate?.profileSavedProjectsDidScroll(scrollView)
  }

  internal override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    self.delegate?.profileSavedProjectsDidEndDecelerating(scrollView)
  }

  internal override func scrollViewDidEndDragging(_ scrollView: UIScrollView,
                                                  willDecelerate decelerate: Bool) {
    self.delegate?.profileSavedProjectsDidEndDragging(scrollView, willDecelerate: decelerate)
  }
}
