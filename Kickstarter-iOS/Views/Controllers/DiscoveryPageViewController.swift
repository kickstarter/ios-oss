import KsApi
import Library
import UIKit

internal final class DiscoveryPageViewController: UITableViewController {
  private let viewModel: DiscoveryPageViewModelType = DiscoveryPageViewModel()
  private let dataSource = DiscoveryProjectsDataSource()

  internal static func configuredWith(sort sort: DiscoveryParams.Sort) -> DiscoveryPageViewController {
    let vc = Storyboard.Discovery.instantiate(DiscoveryPageViewController)
    vc.viewModel.inputs.configureWith(sort: sort)
    return vc
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
    self.viewModel.inputs.viewDidDisappear(animated: animated)
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.activitiesForSample
      .observeForUI()
      .observeNext { [weak self] activities in
        self?.dataSource.load(activities: activities)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.projects
      .observeForUI()
      .observeNext { [weak self] projects in
        self?.dataSource.load(projects: projects)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.goToProject
      .observeForUI()
      .observeNext { [weak self] in
        self?.goTo(project: $0, refTag: $1)
    }

    self.viewModel.outputs.goToProjectUpdate
      .observeForUI()
      .observeNext { [weak self] project, update in
        self?.goTo(project: project, update: update)
    }

    self.viewModel.outputs.showOnboarding
      .observeForUI()
      .observeNext { [weak self] in
        self?.dataSource.show(onboarding: $0)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.focusScreenReaderOnFirstProject
      .observeForUI()
      .observeNext { [weak self] in
        self?.accessibilityFocusOnFirstProject()
    }
  }

  internal override func tableView(tableView: UITableView,
                                   willDisplayCell cell: UITableViewCell,
                                   forRowAtIndexPath indexPath: NSIndexPath) {

    if let cell = cell as? ActivitySampleBackingCell where cell.delegate == nil {
      cell.delegate = self
    } else if let cell = cell as? ActivitySampleFollowCell where cell.delegate == nil {
      cell.delegate = self
    } else if let cell = cell as? ActivitySampleProjectCell where cell.delegate == nil {
      cell.delegate = self
    } else if let cell = cell as? DiscoveryOnboardingCell where cell.delegate == nil {
      cell.delegate = self
    }

    self.viewModel.inputs.willDisplayRow(self.dataSource.itemIndexAt(indexPath),
                                         outOf: self.dataSource.numberOfItems())
  }

  internal override func tableView(tableView: UITableView,
                                   didSelectRowAtIndexPath indexPath: NSIndexPath) {

    if let project = self.dataSource.projectAtIndexPath(indexPath) {
      self.viewModel.inputs.tapped(project: project)
    } else if let activity = self.dataSource.activityAtIndexPath(indexPath) {
      self.viewModel.inputs.tapped(activity: activity)
    }
  }

  private func goTo(project project: Project, refTag: RefTag) {
    let vc = UIStoryboard(name: "ProjectMagazine", bundle: .framework)
      .instantiateViewControllerWithIdentifier("ProjectMagazineViewController")
    guard let projectViewController = vc as? ProjectMagazineViewController else {
      fatalError("Couldn't instantiate project view controller.")
    }

    projectViewController.configureWith(project: project, refTag: refTag)
    let nav = UINavigationController(rootViewController: projectViewController)
    self.presentViewController(nav, animated: true, completion: nil)
  }

  private func goTo(project project: Project, update: Update) {
    guard let updateVC = UIStoryboard(name: "Update", bundle: .framework)
      .instantiateViewControllerWithIdentifier("UpdateViewController") as? UpdateViewController else {
        fatalError("Couldn't instantiate update view controller.")
    }

    updateVC.configureWith(project: project, update: update)
    self.navigationController?.pushViewController(updateVC, animated: true)
  }

  private func accessibilityFocusOnFirstProject() {

    let cell = self.tableView.visibleCells.filter { $0 is DiscoveryProjectCell }.first
    if let cell = cell {
      UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, cell)
    }
  }
}

extension DiscoveryPageViewController: ActivitySampleBackingCellDelegate, ActivitySampleFollowCellDelegate,
  ActivitySampleProjectCellDelegate {
  internal func goToActivity() {
    guard let root = self.tabBarController as? RootTabBarViewController else {
      return
    }
    root.switchToActivities()
  }
}

extension DiscoveryPageViewController: DiscoveryOnboardingCellDelegate {
  internal func discoveryOnboardingTappedSignUpLoginButton() {
    let storyboard = UIStoryboard(name: "Login", bundle: .framework)

    guard let nav = storyboard.instantiateInitialViewController() as? UINavigationController,
      loginTout = nav.viewControllers.first as? LoginToutViewController else {
      fatalError("Could not instantiate initial controller from Login storyboard.")
    }

    loginTout.configureWith(loginIntent: .discoveryOnboarding)
    self.presentViewController(nav, animated: true, completion: nil)
  }
}
