import KsApi
import Library
import Prelude
import UIKit

public final class ProjectPageViewController: UIViewController, MessageBannerViewControllerPresenting {
  // MARK: Properties

  private enum NavigationButtonSizes: CGFloat {
    case spacing = 15.0
  }

  private let viewModel: ProjectPageViewModelType = ProjectPageViewModel()
  private let shareViewModel: ShareViewModelType = ShareViewModel()
  /**
   FIXME: This `contentController` can be renamed `contentViewController` and has to be embedded in a `PagingViewController` in https://kickstarter.atlassian.net/browse/NTV-195
   Maybe check `BackerDashboardViewController`'s pageViewController for in-app examples on how to do this.
   */
  private var contentController: ProjectPamphletContentViewController?

  public var messageBannerViewController: MessageBannerViewController?

  private lazy var navigationShareButton: UIBarButtonItem = {
    let contentView = UIButton()
      |> shareButtonStyle
      |> UIButton.lens.imageEdgeInsets .~ UIEdgeInsets(left: -NavigationButtonSizes.spacing.rawValue)
      |> UIButton.lens.accessibilityLabel %~ { _ in Strings.dashboard_accessibility_label_share_project() }

    contentView.addTarget(
      self,
      action: #selector(ProjectPageViewController.shareButtonTapped),
      for: .touchUpInside
    )

    let barButtonItem = UIBarButtonItem(customView: contentView)

    return barButtonItem
  }()

  private lazy var navigationCloseButton: UIBarButtonItem = {
    let contentView = UIButton(type: .custom)
      |> UIButton.lens.title(for: .normal) .~ nil
      |> UIButton.lens.image(for: .normal) .~ image(named: "icon--cross")
      |> UIButton.lens.tintColor .~ .ksr_support_700
      |> UIButton.lens.accessibilityLabel %~ { _ in Strings.accessibility_projects_buttons_close() }
      |> UIButton.lens.accessibilityHint %~ { _ in Strings.Closes_project() }

    contentView.addTarget(
      self,
      action: #selector(ProjectPageViewController.closeButtonTapped),
      for: .touchUpInside
    )

    let barButtonItem = UIBarButtonItem(customView: contentView)

    return barButtonItem
  }()

  private lazy var navigationSaveButton: UIBarButtonItem = {
    let contentView = UIButton()
      |> saveButtonStyle
      |> UIButton.lens.accessibilityLabel %~ { _ in Strings.Toggle_saving_this_project() }

    let barButtonItem = UIBarButtonItem(customView: contentView)

    return barButtonItem
  }()

  private let pledgeCTAContainerView: PledgeCTAContainerView = {
    PledgeCTAContainerView(frame: .zero) |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  public static func configuredWith(
    projectOrParam: Either<Project, Param>,
    refTag: RefTag?
  ) -> ProjectPageViewController {
    let vc = ProjectPageViewController.instantiate()

    vc.viewModel.inputs.configureWith(projectOrParam: projectOrParam, refTag: refTag)

    return vc
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    self.configurePledgeCTAContainerView()

    /** FIXME:  - https://kickstarter.atlassian.net/browse/NTV-195
     self.contentController = self.children
       .compactMap { $0 as? ProjectPamphletContentViewController }.first
     self.contentController.delegate = self
     */
    self.pledgeCTAContainerView.delegate = self
    self.messageBannerViewController = self.configureMessageBannerViewController(on: self)
    self.navigationItem.leftBarButtonItem = self.navigationCloseButton
    self.navigationItem.rightBarButtonItems = [self.navigationSaveButton, self.navigationShareButton]

    NotificationCenter.default
      .addObserver(
        self,
        selector: #selector(ProjectPageViewController.didBackProject),
        name: NSNotification.Name.ksr_projectBacked,
        object: nil
      )

    self.viewModel.inputs.viewDidLoad()
  }

  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    self.updateContentInsets()
  }

  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.viewModel.inputs.viewDidAppear(animated: animated)
  }

  private func configurePledgeCTAContainerView() {
    _ = (self.pledgeCTAContainerView, self.view)
      |> ksr_addSubviewToParent()

    self.pledgeCTAContainerView.retryButton.addTarget(
      self, action: #selector(ProjectPageViewController.pledgeRetryButtonTapped), for: .touchUpInside
    )

    let pledgeCTAContainerViewConstraints = [
      self.pledgeCTAContainerView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
      self.pledgeCTAContainerView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
      self.pledgeCTAContainerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
    ]

    NSLayoutConstraint.activate(pledgeCTAContainerViewConstraints)
  }

  // MARK: - Styles

  public override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseControllerStyle()
  }

  public override func bindViewModel() {
    super.bindViewModel()

    // MARK: Project Page

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
      .observeValues { [weak self] project, _ in
        /** FIXME: How we do this might change in https://kickstarter.atlassian.net/browse/NTV-195
         self?.contentController?.configureWith(value: (project, refTag))
         */
        self?.shareViewModel.inputs.configureWith(shareContext: .project(project), shareContextView: nil)
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

    // MARK: Sharing

    self.shareViewModel.outputs.showShareSheet
      .observeForControllerAction()
      .observeValues { [weak self] controller, _ in self?.showShareSheet(controller) }
  }

  // MARK: Orientation Change Resizing

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

    self.contentController?.additionalSafeAreaInsets = UIEdgeInsets(bottom: ctaViewSize.height)
  }

  private func showShareSheet(_ controller: UIActivityViewController) {
    if UIDevice.current.userInterfaceIdiom == .pad {
      controller.modalPresentationStyle = .popover
      let popover = controller.popoverPresentationController
      popover?.sourceView = self.navigationShareButton.customView
    }

    self.present(controller, animated: true, completion: nil)
  }

  // MARK: - Selectors

  @objc private func pledgeRetryButtonTapped() {
    self.viewModel.inputs.pledgeRetryButtonTapped()
  }

  @objc private func shareButtonTapped() {
    self.shareViewModel.inputs.shareButtonTapped()
  }

  @objc private func closeButtonTapped() {
    self.dismiss(animated: true, completion: nil)
  }
}

// MARK: - PledgeCTAContainerViewDelegate

extension ProjectPageViewController: PledgeCTAContainerViewDelegate {
  func pledgeCTAButtonTapped(with state: PledgeStateCTAType) {
    self.viewModel.inputs.pledgeCTAButtonTapped(with: state)
  }
}

// MARK: - VideoViewControllerDelegate

extension ProjectPageViewController: VideoViewControllerDelegate {
  public func videoViewControllerDidFinish(_: VideoViewController) {
    /** FIXME: Currently unused - fix in https://kickstarter.atlassian.net/browse/NTV-196
     self.navBarController.projectVideoDidFinish()
     */
  }

  public func videoViewControllerDidStart(_: VideoViewController) {
    /** FIXME: Currently unused fix in https://kickstarter.atlassian.net/browse/NTV-196
     self.navBarController.projectVideoDidStart()
     */
  }
}

// MARK: - ManagePledgeViewControllerDelegate

extension ProjectPageViewController: ManagePledgeViewControllerDelegate {
  func managePledgeViewController(
    _: ManagePledgeViewController,
    managePledgeViewControllerFinishedWithMessage message: String?
  ) {
    self.viewModel.inputs.managePledgeViewControllerFinished(with: message)
  }
}
