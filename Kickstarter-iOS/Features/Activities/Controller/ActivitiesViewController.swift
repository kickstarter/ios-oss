import KsApi
import Library
import Prelude
import ReactiveSwift
import UIKit

internal final class ActivitiesViewController: UITableViewController {
  fileprivate let viewModel: ActivitiesViewModelType = ActivitiesViewModel()
  fileprivate let dataSource = ActivitiesDataSource()
  private var sessionEndedObserver: Any?
  private var sessionStartedObserver: Any?
  private var userUpdatedObserver: Any?

  fileprivate var emptyStatesController: EmptyStatesViewController?

  internal static func instantiate() -> ActivitiesViewController {
    return Storyboard.Activity.instantiate(ActivitiesViewController.self)
  }

  internal required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)

    self.sessionStartedObserver = NotificationCenter.default
      .addObserver(forName: .ksr_sessionStarted, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.userSessionStarted()
      }

    self.sessionEndedObserver = NotificationCenter.default
      .addObserver(forName: .ksr_sessionEnded, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.userSessionEnded()
      }

    self.userUpdatedObserver = NotificationCenter.default
      .addObserver(forName: Notification.Name.ksr_userUpdated, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.currentUserUpdated()
      }
  }

  deinit {
    [
      self.sessionEndedObserver,
      self.sessionStartedObserver,
      self.userUpdatedObserver
    ]
    .compact()
    .forEach(NotificationCenter.default.removeObserver)
  }

  internal override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    self.emptyStatesController?.view.frame = self.view.bounds
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: Styles.gridHalf(3)))
    self.tableView.registerCellClass(ActivityErroredBackingsCell.self)
    self.tableView.registerCellClass(RewardTrackingActivitiesCell.self)
    self.tableView.dataSource = self.dataSource

    let emptyVC = EmptyStatesViewController.configuredWith(emptyState: .activity)
    self.emptyStatesController = emptyVC
    emptyVC.delegate = self
    // Because the ActivitiesViewController is a UITableViewController, it wasn't automatically accounting
    // for the root tab bar height in this child VC. Adding the additional height makes this layout correctly.
    emptyVC.additionalSafeAreaInsets = UIEdgeInsets(bottom: 50)

    self.addChild(emptyVC)
    self.view.addSubview(emptyVC.view)
    emptyVC.didMove(toParent: self)

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.viewModel.inputs.viewWillAppear(animated: animated)
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableControllerStyle(estimatedRowHeight: 200.0)

    _ = self.navigationItem
      |> UINavigationItem.lens.title %~ { _ in Strings.activity_navigation_title_activity() }
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.activities
      .observeForUI()
      .observeValues { [weak self] activities in
        self?.dataSource.load(activities: activities)
        self?.tableView.reloadData()
      }

    self.viewModel.outputs.erroredBackings
      .observeForUI()
      .observeValues { [weak self] backings in
        self?.dataSource.load(erroredBackings: backings)
        self?.tableView.reloadData()
      }

    self.viewModel.outputs.showEmptyStateIsLoggedIn
      .observeForUI()
      .observeValues { [weak self] _ in
        self?.tableView.bounces = false
        if let emptyVC = self?.emptyStatesController {
          self?.emptyStatesController?.view.isHidden = false
          self?.view.bringSubviewToFront(emptyVC.view)
        }
      }

    self.viewModel.outputs.hideEmptyState
      .observeForUI()
      .observeValues { [weak self] in
        self?.tableView.bounces = true
        self?.emptyStatesController?.view.isHidden = true
      }

    self.refreshControl?.rac.refreshing = self.viewModel.outputs.isRefreshing

    self.viewModel.outputs.goToProject
      .observeForControllerAction()
      .observeValues { [weak self] project, refTag in
        self?.present(project: project, refTag: refTag)
      }

    self.viewModel.outputs.unansweredSurveys
      .observeForUI()
      .observeValues { [weak self] in
        self?.dataSource.load(surveys: $0)
        self?.tableView.reloadData()
      }

    self.viewModel.outputs.goToSurveyResponse
      .observeForControllerAction()
      .observeValues { [weak self] surveyResponse in
        self?.goToSurveyResponse(surveyResponse: surveyResponse)
      }

    self.viewModel.outputs.goToUpdate
      .observeForControllerAction()
      .observeValues { [weak self] project, update in
        self?.goToUpdate(project: project, update: update)
      }

    self.viewModel.outputs.goToManagePledge
      .observeForControllerAction()
      .observeValues { [weak self] params in
        self?.goToManagePledge(params: params)
      }

    self.viewModel.outputs.clearBadgeValue
      .observeForUI()
      .observeValues { [weak self] in
        self?.parent?.tabBarItem.badgeValue = nil
      }

    self.viewModel.outputs.updateUserInEnvironment
      .observeValues { user in
        AppEnvironment.updateCurrentUser(user)
        NotificationCenter.default.post(.init(name: .ksr_userUpdated))
      }

    self.viewModel.outputs.rewardTrackingData
      .observeForUI()
      .observeValues { [weak self] trackings in
        self?.dataSource.load(rewardTrackingData: trackings)
        self?.tableView.reloadData()
      }

    self.viewModel.outputs.goToTrackShipping
      .observeForUI()
      .observeValues { [weak self] url in
        self?.goTo(url: url)
      }
  }

  internal override func tableView(
    _: UITableView,
    willDisplay cell: UITableViewCell,
    forRowAt indexPath: IndexPath
  ) {
    switch cell {
    case let updateCell as ActivityUpdateCell:
      updateCell.delegate = self
    case let surveyCell as ActivitySurveyResponseCell:
      surveyCell.delegate = self
    case let erroredCell as ActivityErroredBackingsCell:
      erroredCell.delegate = self
    case let trackingCell as RewardTrackingActivitiesCell:
      trackingCell.delegate = self
    default:
      break
    }

    self.viewModel.inputs.willDisplayRow(
      self.dataSource.itemIndexAt(indexPath),
      outOf: self.dataSource.numberOfItems()
    )
  }

  internal override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let activity = self.dataSource[indexPath] as? Activity else {
      return
    }

    self.viewModel.inputs.tappedActivity(activity)
  }

  @IBAction internal func refresh() {
    self.viewModel.inputs.refresh()
  }

  fileprivate func present(project: Project, refTag: RefTag) {
    let projectParam = Either<Project, any ProjectPageParam>(left: project)
    let vc = ProjectPageViewController.configuredWith(
      projectOrParam: projectParam,
      refInfo: RefInfo(refTag)
    )

    let nav = NavigationController(rootViewController: vc)
    nav.modalPresentationStyle = self.traitCollection.userInterfaceIdiom == .pad ? .fullScreen : .formSheet

    self.present(nav, animated: true, completion: nil)
  }

  fileprivate func goToSurveyResponse(surveyResponse: SurveyResponse) {
    let url = surveyResponse.urls.web.survey
    let vc = SurveyResponseViewController.configuredWith(surveyUrl: url)
    vc.delegate = self

    let nav = UINavigationController(rootViewController: vc)
    nav.modalPresentationStyle = .formSheet

    self.present(nav, animated: true, completion: nil)
  }

  fileprivate func goToUpdate(project: Project, update: Update) {
    let vc = UpdateViewController.configuredWith(project: project, update: update, context: .activity)
    self.navigationController?.pushViewController(vc, animated: true)
  }

  fileprivate func goToManagePledge(params: ManagePledgeViewParamConfigData) {
    let vc = ManagePledgeViewController.controller(with: params, delegate: self)
    self.present(vc, animated: true)
  }
}

// MARK: - ActivityUpdateCellDelegate

extension ActivitiesViewController: ActivityUpdateCellDelegate {
  internal func activityUpdateCellTappedProjectImage(activity: Activity) {
    self.viewModel.inputs.activityUpdateCellTappedProjectImage(activity: activity)
  }
}

// MARK: - ActivitySurveyResponseCellDelegate

extension ActivitiesViewController: ActivitySurveyResponseCellDelegate {
  func activityTappedRespondNow(forSurveyResponse surveyResponse: SurveyResponse) {
    self.viewModel.inputs.tappedRespondNow(forSurveyResponse: surveyResponse)
  }
}

// MARK: - EmptyStatesViewControllerDelegate

extension ActivitiesViewController: EmptyStatesViewControllerDelegate {
  func emptyStatesViewController(
    _: EmptyStatesViewController,
    goToDiscoveryWithParams params: DiscoveryParams?
  ) {
    guard let tabController = self.tabBarController as? RootTabBarViewController else { return }
    tabController.switchToDiscovery(params: params)
  }

  func emptyStatesViewControllerGoToFriends() {}
}

extension ActivitiesViewController: SurveyResponseViewControllerDelegate {
  func surveyResponseViewControllerDismissed() {
    self.viewModel.inputs.surveyResponseViewControllerDismissed()
  }
}

extension ActivitiesViewController: TabBarControllerScrollable {}

// MARK: - ErroredBackingViewDelegate

extension ActivitiesViewController: ErroredBackingViewDelegate {
  func erroredBackingViewDidTapManage(_: ErroredBackingView, backing: ProjectAndBackingEnvelope) {
    self.viewModel.inputs.erroredBackingViewDidTapManage(with: backing)
  }
}

// MARK: - ManagePledgeViewControllerDelegate

extension ActivitiesViewController: ManagePledgeViewControllerDelegate {
  func managePledgeViewController(
    _: ManagePledgeViewController,
    managePledgeViewControllerFinishedWithMessage _: String?
  ) {
    self.viewModel.inputs.managePledgeViewControllerDidFinish()
  }

  func managePledgeViewControllerDidDismiss(_: ManagePledgeViewController) {}
}

// MARK: - RewardTrackingDetailsViewDelegate

extension ActivitiesViewController: RewardTrackingDetailsViewDelegate {
  func didTapTrackingButton(with trackingURL: URL) {
    self.viewModel.inputs.tappedTrackShipping(with: trackingURL)
  }
}
