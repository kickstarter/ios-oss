import KsApi
import Library
import UIKit
import Prelude
import Prelude_UIKit

internal final class DashboardViewController: UITableViewController {
  private let dataSource = DashboardDataSource()
  private let viewModel: DashboardViewModelType = DashboardViewModel()
  private let shareViewModel: ShareViewModelType = ShareViewModel()

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.dataSource = self.dataSource

    self.viewModel.inputs.viewDidLoad()
  }

  override func bindStyles() {
    self |> baseTableControllerStyle(estimatedRowHeight: 200.0)
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.fundingData
      .observeForUI()
      .observeNext { [weak self] stats, project in
        self?.dataSource.load(fundingDateStats: stats, project: project)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.project
      .observeForUI()
      .observeNext { [weak self] project in
        self?.dataSource.load(project: project)
        self?.tableView.reloadData()

        // NB: this is just temporary for now
        self?.shareViewModel.inputs.configureWith(shareContext: .creatorDashboard(project))
    }

    self.viewModel.outputs.projects
      .observeForUI()
      .observeNext { [weak self] projects in
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.referrerData
      .observeForUI()
      .observeNext { [weak self] (cumulative, project, referrers) in
        self?.dataSource.load(cumulative: cumulative, project: project, referrers: referrers)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.rewardData
      .observeForUI()
      .observeNext { [weak self] (stats, project) in
        self?.dataSource.load(rewardStats: stats, project: project)
        self?.tableView.reloadData()
    }

    self.shareViewModel.outputs.showShareSheet
      .observeForUI()
      .observeNext { [weak self] in self?.showShareSheet($0) }

    self.viewModel.outputs.videoStats
      .observeForUI()
      .observeNext { [weak self] videoStats in
        self?.dataSource.load(videoStats: videoStats)
        self?.tableView.reloadData()
    }
  }

  internal override func tableView(tableView: UITableView,
                                   willDisplayCell cell: UITableViewCell,
                                   forRowAtIndexPath indexPath: NSIndexPath) {
    if let actionCell = cell as? DashboardActionCell {
      actionCell.delegate = self
    } else if let contextCell = cell as? DashboardContextCell {
      contextCell.delegate = self
    } else if let referrersCell = cell as? DashboardReferrersCell {
      referrersCell.delegate = self
    } else if let rewardsCell = cell as? DashboardRewardsCell {
      rewardsCell.delegate = self
    }
  }

  private func goToActivity(project: Project) {
    guard let vc = UIStoryboard(name: "ProjectActivity", bundle: .framework)
      .instantiateInitialViewController() as? ProjectActivitiesViewController else {
        fatalError("Could not instantiate ProjectActivitiesViewController.")
    }

    vc.configureWith(project: project)
    self.navigationController?.pushViewController(vc, animated: true)
  }

  private func goToMessages(project: Project) {
    guard let vc = UIStoryboard(name: "Messages", bundle: .framework).instantiateInitialViewController(),
      messages = vc as? MessageThreadsViewController else {
        fatalError("Could not instantiate MessageThreadsViewController.")
    }

    messages.configureWith(project: project)
    self.navigationController?.pushViewController(messages, animated: true)
  }

  private func goToPostUpdate(project: Project) {
    guard let vc = UIStoryboard(name: "UpdateDraft", bundle: .framework).instantiateInitialViewController()
      as? UpdateDraftViewController else {
        fatalError("Could not instantiate DraftViewController.")
    }

    vc.configureWith(project: project)
    vc.delegate = self
    self.presentViewController(UINavigationController(rootViewController: vc),
                               animated: true,
                               completion: nil)
  }

  private func goToProject(project: Project, refTag: RefTag) {
    guard let vc = UIStoryboard(name: "Project", bundle: .framework).instantiateInitialViewController()
      as? ProjectViewController else {
        fatalError("Could not instantiate ProjectViewController.")
    }

    vc.configureWith(project: project, refTag: refTag)
    self.presentViewController(UINavigationController(rootViewController: vc),
                               animated: true,
                               completion: nil)
  }

  private func showShareSheet(controller: UIActivityViewController) {
    controller.completionWithItemsHandler = { [weak self] in
      self?.shareViewModel.inputs.shareActivityCompletion(activityType: $0,
                                                          completed: $1,
                                                          returnedItems: $2,
                                                          activityError: $3)
    }

    if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
      controller.modalPresentationStyle = .Popover
      self.presentViewController(controller, animated: true, completion: nil)
    } else {
      self.presentViewController(controller, animated: true, completion: nil)
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
    self.shareViewModel.inputs.shareButtonTapped()
  }
}

extension DashboardViewController: DashboardContextCellDelegate {
  internal func goToProject(cell: DashboardContextCell?, project: Project, refTag: RefTag) {
    self.goToProject(project, refTag: refTag)
  }
}

extension DashboardViewController: UpdateDraftViewControllerDelegate {
  func updateDraftViewControllerWantsDismissal(updateDraftViewController: UpdateDraftViewController) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
}

extension DashboardViewController: DashboardReferrersCellDelegate {
  func dashboardReferrersCellDidAddReferrerRows(cell: DashboardReferrersCell?) {
    let inset = self.tableView.contentInset
    self.tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 1000, right: 0.0)

    self.tableView.beginUpdates()
    self.tableView.endUpdates()

    self.tableView.contentInset = inset
  }
}

extension DashboardViewController: DashboardRewardsCellDelegate {
  func dashboardRewardsCellDidAddRewardRows(cell: DashboardRewardsCell?) {
    self.tableView.beginUpdates()
    self.tableView.endUpdates()
  }
}
