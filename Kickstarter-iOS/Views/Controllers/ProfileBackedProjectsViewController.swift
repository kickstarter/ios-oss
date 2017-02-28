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

//  fileprivate let viewModel: ProfileBackedProjectsViewModelType = ProfileBackedProjectsViewModel()
//  fileprivate let dataSource = ProfileBackedProjectsDataSource()

  internal weak var delegate: ProfileBackedProjectsViewControllerDelegate?

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

  override internal func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell,
                          forRowAt indexPath: IndexPath) {

//    if let statsCell = cell as? FindFriendsStatsCell, statsCell.delegate == nil {
//      statsCell.delegate = self
//    } else if let fbConnectCell = cell as? FindFriendsFacebookConnectCell, fbConnectCell.delegate == nil {
//      fbConnectCell.delegate = self
//    }
//
//    self.viewModel.inputs.willDisplayRow(self.dataSource.itemIndexAt(indexPath),
//                                         outOf: self.dataSource.numberOfItems())
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
    cell.textLabel!.text = "Backed project #\(indexPath.row)"
    return cell
  }
  ///

  override internal func scrollViewDidScroll(_ scrollView: UIScrollView) {
    self.delegate?.profileBackedProjectsDidScroll(scrollView)
  }

  override internal func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    self.delegate?.profileBackedProjectsDidEndDecelerating(scrollView)
  }

  override internal func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    self.delegate?.profileBackedProjectsDidEndDragging(scrollView, willDecelerate: decelerate)
  }
}
