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

  private let pledgeCTAContainerViewMargins = Styles.grid(3)
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

    if userCanSeeNativeCheckout() {
      self.configurePledgeCTAContainerView()
    }

    self.navBarController = self.children
      .compactMap { $0 as? ProjectNavBarViewController }.first
    self.navBarController.delegate = self

    self.contentController = self.children
      .compactMap { $0 as? ProjectPamphletContentViewController }.first
    self.contentController.delegate = self

    self.pledgeCTAContainerView.delegate = self

    self.viewModel.inputs.initial(topConstraint: self.initialTopConstraint)

    self.messageBannerViewController = self.configureMessageBannerViewController(on: self)

    self.viewModel.inputs.viewDidLoad()
  }

  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.viewModel.inputs.viewWillAppear(animated: animated)
  }

  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    self.setInitial(
      constraints: [navBarTopConstraint],
      constant: self.initialTopConstraint
    )

    if userCanSeeNativeCheckout() {
      self.updateContentInsets()
    }
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

    self.pledgeCTAContainerView.pledgeRetryButton.addTarget(
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

  public override func bindStyles() {
    super.bindStyles()

    if userCanSeeNativeCheckout() {
      _ = self.pledgeCTAContainerView
        |> \.layoutMargins .~ .init(all: self.pledgeCTAContainerViewMargins)

      _ = self.pledgeCTAContainerView.layer
        |> checkoutLayerCardRoundedStyle
        |> \.backgroundColor .~ UIColor.white.cgColor
        |> \.shadowColor .~ UIColor.black.cgColor
        |> \.shadowOpacity .~ 0.12
        |> \.shadowOffset .~ CGSize(width: 0, height: -1.0)
        |> \.shadowRadius .~ 1.0
        |> \.maskedCorners .~ [CACornerMask.layerMaxXMinYCorner, CACornerMask.layerMinXMinYCorner]
    }
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
      .observeValues { [weak self] project in
        self?.goToManageViewPledge(project: project)
      }

    self.viewModel.outputs.goToDeprecatedViewBacking
      .observeForControllerAction()
      .observeValues { [weak self] project, user in
        self?.goToDeprecatedViewBacking(project: project, user: user)
      }

    self.viewModel.outputs.goToDeprecatedManagePledge
      .observeForControllerAction()
      .observeValues { [weak self] project, reward, refTag in
        self?.goToDeprecatedManagePledge(project: project, reward: reward, refTag: refTag)
      }

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
  }

  public override func willTransition(
    to newCollection: UITraitCollection,
    with _: UIViewControllerTransitionCoordinator
  ) {
    self.viewModel.inputs.willTransition(toNewCollection: newCollection)
  }

  // MARK: - Private Helpers

  private func setInitial(constraints: [NSLayoutConstraint?], constant: CGFloat) {
    constraints.forEach {
      $0?.constant = constant
    }
  }

  private func goToRewards(project: Project, refTag: RefTag?) {
    let vc = rewardsCollectionViewController(project: project, refTag: refTag)

    self.present(vc, animated: true)
  }

  private func goToManageViewPledge(project: Project) {
    let vc = ManagePledgeViewController.instantiate()
      |> \.delegate .~ self
    vc.configureWith(project: project)

    let nc = RewardPledgeNavigationController(rootViewController: vc)

    if AppEnvironment.current.device.userInterfaceIdiom == .pad {
      _ = nc
        |> \.modalPresentationStyle .~ .formSheet
    }

    self.present(nc, animated: true)
  }

  private func goToDeprecatedManagePledge(project: Project, reward: Reward, refTag _: RefTag?) {
    let pledgeViewController = DeprecatedRewardPledgeViewController
      .configuredWith(
        project: project, reward: reward
      )

    let nav = UINavigationController(rootViewController: pledgeViewController)
    if AppEnvironment.current.device.userInterfaceIdiom == .pad {
      _ = nav
        |> \.modalPresentationStyle .~ .formSheet
    }
    self.present(nav, animated: true)
  }

  private func goToDeprecatedViewBacking(project: Project, user _: User?) {
    let backingViewController = BackingViewController.configuredWith(project: project, backer: nil)

    if AppEnvironment.current.device.userInterfaceIdiom == .pad {
      let nav = UINavigationController(rootViewController: backingViewController)
        |> \.modalPresentationStyle .~ .formSheet
      self.present(nav, animated: true)
    } else {
      self.navigationController?.pushViewController(backingViewController, animated: true)
    }
  }

  private func updateContentInsets() {
    let buttonSize = self.pledgeCTAContainerView.pledgeCTAButton.systemLayoutSizeFitting(
      UIView.layoutFittingCompressedSize
    )
    let bottomInset = buttonSize.height + 2 * self.pledgeCTAContainerViewMargins

    self.contentController.additionalSafeAreaInsets = UIEdgeInsets(bottom: bottomInset)
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
    shouldDismissAndShowSuccessBannerWithMessage message: String
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

private func rewardsCollectionViewController(
  project: Project,
  refTag: RefTag?
) -> UINavigationController {
  let rewardsCollectionViewController = RewardsCollectionViewController
    .instantiate(with: project, refTag: refTag, context: .createPledge)

  let closeButton = UIBarButtonItem(
    image: UIImage(named: "icon--cross"),
    style: .plain,
    target: rewardsCollectionViewController,
    action: #selector(RewardsCollectionViewController.closeButtonTapped)
  )

  _ = closeButton
    |> \.width .~ Styles.minTouchSize.width
    |> \.accessibilityLabel %~ { _ in Strings.Dismiss() }

  rewardsCollectionViewController.navigationItem.setLeftBarButton(closeButton, animated: false)

  let navigationController = RewardPledgeNavigationController(
    rootViewController: rewardsCollectionViewController
  )

  if AppEnvironment.current.device.userInterfaceIdiom == .pad {
    _ = navigationController
      |> \.modalPresentationStyle .~ .pageSheet
  }

  return navigationController
}
