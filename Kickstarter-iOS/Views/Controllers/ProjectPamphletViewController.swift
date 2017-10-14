import KsApi
import Library
import Prelude
import UIKit

public protocol ProjectPamphletViewControllerDelegate: class {
  func projectPamphlet(_ controller: ProjectPamphletViewController,
                       panGestureRecognizerDidChange recognizer: UIPanGestureRecognizer)
}

public final class ProjectPamphletViewController: UIViewController {
  internal weak var delegate: ProjectPamphletViewControllerDelegate?
  fileprivate let viewModel: ProjectPamphletViewModelType = ProjectPamphletViewModel()

  fileprivate var navBarController: ProjectNavBarViewController!
  fileprivate var contentController: ProjectPamphletContentViewController!

  @IBOutlet weak private var navBarTopConstraint: NSLayoutConstraint!
  @IBOutlet weak private var projectPamphletTopConstraint: NSLayoutConstraint!

  public static func configuredWith(projectOrParam: Either<Project, Param>,
                                    refTag: RefTag?) -> ProjectPamphletViewController {

    let vc = Storyboard.ProjectPamphlet.instantiate(ProjectPamphletViewController.self)
    vc.viewModel.inputs.configureWith(projectOrParam: projectOrParam, refTag: refTag)
    return vc
  }

  public override var prefersStatusBarHidden: Bool {
    return UIApplication.shared.statusBarOrientation.isLandscape
  }

  public override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    self.navBarController = self.childViewControllers
      .flatMap { $0 as? ProjectNavBarViewController }.first
    self.navBarController.delegate = self

    self.contentController = self.childViewControllers
      .flatMap { $0 as? ProjectPamphletContentViewController }.first
    self.contentController.delegate = self

    self.viewModel.inputs.initial(topConstraint: initialTopConstraint)

    self.viewModel.inputs.viewDidLoad()
  }

  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.viewModel.inputs.viewWillAppear(animated: animated)
    self.setInitial(constraints: [navBarTopConstraint, projectPamphletTopConstraint],
                    constant: initialTopConstraint)
  }

  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.viewModel.inputs.viewDidAppear(animated: animated)
  }

  private var initialTopConstraint: CGFloat {
    if #available(iOS 11.0, *) {
      return parent?.view.safeAreaInsets.top ?? 0.0
    } else {
      return UIApplication.shared.statusBarFrame.size.height
    }
  }

  public override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.configureChildViewControllersWithProjectAndLiveStreams
      .observeForUI()
      .observeValues { [weak self] project, liveStreamEvents, refTag in
        self?.contentController.configureWith(project: project, liveStreamEvents: liveStreamEvents)
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

    self.navBarTopConstraint.rac.constant = self.viewModel.outputs.topLayoutConstraintConstant
    self.projectPamphletTopConstraint.rac.constant = self.viewModel.outputs.topLayoutConstraintConstant
  }

  public override func willTransition(to newCollection: UITraitCollection,
                                      with coordinator: UIViewControllerTransitionCoordinator) {
    self.viewModel.inputs.willTransition(toNewCollection: newCollection)
  }

  private func setInitial(constraints: [NSLayoutConstraint?], constant: CGFloat) {

    constraints.forEach {
      $0?.constant = constant
    }
  }
}

extension ProjectPamphletViewController: ProjectPamphletContentViewControllerDelegate {
  public func projectPamphletContent(_ controller: ProjectPamphletContentViewController,
                                     imageIsVisible: Bool) {
    self.navBarController.setProjectImageIsVisible(imageIsVisible)
  }

  public func projectPamphletContent(
    _ controller: ProjectPamphletContentViewController,
    scrollViewPanGestureRecognizerDidChange recognizer: UIPanGestureRecognizer) {

      self.delegate?.projectPamphlet(self, panGestureRecognizerDidChange: recognizer)
  }
}

extension ProjectPamphletViewController: VideoViewControllerDelegate {
  public func videoViewControllerDidFinish(_ controller: VideoViewController) {
    self.navBarController.projectVideoDidFinish()
  }

  public func videoViewControllerDidStart(_ controller: VideoViewController) {
    self.navBarController.projectVideoDidStart()
  }
}

extension ProjectPamphletViewController: ProjectNavBarViewControllerDelegate {
  public func projectNavBarControllerDidTapTitle(_ controller: ProjectNavBarViewController) {
    self.contentController.tableView.scrollToTop()
  }
}
