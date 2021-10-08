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
  private let watchProjectViewModel: WatchProjectViewModelType = WatchProjectViewModel()

  private var pagesDataSource: ProjectPamphletPagesDataSource?
  /**
   FIXME: This `contentController` can be renamed `contentViewController` and has to be embedded in a `PagingViewController` in https://kickstarter.atlassian.net/browse/NTV-195
   Maybe check `BackerDashboardViewController`'s pageViewController for in-app examples on how to do this.
   */
  private var contentController: ProjectPamphletContentViewController?

  // MARK: User session state properties

  private var sessionEndedObserver: Any?
  private var sessionStartedObserver: Any?

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

    contentView
      .addTarget(self, action: #selector(ProjectPageViewController.saveButtonTapped(_:)), for: .touchUpInside)
    contentView
      .addTarget(self, action: #selector(ProjectPageViewController.saveButtonPressed), for: .touchDown)

    let barButtonItem = UIBarButtonItem(customView: contentView)

    return barButtonItem
  }()

  private let pageViewController: UIPageViewController = {
    UIPageViewController(
      transitionStyle: .scroll,
      navigationOrientation: .horizontal,
      options: nil
    )
  }()

  private let pledgeCTAContainerView: PledgeCTAContainerView = {
    PledgeCTAContainerView(frame: .zero) |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private let projectNavigationSelectorView: ProjectNavigationSelectorView = {
    ProjectNavigationSelectorView(frame: .zero) |>
      \.translatesAutoresizingMaskIntoConstraints .~ false
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
    self.configureProjectNavigationSelectorView()
    self.configurePageViewController()

    /** FIXME: Plug in or delete if not needed
     self.contentController = self.children
       .compactMap { $0 as? ProjectPamphletContentViewController }.first
     self.contentController.delegate = self
     */

    self.projectNavigationSelectorView.delegate = self
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

    self.sessionStartedObserver = NotificationCenter
      .default
      .addObserver(forName: .ksr_sessionStarted, object: nil, queue: nil) { [weak self] _ in
        self?.watchProjectViewModel.inputs.userSessionStarted()
      }

    self.sessionEndedObserver = NotificationCenter
      .default
      .addObserver(forName: .ksr_sessionEnded, object: nil, queue: nil) { [weak self] _ in
        self?.watchProjectViewModel.inputs.userSessionEnded()
      }

    self.viewModel.inputs.viewDidLoad()
    self.watchProjectViewModel.inputs.viewDidLoad()
  }

  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    self.updateContentInsets()
  }

  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.viewModel.inputs.viewDidAppear(animated: animated)
  }

  private func configurePageViewController() {
    self.pageViewController.view.translatesAutoresizingMaskIntoConstraints = false

    _ = (self.pageViewController.view, self.view)
      |> ksr_addSubviewToParent()

    NSLayoutConstraint.activate([
      self.pageViewController.view.leftAnchor.constraint(equalTo: self.view.leftAnchor),
      self.pageViewController.view.rightAnchor.constraint(equalTo: self.view.rightAnchor),
      self.pageViewController.view.topAnchor
        .constraint(equalTo: self.projectNavigationSelectorView.bottomAnchor),
      self.pageViewController.view.bottomAnchor.constraint(equalTo: self.pledgeCTAContainerView.topAnchor)
    ])

    self.pageViewController.ksr_setViewControllers(
      [.init()],
      direction: .forward,
      animated: false,
      completion: nil
    )
  }

  private func configureProjectNavigationSelectorView() {
    _ = (self.projectNavigationSelectorView, self.view)
      |> ksr_addSubviewToParent()

    let constraints = [
      self.projectNavigationSelectorView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
      self.projectNavigationSelectorView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
      self.projectNavigationSelectorView.topAnchor.constraint(equalTo: self.view.topAnchor),
      self.projectNavigationSelectorView.heightAnchor
        .constraint(equalToConstant: Styles.projectNavigationSelectorHeight)
    ]

    NSLayoutConstraint.activate(constraints)
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

  // MARK: Deinitialize

  deinit {
    self.sessionEndedObserver.doIfSome(NotificationCenter.default.removeObserver)
    self.sessionStartedObserver.doIfSome(NotificationCenter.default.removeObserver)
  }

  // MARK: - Styles

  public override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseControllerStyle()
  }

  public override func bindViewModel() {
    super.bindViewModel()

    self.bindProjectPageViewModel()
    self.bindSharingViewModel()
    self.bindWatchViewModel()
  }

  // MARK: Orientation Change

  public override func willTransition(
    to newCollection: UITraitCollection,
    with _: UIViewControllerTransitionCoordinator
  ) {
    self.viewModel.inputs.willTransition(toNewCollection: newCollection)
  }

  // MARK: - Private Helpers

  private func bindProjectPageViewModel() {
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

    self.viewModel.outputs.configurePagesDataSource
      .observeForControllerAction()
      .observeValues { [weak self] navSection in
        self?.configurePagesDataSource(navSection: navSection)
      }

    self.viewModel.outputs.configureChildViewControllersWithProject
      .observeForUI()
      .observeValues { [weak self] project, _ in
        /** FIXME: How we do this might change in https://kickstarter.atlassian.net/browse/NTV-195
         self?.contentController?.configureWith(value: (project, refTag))
         */
        self?.shareViewModel.inputs.configureWith(shareContext: .project(project), shareContextView: nil)
        self?.watchProjectViewModel.inputs
          .configure(with: (project, KSRAnalytics.PageContext.projectPage, nil))
      }

    self.viewModel.outputs.configurePledgeCTAView
      .observeForUI()
      .observeValues { [weak self] value in
        self?.pledgeCTAContainerView.configureWith(value: value)
      }

    self.viewModel.outputs.configureProjectNavigationSelectorView
      .observeForUI()
      .observeValues { [weak self] _ in
        self?.projectNavigationSelectorView.configure()
      }

    self.viewModel.outputs.dismissManagePledgeAndShowMessageBannerWithMessage
      .observeForControllerAction()
      .observeValues { [weak self] message in
        self?.dismiss(animated: true, completion: {
          self?.messageBannerViewController?.showBanner(with: .success, message: message)
        })
      }

    self.viewModel.outputs.navigatePageViewController
      .observeForControllerAction()
      .observeValues { [weak self] section in
        guard let self = self, let controller = self.pagesDataSource?.controllerFor(section: section) else {
          fatalError("Controller not found for section \(section)")
        }
        self.pageViewController.ksr_setViewControllers(
          [controller],
          direction: .forward,
          animated: false,
          completion: nil
        )
      }

    self.viewModel.outputs.popToRootViewController
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.navigationController?.popToRootViewController(animated: false)
      }
  }

  private func bindSharingViewModel() {
    self.shareViewModel.outputs.showShareSheet
      .observeForControllerAction()
      .observeValues { [weak self] controller, _ in self?.showShareSheet(controller) }
  }

  private func bindWatchViewModel() {
    let button = self.navigationSaveButton.customView as? UIButton
    button?.rac.accessibilityValue = self.watchProjectViewModel.outputs.saveButtonAccessibilityValue
    button?.rac.selected = self.watchProjectViewModel.outputs.saveButtonSelected

    self.watchProjectViewModel.outputs.generateImpactFeedback
      .observeForUI()
      .observeValues { generateImpactFeedback() }

    self.watchProjectViewModel.outputs.generateNotificationSuccessFeedback
      .observeForUI()
      .observeValues { generateNotificationSuccessFeedback() }

    self.watchProjectViewModel.outputs.generateSelectionFeedback
      .observeForUI()
      .observeValues { generateSelectionFeedback() }

    self.watchProjectViewModel.outputs.showProjectSavedAlert
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.showProjectStarredPrompt()
      }

    self.watchProjectViewModel.outputs.goToLoginTout
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.goToLoginTout()
      }

    self.watchProjectViewModel.outputs.postNotificationWithProject
      .observeForUI()
      .observeValues { project in
        NotificationCenter.default.post(
          name: Notification.Name.ksr_projectSaved,
          object: nil,
          userInfo: ["project": project]
        )
      }
  }

  private func configurePagesDataSource(navSection: NavigationSection) {
    self.pagesDataSource = ProjectPamphletPagesDataSource(delegate: self)
    self.pageViewController.dataSource = self.pagesDataSource

    guard let dataSource = self.pagesDataSource else { return }

    self.pageViewController.ksr_setViewControllers(
      [dataSource.controllerFor(section: navSection)].compact(),
      direction: .forward,
      animated: false,
      completion: nil
    )
  }

  fileprivate func showProjectStarredPrompt() {
    let alert = UIAlertController(
      title: Strings.Project_saved(),
      message: Strings.Well_remind_you_forty_eight_hours_before_this_project_ends(),
      preferredStyle: .alert
    )
    alert.addAction(
      UIAlertAction(
        title: Strings.Got_it(),
        style: .cancel,
        handler: nil
      )
    )

    self.present(alert, animated: true, completion: nil)
  }

  fileprivate func goToLoginTout() {
    let vc = LoginToutViewController.configuredWith(loginIntent: .starProject)
    let isIpad = AppEnvironment.current.device.userInterfaceIdiom == .pad
    let nav = UINavigationController(rootViewController: vc)
      |> \.modalPresentationStyle .~ (isIpad ? .formSheet : .fullScreen)

    self.present(nav, animated: true, completion: nil)
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

  @objc private func didBackProject() {
    self.viewModel.inputs.didBackProject()
  }

  @objc private func pledgeRetryButtonTapped() {
    self.viewModel.inputs.pledgeRetryButtonTapped()
  }

  @objc private func shareButtonTapped() {
    self.shareViewModel.inputs.shareButtonTapped()
  }

  @objc private func closeButtonTapped() {
    self.dismiss(animated: true, completion: nil)
  }

  @objc private func saveButtonTapped(_ button: UIButton) {
    self.watchProjectViewModel.inputs.saveButtonTapped(selected: button.isSelected)
  }

  @objc private func saveButtonPressed() {
    self.watchProjectViewModel.inputs.saveButtonTouched()
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

// MARK: - ProjectNavigationSelectorViewDelegate

extension ProjectPageViewController: ProjectNavigationSelectorViewDelegate {
  func projectNavigationSelectorViewDidSelect(_: ProjectNavigationSelectorView, index: Int) {
    self.viewModel.inputs.projectNavigationSelectorViewDidSelect(index: index)
  }
}
