import KsApi
import Library
import Prelude
import UIKit

internal protocol ProjectPamphletViewControllerDelegate: class {
  func projectPamphlet(_ controller: ProjectPamphletViewController,
                       panGestureRecognizerDidChange recognizer: UIPanGestureRecognizer)
}

internal final class ProjectPamphletViewController: UIViewController {
  internal weak var delegate: ProjectPamphletViewControllerDelegate?
  fileprivate let viewModel: ProjectPamphletViewModelType = ProjectPamphletViewModel()

  fileprivate var navBarController: ProjectNavBarViewController!
  fileprivate var contentController: ProjectPamphletContentViewController!

  internal static func configuredWith(projectOrParam: Either<Project, Param>, refTag: RefTag?)
    -> ProjectPamphletViewController {

      let vc: ProjectPamphletViewController = Storyboard.ProjectPamphlet.instantiate()
      vc.viewModel.inputs.configureWith(projectOrParam: projectOrParam, refTag: refTag)
      return vc
  }

  internal override var prefersStatusBarHidden: Bool {
    return self.viewModel.outputs.prefersStatusBarHidden
  }

  internal override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
    return .fade
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

  internal override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.viewModel.inputs.viewWillAppear(animated: animated)
  }

  internal override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.viewModel.inputs.viewDidAppear(animated: animated)
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.configureChildViewControllersWithProject
      .observeForUI()
      .observeValues { [weak self] project, refTag in
        self?.contentController.configureWith(project: project)
        self?.navBarController.configureWith(project: project, refTag: refTag)
    }

    self.viewModel.outputs.setNavigationBarHiddenAnimated
      .observeForUI()
      .observeValues { [weak self] in self?.navigationController?.setNavigationBarHidden($0, animated: $1) }

    self.viewModel.outputs.setNeedsStatusBarAppearanceUpdate
      .observeForUI()
      .observeValues { [weak self] in
        UIView.animate(withDuration: 0.3) { self?.setNeedsStatusBarAppearanceUpdate() }
    }
  }
}

extension ProjectPamphletViewController: ProjectPamphletContentViewControllerDelegate {
  internal func projectPamphletContent(_ controller: ProjectPamphletContentViewController,
                                       imageIsVisible: Bool) {
    self.navBarController.setProjectImageIsVisible(imageIsVisible)
  }

  internal func projectPamphletContent(
    _ controller: ProjectPamphletContentViewController,
    scrollViewPanGestureRecognizerDidChange recognizer: UIPanGestureRecognizer) {

      self.delegate?.projectPamphlet(self, panGestureRecognizerDidChange: recognizer)
  }
}

extension ProjectPamphletViewController: VideoViewControllerDelegate {
  internal func videoViewControllerDidFinish(_ controller: VideoViewController) {
    self.navBarController.projectVideoDidFinish()
  }

  internal func videoViewControllerDidStart(_ controller: VideoViewController) {
    self.navBarController.projectVideoDidStart()
  }
}

extension ProjectPamphletViewController: ProjectNavBarViewControllerDelegate {
  func projectNavBarControllerDidTapTitle(_ controller: ProjectNavBarViewController) {
    self.contentController.tableView.scrollToTop()
  }
}
