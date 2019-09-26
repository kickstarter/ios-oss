import KsApi
import Library
import Prelude
import Stripe
import UIKit

final class PledgeViewController: UIViewController, MessageBannerViewControllerPresenting {
  // MARK: - Properties

  private lazy var descriptionSectionSeparator: UIView = {
    UIView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var sectionSeparatorViews = {
    [self.descriptionSectionSeparator, self.summarySectionSeparator]
  }()

  private lazy var summarySectionSeparator: UIView = {
    UIView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var pledgeAmountViewController = {
    PledgeAmountViewController.instantiate()
      |> \.delegate .~ self
  }()

  private lazy var continueViewController = {
    PledgeContinueViewController.instantiate()
  }()

  private lazy var descriptionSectionViews = {
    [self.descriptionViewController.view, self.descriptionSectionSeparator]
  }()

  private lazy var descriptionViewController = {
    PledgeDescriptionViewController.instantiate()
  }()

  private lazy var inputsSectionViews = {
    [self.pledgeAmountViewController.view, self.shippingLocationViewController.view]
  }()

  private lazy var loginSectionViews = {
    [self.continueViewController.view]
  }()

  internal var messageBannerViewController: MessageBannerViewController?

  private lazy var paymentMethodsSectionViews = {
    [self.paymentMethodsViewController.view]
  }()

  private lazy var paymentMethodsViewController = {
    PledgePaymentMethodsViewController.instantiate()
      |> \.messageDisplayingDelegate .~ self
      |> \.delegate .~ self
  }()

  private lazy var shippingLocationViewController = {
    PledgeShippingLocationViewController.instantiate()
      |> \.delegate .~ self
  }()

  private lazy var summarySectionViews = {
    [self.summarySectionSeparator, self.summaryViewController.view]
  }()

  private lazy var summaryViewController = {
    PledgeSummaryViewController.instantiate()
  }()

  private lazy var rootScrollView: UIScrollView = { UIScrollView(frame: .zero) }()
  private lazy var rootStackView: UIStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private var sessionStartedObserver: Any?
  private let viewModel: PledgeViewModelType = PledgeViewModel()

  // MARK: - Lifecycle

  func configureWith(project: Project, reward: Reward, refTag: RefTag?) {
    self.viewModel.inputs.configureWith(project: project, reward: reward, refTag: refTag)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    _ = self
      |> \.extendedLayoutIncludesOpaqueBars .~ true

    self.messageBannerViewController = self.configureMessageBannerViewController(on: self)

    _ = self
      |> \.title %~ { _ in Strings.Back_this_project() }

    _ = (self.rootScrollView, self.view)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = (self.rootStackView, self.rootScrollView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    self.view.addGestureRecognizer(
      UITapGestureRecognizer(target: self, action: #selector(PledgeViewController.dismissKeyboard))
    )

    self.configureChildViewControllers()
    self.setupConstraints()

    self.viewModel.inputs.viewDidLoad()
  }

  deinit {
    self.sessionStartedObserver.doIfSome(NotificationCenter.default.removeObserver)
  }

  // MARK: - Configuration

  private func configureChildViewControllers() {
    let childViewControllers = [
      self.descriptionViewController,
      self.pledgeAmountViewController,
      self.shippingLocationViewController,
      self.summaryViewController,
      self.continueViewController,
      self.paymentMethodsViewController
    ]

    let arrangedSubviews = [
      self.descriptionSectionViews,
      self.inputsSectionViews,
      self.summarySectionViews,
      self.loginSectionViews,
      self.paymentMethodsSectionViews
    ]
    .flatMap { $0 }
    .compact()

    arrangedSubviews.forEach { view in
      self.rootStackView.addArrangedSubview(view)
    }

    childViewControllers.forEach { viewController in
      self.addChild(viewController)
      viewController.didMove(toParent: self)
    }
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

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.view
      |> checkoutBackgroundStyle

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

    self.viewModel.outputs.configureStripeIntegration
      .observeForUI()
      .observeValues { merchantIdentifier, publishableKey in
        STPPaymentConfiguration.shared().publishableKey = publishableKey
        STPPaymentConfiguration.shared().appleMerchantIdentifier = merchantIdentifier
      }

    self.viewModel.outputs.configureWithData
      .observeForUI()
      .observeValues { [weak self] data in
        self?.descriptionViewController.configureWith(value: data)
        self?.pledgeAmountViewController.configureWith(value: data)
        self?.shippingLocationViewController.configureWith(value: data)
      }

    self.viewModel.outputs.configureSummaryViewControllerWithData
      .observeForUI()
      .observeValues { [weak self] project, pledgeTotal in
        self?.summaryViewController.configureWith(value: (project, pledgeTotal))
      }
    self.viewModel.outputs.configurePaymentMethodsViewControllerWithValue
      .observeForUI()
      .observeValues { [weak self] value in
        self?.paymentMethodsViewController.configure(with: value)
      }

    self.sessionStartedObserver = NotificationCenter.default
      .addObserver(forName: .ksr_sessionStarted, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.userSessionStarted()
      }

    self.viewModel.outputs.updatePledgeButtonEnabled
      .observeForUI()
      .observeValues { [weak self] isEnabled in
        self?.paymentMethodsViewController.updatePledgeButton(isEnabled)
      }

    self.viewModel.outputs.goToApplePayPaymentAuthorization
      .observeForControllerAction()
      .observeValues { [weak self] paymentAuthorizationData in
        self?.goToPaymentAuthorization(paymentAuthorizationData)
      }

    self.viewModel.outputs.goToThanks
      .observeForControllerAction()
      .observeValues { [weak self] project in
        generateNotificationSuccessFeedback()

        self?.goToThanks(project: project)
      }

    Keyboard.change
      .observeForUI()
      .observeValues { [weak self] change in
        self?.rootScrollView.handleKeyboardVisibilityDidChange(change)
      }

    self.shippingLocationViewController.view.rac.hidden
      = self.viewModel.outputs.shippingLocationViewHidden
    self.continueViewController.view.rac.hidden = self.viewModel.outputs.continueViewHidden
    self.paymentMethodsViewController.view.rac.hidden = self.viewModel.outputs.paymentMethodsViewHidden

    // MARK: Errors

    self.viewModel.outputs.createBackingError
      .observeForUI()
      .observeValues { [weak self] errorMessage in
        self?.messageBannerViewController?.showBanner(with: .error, message: errorMessage)
      }
  }

  private func goToPaymentAuthorization(_ paymentAuthorizationData: PaymentAuthorizationData) {
    let request = PKPaymentRequest
      .paymentRequest(
        for: paymentAuthorizationData.project,
        reward: paymentAuthorizationData.reward,
        pledgeAmount: paymentAuthorizationData.pledgeAmount,
        selectedShippingRule: paymentAuthorizationData.selectedShippingRule,
        merchantIdentifier: paymentAuthorizationData.merchantIdentifier
      )

    guard
      let paymentAuthorizationViewController = PKPaymentAuthorizationViewController(paymentRequest: request)
    else { return }
    paymentAuthorizationViewController.delegate = self

    self.present(paymentAuthorizationViewController, animated: true)
  }

  private func goToThanks(project: Project) {
    let thanksVC = ThanksViewController.configuredWith(project: project)
    self.navigationController?.pushViewController(thanksVC, animated: true)
  }

  // MARK: - Actions

  @objc private func dismissKeyboard() {
    self.view.endEditing(true)
  }
}

// MARK: - PKPaymentAuthorizationViewControllerDelegate

extension PledgeViewController: PKPaymentAuthorizationViewControllerDelegate {
  func paymentAuthorizationViewController(
    _: PKPaymentAuthorizationViewController,
    didAuthorizePayment payment: PKPayment,
    handler completion: @escaping (PKPaymentAuthorizationResult)
      -> Void
  ) {
    let paymentDisplayName = payment.token.paymentMethod.displayName
    let paymentNetworkName = payment.token.paymentMethod.network?.rawValue
    let transactionId = payment.token.transactionIdentifier

    self.viewModel.inputs.paymentAuthorizationDidAuthorizePayment(paymentData: (
      paymentDisplayName,
      paymentNetworkName,
      transactionId
    ))

    STPAPIClient.shared().createToken(with: payment) { [weak self] token, error in
      guard let self = self else { return }

      let status = self.viewModel.inputs.stripeTokenCreated(token: token?.tokenId, error: error)
      let result = PKPaymentAuthorizationResult(status: status, errors: [])

      completion(result)
    }
  }

  func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
    controller.dismiss(animated: true, completion: { [weak self] in
      self?.viewModel.inputs.paymentAuthorizationViewControllerDidFinish()
    })
  }
}

// MARK: - PledgeAmountViewControllerDelegate

extension PledgeViewController: PledgeAmountViewControllerDelegate {
  func pledgeAmountViewController(
    _: PledgeAmountViewController,
    didUpdateAmount amount: Double
  ) {
    self.viewModel.inputs.pledgeAmountDidUpdate(to: amount)
  }
}

// MARK: - PledgeShippingLocationViewControllerDelegate

extension PledgeViewController: PledgeShippingLocationViewControllerDelegate {
  func pledgeShippingLocationViewController(
    _: PledgeShippingLocationViewController,
    didSelect shippingRule: ShippingRule
  ) {
    self.viewModel.inputs.shippingRuleSelected(shippingRule)
  }
}

// MARK: - RewardPledgeTransitionAnimatorDelegate

extension PledgeViewController: RewardPledgeTransitionAnimatorDelegate {
  func beginTransition(_ operation: UINavigationController.Operation) {
    self.descriptionViewController.beginTransition(operation)
  }

  func snapshotData(withContainerView view: UIView) -> RewardPledgeTransitionSnapshotData? {
    return self.descriptionViewController.snapshotData(withContainerView: view)
  }

  func destinationFrameData(withContainerView view: UIView) -> RewardPledgeTransitionDestinationFrameData? {
    guard let (destination, mask) = self.descriptionViewController
      .destinationFrameData(withContainerView: view)
    else { return nil }

    let offsetDestination = destination
      .offsetBy(dx: 0, dy: -self.view.safeAreaInsets.top)

    return (offsetDestination, mask)
  }

  func endTransition(_ operation: UINavigationController.Operation) {
    self.descriptionViewController.endTransition(operation)
  }
}

// MARK: - PledgeViewControllerMessageDisplaying

extension PledgeViewController: PledgeViewControllerMessageDisplaying {
  func pledgeViewController(_: UIViewController, didErrorWith message: String) {
    self.messageBannerViewController?.showBanner(with: .error, message: message)
  }

  func pledgeViewController(_: UIViewController, didSucceedWith message: String) {
    self.messageBannerViewController?.showBanner(with: .success, message: message)
  }
}

// MARK: - PledgePaymentMethodsViewControllerDelegate

extension PledgeViewController: PledgePaymentMethodsViewControllerDelegate {
  func pledgePaymentMethodsViewControllerDidTapApplePayButton(
    _: PledgePaymentMethodsViewController
  ) {
    self.viewModel.inputs.applePayButtonTapped()
  }

  func pledgePaymentMethodsViewController(
    _: PledgePaymentMethodsViewController,
    didSelectCreditCard paymentSourceId: String
  ) {
    self.viewModel.inputs.creditCardSelected(with: paymentSourceId)
  }

  func pledgePaymentMethodsViewControllerDidTapPledgeButton(
    _:
    PledgePaymentMethodsViewController
  ) {
    self.viewModel.inputs.pledgeButtonTapped()
  }
}

// MARK: - Styles

private let rootScrollViewStyle: ScrollStyle = { scrollView in
  scrollView
    |> UIScrollView.lens.showsVerticalScrollIndicator .~ false
    |> \.alwaysBounceVertical .~ true
}
