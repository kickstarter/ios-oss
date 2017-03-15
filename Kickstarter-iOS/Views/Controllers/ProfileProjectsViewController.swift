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

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.emptyStateIsVisible
      .observeForUI()
      .observeValues { [weak self] isVisible, type in
        self?.dataSource.emptyState(visible: isVisible, type: type)
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
