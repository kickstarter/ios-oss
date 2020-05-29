import KsApi
import Library
import Prelude
import UIKit

private enum Layout {
  enum CTAContainerView {
    static let minHeight: CGFloat = 130
  }
}

public protocol ProjectPamphletViewControllerDelegate: AnyObject {
  func projectPamphlet(
    _ controller: ProjectPamphletViewController,
    panGestureRecognizerDidChange recognizer: UIPanGestureRecognizer
  )
}

public final class ProjectPamphletViewController: UIViewController, MessageBannerViewControllerPresenting {
  internal weak var delegate: ProjectPamphletViewControllerDelegate?
  fileprivate let viewModel: ProjectPamphletViewModelType = ProjectPamphletViewModel()

  internal var messageBannerViewController: MessageBannerViewController?
  fileprivate var navBarController: ProjectNavBarViewController!
  fileprivate var contentController: ProjectPamphletContentViewController!

  @IBOutlet private var navBarTopConstraint: NSLayoutConstraint!
  private let pledgeCTAContainerView: PledgeCTAContainerView = {
    PledgeCTAContainerView(frame: .zero) |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  public static func configuredWith(
    projectOrParam: Either<Project, Param>,
    refTag: RefTag?
  ) -> ProjectPamphletViewController {
    let vc = Storyboard.ProjectPamphlet.instantiate(ProjectPamphletViewController.self)
    vc.viewModel.inputs.configureWith(projectOrParam: projectOrParam, refTag: refTag)
    return vc
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    self.configurePledgeCTAContainerView()

    self.navBarController = self.children
      .compactMap { $0 as? ProjectNavBarViewController }.first
    self.navBarController.delegate = self

    self.contentController = self.children
      .compactMap { $0 as? ProjectPamphletContentViewController }.first
    self.contentController.delegate = self

    self.pledgeCTAContainerView.delegate = self

    self.viewModel.inputs.initial(topConstraint: self.initialTopConstraint)

    self.messageBannerViewController = self.configureMessageBannerViewController(on: self)

    NotificationCenter.default
      .addObserver(
        self,
        selector: #selector(ProjectPamphletViewController.didBackProject),
        name: NSNotification.Name.ksr_projectBacked,
        object: nil
      )

    self.viewModel.inputs.viewDidLoad()
  }

  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.viewModel.inputs.viewWillAppear(animated: animated)
  }

  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    self.setInitial(
      constraints: [self.navBarTopConstraint],
      constant: self.initialTopConstraint
    )

    self.updateContentInsets()
  }

  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.viewModel.inputs.viewDidAppear(animated: animated)
  }

  private var initialTopConstraint: CGFloat {
    return self.parent?.view.safeAreaInsets.top ?? 0.0
  }

  private func configurePledgeCTAContainerView() {
    // Configure subviews
    _ = (self.pledgeCTAContainerView, self.view)
      |> ksr_addSubviewToParent()

    self.pledgeCTAContainerView.retryButton.addTarget(
      self, action: #selector(ProjectPamphletViewController.pledgeRetryButtonTapped), for: .touchUpInside
    )

    // Configure constraints
    let pledgeCTAContainerViewConstraints = [
      self.pledgeCTAContainerView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
      self.pledgeCTAContainerView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
      self.pledgeCTAContainerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
    ]

    NSLayoutConstraint.activate(pledgeCTAContainerViewConstraints)
  }

  public override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.goToRewards
      .observeForControllerAction()
      .observeValues { [weak self] params in
        let (project, refTag) = params

        self?.goToRewards(project: project, refTag: refTag)
      }

    self.viewModel.outputs.goToManagePledge
      .observeForControllerAction()
      .observeValues { [weak self] params in
        self?.goToManagePledge(params: params)
      }

    self.viewModel.outputs.configureChildViewControllersWithProject
      .observeForUI()
      .observeValues { [weak self] project, refTag in
        self?.contentController.configureWith(value: (project, refTag))
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

    self.viewModel.outputs.topLayoutConstraintConstant
      .observeForUI()
      .observeValues { [weak self] value in
        self?.navBarTopConstraint.constant = value
      }

    self.viewModel.outputs.configurePledgeCTAView
      .observeForUI()
      .observeValues { [weak self] value in
        self?.pledgeCTAContainerView.configureWith(value: value)
      }

    self.viewModel.outputs.dismissManagePledgeAndShowMessageBannerWithMessage
      .observeForControllerAction()
      .observeValues { [weak self] message in
        self?.dismiss(animated: true, completion: {
          self?.messageBannerViewController?.showBanner(with: .success, message: message)
        })
      }

    self.viewModel.outputs.popToRootViewController
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.navigationController?.popToRootViewController(animated: false)
      }
  }

  public override func willTransition(
    to newCollection: UITraitCollection,
    with _: UIViewControllerTransitionCoordinator
  ) {
    self.viewModel.inputs.willTransition(toNewCollection: newCollection)
  }

  // MARK: - Private Helpers

  @objc private func didBackProject() {
    self.viewModel.inputs.didBackProject()
  }

  private func setInitial(constraints: [NSLayoutConstraint?], constant: CGFloat) {
    constraints.forEach {
      $0?.constant = constant
    }
  }

  private func goToRewards(project: Project, refTag: RefTag?) {
    let vc = RewardsCollectionViewController.controller(with: project, refTag: refTag)

    self.present(vc, animated: true)
  }

  private func goToManagePledge(params: ManagePledgeViewParamConfigData) {
    let vc = ManagePledgeViewController.instantiate()
      |> \.delegate .~ self
    vc.configureWith(params: params)

    let nc = RewardPledgeNavigationController(rootViewController: vc)

    if AppEnvironment.current.device.userInterfaceIdiom == .pad {
      _ = nc
        |> \.modalPresentationStyle .~ .pageSheet
    }

    self.present(nc, animated: true)
  }

  private func updateContentInsets() {
    let ctaViewSize = self.pledgeCTAContainerView.systemLayoutSizeFitting(
      UIView.layoutFittingCompressedSize
    )

    self.contentController.additionalSafeAreaInsets = UIEdgeInsets(bottom: ctaViewSize.height)
  }

  // MARK: - Selectors

  @objc func pledgeRetryButtonTapped() {
    self.viewModel.inputs.pledgeRetryButtonTapped()
  }
}

// MARK: - PledgeCTAContainerViewDelegate

extension ProjectPamphletViewController: PledgeCTAContainerViewDelegate {
  func pledgeCTAButtonTapped(with state: PledgeStateCTAType) {
    self.viewModel.inputs.pledgeCTAButtonTapped(with: state)
  }
}

// MARK: - ProjectPamphletContentViewControllerDelegate

extension ProjectPamphletViewController: ProjectPamphletContentViewControllerDelegate {
  public func projectPamphletContent(
    _: ProjectPamphletContentViewController,
    didScrollToTop: Bool
  ) {
    self.navBarController.setDidScrollToTop(didScrollToTop)
  }

  public func projectPamphletContent(
    _: ProjectPamphletContentViewController,
    imageIsVisible: Bool
  ) {
    self.navBarController.setProjectImageIsVisible(imageIsVisible)
  }

  public func projectPamphletContent(
    _: ProjectPamphletContentViewController,
    scrollViewPanGestureRecognizerDidChange recognizer: UIPanGestureRecognizer
  ) {
    self.delegate?.projectPamphlet(self, panGestureRecognizerDidChange: recognizer)
  }
}

// MARK: - VideoViewControllerDelegate

extension ProjectPamphletViewController: VideoViewControllerDelegate {
  public func videoViewControllerDidFinish(_: VideoViewController) {
    self.navBarController.projectVideoDidFinish()
  }

  public func videoViewControllerDidStart(_: VideoViewController) {
    self.navBarController.projectVideoDidStart()
  }
}

// MARK: - ManagePledgeViewControllerDelegate

extension ProjectPamphletViewController: ManagePledgeViewControllerDelegate {
  func managePledgeViewController(
    _: ManagePledgeViewController,
    managePledgeViewControllerFinishedWithMessage message: String?
  ) {
    self.viewModel.inputs.managePledgeViewControllerFinished(with: message)
  }
}

// MARK: - ProjectNavBarViewControllerDelegate

extension ProjectPamphletViewController: ProjectNavBarViewControllerDelegate {
  public func projectNavBarControllerDidTapTitle(_: ProjectNavBarViewController) {
    self.contentController.tableView.scrollToTop()
  }
}
