import KsApi
import Library
import Prelude
import UIKit

internal protocol ProjectNavigatorDelegate: class {
}

internal final class ProjectNavigatorViewController: UIPageViewController {

  private let transitionAnimator: ProjectNavigatorTransitionAnimator?
  private let navigatorDelegate: ProjectNavigatorDelegate?
  private let pageDataSource: ProjectNavigatorPagesDataSource!
  private let viewModel: ProjectNavigatorViewModelType = ProjectNavigatorViewModel()

  internal static func configuredWith(
    project project: Project,
            refTag: RefTag,
            initialPlaylist: [Project],
            navigatorDelegate: ProjectNavigatorDelegate,
            transitionAnimator: ProjectNavigatorTransitionAnimator) -> UIViewController {

    let vc = ProjectNavigatorViewController(
      initialProject: project,
      initialPlaylist: initialPlaylist,
      refTag: refTag,
      navigatorDelegate: navigatorDelegate,
      transitionAnimator: transitionAnimator
    )
    vc.viewModel.inputs.configureWith(project: project, initialPlaylist: initialPlaylist, refTag: refTag)
    return vc
  }

  private init(initialProject: Project,
               initialPlaylist: [Project],
               refTag: RefTag,
               navigatorDelegate: ProjectNavigatorDelegate,
               transitionAnimator: ProjectNavigatorTransitionAnimator) {

    self.pageDataSource = ProjectNavigatorPagesDataSource(refTag: refTag,
                                                          initialPlaylist: initialPlaylist,
                                                          initialProject: initialProject)
    self.transitionAnimator = transitionAnimator
    self.navigatorDelegate = navigatorDelegate

    super.init(transitionStyle: .Scroll,
               navigationOrientation: .Horizontal,
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
      .observeNext { [weak self] in self?.setInitialPagerViewController() }

    self.viewModel.outputs.cancelInteractiveTransition
      .observeForControllerAction()
      .observeNext { [weak self] in
        self?.transitionAnimator?.cancelInteractiveTransition()
    }

    self.viewModel.outputs.dismissViewController
      .observeForControllerAction()
      .observeNext { [weak self] in
        self?.dismissViewControllerAnimated(true, completion: nil)
    }

    self.viewModel.outputs.finishInteractiveTransition
      .observeForControllerAction()
      .observeNext { [weak self] in
        self?.transitionAnimator?.finishInteractiveTransition()
    }

    self.viewModel.outputs.setTransitionAnimatorIsInFlight
      .observeForUI()
      .observeNext { [weak self] in
        self?.transitionAnimator?.isInFlight = $0
    }

    self.viewModel.outputs.setNeedsStatusBarAppearanceUpdate
      .observeForUI()
      .observeNext { [weak self] in self?.setNeedsStatusBarAppearanceUpdate() }

    self.viewModel.outputs.updateInteractiveTransition
      .observeForControllerAction()
      .observeNext { [weak self] translation in
        guard let _self = self else { return }
        self?.transitionAnimator?.updateInteractiveTransition(translation / _self.view.bounds.height)
    }
  }

  internal override func childViewControllerForStatusBarStyle() -> UIViewController? {
    return self.viewControllers?.first
  }

  internal override func childViewControllerForStatusBarHidden() -> UIViewController? {
    return self.viewControllers?.first
  }

  private func setInitialPagerViewController() {
    guard let navController = self.pageDataSource.initialController(),
      projectController = self.pageDataSource.initialPamphletController() else {
        return
    }

    projectController.delegate = self
    self.setViewControllers([navController], direction: .Forward, animated: false, completion: nil)
  }
}

extension ProjectNavigatorViewController: ProjectPamphletViewControllerDelegate {
  internal func projectPamphlet(controller: ProjectPamphletViewController,
                                panGestureRecognizerDidChange recognizer: UIPanGestureRecognizer) {

    guard let scrollView = recognizer.view as? UIScrollView else { return }

    self.viewModel.inputs.panning(contentOffset: scrollView.contentOffset,
                                  translation: recognizer.translationInView(scrollView),
                                  velocity: recognizer.velocityInView(scrollView),
                                  isDragging: scrollView.tracking)
  }
}

extension ProjectNavigatorViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
    return true
  }
}

extension ProjectNavigatorViewController: UIPageViewControllerDelegate {
  internal func pageViewController(pageViewController: UIPageViewController,
                                   didFinishAnimating finished: Bool,
                                                      previousViewControllers: [UIViewController],
                                                      transitionCompleted completed: Bool) {

    self.viewModel.inputs.pageTransition(completed: completed)
  }

  internal func pageViewController(
    pageViewController: UIPageViewController,
    willTransitionToViewControllers pendingViewControllers: [UIViewController]) {

    guard let nav = pendingViewControllers.first as? UINavigationController,
      vc = nav.viewControllers.first as? ProjectPamphletViewController,
      idx = self.pageDataSource.indexFor(controller: nav) else {
      return
    }

    vc.delegate = self

    self.viewModel.inputs.willTransition(toPage: idx)
  }
}
