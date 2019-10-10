import KsApi
import Library
import Prelude
import UIKit

protocol ManagePledgeViewControllerDelegate: AnyObject {
  func managePledgeViewController(
    _ viewController: ManagePledgeViewController,
    shouldDismissAndShowSuccessBannerWith message: String
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

  private lazy var pledgeSummaryView: ManagePledgeSummaryView = { ManagePledgeSummaryView(frame: .zero) }()

  private lazy var pledgeSummarySectionViews = {
    [self.pledgeSummaryView, self.pledgeSummarySectionSeparator]
  }()

  private lazy var pledgeSummarySectionSeparator: UIView = {
    UIView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

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

  static func instantiate(with project: Project, reward: Reward) -> ManagePledgeViewController {
    let manageViewPledgeVC = ManagePledgeViewController.instantiate()
    manageViewPledgeVC.viewModel.inputs.configureWith(project, reward: reward)

    return manageViewPledgeVC
  }

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
        self?.pledgeSummaryView.configureWith(project)
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
      .observeValues { [weak self] in
        self?.goToChangePaymentMethod()
      }

    self.viewModel.outputs.goToContactCreator
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.goToContactCreator()
      }

    self.viewModel.outputs.goToCancelPledge
      .observeForControllerAction()
      .observeValues { [weak self] project, backing in
        self?.goToCancelPledge(project: project, backing: backing)
      }

    self.viewModel.outputs.notifyDelegateShouldDismissAndShowSuccessBannerWithMessage
      .observeForUI()
      .observeValues { [weak self] message in
        guard let self = self else { return }
        self.delegate?.managePledgeViewController(
          self,
          shouldDismissAndShowSuccessBannerWith: message
        )
      }

    self.viewModel.outputs.showSuccessBannerWithMessage
      .observeForControllerAction()
      .observeValues { [weak self] message in
        guard let self = self else { return }

        self.messageBannerViewController?.showBanner(with: .success, message: message)
      }
  }

  // MARK: - Configuration

  func configureWith(project: Project, reward: Reward) {
    self.viewModel.inputs.configureWith(project, reward: reward)
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

    _ = (childViews, self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    self.addChild(self.rewardReceivedViewController)
    self.rewardReceivedViewController.didMove(toParent: self)
  }

  // MARK: Actions

  @objc private func menuButtonTapped() {
    self.viewModel.inputs.menuButtonTapped()
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
    let rewardsVC = RewardsCollectionViewController.instantiate(with: project, refTag: nil)

    self.navigationController?.pushViewController(rewardsVC, animated: true)
  }

  private func goToUpdatePledge(project: Project, reward: Reward) {
    let vc = PledgeViewController.instantiate()
    vc.configureWith(project: project, reward: reward, refTag: nil, context: .update)
    vc.delegate = self

    self.show(vc, sender: nil)
  }

  private func goToCancelPledge(project: Project, backing: Backing) {
    let cancelPledgeViewController = CancelPledgeViewController.instantiate()
      |> \.delegate .~ self
    cancelPledgeViewController.configure(with: project, backing: backing)

    self.navigationController?.pushViewController(cancelPledgeViewController, animated: true)
  }

  private func goToChangePaymentMethod() {
    // TODO:
  }

  private func goToContactCreator() {
    // TODO:
  }
}

// MARK: CancelPledgeViewControllerDelegate

extension ManagePledgeViewController: CancelPledgeViewControllerDelegate {
  func cancelPledgeViewController(
    _: CancelPledgeViewController,
    didCancelPledgeWith message: String
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
