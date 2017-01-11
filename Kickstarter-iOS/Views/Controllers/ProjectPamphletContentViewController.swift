import KsApi
import Library
import Prelude
import Prelude_UIKit
import LiveStream

internal protocol ProjectPamphletContentViewControllerDelegate: VideoViewControllerDelegate {
  func projectPamphletContent(_ controller: ProjectPamphletContentViewController, imageIsVisible: Bool)
  func projectPamphletContent(_ controller: ProjectPamphletContentViewController,
                              scrollViewPanGestureRecognizerDidChange recognizer: UIPanGestureRecognizer)
}

internal final class ProjectPamphletContentViewController: UITableViewController {
  fileprivate let dataSource = ProjectPamphletContentDataSource()
  internal weak var delegate: ProjectPamphletContentViewControllerDelegate?
  fileprivate let viewModel: ProjectPamphletContentViewModelType = ProjectPamphletContentViewModel()
  fileprivate var navBarController: ProjectNavBarViewController!

  internal func configureWith(project: Project) {
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

  internal override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.viewModel.inputs.viewWillAppear(animated: animated)
  }

  internal override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.viewModel.inputs.viewDidAppear(animated: animated)
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableControllerStyle(estimatedRowHeight: 450)
      |> (UITableViewController.lens.tableView • UITableView.lens.delaysContentTouches) .~ false
      |> (UITableViewController.lens.tableView • UITableView.lens.canCancelContentTouches) .~ true
      |> UITableViewController.lens.view.backgroundColor .~ .clear
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.loadProjectIntoDataSource
      .observeForUI()
      .observeValues { [weak self] project in
        self?.dataSource.load(project: project)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.loadMinimalProjectIntoDataSource
      .observeForUI()
      .observeValues { [weak self] project in
        self?.dataSource.loadMinimal(project: project)
        self?.tableView.reloadData()
    }

    self.viewModel.outputs.goToBacking
      .observeForControllerAction()
      .observeValues { [weak self] in self?.goToBacking(project: $0) }

    self.viewModel.outputs.goToComments
      .observeForControllerAction()
      .observeValues { [weak self] in self?.goToComments(project: $0) }

    self.viewModel.outputs.goToLiveStream
      .observeForControllerAction()
      .observeNext { [weak self] in self?.goToLiveStream(project: $0) }

    self.viewModel.outputs.goToUpdates
      .observeForControllerAction()
      .observeValues { [weak self] in self?.goToUpdates(project: $0) }

    self.viewModel.outputs.goToRewardPledge
      .observeForControllerAction()
      .observeValues { [weak self] project, reward in
        self?.goToRewardPledge(project: project, reward: reward)
    }
  }

  internal override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let (_, rewardOrBacking) = self.dataSource[indexPath] as? (Project, Either<Reward, Backing>) {
      self.viewModel.inputs.tapped(rewardOrBacking: rewardOrBacking)
    } else if self.dataSource.indexPathIsPledgeAnyAmountCell(indexPath) {
      self.viewModel.inputs.tappedPledgeAnyAmount()
    } else if self.dataSource.indexPathIsLiveStreamSubpage(indexPath) {
      self.viewModel.inputs.tappedLiveStream()
    } else if self.dataSource.indexPathIsCommentsSubpage(indexPath) {
      self.viewModel.inputs.tappedComments()
    } else if self.dataSource.indexPathIsUpdatesSubpage(indexPath) {
      self.viewModel.inputs.tappedUpdates()
    }
  }

  internal override func tableView(_ tableView: UITableView,
                                   willDisplay cell: UITableViewCell,
                                   forRowAt indexPath: IndexPath) {

    if let cell = cell as? ProjectPamphletMainCell {
      cell.delegate = self
    } else if let cell = cell as? RewardCell {
      cell.delegate = self
    }
  }

  fileprivate func goToRewardPledge(project: Project, reward: Reward) {
    let vc = RewardPledgeViewController.configuredWith(project: project, reward: reward)
    let nav = UINavigationController(rootViewController: vc)
    nav.modalPresentationStyle = UIModalPresentationStyle.formSheet
    self.present(nav, animated: true, completion: nil)
  }

  fileprivate func goToBacking(project: Project) {
    let vc = BackingViewController.configuredWith(project: project, backer: nil)

    if self.traitCollection.userInterfaceIdiom == .pad {
      let nav = UINavigationController(rootViewController: vc)
      nav.modalPresentationStyle = UIModalPresentationStyle.formSheet
      self.present(nav, animated: true, completion: nil)
    } else {
      self.navigationController?.pushViewController(vc, animated: true)
    }
  }

  fileprivate func goToComments(project: Project) {
    let vc = CommentsViewController.configuredWith(project: project, update: nil)

    if self.traitCollection.userInterfaceIdiom == .pad {
      let nav = UINavigationController(rootViewController: vc)
      nav.modalPresentationStyle = UIModalPresentationStyle.formSheet
      self.present(nav, animated: true, completion: nil)
    } else {
      self.navigationController?.pushViewController(vc, animated: true)
    }
  }

  private func goToLiveStream(project project: Project) {
    let lvc = project.liveStreams.first.flatMap { liveStream -> UIViewController in
      let startDate = NSDate(timeIntervalSince1970: liveStream.startDate)

      if startDate.earlierDate(NSDate()) == startDate {
        return LiveStreamContainerViewController.configuredWith(project: project, event: nil)
      }

      return LiveStreamCountdownViewController.configuredWith(project: project)
    }

    guard let vc = lvc else { return }

    let nav = UINavigationController.init(navigationBarClass: ClearNavigationBar.self, toolbarClass: nil)
    nav.viewControllers = [vc]

    self.presentViewController(nav, animated: true, completion: nil)
  }

  fileprivate func goToUpdates(project: Project) {
    let vc = ProjectUpdatesViewController.configuredWith(project: project)
    self.navigationController?.pushViewController(vc, animated: true)
  }

  override func scrollViewDidScroll(_ scrollView: UIScrollView) {

    guard self.scrollingIsAllowed(scrollView) else {
      scrollView.contentOffset = .zero
      return
    }

    if let
      cell = self.tableView.cellForRow(at: self.dataSource.indexPathForMainCell() as IndexPath),
      let mainCell = cell as? ProjectPamphletMainCell {
        mainCell.scrollContentOffset(scrollView.contentOffset.y + scrollView.contentInset.top)
    }

    self.delegate?.projectPamphletContent(
      self,
      imageIsVisible: scrollView.contentOffset.y < scrollView.bounds.width * 9/16
    )
  }

  @objc fileprivate func scrollViewPanGestureRecognizerDidChange(_ recognizer: UIPanGestureRecognizer) {
    self.delegate?.projectPamphletContent(self, scrollViewPanGestureRecognizerDidChange: recognizer)
  }

  fileprivate func scrollingIsAllowed(_ scrollView: UIScrollView) -> Bool {
    return self.presentingViewController?.presentedViewController?.isBeingDismissed != .some(true)
      && (!scrollView.isTracking || scrollView.contentOffset.y >= 0)
    // swiftlint:disable:previous force_unwrapping
    // NB: this ^ shouldn't be necessary, looks like a bug in swiftlint.
  }
}

extension ProjectPamphletContentViewController: ProjectPamphletMainCellDelegate {
  internal func projectPamphletMainCell(_ cell: ProjectPamphletMainCell,
                                        goToCampaignForProject project: Project) {

    let vc = ProjectDescriptionViewController.configuredWith(project: project)
    self.navigationController?.pushViewController(vc, animated: true)
  }

  internal func projectPamphletMainCell(_ cell: ProjectPamphletMainCell,
                                        addChildController child: UIViewController) {
    self.addChildViewController(child)
    child.didMove(toParentViewController: self)
  }

  internal func projectPamphletMainCell(_ cell: ProjectPamphletMainCell,
                                        goToCreatorForProject project: Project) {

    let vc = ProjectCreatorViewController.configuredWith(project: project)

    if self.traitCollection.userInterfaceIdiom == .pad {
      let nav = UINavigationController(rootViewController: vc)
      nav.modalPresentationStyle = UIModalPresentationStyle.formSheet
      self.present(nav, animated: true, completion: nil)
    } else {
      self.navigationController?.pushViewController(vc, animated: true)
    }
  }
}

extension ProjectPamphletContentViewController: VideoViewControllerDelegate {

  internal func videoViewControllerDidFinish(_ controller: VideoViewController) {
    self.delegate?.videoViewControllerDidFinish(controller)
  }

  internal func videoViewControllerDidStart(_ controller: VideoViewController) {
    self.delegate?.videoViewControllerDidStart(controller)
  }
}

extension ProjectPamphletContentViewController: RewardCellDelegate {
  internal func rewardCellWantsExpansion(_ cell: RewardCell) {
    cell.contentView.setNeedsUpdateConstraints()
    self.tableView.beginUpdates()
    self.tableView.endUpdates()
  }
}
