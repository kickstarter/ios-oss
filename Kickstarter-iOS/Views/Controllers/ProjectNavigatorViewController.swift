import KsApi
import Library
import Prelude
import UIKit

internal protocol ProjectNavigatorDelegate: AnyObject {
  /// Called when a page view controller has completed transitioning.
  func transitionedToProject(at index: Int)
}

internal final class ProjectNavigatorViewController: UIPageViewController {
  fileprivate let transitionAnimator = ProjectNavigatorTransitionAnimator()
  fileprivate weak var navigatorDelegate: ProjectNavigatorDelegate?
  fileprivate let pageDataSource: ProjectNavigatorPagesDataSource!
  fileprivate let viewModel: ProjectNavigatorViewModelType = ProjectNavigatorViewModel()

  internal static func configuredWith(project: Project, refTag: RefTag)
    -> ProjectNavigatorViewController {
    return self.configuredWith(
      project: project,
      refTag: refTag,
      initialPlaylist: nil,
      navigatorDelegate: nil
    )
  }

  internal static func configuredWith(
    project: Project,
    refTag: RefTag,
    initialPlaylist: [Project]? = nil,
    navigatorDelegate: ProjectNavigatorDelegate?
  ) -> ProjectNavigatorViewController {
    let vc = ProjectNavigatorViewController(
      initialProject: project,
      initialPlaylist: initialPlaylist,
      refTag: refTag,
      navigatorDelegate: navigatorDelegate
    )
    vc.ksr_setViewControllers(
      [.init()],
      direction: .forward,
      animated: true,
      completion: nil
    )
    vc.transitioningDelegate = vc
    return vc
  }

  private init(
    initialProject: Project,
    initialPlaylist: [Project]?,
    refTag: RefTag,
    navigatorDelegate: ProjectNavigatorDelegate?
  ) {
    self.pageDataSource = ProjectNavigatorPagesDataSource(
      refTag: refTag,
      initialPlaylist: initialPlaylist,
      initialProject: initialProject
    )
    self.navigatorDelegate = navigatorDelegate

    self.viewModel.inputs.configureWith(project: initialProject, refTag: refTag)

    super.init(
      transitionStyle: .scroll,
      navigationOrientation: .horizontal,
      options: convertToOptionalUIPageViewControllerOptionsKeyDictionary(
        [
          convertFromUIPageViewControllerOptionsKey(
            UIPageViewController.OptionsKey.interPageSpacing): Styles.grid(1)
        ]
      )
    )
  }

  internal required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.dataSource = self.pageDataSource
    self.delegate = self

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.setInitialPagerViewController
      .observeForUI()
      .observeValues { [weak self] in self?.setInitialPagerViewController() }

    self.viewModel.outputs.cancelInteractiveTransition
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.transitionAnimator.cancel()
      }

    self.viewModel.outputs.dismissViewController
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.dismiss(animated: true, completion: nil)
      }

    self.viewModel.outputs.finishInteractiveTransition
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.transitionAnimator.finish()
      }

    self.viewModel.outputs.notifyDelegateTransitionedToProjectIndex
      .observeForUI()
      .observeValues { [weak self] in
        self?.navigatorDelegate?.transitionedToProject(at: $0)
      }

    self.viewModel.outputs.setTransitionAnimatorIsInFlight
      .observeForUI()
      .observeValues { [weak self] in
        self?.transitionAnimator.isInFlight = $0
      }

    self.viewModel.outputs.setNeedsStatusBarAppearanceUpdate
      .observeForUI()
      .observeValues { [weak self] in self?.setNeedsStatusBarAppearanceUpdate() }

    self.viewModel.outputs.updateInteractiveTransition
      .observeForControllerAction()
      .observeValues { [weak self] translation in
        guard let _self = self else { return }
        self?.transitionAnimator.update(translation / _self.view.bounds.height)
      }
  }

  internal override var childForStatusBarStyle: UIViewController? {
    return self.viewControllers?.first
  }

  internal override var childForStatusBarHidden: UIViewController? {
    return self.viewControllers?.first
  }

  /**
   View Controllers that present this View Controller should call this method whenever it loads an
   updated playlist of projects.
   */
  internal func updatePlaylist(_ playlist: [Project]) {
    self.pageDataSource.updatePlaylist(playlist)
  }

  fileprivate func setInitialPagerViewController() {
    guard let navController = self.pageDataSource.initialController(),
      let projectController = self.pageDataSource.initialPamphletController() else {
      return
    }

    projectController.delegate = self
    self.ksr_setViewControllers([navController], direction: .forward, animated: false, completion: nil)
  }
}

// MARK: - ProjectPamphletViewControllerDelegate

extension ProjectNavigatorViewController: ProjectPamphletViewControllerDelegate {
  internal func projectPamphlet(
    _: ProjectPamphletViewController,
    panGestureRecognizerDidChange recognizer: UIPanGestureRecognizer
  ) {
    guard let scrollView = recognizer.view as? UIScrollView else { return }

    self.viewModel.inputs.panning(
      contentOffset: scrollView.contentOffset,
      translation: recognizer.translation(in: scrollView),
      velocity: recognizer.velocity(in: scrollView),
      isDragging: scrollView.isTracking
    )
  }

  func projectPamphletViewController(
    _: ProjectPamphletViewController,
    didTapBackThisProject project: Project,
    refTag: RefTag?
  ) {
    let vc = self.rewardsCollectionViewController(project: project, refTag: refTag)

    self.present(vc, animated: true)
  }

  func deprecatedProjectPamphletViewController(
    _: ProjectPamphletViewController,
    didTapBackThisProject project: Project,
    refTag: RefTag?
  ) {
    let vc = self.rewardsCollectionViewController(project: project, refTag: refTag, deprecated: true)

    self.present(vc, animated: true)
  }

  private func rewardsCollectionViewController(
    project: Project,
    refTag: RefTag?,
    deprecated: Bool = false
  ) -> UINavigationController {
    let rewardsCollectionViewController = RewardsCollectionViewController
      .instantiate(with: project, refTag: refTag)

    let navigationController: UINavigationController

    if deprecated {
      navigationController = UINavigationController(rootViewController: rewardsCollectionViewController)
    } else {
      navigationController = RewardPledgeNavigationController(
        rootViewController: rewardsCollectionViewController
      )
    }

    if AppEnvironment.current.device.userInterfaceIdiom == .pad {
      _ = navigationController
        |> \.modalPresentationStyle .~ .pageSheet
    }

    return navigationController
  }
}

// MARK: - UIGestureRecognizerDelegate

extension ProjectNavigatorViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(_: UIGestureRecognizer, shouldReceive _: UITouch) -> Bool {
    return true
  }
}

// MARK: - UIPageViewControllerDelegate

extension ProjectNavigatorViewController: UIPageViewControllerDelegate {
  internal func pageViewController(
    _: UIPageViewController,
    didFinishAnimating _: Bool,
    previousViewControllers: [UIViewController],
    transitionCompleted completed: Bool
  ) {
    guard let prevController = previousViewControllers.first else { return }

    let previousIndex = self.pageDataSource.indexFor(controller: prevController)
    self.viewModel.inputs.pageTransition(completed: completed, from: previousIndex)
  }

  internal func pageViewController(
    _: UIPageViewController,
    willTransitionTo pendingViewControllers: [UIViewController]
  ) {
    guard let nav = pendingViewControllers.first as? UINavigationController,
      let vc = nav.viewControllers.first as? ProjectPamphletViewController,
      let project = self.pageDataSource.projectFor(controller: nav) else {
      return
    }

    vc.delegate = self

    let newIndex = self.pageDataSource.indexFor(controller: nav)
    self.viewModel.inputs.willTransition(toProject: project, at: newIndex)
  }
}

extension ProjectNavigatorViewController: UIViewControllerTransitioningDelegate {
  internal func animationController(forDismissed _: UIViewController)
    -> UIViewControllerAnimatedTransitioning? {
    return self.transitionAnimator
  }

  func animationController(
    forPresented _: UIViewController,
    presenting _: UIViewController,
    source _: UIViewController
  ) -> UIViewControllerAnimatedTransitioning? {
    return self.transitionAnimator
  }

  func interactionControllerForDismissal(using _: UIViewControllerAnimatedTransitioning)
    -> UIViewControllerInteractiveTransitioning? {
    return self.transitionAnimator.isInFlight ? self.transitionAnimator : nil
  }
}

// Helper function inserted by Swift 4.2 migrator.
private func convertToOptionalUIPageViewControllerOptionsKeyDictionary(
  _ input: [String: Any]?
) -> [UIPageViewController.OptionsKey: Any]? {
  guard let input = input else { return nil }
  return Dictionary(
    uniqueKeysWithValues: input
      .map { key, value in
        (UIPageViewController.OptionsKey(rawValue: key), value)
      }
  )
}

// Helper function inserted by Swift 4.2 migrator.
private func convertFromUIPageViewControllerOptionsKey(_ input: UIPageViewController.OptionsKey) -> String {
  return input.rawValue
}
