import KsApi
import Library
import Prelude
import UIKit

protocol ProjectPageViewControllerDelegate: AnyObject {
  func dismissPage(animated: Bool, completion: (() -> Void)?)
  func goToLogin()
  func displayProjectStarredPrompt()
  func showShareSheet(_ controller: UIActivityViewController, sourceView: UIView?)
}

public final class ProjectPageViewController: UIViewController, MessageBannerViewControllerPresenting {
  // MARK: Properties

  private let viewModel: ProjectPageViewModelType = ProjectPageViewModel()

  /**
   FIXME: This `contentViewController` has to be embedded in a `PagingViewController` in https://kickstarter.atlassian.net/browse/NTV-195
   Maybe check `BackerDashboardViewController`'s pageViewController for in-app examples on how to do this.
   */
  private var contentViewController: ProjectPamphletContentViewController?

  private var navigationBarView: ProjectPageNavigationBarView = {
    ProjectPageNavigationBarView(frame: .zero) |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private let pledgeCTAContainerView: PledgeCTAContainerView = {
    PledgeCTAContainerView(frame: .zero) |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  weak var navigationDelegate: ProjectPageNavigationBarViewDelegate?
  public var messageBannerViewController: MessageBannerViewController?

  public static func configuredWith(
    projectOrParam: Either<Project, Param>,
    refTag: RefTag?
  ) -> ProjectPageViewController {
    let vc = ProjectPageViewController.instantiate()

    vc.viewModel.inputs.configureWith(projectOrParam: projectOrParam, refTag: refTag)
    vc.setupNavigationView()

    return vc
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    self.setupNavigationView()
    self.configurePledgeCTAContainerView()

    /** FIXME:  - https://kickstarter.atlassian.net/browse/NTV-195
     self.contentViewController = self.children
       .compactMap { $0 as? ProjectPamphletContentViewController }.first
     self.contentViewController.delegate = self
     */
    self.pledgeCTAContainerView.delegate = self
    self.messageBannerViewController = self.configureMessageBannerViewController(on: self)

    self.setupNotifications()
    self.viewModel.inputs.viewDidLoad()
    self.navigationDelegate?.viewDidLoad()
  }

  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    self.updateContentInsets()
  }

  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    self.viewModel.inputs.viewDidAppear(animated: animated)
  }

  public func setupNavigationView() {
    guard let defaultNavigationBarView = self.navigationController?.navigationBar else {
      return
    }

    _ = (self.navigationBarView, defaultNavigationBarView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    self.navigationBarView.delegate = self
    self.navigationDelegate = self.navigationBarView
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

    self.bindProjectPageViewModel()
  }

  // MARK: Orientation Change

  public override func willTransition(
    to newCollection: UITraitCollection,
    with _: UIViewControllerTransitionCoordinator
  ) {
    self.viewModel.inputs.willTransition(toNewCollection: newCollection)
  }

  // MARK: - Private Helpers

  private func setupNotifications() {
    NotificationCenter.default
      .addObserver(
        self,
        selector: #selector(ProjectPageViewController.didBackProject),
        name: .ksr_projectBacked,
        object: nil
      )
  }

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

    self.viewModel.outputs.configureChildViewControllersWithProject
      .observeForUI()
      .observeValues { [weak self] project, _ in
        /** FIXME: How we do this might change in https://kickstarter.atlassian.net/browse/NTV-195
         self?.contentViewController?.configureWith(value: (project, refTag))
         */
        self?.navigationDelegate?.configureSharing(with: .project(project))

        let watchProjectValue = WatchProjectValue(project, KSRAnalytics.PageContext.projectPage, nil)

        self?.navigationDelegate?.configureWatchProject(with: watchProjectValue)
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

  private func showProjectStarredPrompt() {
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

  private func goToLoginTout() {
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

    self.contentViewController?.additionalSafeAreaInsets = UIEdgeInsets(bottom: ctaViewSize.height)
  }

  // MARK: - Selectors

  @objc private func didBackProject() {
    self.viewModel.inputs.didBackProject()
  }

  @objc private func pledgeRetryButtonTapped() {
    self.viewModel.inputs.pledgeRetryButtonTapped()
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

// MARK: - ProjectPageViewControllerDelegate

extension ProjectPageViewController: ProjectPageViewControllerDelegate {
  func goToLogin() {
    self.goToLoginTout()
  }

  func displayProjectStarredPrompt() {
    self.showProjectStarredPrompt()
  }

  func dismissPage(animated flag: Bool, completion: (() -> Void)?) {
    self.dismiss(animated: flag, completion: completion)
  }

  func showShareSheet(_ controller: UIActivityViewController, sourceView: UIView?) {
    if UIDevice.current.userInterfaceIdiom == .pad {
      controller.modalPresentationStyle = .popover
      let popover = controller.popoverPresentationController
      popover?.sourceView = sourceView
    }

    self.present(controller, animated: true, completion: nil)
  }
}
