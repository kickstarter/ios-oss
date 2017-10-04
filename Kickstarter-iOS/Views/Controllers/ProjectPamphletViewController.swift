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
    return self.viewModel.outputs.prefersStatusBarHidden
  }

  public override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
    return .fade
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    self.navBarController = self.childViewControllers
      .flatMap { $0 as? ProjectNavBarViewController }.first
    self.navBarController.delegate = self

    self.contentController = self.childViewControllers
      .flatMap { $0 as? ProjectPamphletContentViewController }.first
    self.contentController.delegate = self

    self.viewModel.inputs.viewDidLoad()
  }

  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.viewModel.inputs.viewWillAppear(animated: animated)
  }

  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.viewModel.inputs.viewDidAppear(animated: animated)
    if #available(iOS 11.0, *) {
      update(constraints: [navBarTopConstraint, projectPamphletTopConstraint],
             constant: parent?.view.safeAreaInsets.top)
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
    self.viewModel.inputs.willTransitionToNewCollection(parent: parent)
  }

  private func update(constraints: [NSLayoutConstraint?], constant: CGFloat?) {
    _ = constraints.map {
      $0?.constant = constant ?? 0.0
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
