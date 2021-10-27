import KsApi
import Library
import Prelude
import UIKit

public enum ProjectPageViewControllerStyles {
  public enum Layout {
    public static let projectNavigationSelectorHeight: CGFloat = 60
  }
}

protocol ProjectPageViewControllerDelegate: AnyObject {
  func dismissPage(animated: Bool, completion: (() -> Void)?)
  func goToLogin()
  func displayProjectStarredPrompt()
  func showShareSheet(_ controller: UIActivityViewController, sourceView: UIView?)
}

public final class ProjectPageViewController: UIViewController, MessageBannerViewControllerPresenting {
  // MARK: Properties

  private let viewModel: ProjectPageViewModelType = ProjectPageViewModel()

  private var pagesDataSource: ProjectPagesDataSource?

  private var contentViewController: ProjectPamphletContentViewController?

  private let videoPlayerContainerView: UIView = {
    UIView(frame: .zero) |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private var navigationBarView: ProjectPageNavigationBarView = {
    ProjectPageNavigationBarView(frame: .zero) |> \.translatesAutoresizingMaskIntoConstraints .~ false
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
    self.configureVideoPlayerContainerViewConstraints()
    self.configurePledgeCTAContainerView()
    self.configureProjectNavigationSelectorView()
    self.configurePageViewController()

    /** FIXME:
     self.contentViewController = self.children
       .compactMap { $0 as? ProjectPamphletContentViewController }.first
     self.contentViewController.delegate = self
     */
    self.projectNavigationSelectorView.delegate = self
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

  private func configureVideoPlayerContainerViewConstraints() {
    _ = (self.videoPlayerContainerView, self.view)
      |> ksr_addSubviewToParent()

    let aspectRatio = CGFloat(9.0 / 16.0)

    let videoPlayerViewConstraints = [
      self.videoPlayerContainerView.topAnchor.constraint(equalTo: self.view.topAnchor),
      self.videoPlayerContainerView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
      self.videoPlayerContainerView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
      self.videoPlayerContainerView.widthAnchor.constraint(
        equalTo: self.view.widthAnchor
      ),
      self.videoPlayerContainerView.heightAnchor.constraint(
        equalTo: self.videoPlayerContainerView.widthAnchor,
        multiplier: aspectRatio
      )
    ]

    NSLayoutConstraint.activate(videoPlayerViewConstraints)
  }

  private func configureVideoPlayer(project: Project) {
    let videoPlayerViewController = VideoViewController.configuredWith(project: project)
    videoPlayerViewController.view.translatesAutoresizingMaskIntoConstraints = false

    _ = (videoPlayerViewController.view, self.videoPlayerContainerView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    self.addChild(videoPlayerViewController)
    videoPlayerViewController.beginAppearanceTransition(true, animated: false)
    videoPlayerViewController.didMove(toParent: self)
    videoPlayerViewController.endAppearanceTransition()
  }

  private func configurePageViewController() {
    self.pageViewController.view.translatesAutoresizingMaskIntoConstraints = false

    _ = self.view
      |> ksr_insertSubview(self.pageViewController.view, belowSubview: self.pledgeCTAContainerView)

    NSLayoutConstraint.activate([
      self.pageViewController.view.leftAnchor.constraint(equalTo: self.view.leftAnchor),
      self.pageViewController.view.rightAnchor.constraint(equalTo: self.view.rightAnchor),
      self.pageViewController.view.topAnchor
        .constraint(equalTo: self.projectNavigationSelectorView.bottomAnchor),
      self.pageViewController.view.bottomAnchor.constraint(equalTo: self.pledgeCTAContainerView.bottomAnchor)
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
      self.projectNavigationSelectorView.topAnchor
        .constraint(equalTo: self.videoPlayerContainerView.bottomAnchor),
      self.projectNavigationSelectorView.heightAnchor
        .constraint(equalToConstant: ProjectPageViewControllerStyles.Layout.projectNavigationSelectorHeight)
    ]

    NSLayoutConstraint.activate(constraints)
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
        self?.navigationDelegate?.configureSharing(with: .project(project))

        let watchProjectValue = WatchProjectValue(project, KSRAnalytics.PageContext.projectPage, nil)

        self?.navigationDelegate?.configureWatchProject(with: watchProjectValue)
      }

    self.viewModel.outputs.configurePagesDataSource
      .observeForControllerAction()
      .observeValues { [weak self] navSection, project in
        self?.configurePagesDataSource(navSection: navSection, project: project)
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

    self.viewModel.outputs.configureVideoPlayerController
      .observeForUI()
      .observeValues { [weak self] in
        self?.configureVideoPlayer(project: $0)
      }
  }

  private func configurePagesDataSource(navSection: NavigationSection, project: Project) {
    self.pagesDataSource = ProjectPagesDataSource(delegate: self, project: project)
    self.pageViewController.dataSource = self.pagesDataSource

    guard let dataSource = self.pagesDataSource else { return }

    self.pageViewController.ksr_setViewControllers(
      [dataSource.controllerFor(section: navSection)].compact(),
      direction: .forward,
      animated: false,
      completion: nil
    )
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

// MARK: - ProjectNavigationSelectorViewDelegate

extension ProjectPageViewController: ProjectNavigationSelectorViewDelegate {
  func projectNavigationSelectorViewDidSelect(_: ProjectNavigationSelectorView, index: Int) {
    self.viewModel.inputs.projectNavigationSelectorViewDidSelect(index: index)
  }
}
