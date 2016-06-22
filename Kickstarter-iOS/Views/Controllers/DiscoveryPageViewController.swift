import KsApi
import Library
import UIKit

internal final class DiscoveryPageViewController: UITableViewController {
  private let viewModel: DiscoveryPageViewModelType = DiscoveryPageViewModel()
  private let dataSource = DiscoveryProjectsDataSource()

  internal func configureWith(sort sort: DiscoveryParams.Sort) {
    self.viewModel.inputs.configureWith(sort: sort)
  }

  internal func change(filter filter: DiscoveryParams) {
    self.viewModel.inputs.selectedFilter(filter)
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.estimatedRowHeight = 400.0
    self.tableView.rowHeight = UITableViewAutomaticDimension
    self.tableView.dataSource = self.dataSource

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.viewModel.inputs.viewWillAppear()
  }

  internal override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    self.viewModel.inputs.viewDidAppear()
  }

  override func viewDidDisappear(animated: Bool) {
    super.viewDidDisappear(animated)
    self.viewModel.inputs.viewDidDisappear()
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.projects
      .observeForUI()
      .observeNext { [weak self] projects in
        self?.dataSource.load(projects: projects)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.goToProject
      .observeForUI()
      .observeNext { [weak self] in self?.goTo(project: $0, refTag: $1) }

    self.viewModel.outputs.showOnboarding
      .observeForUI()
      .observeNext { [weak self] in
        self?.dataSource.show(onboarding: $0)
        self?.tableView.reloadData()
    }
  }

  internal override func tableView(tableView: UITableView,
                                   willDisplayCell cell: UITableViewCell,
                                   forRowAtIndexPath indexPath: NSIndexPath) {

    if let cell = cell as? DiscoveryOnboardingCell where cell.delegate == nil {
      cell.delegate = self
    }

    self.viewModel.inputs.willDisplayRow(self.dataSource.itemIndexAt(indexPath),
                                         outOf: self.dataSource.numberOfItems())
  }

  internal override func tableView(tableView: UITableView,
                                   didSelectRowAtIndexPath indexPath: NSIndexPath) {

    if let project = self.dataSource.projectAtIndexPath(indexPath) {
      self.viewModel.inputs.tapped(project: project)
    }
  }

  private func goTo(project project: Project, refTag: RefTag) {
    guard let projectViewController = UIStoryboard(name: "Project", bundle: nil)
      .instantiateInitialViewController() as? ProjectViewController else {
        fatalError("Couldn't instantiate project view controller.")
    }

    projectViewController.configureWith(project: project, refTag: refTag)
    let nav = UINavigationController(rootViewController: projectViewController)
    self.presentViewController(nav, animated: true, completion: nil)
  }
}

extension DiscoveryPageViewController: DiscoveryOnboardingCellDelegate {
  internal func discoveryOnboardingTappedSignUpLoginButton() {
    let storyboard = UIStoryboard(name: "Login", bundle: nil)

    guard let nav = storyboard.instantiateInitialViewController() as? UINavigationController,
      loginTout = nav.viewControllers.first as? LoginToutViewController else {
      fatalError("Could not instantiate initial controller from Login storyboard.")
    }

    loginTout.configureWith(loginIntent: .discoveryOnboarding)
    self.presentViewController(nav, animated: true, completion: nil)
  }
}
