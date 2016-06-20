import KsApi
import Library
import UIKit
import Prelude
import Prelude_UIKit

internal final class DashboardViewController: UITableViewController {
  let dataSource = DashboardDataSource()
  let viewModel: DashboardViewModelType = DashboardViewModel()

  internal override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.estimatedRowHeight = 200.0
    self.tableView.rowHeight = UITableViewAutomaticDimension
    self.tableView.dataSource = self.dataSource

    self.view.backgroundColor = Color.OffWhite.toUIColor()

    self.viewModel.inputs.viewDidLoad()
  }

  override func bindStyles() {
    self |> baseTableControllerStyle(estimatedRowHeight: 200.0)
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.goToProject
      .observeForUI()
      .observeNext { [weak self] project, refTag in
        self?.goToProject(project, refTag: refTag)
    }

    self.viewModel.outputs.project
      .observeForUI()
      .observeNext { [weak self] project in
        self?.dataSource.load(project: project)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.projects
      .observeForUI()
      .observeNext { [weak self] projects in
        self?.tableView.reloadData()
    }
  }

  internal override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    guard let project = self.dataSource[indexPath] as? Project else {
      return
    }

    if self.dataSource.didSelectContext(at: indexPath) {
      self.viewModel.inputs.projectContextTapped(project)
    }
  }

  internal override func tableView(tableView: UITableView,
                                   willDisplayCell cell: UITableViewCell,
                                   forRowAtIndexPath indexPath: NSIndexPath) {
    if let cell = cell as? DashboardActionCell {
      cell.delegate = self
    }
  }

  private func goToActivity(project: Project) {
    print("Not implemented yet!")
  }

  private func goToMessages(project: Project) {
    guard let vc = UIStoryboard(name: "Messages", bundle: nil).instantiateInitialViewController(),
      messages = vc as? MessageThreadsViewController else {
        fatalError("Could not instantiate MessageThreadsViewController.")
    }

    messages.configureWith(project: project)
    self.navigationController?.pushViewController(messages, animated: true)
  }

  private func goToPostUpdate(project: Project) {
    print("Not implemented yet!")
  }

  private func goToProject(project: Project, refTag: RefTag) {
    guard let vc = UIStoryboard(name: "Project", bundle: nil).instantiateInitialViewController()
      as? ProjectViewController else {
        fatalError("Could not instantiate ProjectViewController.")
    }

    vc.configureWith(project: project, refTag: refTag)
    self.presentViewController(UINavigationController(rootViewController: vc),
                               animated: true,
                               completion: nil)
  }

  private func showShareSheet(project: Project) {
    let activityVC = UIActivityViewController.shareProject(
      project: project,
      completionHandler: { activityType, shouldShowPasteboardAlert, completed in
        if shouldShowPasteboardAlert {
          let alert = UIAlertController.projectCopiedToPasteboard(projectURL: project.urls.web.project)
          self.presentViewController(alert, animated: true, completion: nil)
        }
    })

    if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
      activityVC.modalPresentationStyle = .Popover
      self.presentViewController(activityVC, animated: true, completion: nil)
    } else {
      self.presentViewController(activityVC, animated: true, completion: nil)
    }
  }
}

extension DashboardViewController: DashboardActionCellDelegate {
  internal func goToActivity(cell: DashboardActionCell?, project: Project) {
    self.goToActivity(project)
  }

  internal func goToMessages(cell: DashboardActionCell?, project: Project) {
    self.goToMessages(project)
  }

  internal func goToPostUpdate(cell: DashboardActionCell?, project: Project) {
    self.goToPostUpdate(project)
  }

  internal func showShareSheet(cell: DashboardActionCell?, project: Project) {
    self.showShareSheet(project)
  }
}
