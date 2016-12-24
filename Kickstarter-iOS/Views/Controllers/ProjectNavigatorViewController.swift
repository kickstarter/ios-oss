import KsApi
import Library
import Prelude
import UIKit

internal protocol ProjectNavigatorDelegate: class {
}

internal final class ProjectNavigatorViewController: UIPageViewController {

  fileprivate let transitionAnimator = ProjectNavigatorTransitionAnimator()
  fileprivate weak var navigatorDelegate: ProjectNavigatorDelegate?
  fileprivate let pageDataSource: ProjectNavigatorPagesDataSource!
  fileprivate let viewModel: ProjectNavigatorViewModelType = ProjectNavigatorViewModel()

  internal static func configuredWith(project: Project, refTag: RefTag)
    -> ProjectNavigatorViewController {

      return self.configuredWith(project: project,
                                 refTag: refTag,
                                 initialPlaylist: nil,
                                 navigatorDelegate: nil)
  }

  internal static func configuredWith(
    project: Project,
            refTag: RefTag,
            initialPlaylist: [Project]? = nil,
            navigatorDelegate: ProjectNavigatorDelegate?) -> ProjectNavigatorViewController {

    let vc = ProjectNavigatorViewController(
      initialProject: project,
      initialPlaylist: initialPlaylist,
      refTag: refTag,
      navigatorDelegate: navigatorDelegate
    )
    vc.transitioningDelegate = vc
    return vc
  }

  fileprivate init(initialProject: Project,
               initialPlaylist: [Project]?,
               refTag: RefTag,
               navigatorDelegate: ProjectNavigatorDelegate?) {

    self.pageDataSource = ProjectNavigatorPagesDataSource(refTag: refTag,
                                                          initialPlaylist: initialPlaylist,
                                                          initialProject: initialProject)
    self.navigatorDelegate = navigatorDelegate
    self.viewModel.inputs.configureWith(project: initialProject, refTag: refTag)

    super.init(transitionStyle: .scroll,
               navigationOrientation: .horizontal,
               options: [UIPageViewControllerOptionInterPageSpacingKey : Styles.grid(5)])
  }

  internal required init?(coder: NSCoder) {
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

  internal override var childViewControllerForStatusBarStyle : UIViewController? {
    return self.viewControllers?.first
  }

  internal override var childViewControllerForStatusBarHidden : UIViewController? {
    return self.viewControllers?.first
  }

  fileprivate func setInitialPagerViewController() {
    guard let navController = self.pageDataSource.initialController(),
      let projectController = self.pageDataSource.initialPamphletController() else {
        return
    }

    projectController.delegate = self
    self.setViewControllers([navController], direction: .forward, animated: false, completion: nil)
  }
}

extension ProjectNavigatorViewController: ProjectPamphletViewControllerDelegate {
  internal func projectPamphlet(_ controller: ProjectPamphletViewController,
                                panGestureRecognizerDidChange recognizer: UIPanGestureRecognizer) {

    guard let scrollView = recognizer.view as? UIScrollView else { return }

    self.viewModel.inputs.panning(contentOffset: scrollView.contentOffset,
                                  translation: recognizer.translation(in: scrollView),
                                  velocity: recognizer.velocity(in: scrollView),
                                  isDragging: scrollView.isTracking)
  }
}

extension ProjectNavigatorViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
    return true
  }
}

extension ProjectNavigatorViewController: UIPageViewControllerDelegate {
  internal func pageViewController(_ pageViewController: UIPageViewController,
                                   didFinishAnimating finished: Bool,
                                                      previousViewControllers: [UIViewController],
                                                      transitionCompleted completed: Bool) {

    self.viewModel.inputs.pageTransition(completed: completed)
  }

  internal func pageViewController(
    _ pageViewController: UIPageViewController,
    willTransitionTo pendingViewControllers: [UIViewController]) {

    guard let nav = pendingViewControllers.first as? UINavigationController,
      let vc = nav.viewControllers.first as? ProjectPamphletViewController,
      let project = self.pageDataSource.projectFor(controller: nav) else {
      return
    }

    vc.delegate = self

    self.viewModel.inputs.willTransition(toProject: project)
  }
}

extension ProjectNavigatorViewController: UIViewControllerTransitioningDelegate {
  internal func animationController(forDismissed dismissed: UIViewController)
    -> UIViewControllerAnimatedTransitioning? {

      return self.transitionAnimator
  }

  func animationController(
    forPresented presented: UIViewController,
    presenting: UIViewController,
    source: UIViewController) -> UIViewControllerAnimatedTransitioning? {

    return self.transitionAnimator
  }

  func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning)
    -> UIViewControllerInteractiveTransitioning? {

      return self.transitionAnimator.isInFlight ? self.transitionAnimator : nil
  }
}
