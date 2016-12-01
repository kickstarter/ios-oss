import KsApi
import Library
import Prelude
import Prelude_UIKit

internal protocol ProjectPamphletContentViewControllerDelegate: VideoViewControllerDelegate {
  func projectPamphletContent(controller: ProjectPamphletContentViewController, imageIsVisible: Bool)
  func projectPamphletContent(controller: ProjectPamphletContentViewController,
                              scrollViewPanGestureRecognizerDidChange recognizer: UIPanGestureRecognizer)
}

internal final class ProjectPamphletContentViewController: UITableViewController {
  private let dataSource = ProjectPamphletContentDataSource()
  internal weak var delegate: ProjectPamphletContentViewControllerDelegate?
  private let viewModel: ProjectPamphletContentViewModelType = ProjectPamphletContentViewModel()
  private var navBarController: ProjectNavBarViewController!

  internal func configureWith(project project: Project) {
    self.viewModel.inputs.configureWith(project: project)
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.dataSource = dataSource
    self.tableView.panGestureRecognizer.addTarget(
      self, action: #selector(scrollViewPanGestureRecognizerDidChange(_:))
    )

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.viewModel.inputs.viewWillAppear(animated: animated)
  }

  internal override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    self.viewModel.inputs.viewDidAppear(animated: animated)
  }

  internal override func bindStyles() {
    super.bindStyles()

    self
      |> baseTableControllerStyle(estimatedRowHeight: 450)
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

    self.viewModel.outputs.loadMinimalProjectIntoDataSource
      .observeForUI()
      .observeNext { [weak self] project in
        self?.dataSource.loadMinimal(project: project)
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

  internal override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if let (_, rewardOrBacking) = self.dataSource[indexPath] as? (Project, Either<Reward, Backing>) {
      self.viewModel.inputs.tapped(rewardOrBacking: rewardOrBacking)
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
    } else if let cell = cell as? RewardCell {
      cell.delegate = self
    }
  }

  private func goToRewardPledge(project project: Project, reward: Reward) {
    let vc = RewardPledgeViewController.configuredWith(project: project, reward: reward)
    let nav = UINavigationController(rootViewController: vc)
    nav.modalPresentationStyle = UIModalPresentationStyle.FormSheet
    self.presentViewController(nav, animated: true, completion: nil)
  }

  private func goToBacking(project project: Project) {
    let vc = BackingViewController.configuredWith(project: project, backer: nil)

    if self.traitCollection.userInterfaceIdiom == .Pad {
      let nav = UINavigationController(rootViewController: vc)
      nav.modalPresentationStyle = UIModalPresentationStyle.FormSheet
      self.presentViewController(nav, animated: true, completion: nil)
    } else {
      self.navigationController?.pushViewController(vc, animated: true)
    }
  }

  private func goToComments(project project: Project) {
    let vc = CommentsViewController.configuredWith(project: project, update: nil)

    if self.traitCollection.userInterfaceIdiom == .Pad {
      let nav = UINavigationController(rootViewController: vc)
      nav.modalPresentationStyle = UIModalPresentationStyle.FormSheet
      self.presentViewController(nav, animated: true, completion: nil)
    } else {
      self.navigationController?.pushViewController(vc, animated: true)
    }
  }

  private func goToUpdates(project project: Project) {
    let vc = ProjectUpdatesViewController.configuredWith(project: project)
    self.navigationController?.pushViewController(vc, animated: true)
  }

  override func scrollViewDidScroll(scrollView: UIScrollView) {

    guard self.scrollingIsAllowed(scrollView) else {
      scrollView.contentOffset = .zero
      return
    }

    if let
      cell = self.tableView.cellForRowAtIndexPath(self.dataSource.indexPathForMainCell()),
      mainCell = cell as? ProjectPamphletMainCell {
        mainCell.scrollContentOffset(scrollView.contentOffset.y + scrollView.contentInset.top)
    }

    self.delegate?.projectPamphletContent(
      self,
      imageIsVisible: scrollView.contentOffset.y < scrollView.bounds.width * 9/16
    )
  }

  @objc private func scrollViewPanGestureRecognizerDidChange(recognizer: UIPanGestureRecognizer) {
    self.delegate?.projectPamphletContent(self, scrollViewPanGestureRecognizerDidChange: recognizer)
  }

  private func scrollingIsAllowed(scrollView: UIScrollView) -> Bool {
    return self.presentingViewController?.presentedViewController?.isBeingDismissed() != .Some(true)
      && (!scrollView.tracking || scrollView.contentOffset.y >= 0)
    // swiftlint:disable:previous force_unwrapping
    // NB: this ^ shouldn't be necessary, looks like a bug in swiftlint.
  }
}

extension ProjectPamphletContentViewController: ProjectPamphletMainCellDelegate {
  internal func projectPamphletMainCell(cell: ProjectPamphletMainCell,
                                        goToCampaignForProject project: Project) {

    let vc = ProjectDescriptionViewController.configuredWith(project: project)
    self.navigationController?.pushViewController(vc, animated: true)
  }

  internal func projectPamphletMainCell(cell: ProjectPamphletMainCell,
                                        addChildController child: UIViewController) {
    self.addChildViewController(child)
    child.didMoveToParentViewController(self)
  }

  internal func projectPamphletMainCell(cell: ProjectPamphletMainCell,
                                        goToCreatorForProject project: Project) {

    let vc = ProjectCreatorViewController.configuredWith(project: project)

    if self.traitCollection.userInterfaceIdiom == .Pad {
      let nav = UINavigationController(rootViewController: vc)
      nav.modalPresentationStyle = UIModalPresentationStyle.FormSheet
      self.presentViewController(nav, animated: true, completion: nil)
    } else {
      self.navigationController?.pushViewController(vc, animated: true)
    }
  }
}

extension ProjectPamphletContentViewController: VideoViewControllerDelegate {

  internal func videoViewControllerDidFinish(controller: VideoViewController) {
    self.delegate?.videoViewControllerDidFinish(controller)
  }

  internal func videoViewControllerDidStart(controller: VideoViewController) {
    self.delegate?.videoViewControllerDidStart(controller)
  }
}

extension ProjectPamphletContentViewController: RewardCellDelegate {
  internal func rewardCellWantsExpansion(cell: RewardCell) {
    cell.contentView.setNeedsUpdateConstraints()
    self.tableView.beginUpdates()
    self.tableView.endUpdates()
  }
}
