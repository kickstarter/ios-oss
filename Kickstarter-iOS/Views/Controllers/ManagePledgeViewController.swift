import KsApi
import Library
import Prelude
import UIKit

protocol ManagePledgeViewControllerDelegate: AnyObject {
  func managePledgeViewController(
    _ viewController: ManagePledgeViewController,
    managePledgeViewControllerFinishedWithMessage message: String?
  )
}

final class ManagePledgeViewController: UIViewController, MessageBannerViewControllerPresenting {
  weak var delegate: ManagePledgeViewControllerDelegate?
  private let viewModel: ManagePledgeViewModelType = ManagePledgeViewModel()

  // MARK: - Properties

  private lazy var closeButton: UIBarButtonItem = {
    UIBarButtonItem(
      image: UIImage(named: "icon--cross"),
      style: .plain,
      target: self,
      action: #selector(ManagePledgeViewController.closeButtonTapped)
    )
  }()

  private lazy var menuButton: UIBarButtonItem = {
    UIBarButtonItem(
      image: UIImage(named: "icon--more-menu"),
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
  }()

  private lazy var paymentMethodViews = {
    [self.paymentMethodView, self.paymentMethodSectionSeparator]
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

  private lazy var refreshControl: UIRefreshControl = { UIRefreshControl() }()

  private lazy var rewardView: ManagePledgeRewardView = {
    ManagePledgeRewardView(frame: .zero)
  }()

  private lazy var rewardReceivedViewController: ManageViewPledgeRewardReceivedViewController = {
    ManageViewPledgeRewardReceivedViewController.instantiate()
  }()

  private lazy var rewardSectionSeparator: UIView = {
    UIView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var rewardSectionViews = {
    [self.rewardView, self.rewardSectionSeparator]
  }()

  private lazy var rootScrollView: UIScrollView = {
    UIScrollView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var rootStackView: UIStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var sectionSeparatorViews = {
    [self.pledgeSummarySectionSeparator, self.paymentMethodSectionSeparator, self.rewardSectionSeparator]
  }()

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    _ = self.navigationItem
      ?|> \.leftBarButtonItem .~ self.closeButton
      ?|> \.rightBarButtonItem .~ self.menuButton

    self.messageBannerViewController = self.configureMessageBannerViewController(on: self)

    self.configureViews()
    self.setupConstraints()

    self.viewModel.inputs.viewDidLoad()
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.view
      |> checkoutBackgroundStyle

    _ = self.closeButton
      |> \.accessibilityLabel %~ { _ in Strings.Dismiss() }
      |> \.width .~ Styles.minTouchSize.width

    _ = self.menuButton
      |> \.accessibilityLabel %~ { _ in Strings.Menu() }

    _ = self.rootScrollView
      |> rootScrollViewStyle

    _ = self.rootStackView
      |> checkoutRootStackViewStyle

    _ = self.sectionSeparatorViews
      ||> separatorStyleDark
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.rewardReceivedViewController.view.rac.hidden =
      self.viewModel.outputs.rewardReceivedViewControllerViewIsHidden

    self.viewModel.outputs.title
      .observeForUI()
      .observeValues { [weak self] title in
        guard let self = self else { return }
        _ = self
          |> \.title .~ title
      }

    self.viewModel.outputs.configurePaymentMethodView
      .observeForUI()
      .observeValues { [weak self] card in
        self?.paymentMethodView.configure(with: card)
      }

    self.viewModel.outputs.configurePledgeSummaryView
      .observeForUI()
      .observeValues { [weak self] project in
        self?.pledgeSummaryViewController.configureWith(project)
      }

    self.viewModel.outputs.configureRewardReceivedWithProject
      .observeForControllerAction()
      .observeValues { [weak self] project in
        self?.rewardReceivedViewController.configureWith(project: project)
      }

    self.viewModel.outputs.configureRewardSummaryView
      .observeForUI()
      .observeValues { [weak self] in
        self?.rewardView.configure(with: $0)
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

    self.viewModel.outputs.goToUpdatePledge
      .observeForControllerAction()
      .observeValues { [weak self] project, reward in
        self?.goToUpdatePledge(project: project, reward: reward)
      }

    self.viewModel.outputs.goToChangePaymentMethod
      .observeForControllerAction()
      .observeValues { [weak self] project, reward in
        self?.goToChangePaymentMethod(project: project, reward: reward)
      }

    self.viewModel.outputs.goToContactCreator
      .observeForControllerAction()
      .observeValues { [weak self] messageSubject, context in
        self?.goToContactCreator(messageSubject: messageSubject, context: context)
      }

    self.viewModel.outputs.goToCancelPledge
      .observeForControllerAction()
      .observeValues { [weak self] project, backing in
        self?.goToCancelPledge(project: project, backing: backing)
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
  }

  // MARK: - Configuration

  func configureWith(project: Project) {
    self.viewModel.inputs.configureWith(project)
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.rootStackView.widthAnchor.constraint(equalTo: self.rootScrollView.widthAnchor)
    ])

    self.sectionSeparatorViews.forEach { view in
      _ = view.heightAnchor.constraint(equalToConstant: 1)
        |> \.isActive .~ true

      view.setContentCompressionResistancePriority(.required, for: .vertical)
    }
  }

  // MARK: Functions

  private func configureViews() {
    _ = (self.rootScrollView, self.view)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = self.rootScrollView
      |> \.refreshControl .~ self.refreshControl

    _ = (self.rootStackView, self.rootScrollView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    let childViews: [UIView] = [
      self.pledgeSummarySectionViews,
      self.paymentMethodViews,
      self.rewardSectionViews,
      [self.rewardReceivedViewController.view]
    ]
    .flatMap { $0 }
    .compact()

    _ = (childViews, self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    [
      self.rewardReceivedViewController,
      self.pledgeSummaryViewController
    ]
    .forEach { viewController in
      self.addChild(viewController)
      viewController.didMove(toParent: self)
    }

    self.refreshControl.addTarget(
      self,
      action: #selector(ManagePledgeViewController.beginRefresh),
      for: .valueChanged
    )
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
      case .updatePledge:
        title = Strings.Update_pledge()
      case .changePaymentMethod:
        title = Strings.Change_payment_method()
      case .chooseAnotherReward:
        title = Strings.Choose_another_reward()
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

  private func goToUpdatePledge(project: Project, reward: Reward) {
    let vc = PledgeViewController.instantiate()
    vc.configureWith(project: project, reward: reward, refTag: nil, context: .update)
    vc.delegate = self

    self.navigationController?.pushViewController(vc, animated: true)
  }

  private func goToCancelPledge(project: Project, backing: Backing) {
    let cancelPledgeViewController = CancelPledgeViewController.instantiate()
      |> \.delegate .~ self
    cancelPledgeViewController.configure(with: project, backing: backing)

    self.navigationController?.pushViewController(cancelPledgeViewController, animated: true)
  }

  private func goToChangePaymentMethod(project: Project, reward: Reward) {
    let vc = PledgeViewController.instantiate()
    vc.configureWith(project: project, reward: reward, refTag: nil, context: .changePaymentMethod)
    vc.delegate = self

    self.navigationController?.pushViewController(vc, animated: true)
  }

  private func goToContactCreator(
    messageSubject: MessageSubject,
    context: Koala.MessageDialogContext
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

// MARK: - PledgeViewControllerDelegate

extension ManagePledgeViewController: PledgeViewControllerDelegate {
  func pledgeViewControllerDidUpdatePledge(_: PledgeViewController, message: String) {
    self.viewModel.inputs.pledgeViewControllerDidUpdatePledgeWithMessage(message)
  }
}

// MARK: Styles

private let rootScrollViewStyle = { (scrollView: UIScrollView) in
  scrollView
    |> \.alwaysBounceVertical .~ true
}

private let rootStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.layoutMargins .~ .init(
      top: Styles.grid(3),
      left: Styles.grid(4),
      bottom: Styles.grid(3),
      right: Styles.grid(4)
    )
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.axis .~ NSLayoutConstraint.Axis.vertical
    |> \.distribution .~ UIStackView.Distribution.fill
    |> \.alignment .~ UIStackView.Alignment.fill
    |> \.spacing .~ Styles.grid(4)
}

extension ManagePledgeViewController: MessageDialogViewControllerDelegate {
  internal func messageDialogWantsDismissal(_ dialog: MessageDialogViewController) {
    dialog.dismiss(animated: true, completion: nil)
  }

  internal func messageDialog(_: MessageDialogViewController, postedMessage _: Message) {}
}
