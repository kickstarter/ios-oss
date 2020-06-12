import KsApi
import Library
import Prelude
import UIKit

protocol DiscoveryPageViewControllerDelegate: AnyObject {
  func discoverPageViewController(
    _ viewController: DiscoveryPageViewController,
    contentOffsetDidChangeTo offset: CGPoint
  )
}

internal final class DiscoveryPageViewController: UITableViewController {
  fileprivate let viewModel: DiscoveryPageViewModelType = DiscoveryPageViewModel()
  fileprivate let shareViewModel: ShareViewModelType = ShareViewModel()

  // MARK: - Properties

  private var configUpdatedObserver: Any?
  private var currentEnvironmentChangedObserver: Any?
  fileprivate let dataSource = DiscoveryProjectsDataSource()
  public weak var delegate: DiscoveryPageViewControllerDelegate?
  fileprivate var emptyStatesController: EmptyStatesViewController?
  private lazy var headerLabel = { UILabel(frame: .zero) }()
  private var onboardingCompletedObserver: Any?
  private var sessionEndedObserver: Any?
  private var sessionStartedObserver: Any?

  internal static func configuredWith(sort: DiscoveryParams.Sort) -> DiscoveryPageViewController {
    let vc = Storyboard.DiscoveryPage.instantiate(DiscoveryPageViewController.self)
    vc.viewModel.inputs.configureWith(sort: sort)
    return vc
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.register(nib: Nib.DiscoveryPostcardCell)
    self.tableView.registerCellClass(DiscoveryEditorialCell.self)
    self.tableView.registerCellClass(PersonalizationCell.self)
    self.tableView.registerCellClass(DiscoveryProjectCardCell.self)

    self.tableView.dataSource = self.dataSource

    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(
      self,
      action: #selector(self.pulledToRefresh),
      for: .valueChanged
    )
    self.refreshControl = refreshControl

    self.onboardingCompletedObserver = NotificationCenter.default
      .addObserver(forName: .ksr_onboardingCompleted, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.onboardingCompleted()
      }

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
        self?.viewModel.inputs.currentEnvironmentChanged(
          environment:
          AppEnvironment.current.apiService.serverConfig.environment
        )
      })

    self.configUpdatedObserver = NotificationCenter.default
      .addObserver(forName: .ksr_configUpdated, object: nil, queue: nil, using: { [weak self] _ in
        self?.viewModel.inputs.configUpdated(config: AppEnvironment.current.config)
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
      emptyVC.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
    ])
    emptyVC.didMove(toParent: self)
  }

  deinit {
    [
      self.sessionEndedObserver,
      self.sessionStartedObserver,
      self.currentEnvironmentChangedObserver,
      self.configUpdatedObserver,
      self.onboardingCompletedObserver
    ].forEach { $0.doIfSome(NotificationCenter.default.removeObserver) }
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

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    self.tableView.ksr_sizeHeaderFooterViewsToFit()
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self.tableView
      |> \.rowHeight .~ UITableView.automaticDimension
      |> \.estimatedRowHeight .~ 200.0

    _ = self.view
      |> \.backgroundColor .~ (
        // Update the background if it is not currently clear (contained in EditorialProjectsViewController)
        self.view.backgroundColor != .clear ? discoveryPageBackgroundColor() : self.view.backgroundColor
      )

    _ = self.headerLabel
      |> headerLabelStyle
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.projectsAreLoadingAnimated
      .observeForUI()
      .observeValues { [weak self] isLoading, animated in
        DispatchQueue.main.async {
          if isLoading {
            UIView.perform(animated: true) {
              self?.refreshControl?.beginRefreshing()
            }
          } else {
            UIView.perform(animated: animated) {
              self?.refreshControl?.endRefreshing()
            }
          }
        }
      }

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
      .observeValues { [weak self] projects, params, variant in
        self?.dataSource.load(projects: projects, params: params, projectCardVariant: variant)
        self?.tableView.reloadData()
        self?.updateProjectPlaylist(projects)
      }

    self.viewModel.outputs.showOnboarding
      .observeForUI()
      .observeValues { [weak self] in
        self?.dataSource.show(onboarding: $0)
        self?.tableView.reloadData()
      }

    self.viewModel.outputs.showEditorialHeader
      .observeForUI()
      .observeValues { [weak self] value in
        self?.dataSource.showEditorial(value: value)

        self?.tableView.reloadData()
      }

    self.viewModel.outputs.showPersonalization
      .observeForUI()
      .observeValues { [weak self] shouldShow in
        self?.dataSource.showPersonalization(shouldShow)

        self?.tableView.reloadData()
      }

    self.viewModel.outputs.dismissPersonalizationCell
      .observeForUI()
      .observeValues { [weak self] _ in
        self?.dataSource.showPersonalization(false)

        let section = DiscoveryProjectsDataSource.Section.personalization.rawValue
        self?.tableView.beginUpdates()
        self?.tableView.deleteRows(at: [IndexPath(row: 0, section: section)], with: .automatic)
        self?.tableView.endUpdates()
      }

    self.viewModel.outputs.goToCuratedProjects
      .observeForUI()
      .observeValues { [weak self] categories in
        let curatedProjectsVC = CuratedProjectsViewController.instantiate()
        curatedProjectsVC.configure(with: categories, context: .discovery)

        let isIpad = AppEnvironment.current.device.userInterfaceIdiom == .pad

        let navController = NavigationController(rootViewController: curatedProjectsVC)
          |> \.modalPresentationStyle .~ (isIpad ? .formSheet : .fullScreen)

        self?.present(navController, animated: true)
      }

    self.viewModel.outputs.setScrollsToTop
      .observeForUI()
      .observeValues { [weak self] in
        _ = self?.tableView ?|> UIScrollView.lens.scrollsToTop .~ $0
      }

    self.viewModel.outputs.scrollToProjectRow
      .observeForUI()
      .observeValues { [weak self] row in
        guard let self = self else { return }
        self.tableView.scrollToRow(
          at: self.dataSource.indexPath(forProjectRow: row),
          at: .top,
          animated: false
        )
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

    self.viewModel.outputs.goToEditorialProjectList
      .observeForControllerAction()
      .observeValues { [weak self] tagId in
        self?.goToEditorialProjectList(using: tagId)
      }

    self.viewModel.outputs.notifyDelegateContentOffsetChanged
      .observeForUI()
      .observeValues { [weak self] offset in
        guard let self = self else { return }

        self.delegate?.discoverPageViewController(self, contentOffsetDidChangeTo: offset)
      }

    self.viewModel.outputs.goToLoginSignup
      .observeForControllerAction()
      .observeValues { [weak self] intent in
        let loginTout = LoginToutViewController.configuredWith(loginIntent: intent)

        let isIpad = AppEnvironment.current.device.userInterfaceIdiom == .pad
        let nav = UINavigationController(rootViewController: loginTout)
          |> \.modalPresentationStyle .~ (isIpad ? .formSheet : .fullScreen)

        self?.present(nav, animated: true, completion: nil)
      }

    self.viewModel.outputs.contentInset
      .observeForUI()
      .observeValues { [weak self] inset in
        guard let self = self else { return }

        _ = self.tableView
          |> \.contentInset .~ inset
      }
  }

  internal override func tableView(
    _: UITableView,
    willDisplay cell: UITableViewCell,
    forRowAt indexPath: IndexPath
  ) {
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
    } else if let cell = cell as? DiscoveryEditorialCell {
      cell.delegate = self
    } else if let cell = cell as? PersonalizationCell {
      cell.delegate = self
    } else if let cell = cell as? DiscoveryProjectCardCell {
      cell.delegate = self
    }

    self.viewModel.inputs.willDisplayRow(
      self.dataSource.itemIndexAt(indexPath),
      outOf: self.dataSource.numberOfItems()
    )
  }

  internal override func tableView(
    _: UITableView,
    didSelectRowAt indexPath: IndexPath
  ) {
    if let project = self.dataSource.projectAtIndexPath(indexPath) {
      self.viewModel.inputs.tapped(project: project)
    } else if let activity = self.dataSource.activityAtIndexPath(indexPath) {
      self.viewModel.inputs.tapped(activity: activity)
    }
  }

  // MARK: - Functions

  fileprivate func showShareSheet(_ controller: UIActivityViewController, shareContextView: UIView?) {
    controller.completionWithItemsHandler = { [weak self] activityType, completed, returnedItems, error in

      self?.shareViewModel.inputs.shareActivityCompletion(
        with: .init(
          activityType: activityType,
          completed: completed,
          returnedItems: returnedItems,
          activityError: error
        )
      )
    }

    if UIDevice.current.userInterfaceIdiom == .pad {
      controller.modalPresentationStyle = .popover
      let popover = controller.popoverPresentationController
      popover?.sourceView = shareContextView
    }

    self.present(controller, animated: true, completion: nil)
  }

  fileprivate func goToEditorialProjectList(using tagId: DiscoveryParams.TagID) {
    let vc = EditorialProjectsViewController.instantiate()
    vc.configure(with: tagId)
    self.present(vc, animated: true)
  }

  fileprivate func goTo(project: Project, refTag: RefTag) {
    let vc = ProjectNavigatorViewController.configuredWith(project: project, refTag: refTag)
    if UIDevice.current.userInterfaceIdiom == .pad {
      vc.modalPresentationStyle = .fullScreen
    }
    self.present(vc, animated: true, completion: nil)
  }

  fileprivate func goTo(project: Project, initialPlaylist: [Project], refTag: RefTag) {
    let vc = ProjectNavigatorViewController.configuredWith(
      project: project,
      refTag: refTag,
      initialPlaylist: initialPlaylist,
      navigatorDelegate: self
    )
    if UIDevice.current.userInterfaceIdiom == .pad {
      vc.modalPresentationStyle = .fullScreen
    }
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
    UIView.animate(
      withDuration: 0.3,
      animations: {
        self.emptyStatesController?.view.alpha = 1.0
      }, completion: nil
    )
    if let discovery = self.parent?.parent as? DiscoveryViewController {
      discovery.setSortsEnabled(false)
    }
  }

  private func updateProjectPlaylist(_ playlist: [Project]) {
    guard let navigator = self.presentedViewController as? ProjectNavigatorViewController else { return }
    navigator.updatePlaylist(playlist)
  }

  // MARK: - Accessors

  internal func change(filter: DiscoveryParams) {
    self.viewModel.inputs.selectedFilter(filter)
  }

  // MARK: - Actions

  @objc private func pulledToRefresh() {
    self.viewModel.inputs.pulledToRefresh()
  }

  override func scrollViewDidScroll(_ scrollView: UIScrollView) {
    self.viewModel.inputs.scrollViewDidScroll(toContentOffset: scrollView.contentOffset)
  }
}

extension DiscoveryPageViewController: ActivitySampleBackingCellDelegate, ActivitySampleFollowCellDelegate,
  ActivitySampleProjectCellDelegate {
  internal func goToActivity() {
    guard let root = self.tabBarController as? RootTabBarViewController else { return }
    root.switchToActivities()
  }
}

// MARK: - DiscoveryOnboardingCellDelegate

extension DiscoveryPageViewController: DiscoveryOnboardingCellDelegate {
  internal func discoveryOnboardingTappedSignUpLoginButton() {
    self.viewModel.inputs.signupLoginButtonTapped()
  }
}

// MARK: - DiscoveryEditorialCellDelegate

extension DiscoveryPageViewController: DiscoveryEditorialCellDelegate {
  func discoveryEditorialCellTapped(_: DiscoveryEditorialCell, tagId: DiscoveryParams.TagID) {
    self.viewModel.inputs.discoveryEditorialCellTapped(with: tagId)
  }
}

// MARK: - PersonalizationCellDelegate

extension DiscoveryPageViewController: PersonalizationCellDelegate {
  func personalizationCellTapped(_: PersonalizationCell) {
    self.viewModel.inputs.personalizationCellTapped()
  }

  func personalizationCellDidTapDismiss(_: PersonalizationCell) {
    self.viewModel.inputs.personalizationCellDismissTapped()
  }
}

// MARK: - EmptyStatesViewControllerDelegate

extension DiscoveryPageViewController: EmptyStatesViewControllerDelegate {
  func emptyStatesViewController(
    _: EmptyStatesViewController,
    goToDiscoveryWithParams params: DiscoveryParams?
  ) {
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
  internal func discoveryPostcard(
    cell _: DiscoveryPostcardCell, tappedShare context: ShareContext,
    fromSourceView: UIView
  ) {
    self.shareViewModel.inputs.configureWith(shareContext: context, shareContextView: fromSourceView)
    self.shareViewModel.inputs.shareButtonTapped()
  }

  internal func discoveryPostcardCellProjectSaveAlert() {
    let alertController = UIAlertController(
      title: Strings.Project_saved(),
      message: Strings.Well_remind_you_forty_eight_hours_before_this_project_ends(),
      preferredStyle: .alert
    )
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
    let isIpad = AppEnvironment.current.device.userInterfaceIdiom == .pad
    let nav = UINavigationController(rootViewController: vc)
      |> \.modalPresentationStyle .~ (isIpad ? .formSheet : .fullScreen)

    self.present(nav, animated: true, completion: nil)
  }
}

extension DiscoveryPageViewController: ProjectNavigatorDelegate {
  func transitionedToProject(at index: Int) {
    self.viewModel.inputs.transitionedToProject(at: index, outOf: self.dataSource.numberOfItems())
  }
}

private extension UIView {
  static func perform(animated: Bool, _ closure: () -> Void) {
    if animated {
      closure()
    } else {
      UIView.performWithoutAnimation { closure() }
    }
  }
}

// MARK: - Styles

private let headerLabelStyle: LabelStyle = { label in
  label
    |> \.textColor .~ UIColor.ksr_trust_700
    |> \.font .~ UIFont.ksr_subhead().bolded
    |> \.lineBreakMode .~ .byWordWrapping
    |> \.numberOfLines .~ 0
    |> \.textAlignment .~ .center
    |> \.translatesAutoresizingMaskIntoConstraints .~ false
}
