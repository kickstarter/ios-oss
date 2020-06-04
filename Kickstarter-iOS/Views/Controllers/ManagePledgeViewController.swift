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
      |> \.delegate .~ self
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

  private lazy var pullToRefreshImageView: UIImageView = {
    UIImageView(image: image(named: "icon--refresh-small"))
  }()

  private lazy var pullToRefreshLabel: UILabel = {
    UILabel(frame: .zero)
  }()

  private lazy var pullToRefreshStackView: UIStackView = {
    UIStackView(frame: .zero)
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

    _ = self.pullToRefreshLabel
      |> \.text %~ { _ in localizedString(
        key: "Something_went_wrong_pull_to_refresh",
        defaultValue: "Something went wrong, pull to refresh."
      )
      }

    _ = self.pullToRefreshStackView
      |> \.axis .~ .vertical
      |> \.spacing .~ Styles.grid(2)
      |> \.alignment .~ .center

    _ = self.sectionSeparatorViews
      ||> separatorStyleDark
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.pullToRefreshStackView.rac.hidden = self.viewModel.outputs.pullToRefreshStackViewHidden
    self.rootStackView.rac.hidden = self.viewModel.outputs.rootStackViewHidden
    self.rewardReceivedViewController.view.rac.hidden =
      self.viewModel.outputs.rewardReceivedViewControllerViewIsHidden

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

    self.viewModel.outputs.goToFixPaymentMethod
      .observeForControllerAction()
      .observeValues { [weak self] project, reward in
        self?.goToFixPaymentMethod(project: project, reward: reward)
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
  }

  // MARK: - Configuration

  func configureWith(params: ManagePledgeViewParamConfigData) {
    self.viewModel.inputs.configureWith(params)
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      // rootStackView
      self.rootStackView.widthAnchor.constraint(equalTo: self.rootScrollView.widthAnchor),

      // pullToRefreshStackView
      self.pullToRefreshStackView.leftAnchor.constraint(equalTo: self.rootScrollView.leftAnchor),
      self.pullToRefreshStackView.rightAnchor.constraint(equalTo: self.rootScrollView.rightAnchor),
      self.pullToRefreshStackView.centerXAnchor.constraint(equalTo: self.rootScrollView.centerXAnchor),
      self.pullToRefreshStackView.centerYAnchor.constraint(
        equalTo: self.rootScrollView.centerYAnchor, constant: -Styles.grid(8)
      )
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

    _ = (self.pullToRefreshStackView, self.rootScrollView)
      |> ksr_addSubviewToParent()

    _ = ([self.pullToRefreshImageView, self.pullToRefreshLabel], self.pullToRefreshStackView)
      |> ksr_addArrangedSubviewsToStackView()

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

  private func goToCancelPledge(with data: CancelPledgeViewData) {
    let cancelPledgeViewController = CancelPledgeViewController.instantiate()
      |> \.delegate .~ self
    cancelPledgeViewController.configure(with: data)

    self.navigationController?.pushViewController(cancelPledgeViewController, animated: true)
  }

  private func goToChangePaymentMethod(project: Project, reward: Reward) {
    let vc = PledgeViewController.instantiate()
    vc.configureWith(project: project, reward: reward, refTag: nil, context: .changePaymentMethod)
    vc.delegate = self

    self.navigationController?.pushViewController(vc, animated: true)
  }

  private func goToFixPaymentMethod(project: Project, reward: Reward) {
    let vc = PledgeViewController.instantiate()
    vc.configureWith(project: project, reward: reward, refTag: nil, context: .fixPaymentMethod)
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

extension ManagePledgeViewController: ManagePledgePaymentMethodViewDelegate {
  func managePledgePaymentMethodViewDidTapFixButton(_: ManagePledgePaymentMethodView) {
    self.viewModel.inputs.fixButtonTapped()
  }
}

// MARK: Styles

private let rootScrollViewStyle = { (scrollView: UIScrollView) in
  scrollView
    |> \.alwaysBounceVertical .~ true
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
      image: UIImage(named: "icon--cross"),
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
