import Library
import UIKit
import Models

internal final class ProjectViewController: UITableViewController {
  private let viewModel: ProjectViewModelType = ProjectViewModel()
  private let dataSource = ProjectDataSource()

  internal func configureWith(project project: Project, refTag: RefTag?) {
    self.viewModel.inputs.project(project)
    self.viewModel.inputs.refTag(refTag)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.dataSource = dataSource
    self.tableView.backgroundColor = Color.OffWhite.toUIColor()

    self.navigationItem.rightBarButtonItem = .close(self, selector: #selector(closeButtonPressed))
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.viewModel.inputs.viewWillAppear()
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.project
      .observeForUI()
      .observeNext { [dataSource, weak tableView] project in
        dataSource.loadProject(project)
        tableView?.reloadData()
    }
  }

  override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 32.0
  }

  override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    let view = UIView()
    view.backgroundColor = .clearColor()
    return view
  }

  override func tableView(tableView: UITableView,
                          estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return UITableViewAutomaticDimension
  }

  internal func closeButtonPressed() {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
}
