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

    self.tableView.estimatedRowHeight = 300.0
    self.tableView.rowHeight = UITableViewAutomaticDimension
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

    self.viewModel.outputs.openComments
      .observeForUI()
      .observeNext { [weak self] project in
        self?.openComments(forProject: project)
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

  private func openComments(forProject project: Project) {
    guard let commentsViewController = UIStoryboard(name: "Comments", bundle: nil)
      .instantiateInitialViewController() as? CommentsViewController else {
        fatalError("Could not instantiate CommentsViewController.")
    }

    commentsViewController.configureWith(project: project)
    self.navigationController?.pushViewController(commentsViewController, animated: true)
  }

  internal func closeButtonPressed() {
    self.dismissViewControllerAnimated(true, completion: nil)
  }

  @IBAction func commentsButtonPressed() {
    self.viewModel.inputs.commentsButtonPressed()
  }
}
