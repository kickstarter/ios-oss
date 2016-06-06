import UIKit
import Library
import KsApi

internal final class SearchViewController: UITableViewController {
  private let viewModel: SearchViewModelType = SearchViewModel()
  private let dataSource = SearchDataSource()

  @IBOutlet internal weak var searchTextField: UITextField!

  override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.estimatedRowHeight = 160.0
    self.tableView.rowHeight = UITableViewAutomaticDimension
    self.tableView.dataSource = self.dataSource

    self.searchTextField.becomeFirstResponder()
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    self.viewModel.inputs.viewDidAppear()
  }

  override func bindViewModel() {

    self.viewModel.outputs.projects
      .observeForUI()
      .observeNext { [weak self] projects in
        self?.dataSource.load(projects: projects)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.isPopularTitleVisible
      .observeForUI()
      .observeNext { [weak self] visible in
        self?.dataSource.popularTitle(isVisible: visible)
        self?.tableView.reloadData()
    }
  }

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    guard let project = self.dataSource[indexPath] as? Project else {
      return
    }
    guard let projectVC = UIStoryboard(name: "Project", bundle: nil)
      .instantiateInitialViewController() as? ProjectViewController else {
        return
    }

    projectVC.configureWith(project: project, refTag: RefTag.search)
    self.presentViewController(UINavigationController(rootViewController: projectVC),
                               animated: true,
                               completion: nil)
  }

  @IBAction internal func searchTextChanged(textField: UITextField) {
    self.viewModel.inputs.searchTextChanged(textField.text ?? "")
  }

  @IBAction internal func cancelButtonPressed() {
    guard let root = self.tabBarController as? RootTabBarViewController else {
      return
    }
    root.switchToDiscovery()
  }
}
