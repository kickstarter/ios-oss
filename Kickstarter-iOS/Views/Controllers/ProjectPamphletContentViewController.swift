import KsApi
import Library
import Prelude
import Prelude_UIKit

internal protocol ProjectPamphletContentViewControllerDelegate: VideoViewControllerDelegate {
  func projectPamphletContent(controller: ProjectPamphletContentViewController, imageIsVisible: Bool)
}

internal final class ProjectPamphletContentViewController: UITableViewController {
  private let dataSource = ProjectPamphletContentDataSource()
  internal weak var delegate: ProjectPamphletContentViewControllerDelegate!
  private let viewModel: ProjectPamphletContentViewModelType = ProjectPamphletContentViewModel()
  private var navBarController: ProjectNavBarViewController!

  internal func configureWith(project project: Project) {
    self.viewModel.inputs.configureWith(project: project)
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.dataSource = dataSource
    self.viewModel.inputs.viewDidLoad()
  }

  internal override func bindStyles() {
    super.bindStyles()

    self
      |> baseTableControllerStyle(estimatedRowHeight: 300)
      |> (UITableViewController.lens.tableView • UITableView.lens.delaysContentTouches) .~ false
      |> (UITableViewController.lens.tableView • UITableView.lens.canCancelContentTouches) .~ true
      |> UITableViewController.lens.view.backgroundColor .~ .clearColor()
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.loadProjectIntoDataSource
      .observeForUI()
      .observeNext { [weak self] project in
        self?.dataSource.load(project: project)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.goToBacking
      .observeForControllerAction()
      .observeNext { [weak self] in self?.goToBacking(project: $0) }

    self.viewModel.outputs.goToComments
      .observeForControllerAction()
      .observeNext { [weak self] in self?.goToComments(project: $0) }

    self.viewModel.outputs.goToUpdates
      .observeForControllerAction()
      .observeNext { [weak self] in self?.goToUpdates(project: $0) }

    self.viewModel.outputs.goToRewardPledge
      .observeForControllerAction()
      .observeNext { [weak self] project, reward in
        self?.goToRewardPledge(project: project, reward: reward)
    }
  }

  internal override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    self.viewModel.inputs.viewDidLayoutSubviews(contentSize: self.tableView.contentSize)
  }

  internal override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if let (_, reward) = self.dataSource[indexPath] as? (Project, Reward) {
      self.viewModel.inputs.tapped(reward: reward)
    } else if self.dataSource.indexPathIsPledgeAnyAmountCell(indexPath) {
      self.viewModel.inputs.tappedPledgeAnyAmount()
    } else if self.dataSource.indexPathIsCommentsSubpage(indexPath) {
      self.viewModel.inputs.tappedComments()
    } else if self.dataSource.indexPathIsUpdatesSubpage(indexPath) {
      self.viewModel.inputs.tappedUpdates()
    }
  }

  internal override func tableView(tableView: UITableView,
                                   willDisplayCell cell: UITableViewCell,
                                   forRowAtIndexPath indexPath: NSIndexPath) {

    if let cell = cell as? ProjectPamphletMainCell {
      cell.delegate = self
    }
  }

  private func goToRewardPledge(project project: Project, reward: Reward) {
    let vc = RewardPledgeViewController.configuredWith(project: project, reward: reward)
    let nav = UINavigationController(rootViewController: vc)
    self.presentViewController(nav, animated: true, completion: nil)
  }

  private func goToBacking(project project: Project) {
    let vc = BackingViewController.configuredWith(project: project, backer: nil)
    self.navigationController?.pushViewController(vc, animated: true)
  }

  private func goToComments(project project: Project) {
    let vc = CommentsViewController.configuredWith(project: project, update: nil)
    self.navigationController?.pushViewController(vc, animated: true)
  }

  private func goToUpdates(project project: Project) {
    let vc = ProjectUpdatesViewController.configuredWith(project: project)
    self.navigationController?.pushViewController(vc, animated: true)
  }

  override func scrollViewDidScroll(scrollView: UIScrollView) {

    guard let cell = self.tableView.cellForRowAtIndexPath(self.dataSource.indexPathForMainCell()),
      let mainCell = cell as? ProjectPamphletMainCell else {
        return
    }

    mainCell.scrollContentOffset(scrollView.contentOffset.y + scrollView.contentInset.top)

    self.delegate.projectPamphletContent(
      self,
      imageIsVisible: scrollView.contentOffset.y < scrollView.bounds.width * 9/16
    )
  }
}

extension ProjectPamphletContentViewController: ProjectPamphletMainCellDelegate {
  internal func projectPamphletMainCell(cell: ProjectPamphletMainCell,
                                        goToCampaignForProject project: Project) {

    self.navigationController?.pushViewController(
      ProjectDescriptionViewController.configuredWith(project: project),
      animated: true
    )
  }

  internal func projectPamphletMainCell(cell: ProjectPamphletMainCell,
                                        addChildController child: UIViewController) {
    self.addChildViewController(child)
    child.didMoveToParentViewController(self)
  }

  internal func projectPamphletMainCell(cell: ProjectPamphletMainCell,
                                        goToCreatorForProject project: Project) {

    self.navigationController?.pushViewController(
      ProjectCreatorViewController.configuredWith(project: project),
      animated: true
    )
  }
}

extension ProjectPamphletContentViewController: VideoViewControllerDelegate {

  internal func videoViewControllerDidFinish(controller: VideoViewController) {
    self.delegate.videoViewControllerDidFinish(controller)
    self.animateMainCellLayout()
  }

  internal func videoViewControllerDidStart(controller: VideoViewController) {
    self.delegate.videoViewControllerDidStart(controller)
    self.animateMainCellLayout()
  }

  private func animateMainCellLayout() {
    let cell = self.tableView.cellForRowAtIndexPath(self.dataSource.indexPathForMainCell())
    cell?.setNeedsUpdateConstraints()

    UIView.animateWithDuration(0.3) {
      cell?.contentView.layoutIfNeeded()
    }

    self.tableView.beginUpdates()
    self.tableView.endUpdates()
  }
}
