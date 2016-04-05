import class UIKit.UITableView
import class UIKit.UIView
import class UIKit.NSIndexPath
import struct UIKit.CGFloat
import struct UIKit.CGRect
import struct UIKit.UIEdgeInsets
import var UIKit.UITableViewAutomaticDimension
import class Library.MVVMTableViewController
import struct Library.Environment
import struct Library.AppEnvironment
import Foundation

internal final class DiscoveryViewController: MVVMTableViewController {
  let viewModel: DiscoveryViewModelType = DiscoveryViewModel()
  let dataSource = DiscoveryProjectsDataSource()

  override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.dataSource = dataSource
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.projects
      .observeForUI()
      .startWithNext { [weak self] projects in
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

  override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return UITableViewAutomaticDimension
  }
}
