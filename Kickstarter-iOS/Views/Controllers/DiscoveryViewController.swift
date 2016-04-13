import UIKit
import Library
import Foundation

internal final class DiscoveryViewController: MVVMTableViewController {
  let viewModel: DiscoveryViewModelType = DiscoveryViewModel()
  let dataSource = DiscoveryProjectsDataSource()

  override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.dataSource = dataSource
    self.viewModel.inputs.viewDidLoad()
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.projects
      .observeForUI()
      .observeNext { [weak self] projects in
        self?.dataSource.loadData(projects)
        self?.tableView.reloadData()
    }
  }

  override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 32.0
  }

  override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let view = UIView()
    view.backgroundColor = .clearColor()
    return view
  }

  override func tableView(tableView: UITableView,
                          estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return UITableViewAutomaticDimension
  }

  override func tableView(tableView: UITableView,
                          willDisplayCell cell: UITableViewCell,
                          forRowAtIndexPath indexPath: NSIndexPath) {

    let (row, total) = rowAndTotal(tableView: tableView, indexPath: indexPath)
    self.viewModel.inputs.willDisplayRow(row, outOf: total)
  }
}

/**
 Returns the linear row index of an index path in a table view, and the total number of rows in the
 table view.

 - parameter tableView: A table view.
 - parameter indexPath: An index path.

 - returns: The row and total.
 */
private func rowAndTotal(tableView tableView: UITableView, indexPath: NSIndexPath) -> (row: Int, total: Int) {

  let sections = (0..<tableView.numberOfSections).lazy

  let total = sections
    .map(UITableView.numberOfRowsInSection(tableView))
    .reduce(0, combine: +)

  let row = sections[0..<indexPath.section]
    .map(UITableView.numberOfRowsInSection(tableView))
    .reduce(indexPath.row, combine: +)

  return (row, total)
}
