import KsApi
import Library
import PassKit
import Prelude
import Prelude_UIKit

public protocol ProjectPamphletContentViewControllerDelegate: VideoViewControllerDelegate {
  func projectPamphletContent(_ controller: ProjectPamphletContentViewController, imageIsVisible: Bool)
  func projectPamphletContent(_ controller: ProjectPamphletContentViewController, didScrollToTop: Bool)
  func projectPamphletContent(
    _ controller: ProjectPamphletContentViewController,
    scrollViewPanGestureRecognizerDidChange recognizer: UIPanGestureRecognizer
  )
}

public final class ProjectPamphletContentViewController: UITableViewController {
  fileprivate let dataSource = ProjectPamphletContentDataSource()
  internal weak var delegate: ProjectPamphletContentViewControllerDelegate?
  fileprivate let viewModel: ProjectPamphletContentViewModelType = ProjectPamphletContentViewModel()
  fileprivate var navBarController: ProjectNavBarViewController!

  internal func configureWith(project: Project) {
    self.viewModel.inputs.configureWith(project: project)
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.dataSource = self.dataSource
    self.tableView.panGestureRecognizer.addTarget(
      self, action: #selector(self.scrollViewPanGestureRecognizerDidChange(_:))
    )

    self.tableView.register(nib: .RewardCell)

    self.viewModel.inputs.viewDidLoad()
  }

  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.viewModel.inputs.viewWillAppear(animated: animated)
  }

  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.viewModel.inputs.viewDidAppear(animated: animated)
  }

  public override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableControllerStyle(estimatedRowHeight: 450)
      |> (UITableViewController.lens.tableView .. UITableView.lens.delaysContentTouches) .~ false
      |> (UITableViewController.lens.tableView .. UITableView.lens.canCancelContentTouches) .~ true
  }

  public override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.loadProjectIntoDataSource
      .observeForUI()
      .observeValues { [weak self] project, visible in
        self?.dataSource.load(project: project, visible: visible)
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

    self.viewModel.outputs.goToUpdates
      .observeForControllerAction()
      .observeValues { [weak self] in self?.goToUpdates(project: $0) }

    self.viewModel.outputs.goToRewardPledge
      .observeForControllerAction()
      .observeValues { [weak self] project, reward in
        self?.goToRewardPledge(project: project, reward: reward)
      }
  }

  public override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
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

  public override func tableView(
    _: UITableView,
    willDisplay cell: UITableViewCell,
    forRowAt _: IndexPath
  ) {
    if let cell = cell as? ProjectPamphletMainCell {
      cell.delegate = self
    } else if let cell = cell as? RewardCell {
      cell.delegate = self
    }
  }

  fileprivate func goToRewardPledge(project: Project, reward: Reward) {
    let applePayCapable = PKPaymentAuthorizationViewController.applePayCapable(for: project)

    let vc = DeprecatedRewardPledgeViewController.configuredWith(project: project,
                                                                 reward: reward,
                                                                 applePayCapable: applePayCapable)
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

  fileprivate func goToUpdates(project: Project) {
    let vc = ProjectUpdatesViewController.configuredWith(project: project)
    self.navigationController?.pushViewController(vc, animated: true)
  }

  public override func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
      imageIsVisible: scrollView.contentOffset.y < scrollView.bounds.width * 9 / 16
    )

    self.delegate?.projectPamphletContent(
      self,
      didScrollToTop: scrollView.contentOffset.y <= 0
    )
  }

  @objc fileprivate func scrollViewPanGestureRecognizerDidChange(_ recognizer: UIPanGestureRecognizer) {
    self.delegate?.projectPamphletContent(self, scrollViewPanGestureRecognizerDidChange: recognizer)
  }

  fileprivate func scrollingIsAllowed(_ scrollView: UIScrollView) -> Bool {
    return self.presentingViewController?.presentedViewController?.isBeingDismissed != .some(true)
      && (!scrollView.isTracking || scrollView.contentOffset.y >= 0)
  }
}

extension ProjectPamphletContentViewController: ProjectPamphletMainCellDelegate {
  internal func projectPamphletMainCell(
    _: ProjectPamphletMainCell,
    goToCampaignForProject project: Project
  ) {
    let vc = ProjectDescriptionViewController.configuredWith(project: project)
    self.navigationController?.pushViewController(vc, animated: true)
  }

  internal func projectPamphletMainCell(
    _: ProjectPamphletMainCell,
    addChildController child: UIViewController
  ) {
    self.addChild(child)
    child.beginAppearanceTransition(true, animated: false)
    child.didMove(toParent: self)
    child.endAppearanceTransition()
  }

  internal func projectPamphletMainCell(
    _: ProjectPamphletMainCell,
    goToCreatorForProject project: Project
  ) {
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
  public func videoViewControllerDidFinish(_ controller: VideoViewController) {
    self.delegate?.videoViewControllerDidFinish(controller)
  }

  public func videoViewControllerDidStart(_ controller: VideoViewController) {
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
