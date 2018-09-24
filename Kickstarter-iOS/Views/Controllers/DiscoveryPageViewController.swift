import KsApi
import Library
import Prelude
import Social
import UIKit

internal final class DiscoveryPageViewController: UITableViewController {
  fileprivate var emptyStatesController: EmptyStatesViewController?
  fileprivate let dataSource = DiscoveryProjectsDataSource()
  fileprivate let loadingIndicatorView = UIActivityIndicatorView()
  private var sessionEndedObserver: Any?
  private var sessionStartedObserver: Any?
  private var currentEnvironmentChangedObserver: Any?
  fileprivate let viewModel: DiscoveryPageViewModelType = DiscoveryPageViewModel()
  fileprivate let shareViewModel: ShareViewModelType = ShareViewModel()

  internal static func configuredWith(sort: DiscoveryParams.Sort) -> DiscoveryPageViewController {
    let vc = Storyboard.DiscoveryPage.instantiate(DiscoveryPageViewController.self)
    vc.viewModel.inputs.configureWith(sort: sort)
    return vc
  }

  internal func change(filter: DiscoveryParams) {
    self.viewModel.inputs.selectedFilter(filter)
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.addSubview(self.loadingIndicatorView)

    self.tableView.dataSource = self.dataSource

    self.tableView.register(nib: Nib.DiscoveryPostcardCell)

    self.sessionStartedObserver = NotificationCenter.default
      .addObserver(forName: .ksr_sessionStarted, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.userSessionStarted()
    }

    self.sessionEndedObserver = NotificationCenter.default
      .addObserver(forName: .ksr_sessionEnded, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.userSessionEnded()
    }

    self.currentEnvironmentChangedObserver = NotificationCenter.default
      .addObserver(forName: .ksr_environmentChanged, object: nil, queue: nil, using: { [weak self] _ in
        self?.viewModel.inputs.currentEnvironmentChanged(environment:
          AppEnvironment.current.apiService.serverConfig.environment)
      })

    let emptyVC = EmptyStatesViewController.configuredWith(emptyState: nil)
    self.emptyStatesController = emptyVC
    emptyVC.delegate = self
    self.addChild(emptyVC)
    self.view.addSubview(emptyVC.view)
    NSLayoutConstraint.activate([
      emptyVC.view.topAnchor.constraint(equalTo: self.view.topAnchor),
      emptyVC.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
      emptyVC.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
      emptyVC.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
      ])
    emptyVC.didMove(toParent: self)
  }

  deinit {
    self.sessionEndedObserver.doIfSome(NotificationCenter.default.removeObserver)
    self.sessionStartedObserver.doIfSome(NotificationCenter.default.removeObserver)
    self.currentEnvironmentChangedObserver.doIfSome(NotificationCenter.default.removeObserver)
  }

  internal override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.viewModel.inputs.viewWillAppear()
  }

  internal override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    self.viewModel.inputs.viewDidAppear()
  }

  internal override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    self.viewModel.inputs.viewDidDisappear(animated: animated)
  }

  internal override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    self.loadingIndicatorView.center = self.tableView.center
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableControllerStyle(estimatedRowHeight: 200.0)

    _ = self.loadingIndicatorView
      |> baseActivityIndicatorStyle
  }

    internal override func bindViewModel() {
    super.bindViewModel()

    self.loadingIndicatorView.rac.animating = self.viewModel.outputs.projectsAreLoading

    self.viewModel.outputs.activitiesForSample
      .observeForUI()
      .observeValues { [weak self] activities in
        self?.dataSource.load(activities: activities)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.asyncReloadData
      .observeForUI()
      .observeValues { [weak self] in
        DispatchQueue.main.async {
          self?.tableView.reloadData()
        }
    }

    self.viewModel.outputs.goToActivityProject
      .observeForControllerAction()
      .observeValues { [weak self] in self?.goTo(project: $0, refTag: $1) }

    self.viewModel.outputs.goToProjectPlaylist
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.goTo(project: $0, initialPlaylist: $1, refTag: $2)
      }

    self.viewModel.outputs.goToProjectUpdate
      .observeForControllerAction()
      .observeValues { [weak self] project, update in self?.goTo(project: project, update: update) }

    self.viewModel.outputs.projectsLoaded
      .observeForUI()
      .observeValues { [weak self] projects, params in
        self?.dataSource.load(projects: projects, params: params)
        self?.tableView.reloadData()
        self?.updateProjectPlaylist(projects)
      }

    self.viewModel.outputs.showOnboarding
      .observeForUI()
      .observeValues { [weak self] in
        self?.dataSource.show(onboarding: $0)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.setScrollsToTop
      .observeForUI()
      .observeValues { [weak self] in
        _ = self?.tableView ?|> UIScrollView.lens.scrollsToTop .~ $0
    }

    self.viewModel.outputs.scrollToProjectRow
      .observeForUI()
      .observeValues { [weak self] row in
        guard let _self = self else { return }
        _self.tableView.scrollToRow(at: _self.dataSource.indexPath(forProjectRow: row),
                                    at: .top,
                                    animated: false)
    }

    self.shareViewModel.outputs.showShareSheet
      .observeForControllerAction()
      .observeValues { [weak self] in self?.showShareSheet($0, shareContextView: $1) }

    self.viewModel.outputs.showEmptyState
      .observeForUI()
      .observeValues { [weak self] emptyState in
        self?.showEmptyState(emptyState)
    }

    self.viewModel.outputs.hideEmptyState
      .observeForUI()
      .observeValues { [weak self] in
        self?.emptyStatesController?.view.alpha = 0
        self?.emptyStatesController?.view.isHidden = true

        if let discovery = self?.parent?.parent as? DiscoveryViewController {
          discovery.setSortsEnabled(true)
        }
    }
  }

  internal override func tableView(_ tableView: UITableView,
                                   willDisplay cell: UITableViewCell,
                                   forRowAt indexPath: IndexPath) {

    if let cell = cell as? DiscoveryPostcardCell {
      cell.delegate = self
    } else if let cell = cell as? ActivitySampleBackingCell, cell.delegate == nil {
      cell.delegate = self
    } else if let cell = cell as? ActivitySampleFollowCell, cell.delegate == nil {
      cell.delegate = self
    } else if let cell = cell as? ActivitySampleProjectCell, cell.delegate == nil {
      cell.delegate = self
    } else if let cell = cell as? DiscoveryOnboardingCell, cell.delegate == nil {
      cell.delegate = self
    }

    self.viewModel.inputs.willDisplayRow(self.dataSource.itemIndexAt(indexPath),
                                         outOf: self.dataSource.numberOfItems())
  }

  internal override func tableView(_ tableView: UITableView,
                                   didSelectRowAt indexPath: IndexPath) {

    if let project = self.dataSource.projectAtIndexPath(indexPath) {
      self.viewModel.inputs.tapped(project: project)
    } else if let activity = self.dataSource.activityAtIndexPath(indexPath) {
      self.viewModel.inputs.tapped(activity: activity)
    }
  }

  fileprivate func showShareSheet(_ controller: UIActivityViewController, shareContextView: UIView?) {

    controller.completionWithItemsHandler = { [weak self] activityType, completed, returnedItems, error in

      self?.shareViewModel.inputs.shareActivityCompletion(
        with: .init(activityType: activityType,
                    completed: completed,
                    returnedItems: returnedItems,
                    activityError: error)
      )
    }

    if UIDevice.current.userInterfaceIdiom == .pad {
      controller.modalPresentationStyle = .popover
      let popover = controller.popoverPresentationController
      popover?.sourceView = shareContextView
    }

    self.present(controller, animated: true, completion: nil)
  }

  fileprivate func goTo(project: Project, refTag: RefTag) {
    let vc = ProjectNavigatorViewController.configuredWith(project: project, refTag: refTag)
    self.present(vc, animated: true, completion: nil)
  }

  fileprivate func goTo(project: Project, initialPlaylist: [Project], refTag: RefTag) {
    let vc = ProjectNavigatorViewController.configuredWith(project: project,
                                                           refTag: refTag,
                                                           initialPlaylist: initialPlaylist,
                                                           navigatorDelegate: self)
    self.present(vc, animated: true, completion: nil)
  }

  fileprivate func goTo(project: Project, update: Update) {
    let vc = UpdateViewController.configuredWith(project: project, update: update, context: .activitySample)
    self.navigationController?.pushViewController(vc, animated: true)
  }

  fileprivate func showEmptyState(_ emptyState: EmptyState) {
    guard let emptyVC = self.emptyStatesController else { return }

    emptyVC.setEmptyState(emptyState)
    emptyVC.view.isHidden = false
    self.view.bringSubviewToFront(emptyVC.view)
    UIView.animate(withDuration: 0.3,
                   animations: {
      self.emptyStatesController?.view.alpha = 1.0
    }, completion: nil)
    if let discovery = self.parent?.parent as? DiscoveryViewController {
      discovery.setSortsEnabled(false)
    }
  }

  private func updateProjectPlaylist(_ playlist: [Project]) {
    guard let navigator = self.presentedViewController as? ProjectNavigatorViewController else { return }
    navigator.updatePlaylist(playlist)
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
    nav.modalPresentationStyle = .formSheet

    self.present(nav, animated: true, completion: nil)
  }
}

extension DiscoveryPageViewController: EmptyStatesViewControllerDelegate {
  func emptyStatesViewController(_ viewController: EmptyStatesViewController,
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

extension DiscoveryPageViewController: DiscoveryPostcardCellDelegate {
  internal func discoveryPostcard(cell: DiscoveryPostcardCell, tappedShare context: ShareContext,
                                  fromSourceView: UIView) {
    self.shareViewModel.inputs.configureWith(shareContext: context, shareContextView: fromSourceView)
    self.shareViewModel.inputs.shareButtonTapped()
  }

  internal func discoveryPostcardCellProjectSaveAlert() {
    let alertController = UIAlertController(
      title: Strings.Project_saved(),
      message: Strings.Well_remind_you_forty_eight_hours_before_this_project_ends(),
      preferredStyle: .alert)
    alertController.addAction(
      UIAlertAction(
        title: Strings.Got_it(),
        style: .cancel,
        handler: nil
      )
    )

    self.present(alertController, animated: true, completion: nil)
  }

  internal func discoveryPostcardCellGoToLoginTout() {
    let vc = LoginToutViewController.configuredWith(loginIntent: .starProject)
    let nav = UINavigationController(rootViewController: vc)
    nav.modalPresentationStyle = .formSheet

    self.present(nav, animated: true, completion: nil)
  }
 }

extension DiscoveryPageViewController: ProjectNavigatorDelegate {
  func transitionedToProject(at index: Int) {
    self.viewModel.inputs.transitionedToProject(at: index, outOf: self.dataSource.numberOfItems())
  }
}
