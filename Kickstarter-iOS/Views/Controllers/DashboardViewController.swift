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

    self.viewModel.outputs.goToProject
      .observeForUI()
      .observeNext { [weak self] project, refTag in
        self?.goToProject(project, refTag: refTag)
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

    self.viewModel.outputs.videoStats
      .observeForUI()
      .observeNext { [weak self] videoStats in
        self?.dataSource.load(videoStats: videoStats)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.rewardStats
      .observeForUI()
      .observeNext { [weak self] (stats, project) in
        self?.dataSource.load(rewardStats: stats, project: project)
        self?.tableView.reloadData()
    }

    self.shareViewModel.outputs.showShareSheet
      .observeForUI()
      .observeNext { [weak self] in self?.showShareSheet($0) }
  }

  internal override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    guard let project = self.dataSource[indexPath] as? Project else {
      return
    }

    if self.dataSource.didSelectContext(at: indexPath) {
      self.viewModel.inputs.projectContextTapped(project)
    }
  }

  internal override func tableView(tableView: UITableView,
                                   willDisplayCell cell: UITableViewCell,
                                   forRowAtIndexPath indexPath: NSIndexPath) {
    if let actionCell = cell as? DashboardActionCell {
      actionCell.delegate = self
    } else if let rewardsCell = cell as? DashboardRewardsCell {
      rewardsCell.delegate = self
    }
  }

  private func goToActivity(project: Project) {
    guard let vc = UIStoryboard(name: "ProjectActivity", bundle: nil)
      .instantiateInitialViewController() as? ProjectActivitiesViewController else {
        fatalError("Could not instantiate ProjectActivitiesViewController.")
    }

    vc.configureWith(project: project)
    self.navigationController?.pushViewController(vc, animated: true)
  }

  private func goToMessages(project: Project) {
    guard let vc = UIStoryboard(name: "Messages", bundle: nil).instantiateInitialViewController(),
      messages = vc as? MessageThreadsViewController else {
        fatalError("Could not instantiate MessageThreadsViewController.")
    }

    messages.configureWith(project: project)
    self.navigationController?.pushViewController(messages, animated: true)
  }

  private func goToPostUpdate(project: Project) {
    guard let vc = UIStoryboard(name: "UpdateDraft", bundle: nil).instantiateInitialViewController()
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
    guard let vc = UIStoryboard(name: "Project", bundle: nil).instantiateInitialViewController()
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

extension DashboardViewController: UpdateDraftViewControllerDelegate {
  func updateDraftViewControllerWantsDismissal(updateDraftViewController: UpdateDraftViewController) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
}

extension DashboardViewController: DashboardRewardsCellDelegate {
  func dashboardRewardsCellDidAddRewardRows(cell: DashboardRewardsCell?) {
    self.tableView.beginUpdates()
    self.tableView.endUpdates()
  }
}
