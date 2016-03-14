import class Library.MVVMTableViewController
import var UIKit.UITableViewAutomaticDimension
import class UIKit.NSIndexPath
import class UIKit.UITableView
import UIKit

internal final class ActivitiesViewController: MVVMTableViewController {
  let viewModel: ActivitiesViewModelType = ActivitiesViewModel()
  let dataSource = ActivitiesDataSource()

  override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.dataSource = dataSource
  }

  internal override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.viewModel.inputs.viewWillAppear()
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.activities
      .observeForUI()
      .startWithNext { [weak self] activities in
        self?.dataSource.loadData(activities)
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

  override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return UITableViewAutomaticDimension
  }
}
