import KsApi
import Library
import UIKit
import Prelude
import Prelude_UIKit

internal final class DashboardViewController: UITableViewController {
  @IBOutlet fileprivate weak var titleView: DashboardTitleView!
  @IBOutlet fileprivate weak var shareButton: UIBarButtonItem!

  fileprivate let dataSource = DashboardDataSource()
  fileprivate let viewModel: DashboardViewModelType = DashboardViewModel()
  fileprivate let shareViewModel: ShareViewModelType = ShareViewModel()
  fileprivate let loadingIndicatorView = UIActivityIndicatorView()
  fileprivate let backgroundView = UIView()

  internal static func instantiate() -> DashboardViewController {
    return Storyboard.Dashboard.instantiate(DashboardViewController.self)
  }

  internal func `switch`(toProject param: Param) {
    self.viewModel.inputs.`switch`(toProject: param)
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.backgroundView = self.backgroundView

    self.tableView.dataSource = self.dataSource

    let shareButton = UIBarButtonItem()
      |> shareBarButtonItemStyle
      |> UIBarButtonItem.lens.targetAction .~ (self, #selector(DashboardViewController.shareButtonTapped))

    self.navigationItem.rightBarButtonItem = shareButton

    self.titleView.delegate = self

    self.viewModel.inputs.viewDidLoad()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.viewModel.inputs.viewWillAppear(animated: animated)
  }

  override func bindStyles() {
    _ = self
      |> baseTableControllerStyle(estimatedRowHeight: 200.0)
      |> UITableViewController.lens.view.backgroundColor .~ .white

    _ = self.loadingIndicatorView
      |> UIActivityIndicatorView.lens.hidesWhenStopped .~ true
      |> UIActivityIndicatorView.lens.activityIndicatorViewStyle .~ .white
      |> UIActivityIndicatorView.lens.color .~ .ksr_dark_grey_900
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    self.viewModel.inputs.viewWillDisappear()
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.loadingIndicatorView.rac.animating = self.viewModel.outputs.loaderIsAnimating

    self.viewModel.outputs.loaderIsAnimating
      .observeForUI()
      .observeValues { [weak self] isAnimating in
        guard let _self = self else { return }
        _self.tableView.tableHeaderView = isAnimating ? _self.loadingIndicatorView : nil
        if let headerView = _self.tableView.tableHeaderView {
          headerView.frame = CGRect(x: headerView.frame.origin.x,
                                    y: headerView.frame.origin.y,
                                    width: headerView.frame.size.width,
                                    height: Styles.grid(15))
        }
    }

    self.viewModel.outputs.fundingData
      .observeForUI()
      .observeValues { [weak self] stats, project in
        self?.dataSource.load(fundingDateStats: stats, project: project)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.project
      .observeForUI()
      .observeValues { [weak self] project in
        self?.dataSource.load(project: project)
        self?.tableView.reloadData()

        // NB: this is just temporary for now
        self?.shareViewModel.inputs.configureWith(shareContext: .creatorDashboard(project),
                                                  shareContextView: nil)
    }

    self.viewModel.outputs.referrerData
      .observeForUI()
      .observeValues { [weak self] (cumulative, project, aggregates, referrers) in
        self?.dataSource.load(cumulative: cumulative, project: project,
                              aggregate: aggregates, referrers: referrers)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.rewardData
      .observeForUI()
      .observeValues { [weak self] (stats, project) in
        self?.dataSource.load(rewardStats: stats, project: project)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.videoStats
      .observeForUI()
      .observeValues { [weak self] videoStats in
        self?.dataSource.load(videoStats: videoStats)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.presentProjectsDrawer
      .observeForControllerAction()
      .observeValues { [weak self] data in
        self?.presentProjectsDrawer(data: data)
    }

    self.viewModel.outputs.animateOutProjectsDrawer
      .observeForControllerAction()
      .observeValues { [weak self] in
        if let drawerVC = self?.presentedViewController as? DashboardProjectsDrawerViewController {
          drawerVC.animateOut()
        }
    }

    self.viewModel.outputs.dismissProjectsDrawer
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.dismiss(animated: false, completion: nil)
    }

    self.viewModel.outputs.updateTitleViewData
      .observeForControllerAction()
      .observeValues { [weak element = self.titleView] data in
        element?.updateData(data)
    }

    self.viewModel.outputs.goToMessages
      .observeForControllerAction()
      .observeValues { [weak self] project in
        self?.goToMessages(project: project)
    }

    self.viewModel.outputs.goToProject
      .observeForControllerAction()
      .observeValues { [weak self] project, reftag in
        self?.goToProject(project, refTag: reftag)
    }

    self.viewModel.outputs.focusScreenReaderOnTitleView
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.accessibilityFocusOnTitleView()
    }

    self.shareViewModel.outputs.showShareSheet
      .observeForControllerAction()
      .observeValues { [weak self] controller, _ in self?.showShareSheet(controller) }

    self.viewModel.outputs.goToMessageThread
      .observeForControllerAction()
      .observeValues { [weak self] project, messageThread in
        self?.goToMessageThread(project: project, messageThread: messageThread)
    }

    self.viewModel.outputs.goToActivities
      .observeForControllerAction()
      .observeValues { [weak self] project in
        self?.goToActivity(project)
    }
  }

  internal override func tableView(_ tableView: UITableView,
                                   willDisplay cell: UITableViewCell,
                                   forRowAt indexPath: IndexPath) {
    if let actionCell = cell as? DashboardActionCell {
      actionCell.delegate = self
    } else if let referrersCell = cell as? DashboardReferrersCell {
      referrersCell.delegate = self
    } else if let rewardsCell = cell as? DashboardRewardsCell {
      rewardsCell.delegate = self
    }
  }

  fileprivate func goToActivity(_ project: Project) {
    let vc = ProjectActivitiesViewController.configuredWith(project: project)
    self.navigationController?.pushViewController(vc, animated: true)

    self.navigationItem.backBarButtonItem = UIBarButtonItem.back(nil, selector: nil)
  }

  internal override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let cell = tableView.cellForRow(at: indexPath)
    if cell as? DashboardContextCell != nil {
      self.viewModel.inputs.projectContextCellTapped()
    }
  }

  private func goToMessages(project: Project) {
    let vc = MessageThreadsViewController.configuredWith(project: project, refTag: .dashboard)
    self.navigationController?.pushViewController(vc, animated: true)
  }

  fileprivate func goToPostUpdate(_ project: Project) {
    let vc = UpdateDraftViewController.configuredWith(project: project)
    vc.delegate = self

    let nav = UINavigationController(rootViewController: vc)
    nav.modalPresentationStyle = .formSheet

    self.present(nav, animated: true, completion: nil)
  }

  private func goToProject(_ project: Project, refTag: RefTag) {
    let vc = ProjectNavigatorViewController.configuredWith(project: project, refTag: refTag)
    self.present(vc, animated: true, completion: nil)
  }

  private func presentProjectsDrawer(data: [ProjectsDrawerData]) {
    let vc = DashboardProjectsDrawerViewController.configuredWith(data: data)
    vc.delegate = self
    self.modalPresentationStyle = .overCurrentContext
    self.present(vc, animated: false, completion: nil)
  }

  private func showShareSheet(_ controller: UIActivityViewController) {

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
      controller.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
      self.present(controller, animated: true, completion: nil)

    } else {
      self.present(controller, animated: true, completion: nil)
    }
  }

  private func accessibilityFocusOnTitleView() {
    UIAccessibility.post(notification: UIAccessibility.Notification.screenChanged, argument: self.titleView)
  }

  @objc fileprivate func shareButtonTapped() {
    self.shareViewModel.inputs.shareButtonTapped()
  }

  private func goToMessageThread(project: Project, messageThread: MessageThread) {
    let threadsVC = MessageThreadsViewController.configuredWith(project: project, refTag: .dashboard)
    let messageThreadVC = MessagesViewController.configuredWith(messageThread: messageThread)

    self.navigationController?.setViewControllers([self, threadsVC, messageThreadVC], animated: true)
  }

  public func navigateToProjectMessageThread(projectId: Param, messageThread: MessageThread) {
    self.viewModel.inputs.messageThreadNavigated(projectId: projectId, messageThread: messageThread)
  }

  public func navigateToProjectActivities(projectId: Param) {
    self.viewModel.inputs.activitiesNavigated(projectId: projectId)
  }
}

extension DashboardViewController: DashboardActionCellDelegate {
  internal func goToActivity(_ cell: DashboardActionCell?, project: Project) {
    self.goToActivity(project)
  }

  internal func goToMessages(_ cell: DashboardActionCell?) {
    self.viewModel.inputs.messagesCellTapped()
  }

  internal func goToPostUpdate(_ cell: DashboardActionCell?, project: Project) {
    self.goToPostUpdate(project)
  }
}

extension DashboardViewController: UpdateDraftViewControllerDelegate {
  func updateDraftViewControllerWantsDismissal(_ updateDraftViewController: UpdateDraftViewController) {
    self.dismiss(animated: true, completion: nil)
  }
}

extension DashboardViewController: DashboardReferrersCellDelegate {
  func dashboardReferrersCellDidAddReferrerRows(_ cell: DashboardReferrersCell?) {
    let inset = self.tableView.contentInset
    self.tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 1000, right: 0.0)

    self.tableView.beginUpdates()
    self.tableView.endUpdates()

    self.tableView.contentInset = inset
  }
}

extension DashboardViewController: DashboardRewardsCellDelegate {
  func dashboardRewardsCellDidAddRewardRows(_ cell: DashboardRewardsCell?) {
    self.tableView.beginUpdates()
    self.tableView.endUpdates()
  }
}

extension DashboardViewController: DashboardProjectsDrawerViewControllerDelegate {
  func dashboardProjectsDrawerCellDidTapProject(_ project: Project) {
    self.viewModel.inputs.`switch`(toProject: .id(project.id))
  }

  func dashboardProjectsDrawerDidAnimateOut() {
    self.viewModel.inputs.dashboardProjectsDrawerDidAnimateOut()
  }

  func dashboardProjectsDrawerHideDrawer() {
    self.viewModel.inputs.showHideProjectsDrawer()
  }
}

extension DashboardViewController: DashboardTitleViewDelegate {
  func dashboardTitleViewShowHideProjectsDrawer() {
    self.viewModel.inputs.showHideProjectsDrawer()
  }
}
