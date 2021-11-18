import KsApi
import Library
import Prelude
import UIKit

public enum ProjectPageViewControllerStyles {
  public enum Layout {
    public static let projectNavigationSelectorHeight: CGFloat = 60
    public static let tableFooterViewHeight: CGFloat = 1
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

  private let dataSource = ProjectPageViewControllerDataSource()
  private let viewModel: ProjectPageViewModelType = ProjectPageViewModel()

  private var navigationBarView: ProjectPageNavigationBarView = {
    ProjectPageNavigationBarView(frame: .zero) |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private let pledgeCTAContainerView: PledgeCTAContainerView = {
    PledgeCTAContainerView(frame: .zero) |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private let projectNavigationSelectorView: ProjectNavigationSelectorView = {
    ProjectNavigationSelectorView(frame: .zero) |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var tableView: UITableView = {
    UITableView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
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
    self.configureTableView()

    self.projectNavigationSelectorView.delegate = self
    self.pledgeCTAContainerView.delegate = self
    self.messageBannerViewController = self.configureMessageBannerViewController(on: self)

    _ = self.tableView
      |> \.dataSource .~ self.dataSource
      |> \.delegate .~ self
      |> \.tableHeaderView .~ self.projectNavigationSelectorView
      |> \.tableFooterView .~
      UIView(frame: CGRect(
        x: 0,
        y: 0,
        width: 0,
        height: ProjectPageViewControllerStyles.Layout.tableFooterViewHeight
      ))
    self.tableView.registerCellClass(ProjectFAQsAskAQuestionCell.self)
    self.tableView.registerCellClass(ProjectFAQsCell.self)
    self.tableView.registerCellClass(ProjectFAQsEmptyStateCell.self)
    self.tableView.registerCellClass(ProjectEnvironmentalCommitmentCell.self)
    self.tableView.registerCellClass(ProjectEnvironmentalCommitmentDisclaimerCell.self)
    self.tableView.registerCellClass(ProjectHeaderCell.self)
    self.tableView.registerCellClass(ProjectPamphletCreatorHeaderCell.self)
    self.tableView.register(nib: .ProjectPamphletMainCell)
    self.tableView.register(nib: .ProjectPamphletSubpageCell)
    self.tableView.registerCellClass(ProjectRisksCell.self)
    self.tableView.registerCellClass(ProjectRisksDisclaimerCell.self)
    self.setupNotifications()
    self.viewModel.inputs.viewDidLoad()
    self.navigationDelegate?.viewDidLoad()
  }

  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    self.viewModel.inputs.viewDidAppear(animated: animated)
  }

  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.viewModel.inputs.viewWillAppear(animated: animated)
  }

  public func setupNavigationView() {
    guard let defaultNavigationBarView = self.navigationController?.navigationBar else {
      return
    }

    // Remove bottom border
    defaultNavigationBarView.shadowImage = UIImage()

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

  private func configureTableView() {
    _ = (self.tableView, self.view)
      |> ksr_addSubviewToParent()

    _ = (self.projectNavigationSelectorView, self.view)
      |> ksr_addSubviewToParent()

    let constraints = [
      self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
      self.tableView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
      self.tableView.bottomAnchor
        .constraint(equalTo: self.pledgeCTAContainerView.topAnchor, constant: -Styles.grid(1)),
      self.projectNavigationSelectorView.widthAnchor.constraint(equalTo: self.tableView.widthAnchor),
      self.projectNavigationSelectorView.heightAnchor
        .constraint(equalToConstant: ProjectPageViewControllerStyles.Layout.projectNavigationSelectorHeight)
    ]

    NSLayoutConstraint.activate(constraints)
  }

  public override func bindStyles() {
    super.bindStyles()

    _ = self.view |>
      \.backgroundColor .~ .ksr_white

    _ = self.tableView |> tableViewStyle
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

    NotificationCenter.default
      .addObserver(
        self,
        selector: #selector(ProjectPageViewController.userSessionStarted),
        name: .ksr_sessionStarted,
        object: nil
      )
  }

  private func bindProjectPageViewModel() {
    self.navigationBarView.rac.hidden = self.viewModel.outputs.navigationBarIsHidden

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

    self.viewModel.outputs.configureDataSource
      .observeForControllerAction()
      .observeValues { [weak self] navSection, project, refTag in
        self?.dataSource.load(
          navigationSection: navSection,
          project: project,
          refTag: refTag
        )
        self?.tableView.reloadData()
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

    self.viewModel.outputs.goToComments
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.goToComments(project: $0)
      }

    self.viewModel.outputs.goToDashboard
      .observeForControllerAction()
      .observeValues { [weak self] param in
        self?.goToDashboard(param: param)
      }

    self.viewModel.outputs.goToUpdates
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.goToUpdates(project: $0)
      }

    self.viewModel.outputs.presentMessageDialog
      .observeForUI()
      .observeValues { [weak self] project in
        self?.presentMessageDialog(project: project)
      }

    self.viewModel.outputs.showHelpWebViewController
      .observeForControllerAction()
      .observeValues { [weak self] helpType in
        self?.presentHelpWebViewController(with: helpType, presentationStyle: .formSheet)
      }

    self.viewModel.outputs.updateDataSource
      .observeForControllerAction()
      .observeValues { [weak self] navSection, project, refTag, initialIsExpandedArray in
        self?.dataSource.load(
          navigationSection: navSection,
          project: project,
          refTag: refTag,
          isExpandedStates: initialIsExpandedArray
        )
        self?.tableView.reloadData()
      }

    self.viewModel.outputs.updateFAQsInDataSource
      .observeForControllerAction()
      .observeValues { [weak self] project, refTag, isExpandedValues in
        self?.dataSource.load(
          navigationSection: .faq,
          project: project,
          refTag: refTag,
          isExpandedStates: isExpandedValues
        )
        self?.tableView.reloadData()
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

  private func goToComments(project: Project) {
    let vc = commentsViewController(for: project)
    if self.traitCollection.userInterfaceIdiom == .pad {
      let nav = UINavigationController(rootViewController: vc)
      nav.modalPresentationStyle = UIModalPresentationStyle.formSheet
      self.present(nav, animated: true, completion: nil)
    } else {
      self.viewModel.inputs.hideNavigationBar()
      self.navigationController?.pushViewController(vc, animated: true)
    }
  }

  private func goToDashboard(param: Param) {
    self.view.window?.rootViewController
      .flatMap { $0 as? RootTabBarViewController }
      .doIfSome { root in
        UIView.transition(with: root.view, duration: 0.3, options: [.transitionCrossDissolve], animations: {
          root.switchToDashboard(project: param)
        }, completion: { [weak self] _ in
          self?.dismiss(animated: true, completion: nil)
        })
      }
  }

  private func goToUpdates(project: Project) {
    let vc = ProjectUpdatesViewController.configuredWith(project: project)
    self.viewModel.inputs.hideNavigationBar()
    self.navigationController?.pushViewController(vc, animated: true)
  }

  private func presentMessageDialog(project: Project) {
    let dialog = MessageDialogViewController
      .configuredWith(messageSubject: .project(project), context: .projectPage)
    dialog.modalPresentationStyle = .formSheet
    dialog.delegate = self
    self.present(
      UINavigationController(rootViewController: dialog),
      animated: true,
      completion: nil
    )
  }

  // MARK: - Selectors

  @objc private func didBackProject() {
    self.viewModel.inputs.didBackProject()
  }

  @objc private func pledgeRetryButtonTapped() {
    self.viewModel.inputs.pledgeRetryButtonTapped()
  }

  @objc private func userSessionStarted() {
    self.viewModel.inputs.userSessionStarted()
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

// MARK: - ProjectNavigationSelectorViewDelegate

extension ProjectPageViewController: ProjectNavigationSelectorViewDelegate {
  func projectNavigationSelectorViewDidSelect(_: ProjectNavigationSelectorView, index: Int) {
    self.viewModel.inputs.projectNavigationSelectorViewDidSelect(index: index)
  }
}

// MARK: - UITableViewDelegate

extension ProjectPageViewController: UITableViewDelegate {
  public func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch indexPath.section {
    case ProjectPageViewControllerDataSource.Section.overviewSubpages.rawValue:
      if self.dataSource.indexPathIsCommentsSubpage(indexPath) {
        self.viewModel.inputs.tappedComments()
      } else if self.dataSource.indexPathIsUpdatesSubpage(indexPath) {
        self.viewModel.inputs.tappedUpdates()
      }
    case ProjectPageViewControllerDataSource.Section.faqsAskAQuestion.rawValue:
      self.viewModel.inputs.askAQuestionCellTapped()
    case ProjectPageViewControllerDataSource.Section.faqs.rawValue:
      let values = self.dataSource.isExpandedValuesForFAQsSection() ?? []
      self.viewModel.inputs.didSelectFAQsRowAt(row: indexPath.row, values: values)
    default:
      return
    }
  }

  public func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if let cell = cell as? ProjectEnvironmentalCommitmentDisclaimerCell, cell.delegate == nil {
      cell.delegate = self
    } else if let cell = cell as? ProjectRisksDisclaimerCell, cell.delegate == nil {
      cell.delegate = self
    } else if let cell = cell as? ProjectPamphletMainCell, cell.delegate == nil {
      cell.delegate = self
    } else if let cell = cell as? ProjectPamphletCreatorHeaderCell {
      cell.delegate = self
    }

    /// If we are displaying the `ProjectPamphletSubpageCell` we do not want to show the cells separator.
    self.tableView.separatorStyle = indexPath.section == ProjectPageViewControllerDataSource.Section
      .overviewSubpages.rawValue ? .none : .singleLine
  }
}

// MARK: - MessageDialogViewControllerDelegate

extension ProjectPageViewController: MessageDialogViewControllerDelegate {
  internal func messageDialogWantsDismissal(_ dialog: MessageDialogViewController) {
    dialog.dismiss(animated: true, completion: nil)
  }

  internal func messageDialog(_: MessageDialogViewController, postedMessage _: Message) {}
}

// MARK: - ProjectEnvironmentalCommitmentDisclaimerCellDelegate

extension ProjectPageViewController: ProjectEnvironmentalCommitmentDisclaimerCellDelegate {
  func projectEnvironmentalCommitmentDisclaimerCell(
    _: ProjectEnvironmentalCommitmentDisclaimerCell,
    didTapURL: URL
  ) {
    self.viewModel.inputs.projectEnvironmentalCommitmentDisclaimerCellDidTapURL(didTapURL)
  }
}

// MARK: ProjectRisksDisclaimerCellDelegate

extension ProjectPageViewController: ProjectRisksDisclaimerCellDelegate {
  func projectRisksDisclaimerCell(_: ProjectRisksDisclaimerCell, didTapURL: URL) {
    self.viewModel.inputs.projectRisksDisclaimerCellDidTapURL(didTapURL)
  }
}

// MARK: ProjectPamphletMainCellDelegate

extension ProjectPageViewController: ProjectPamphletMainCellDelegate {
  internal func projectPamphletMainCell(
    _: ProjectPamphletMainCell,
    goToCampaignForProjectWith data: ProjectPamphletMainCellData
  ) {
    let vc = ProjectDescriptionViewController.configuredWith(data: data)
    self.viewModel.inputs.hideNavigationBar()
    self.navigationController?.pushViewController(vc, animated: true)
  }

  internal func projectPamphletMainCell(
    _: ProjectPamphletMainCell,
    addChildController child: UIViewController
  ) {
    self.addChild(child)
    child.beginAppearanceTransition(true, animated: false)
    child.didMove(toParent: self)
    child.endAppearanceTransition()
  }

  internal func projectPamphletMainCell(
    _: ProjectPamphletMainCell,
    goToCreatorForProject project: Project
  ) {
    let vc = ProjectCreatorViewController.configuredWith(project: project)

    if self.traitCollection.userInterfaceIdiom == .pad {
      let nav = UINavigationController(rootViewController: vc)
      nav.modalPresentationStyle = UIModalPresentationStyle.formSheet
      self.present(nav, animated: true, completion: nil)
    } else {
      self.viewModel.inputs.hideNavigationBar()
      self.navigationController?.pushViewController(vc, animated: true)
    }
  }
}

// MARK: ProjectPamphletCreatorHeaderCellDelegate

extension ProjectPageViewController: ProjectPamphletCreatorHeaderCellDelegate {
  func projectPamphletCreatorHeaderCellDidTapViewProgress(
    _: ProjectPamphletCreatorHeaderCell,
    with project: Project
  ) {
    self.viewModel.inputs.tappedViewProgress(of: project)
  }
}

// MARK: - Styles

private let tableViewStyle: TableViewStyle = { tableView in
  tableView
    |> \.estimatedRowHeight .~ 100.0
    |> \.rowHeight .~ UITableView.automaticDimension
}
