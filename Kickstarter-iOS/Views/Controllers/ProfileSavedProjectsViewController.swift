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

  //  fileprivate let viewModel: ProfileSavedProjectsViewModelType = ProfileSavedProjectsViewModel()
  //  fileprivate let dataSource = ProfileSavedProjectsDataSource()

  internal weak var delegate: ProfileSavedProjectsViewControllerDelegate?

  //  internal static func configureWith(sort: BackedSort) {
  //  }

  override func viewDidLoad() {
    super.viewDidLoad()

    //self.tableView.estimatedRowHeight = 100.0
    self.tableView.rowHeight = UITableViewAutomaticDimension
    //self.tableView.dataSource = dataSource

    //self.viewModel.inputs.viewDidLoad()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }

  override func bindViewModel() {
    super.bindViewModel()
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableControllerStyle()
      |> UIViewController.lens.title %~ { _ in Strings.Follow_friends() }

    _ = self.navigationController?.navigationBar
      ?|> baseNavigationBarStyle
  }

  override internal func tableView(_ tableView: UITableView,
                                   willDisplay cell: UITableViewCell,
                                   forRowAt indexPath: IndexPath) {
  }

  /// placeholder
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 20
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell()
    cell.textLabel?.text = "Saved project #\(indexPath.row)"
    return cell
  }

  override internal func scrollViewDidScroll(_ scrollView: UIScrollView) {
    self.delegate?.profileSavedProjectsDidScroll(scrollView)
  }

  override internal func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    self.delegate?.profileSavedProjectsDidEndDecelerating(scrollView)
  }

  override internal func scrollViewDidEndDragging(_ scrollView: UIScrollView,
                                                  willDecelerate decelerate: Bool) {
    self.delegate?.profileSavedProjectsDidEndDragging(scrollView, willDecelerate: decelerate)
  }
}
