import KsApi
import Library
import Prelude
import UIKit

internal final class DiscoveryPageViewController: UITableViewController {
  private var emptyStatesController: EmptyStatesViewController?
  private let dataSource = DiscoveryProjectsDataSource()
  private let loadingIndicatorView = UIActivityIndicatorView()

  private let viewModel: DiscoveryPageViewModelType = DiscoveryPageViewModel()

  internal static func configuredWith(sort sort: DiscoveryParams.Sort) -> DiscoveryPageViewController {
    let vc = Storyboard.DiscoveryPage.instantiate(DiscoveryPageViewController)
    vc.viewModel.inputs.configureWith(sort: sort)
    return vc
  }

  internal func change(filter filter: DiscoveryParams) {
    self.viewModel.inputs.selectedFilter(filter)
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.addSubview(self.loadingIndicatorView)

    self.tableView.dataSource = self.dataSource

    NSNotificationCenter.defaultCenter()
      .addObserverForName(CurrentUserNotifications.sessionStarted, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.userSessionStarted()
    }

    NSNotificationCenter.defaultCenter()
      .addObserverForName(CurrentUserNotifications.sessionEnded, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.userSessionEnded()
    }

    let emptyVC = EmptyStatesViewController.configuredWith(emptyState: nil)
    self.emptyStatesController = emptyVC
    emptyVC.delegate = self
    self.addChildViewController(emptyVC)
    self.view.addSubview(emptyVC.view)
    NSLayoutConstraint.activateConstraints([
      emptyVC.view.topAnchor.constraintEqualToAnchor(self.view.topAnchor),
      emptyVC.view.leadingAnchor.constraintEqualToAnchor(self.view.leadingAnchor),
      emptyVC.view.bottomAnchor.constraintEqualToAnchor(self.view.bottomAnchor),
      emptyVC.view.trailingAnchor.constraintEqualToAnchor(self.view.trailingAnchor),
      ])
    emptyVC.didMoveToParentViewController(self)
  }

  internal override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    self.viewModel.inputs.viewWillAppear()
  }

  internal override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)

    self.viewModel.inputs.viewDidAppear()
  }

  internal override func viewDidDisappear(animated: Bool) {
    super.viewDidDisappear(animated)

    self.viewModel.inputs.viewDidDisappear(animated: animated)
  }

  internal override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    self.loadingIndicatorView.center = self.tableView.center
  }

  internal override func bindStyles() {
    super.bindStyles()

    self
      |> baseTableControllerStyle(estimatedRowHeight: 200.0)

    self.loadingIndicatorView
      |> UIActivityIndicatorView.lens.hidesWhenStopped .~ true
      |> UIActivityIndicatorView.lens.activityIndicatorViewStyle .~ .White
      |> UIActivityIndicatorView.lens.color .~ .ksr_navy_900
  }

  // swiftlint:disable function_body_length
  internal override func bindViewModel() {
    super.bindViewModel()

    self.loadingIndicatorView.rac.animating = self.viewModel.outputs.projectsAreLoading

    self.viewModel.outputs.activitiesForSample
      .observeForUI()
      .observeNext { [weak self] activities in
        self?.dataSource.load(activities: activities)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.asyncReloadData
      .observeForUI()
      .observeNext { [weak self] in
        dispatch_async(dispatch_get_main_queue()) {
          self?.tableView.reloadData()
        }
    }

    self.viewModel.outputs.goToActivityProject
      .observeForControllerAction()
      .observeNext { [weak self] in self?.goTo(project: $0, refTag: $1) }

    self.viewModel.outputs.goToProjectPlaylist
      .observeForControllerAction()
      .observeNext { [weak self] in self?.goTo(project: $0, initialPlaylist: $1, refTag: $2) }

    self.viewModel.outputs.goToProjectUpdate
      .observeForControllerAction()
      .observeNext { [weak self] project, update in self?.goTo(project: project, update: update) }

    self.viewModel.outputs.projects
      .observeForUI()
      .observeNext { [weak self] projects in
        self?.dataSource.load(projects: projects)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.showOnboarding
      .observeForUI()
      .observeNext { [weak self] in
        self?.dataSource.show(onboarding: $0)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.setScrollsToTop
      .observeForUI()
      .observeNext { [weak self] in
        self?.tableView ?|> UIScrollView.lens.scrollsToTop .~ $0
    }

    self.viewModel.outputs.showEmptyState
      .observeForUI()
      .observeNext { [weak self] emptyState in
        self?.showEmptyState(emptyState)
    }

    self.viewModel.outputs.hideEmptyState
      .observeForUI()
      .observeNext { [weak self] in
        self?.emptyStatesController?.view.alpha = 0
        self?.emptyStatesController?.view.hidden = true

        if let discovery = self?.parentViewController?.parentViewController as? DiscoveryViewController {
          discovery.setSortsEnabled(true)
        }
    }
  }
  // swiftlint:enable function_body_length

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
    let vc = ProjectNavigatorViewController.configuredWith(project: project, refTag: refTag)
    self.presentViewController(vc, animated: true, completion: nil)
  }

  private func goTo(project project: Project, initialPlaylist: [Project], refTag: RefTag) {
    let vc = ProjectNavigatorViewController.configuredWith(project: project,
                                                           refTag: refTag,
                                                           initialPlaylist: initialPlaylist,
                                                           navigatorDelegate: self)
    self.presentViewController(vc, animated: true, completion: nil)
  }

  private func goTo(project project: Project, update: Update) {
    let vc = UpdateViewController.configuredWith(project: project, update: update)
    self.navigationController?.pushViewController(vc, animated: true)
  }

  private func showEmptyState(emptyState: EmptyState) {
    guard let emptyVC = self.emptyStatesController else { return }

    emptyVC.setEmptyState(emptyState)
    emptyVC.view.hidden = false
    self.view.bringSubviewToFront(emptyVC.view)
    UIView.animateWithDuration(0.3) {
      self.emptyStatesController?.view.alpha = 1.0
    }

    if let discovery = self.parentViewController?.parentViewController as? DiscoveryViewController {
      discovery.setSortsEnabled(false)
    }
  }
}

extension DiscoveryPageViewController: ActivitySampleBackingCellDelegate, ActivitySampleFollowCellDelegate,
  ActivitySampleProjectCellDelegate {
  internal func goToActivity() {
    guard let root = self.tabBarController as? RootTabBarViewController else { return }
    root.switchToActivities()
  }
}

extension DiscoveryPageViewController: DiscoveryOnboardingCellDelegate {
  internal func discoveryOnboardingTappedSignUpLoginButton() {
    let loginTout = LoginToutViewController.configuredWith(loginIntent: .discoveryOnboarding)
    let nav = UINavigationController(rootViewController: loginTout)
    nav.modalPresentationStyle = .FormSheet

    self.presentViewController(nav, animated: true, completion: nil)
  }
}

extension DiscoveryPageViewController: EmptyStatesViewControllerDelegate {
  func emptyStatesViewController(viewController: EmptyStatesViewController,
                                 goToDiscoveryWithParams params: DiscoveryParams?) {

    self.view.window?.rootViewController
      .flatMap { $0 as? RootTabBarViewController }
      .doIfSome { $0.switchToDiscovery(params: params) }
  }

  func emptyStatesViewControllerGoToFriends() {
    let vc = FindFriendsViewController.configuredWith(source: .discovery)
    self.navigationController?.pushViewController(vc, animated: true)
  }
}

extension DiscoveryPageViewController: ProjectNavigatorDelegate {
}
