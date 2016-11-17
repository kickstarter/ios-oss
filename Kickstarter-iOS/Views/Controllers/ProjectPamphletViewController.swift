import KsApi
import Library
import Prelude
import UIKit

internal protocol ProjectPamphletViewControllerDelegate: class {
  func projectPamphlet(controller: ProjectPamphletViewController,
                       panGestureRecognizerDidChange recognizer: UIPanGestureRecognizer)
}

internal final class ProjectPamphletViewController: UIViewController {
  internal weak var delegate: ProjectPamphletViewControllerDelegate?
  private let viewModel: ProjectPamphletViewModelType = ProjectPamphletViewModel()

  private var navBarController: ProjectNavBarViewController!
  private var contentController: ProjectPamphletContentViewController!

  internal static func configuredWith(projectOrParam projectOrParam: Either<Project, Param>, refTag: RefTag?)
    -> ProjectPamphletViewController {

      let vc = Storyboard.ProjectPamphlet.instantiate(ProjectPamphletViewController)
      vc.viewModel.inputs.configureWith(projectOrParam: projectOrParam, refTag: refTag)
      return vc
  }

  internal override func prefersStatusBarHidden() -> Bool {
    return self.viewModel.outputs.prefersStatusBarHidden
  }

  internal override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
    return .Fade
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.navBarController = self.childViewControllers
      .flatMap { $0 as? ProjectNavBarViewController }.first
    self.navBarController.delegate = self

    self.contentController = self.childViewControllers
      .flatMap { $0 as? ProjectPamphletContentViewController }.first
    self.contentController.delegate = self

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

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.configureChildViewControllersWithProject
      .observeForUI()
      .observeNext { [weak self] project, refTag in
        self?.contentController.configureWith(project: project)
        self?.navBarController.configureWith(project: project, refTag: refTag)
    }

    self.viewModel.outputs.setNavigationBarHiddenAnimated
      .observeForUI()
      .observeNext { [weak self] in self?.navigationController?.setNavigationBarHidden($0, animated: $1) }

    self.viewModel.outputs.setNeedsStatusBarAppearanceUpdate
      .observeForUI()
      .observeNext { [weak self] in
        UIView.animateWithDuration(0.3) { self?.setNeedsStatusBarAppearanceUpdate() }
    }
  }
}

extension ProjectPamphletViewController: ProjectPamphletContentViewControllerDelegate {
  internal func projectPamphletContent(controller: ProjectPamphletContentViewController,
                                       imageIsVisible: Bool) {
    self.navBarController.setProjectImageIsVisible(imageIsVisible)
  }

  internal func projectPamphletContent(
    controller: ProjectPamphletContentViewController,
    scrollViewPanGestureRecognizerDidChange recognizer: UIPanGestureRecognizer) {

      self.delegate?.projectPamphlet(self, panGestureRecognizerDidChange: recognizer)
  }
}

extension ProjectPamphletViewController: VideoViewControllerDelegate {
  internal func videoViewControllerDidFinish(controller: VideoViewController) {
    self.navBarController.projectVideoDidFinish()
  }

  internal func videoViewControllerDidStart(controller: VideoViewController) {
    self.navBarController.projectVideoDidStart()
  }
}

extension ProjectPamphletViewController: ProjectNavBarViewControllerDelegate {
  func projectNavBarControllerDidTapTitle(controller: ProjectNavBarViewController) {
    self.contentController.tableView.scrollToTop()
  }
}
