import class Library.MVVMTableViewController
import class UIKit.UICollectionViewFlowLayout
import struct UIKit.CGSize
import struct UIKit.CGFloat
import class UIKit.UITableView
import class UIKit.UIView
import class UIKit.NSIndexPath
import var UIKit.UITableViewAutomaticDimension

internal final class ProjectViewController: MVVMTableViewController {
  private let dataSource = ProjectDataSource()

  override func viewDidLoad() {
    super.viewDidLoad()

    dataSource.loadData()
    self.tableView.dataSource = dataSource
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
}
