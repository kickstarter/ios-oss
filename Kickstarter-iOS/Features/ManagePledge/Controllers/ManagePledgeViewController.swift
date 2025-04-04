import KsApi
import Library
import Prelude
import UIKit

protocol ManagePledgeViewControllerDelegate: AnyObject {
  func managePledgeViewController(
    _ viewController: ManagePledgeViewController,
    managePledgeViewControllerFinishedWithMessage message: String?
  )

  func managePledgeViewControllerDidDismiss(_ viewController: ManagePledgeViewController)
}

final class ManagePledgeViewController: UIViewController, MessageBannerViewControllerPresenting {
  weak var delegate: ManagePledgeViewControllerDelegate?
  private let viewModel: ManagePledgeViewModelType = ManagePledgeViewModel()

  // MARK: - Properties

  internal lazy var tableView: UITableView = {
    UITableView(frame: .zero)
      |> \.alwaysBounceVertical .~ true
      |> \.dataSource .~ self.dataSource
      |> \.rowHeight .~ UITableView.automaticDimension
      |> \.tableFooterView .~ UIView(frame: .zero)
  }()

  private let dataSource = ManagePledgeDataSource()

  private lazy var closeButton: UIBarButtonItem = {
    UIBarButtonItem(
      image: image(named: "icon--cross"),
      style: .plain,
      target: self,
      action: #selector(ManagePledgeViewController.closeButtonTapped)
    )
  }()

  private lazy var headerView: UIView = {
    UIView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var menuButton: UIBarButtonItem = {
    UIBarButtonItem(
      image: image(named: "icon--more-menu"),
      style: .plain,
      target: self,
      action: #selector(ManagePledgeViewController.menuButtonTapped)
    )
  }()

  internal var messageBannerViewController: MessageBannerViewController?

  private lazy var paymentMethodSectionSeparator: UIView = {
    UIView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var paymentMethodView: ManagePledgePaymentMethodView = {
    ManagePledgePaymentMethodView(frame: .zero)
      |> \.delegate .~ self
  }()

  private lazy var paymentMethodViews = {
    [self.paymentMethodView, self.paymentMethodSectionSeparator]
  }()

  private lazy var plotPaymentScheduleViewController: PledgeOverTimePaymentScheduleViewController = {
    let controller = PledgeOverTimePaymentScheduleViewController.instantiate()
    controller.delegate = self
    return controller
  }()

  private lazy var plotPaymentScheduleSectionSeparator: UIView = {
    UIView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var plotPaymentScheduleStackView = { UIStackView(frame: .zero) }()

  private lazy var pledgeDetailsSectionLabel: UILabel = {
    UILabel(frame: .zero)
  }()

  private lazy var pledgeDetailsSectionViews = {
    [self.pledgeDetailsSectionLabel]
  }()

  private lazy var pledgeSummaryViewController: ManagePledgeSummaryViewController = {
    ManagePledgeSummaryViewController.instantiate()
  }()

  private lazy var pledgeSummarySectionViews = {
    [self.pledgeSummaryViewController.view, self.pledgeSummarySectionSeparator]
  }()

  private lazy var pledgeSummarySectionSeparator: UIView = {
    UIView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var pullToRefreshImageView: UIImageView = {
    UIImageView(image: image(named: "icon--refresh-small"))
  }()

  private lazy var pullToRefreshLabel: UILabel = {
    UILabel(frame: .zero)
  }()

  private lazy var pullToRefreshHeaderView: UIView = {
    UIView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var pullToRefreshStackView: UIStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var refreshControl: UIRefreshControl = { UIRefreshControl() }()

  private lazy var rootStackView: UIStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var sectionSeparatorViews = {
    [
      self.pledgeSummarySectionSeparator,
      self.paymentMethodSectionSeparator,
      self.plotPaymentScheduleSectionSeparator
    ]
  }()

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    _ = self.navigationItem
      ?|> \.leftBarButtonItem .~ self.closeButton
      ?|> \.rightBarButtonItem .~ self.menuButton

    self.messageBannerViewController = self.configureMessageBannerViewController(on: self)

    self.tableView.registerCellClass(RewardTableViewCell.self)

    self.refreshControl.addTarget(
      self,
      action: #selector(ManagePledgeViewController.beginRefresh),
      for: .valueChanged
    )

    self.configureViews()

    self.viewModel.inputs.viewDidLoad()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    self.tableView.ksr_sizeHeaderFooterViewsToFit()
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.tableView
      |> checkoutBackgroundStyle

    _ = self.closeButton
      |> \.accessibilityLabel %~ { _ in Strings.Dismiss() }
      |> \.width .~ Styles.minTouchSize.width

    _ = self.menuButton
      |> \.accessibilityLabel %~ { _ in Strings.Menu() }

    _ = self.rootStackView
      |> checkoutRootStackViewStyle

    _ = self.pledgeDetailsSectionLabel
      |> pledgeDetailsSectionLabelStyle

    _ = self.sectionSeparatorViews
      ||> separatorStyleDark

    applyPlotPaymentScheduleStackViewStyle(self.plotPaymentScheduleStackView)
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.pledgeDetailsSectionLabel.rac.text = self.viewModel.outputs.pledgeDetailsSectionLabelText

    self.viewModel.outputs.paymentMethodViewHidden
      .observeForUI()
      .observeValues { [weak self] hidden in
        self?.paymentMethodViews.forEach { $0.isHidden = hidden }
      }

    self.viewModel.outputs.rightBarButtonItemHidden
      .observeForUI()
      .observeValues { [weak self] hidden in
        self?.navigationItem.rightBarButtonItem = hidden ? nil : self?.menuButton
      }

    self.viewModel.outputs.title
      .observeForUI()
      .observeValues { [weak self] title in
        guard let self = self else { return }
        _ = self
          |> \.title .~ title
      }

    self.viewModel.outputs.configurePaymentMethodView
      .observeForUI()
      .observeValues { [weak self] backing in
        self?.paymentMethodView.configure(with: backing)
      }

    self.viewModel.outputs.configurePledgeSummaryView
      .observeForUI()
      .observeValues { [weak self] data in
        self?.pledgeSummaryViewController.configureWith(data)
      }

    self.viewModel.outputs.loadProjectAndRewardsIntoDataSource
      .observeForUI()
      .observeValues { [weak self] project, rewards in
        self?.dataSource.load(project: project, rewards: rewards)
        self?.configureHeaderView()
        self?.tableView.reloadData()
        self?.tableView.setNeedsLayout()
      }

    self.viewModel.outputs.loadPullToRefreshHeaderView
      .observeForUI()
      .observeValues { [weak self] in
        self?.dataSource.clearValues()
        self?.configurePullToRefreshHeaderView()
      }

    self.viewModel.outputs.startRefreshing
      .observeForUI()
      .observeValues { [weak self] in
        self?.refreshControl.ksr_beginRefreshing()
      }

    self.viewModel.outputs.endRefreshing
      .observeForUI()
      .observeValues { [weak self] in
        self?.refreshControl.endRefreshing()
      }

    self.viewModel.outputs.showActionSheetMenuWithOptions
      .observeForControllerAction()
      .observeValues { [weak self] options in
        self?.showActionSheetMenuWithOptions(options)
      }

    self.viewModel.outputs.goToRewards
      .observeForControllerAction()
      .observeValues { [weak self] project in
        self?.goToRewards(project)
      }

    self.viewModel.outputs.goToChangePaymentMethod
      .observeForControllerAction()
      .observeValues { [weak self] data in
        self?.goToChangePaymentMethod(data: data)
      }

    self.viewModel.outputs.goToFixPaymentMethod
      .observeForControllerAction()
      .observeValues { [weak self] data in
        self?.goToFixPaymentMethod(data: data)
      }

    self.viewModel.outputs.goToContactCreator
      .observeForControllerAction()
      .observeValues { [weak self] messageSubject, context in
        self?.goToContactCreator(messageSubject: messageSubject, context: context)
      }

    self.viewModel.outputs.goToCancelPledge
      .observeForControllerAction()
      .observeValues { [weak self] data in
        self?.goToCancelPledge(with: data)
      }

    self.viewModel.outputs.notifyDelegateManagePledgeViewControllerFinishedWithMessage
      .observeForUI()
      .observeValues { [weak self] message in
        guard let self = self else { return }
        self.delegate?.managePledgeViewController(
          self,
          managePledgeViewControllerFinishedWithMessage: message
        )
      }

    self.viewModel.outputs.showSuccessBannerWithMessage
      .observeForControllerAction()
      .observeValues { [weak self] message in
        guard let self = self else { return }

        self.messageBannerViewController?.showBanner(with: .success, message: message)
      }

    self.viewModel.outputs.showErrorBannerWithMessage
      .observeForControllerAction()
      .observeValues { [weak self] errorMessage in
        self?.messageBannerViewController?.showBanner(with: .error, message: errorMessage)
      }

    self.plotPaymentScheduleStackView.rac.hidden = self.viewModel.outputs.plotPaymentScheduleViewHidden

    self.viewModel.outputs.configurePlotPaymentScheduleView
      .observeForUI()
      .observeValues { [weak self] increments in
        self?.plotPaymentScheduleViewController.configure(with: increments)
      }

    self.viewModel.outputs.showWebHelp
      .observeForControllerAction()
      .observeValues { [weak self] helpType in
        guard let self = self else { return }
        self.presentHelpWebViewController(with: helpType, presentationStyle: .formSheet)
      }
  }

  // MARK: - Configuration

  func configureWith(params: ManagePledgeViewParamConfigData) {
    self.viewModel.inputs.configureWith(params)
  }

  /// Toggles the collapsed state of the `PledgeOverTimePaymentScheduleViewController` via its `collapseToggle` function.
  /// This is used specifically in UI tests to simulate user interaction and verify correct behavior
  /// during transitions between collapsed and expanded states.
  ///
  /// This method directly interacts with the `PledgeOverTimePaymentScheduleViewController` to test collapse functionality.
  public func plotPaymentScheduleToggle() {
    self.plotPaymentScheduleViewController.collapseToggle()
  }

  // MARK: Functions

  private func configureViews() {
    _ = (self.tableView, self.view)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = self.tableView
      |> \.refreshControl .~ self.refreshControl

    self.plotPaymentScheduleStackView.addArrangedSubviews(
      self.plotPaymentScheduleViewController.view,
      self.plotPaymentScheduleSectionSeparator
    )
  }

  private func configureHeaderView() {
    guard self.tableView.tableHeaderView != self.headerView else { return }

    _ = (self.rootStackView, self.headerView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    let childViews: [UIView] = [
      self.pledgeSummarySectionViews,
      self.paymentMethodViews,
      [self.plotPaymentScheduleStackView],
      self.pledgeDetailsSectionViews
    ]
    .flatMap { $0 }
    .compact()

    _ = (childViews, self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    [
      self.pledgeSummaryViewController,
      self.plotPaymentScheduleViewController
    ]
    .forEach { viewController in
      self.addChild(viewController)
      viewController.didMove(toParent: self)
    }

    self.sectionSeparatorViews.forEach { view in
      _ = view.heightAnchor.constraint(equalToConstant: 1)
        |> \.isActive .~ true

      view.setContentCompressionResistancePriority(.required, for: .vertical)
    }

    self.tableView.tableHeaderView = self.headerView

    self.headerView.widthAnchor.constraint(equalTo: self.tableView.widthAnchor).isActive = true
  }

  private func configurePullToRefreshHeaderView() {
    guard self.tableView.tableHeaderView != self.pullToRefreshHeaderView else { return }

    _ = (self.pullToRefreshStackView, self.pullToRefreshHeaderView)
      |> ksr_addSubviewToParent()

    _ = ([self.pullToRefreshImageView, self.pullToRefreshLabel], self.pullToRefreshStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = self.pullToRefreshLabel
      |> \.text %~ { _ in
        Strings.Something_went_wrong_pull_to_refresh()
      }

    _ = self.pullToRefreshStackView
      |> \.axis .~ .vertical
      |> \.spacing .~ Styles.grid(2)
      |> \.alignment .~ .center

    self.tableView.tableHeaderView = self.pullToRefreshHeaderView

    NSLayoutConstraint.activate([
      self.pullToRefreshStackView.leftAnchor.constraint(equalTo: self.pullToRefreshHeaderView.leftAnchor),
      self.pullToRefreshStackView.rightAnchor.constraint(equalTo: self.pullToRefreshHeaderView.rightAnchor),
      self.pullToRefreshStackView.centerXAnchor
        .constraint(equalTo: self.pullToRefreshHeaderView.centerXAnchor),
      self.pullToRefreshStackView.centerYAnchor.constraint(
        equalTo: self.pullToRefreshHeaderView.centerYAnchor, constant: -Styles.grid(8)
      ),
      self.pullToRefreshHeaderView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
      self.pullToRefreshHeaderView.heightAnchor.constraint(equalTo: self.view.heightAnchor)
    ])
  }

  // MARK: Actions

  @objc private func menuButtonTapped() {
    self.viewModel.inputs.menuButtonTapped()
  }

  @objc private func beginRefresh() {
    self.viewModel.inputs.beginRefresh()
  }

  private func showActionSheetMenuWithOptions(_ options: [ManagePledgeAlertAction]) {
    let actionSheet = UIAlertController.alert(
      title: Strings.Select_an_option(),
      preferredStyle: .actionSheet,
      barButtonItem: self.menuButton
    )

    options.forEach { option in
      let title: String

      switch option {
      case .changePaymentMethod:
        title = Strings.Change_payment_method()
      case .chooseAnotherReward:
        title = Strings.Edit_reward()
      case .contactCreator:
        title = Strings.Contact_creator()
      case .cancelPledge:
        title = Strings.Cancel_pledge()
      case .viewRewards:
        title = Strings.View_rewards()
      }

      let style: UIAlertAction.Style = option == .cancelPledge ? .destructive : .default

      actionSheet.addAction(
        UIAlertAction(title: title, style: style, handler: { _ in
          self.viewModel.inputs.menuOptionSelected(with: option)
        })
      )
    }

    actionSheet.addAction(
      UIAlertAction(title: Strings.Cancel(), style: .cancel)
    )

    self.present(actionSheet, animated: true)
  }

  @objc private func closeButtonTapped() {
    self.dismiss(animated: true)
    self.delegate?.managePledgeViewControllerDidDismiss(self)
  }

  // MARK: - Functions

  private func goToRewards(_ project: Project) {
    let vc = RewardsCollectionViewController.instantiate(
      with: project,
      refTag: nil,
      context: .managePledge
    )
    vc.pledgeViewDelegate = self

    self.navigationController?.pushViewController(vc, animated: true)
  }

  private func goToCancelPledge(with data: CancelPledgeViewData) {
    let cancelPledgeViewController = CancelPledgeViewController.instantiate()
      |> \.delegate .~ self
    cancelPledgeViewController.configure(with: data)

    self.navigationController?.pushViewController(cancelPledgeViewController, animated: true)
  }

  private func goToChangePaymentMethod(data: PledgeViewData) {
    let vc = PledgeViewController.instantiate()
    vc.configure(with: data)
    vc.delegate = self

    self.navigationController?.pushViewController(vc, animated: true)
  }

  private func goToFixPaymentMethod(data: PledgeViewData) {
    let vc = PledgeViewController.instantiate()
    vc.configure(with: data)
    vc.delegate = self

    self.navigationController?.pushViewController(vc, animated: true)
  }

  private func goToContactCreator(
    messageSubject: MessageSubject,
    context: KSRAnalytics.MessageDialogContext
  ) {
    let vc = MessageDialogViewController.configuredWith(messageSubject: messageSubject, context: context)
    let nav = UINavigationController(rootViewController: vc)
    nav.modalPresentationStyle = .formSheet
    vc.delegate = self
    self.present(nav, animated: true, completion: nil)
  }
}

// MARK: CancelPledgeViewControllerDelegate

extension ManagePledgeViewController: CancelPledgeViewControllerDelegate {
  func cancelPledgeViewController(
    _: CancelPledgeViewController,
    didCancelPledgeWithMessage message: String
  ) {
    self.viewModel.inputs.cancelPledgeDidFinish(with: message)
  }
}

extension ManagePledgeViewController: ManagePledgePaymentMethodViewDelegate {
  func managePledgePaymentMethodViewDidTapFixButton(_: ManagePledgePaymentMethodView) {
    self.viewModel.inputs.fixButtonTapped()
  }
}

// MARK: - PledgeViewControllerDelegate

extension ManagePledgeViewController: PledgeViewControllerDelegate {
  func pledgeViewControllerDidUpdatePledge(_: PledgeViewController, message: String) {
    self.viewModel.inputs.pledgeViewControllerDidUpdatePledgeWithMessage(message)
  }
}

// MARK: Styles

private let pledgeDetailsSectionLabelStyle: LabelStyle = { label in
  label
    |> checkoutTitleLabelStyle
}

private func applyPlotPaymentScheduleStackViewStyle(_ stackView: UIStackView) {
  stackView.axis = .vertical
  stackView.spacing = Styles.grid(4)
}

extension ManagePledgeViewController: MessageDialogViewControllerDelegate {
  internal func messageDialogWantsDismissal(_ dialog: MessageDialogViewController) {
    dialog.dismiss(animated: true, completion: nil)
  }

  internal func messageDialog(_: MessageDialogViewController, postedMessage _: Message) {}
}

extension ManagePledgeViewController {
  public static func controller(
    with params: ManagePledgeViewParamConfigData,
    delegate: ManagePledgeViewControllerDelegate? = nil
  ) -> UINavigationController {
    let managePledgeViewController = ManagePledgeViewController
      .instantiate()
    managePledgeViewController.configureWith(params: params)
    managePledgeViewController.delegate = delegate

    let closeButton = UIBarButtonItem(
      image: image(named: "icon--cross"),
      style: .plain,
      target: managePledgeViewController,
      action: #selector(ManagePledgeViewController.closeButtonTapped)
    )

    _ = closeButton
      |> \.width .~ Styles.minTouchSize.width
      |> \.accessibilityLabel %~ { _ in Strings.Dismiss() }

    managePledgeViewController.navigationItem.setLeftBarButton(closeButton, animated: false)

    let navigationController = RewardPledgeNavigationController(
      rootViewController: managePledgeViewController
    )

    if AppEnvironment.current.device.userInterfaceIdiom == .pad {
      _ = navigationController
        |> \.modalPresentationStyle .~ .pageSheet
    }

    return navigationController
  }
}

// MARK: - PledgeOverTimePaymentScheduleViewControllerDelegate

extension ManagePledgeViewController: PledgeOverTimePaymentScheduleDelegate {
  func termsOfUseTapped(with helpType: HelpType) {
    self.viewModel.inputs.termsOfUseTapped(with: helpType)
  }
}
