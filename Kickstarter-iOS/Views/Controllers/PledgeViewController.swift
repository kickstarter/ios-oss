import KsApi
import Library
import Prelude
import Stripe
import UIKit

private enum Layout {
  enum Style {
    static let cornerRadius: CGFloat = Styles.grid(2)
  }

  enum Margin {
    static let topBottom: CGFloat = Styles.grid(3)
    static let leftRight: CGFloat = CheckoutConstants.PledgeView.Inset.leftRight
  }
}

protocol PledgeViewControllerDelegate: AnyObject {
  func pledgeViewControllerDidUpdatePledge(_ viewController: PledgeViewController, message: String)
}

final class PledgeViewController: UIViewController,
  MessageBannerViewControllerPresenting, ProcessingViewPresenting {
  // MARK: - Properties

  private lazy var confirmationSectionViews = {
    [self.pledgeDisclaimerView]
  }()

  public weak var delegate: PledgeViewControllerDelegate?

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

  internal var processingView: ProcessingView? = ProcessingView(frame: .zero)
  private lazy var pledgeDisclaimerView: PledgeDisclaimerView = {
    PledgeDisclaimerView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
      |> \.delegate .~ self
  }()

  private lazy var descriptionSectionViews = {
    [self.pledgeDescriptionView, self.descriptionSectionSeparator]
  }()

  private lazy var pledgeDescriptionView: PledgeDescriptionView = {
    PledgeDescriptionView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var inputsSectionViews = {
    [self.pledgeAmountViewController.view, self.shippingLocationViewController.view]
  }()

  fileprivate lazy var keyboardDimissingTapGestureRecognizer: UITapGestureRecognizer = {
    UITapGestureRecognizer(
      target: self,
      action: #selector(PledgeViewController.dismissKeyboard)
    )
      |> \.cancelsTouchesInView .~ false
  }()

  internal var messageBannerViewController: MessageBannerViewController?

  private lazy var pledgeAmountSummaryViewController: PledgeAmountSummaryViewController = {
    PledgeAmountSummaryViewController.instantiate()
  }()

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
    [
      self.summarySectionSeparator,
      self.pledgeAmountSummaryViewController.view,
      self.summaryViewController.view
    ]
  }()

  private lazy var summaryViewController = {
    PledgeSummaryViewController.instantiate()
  }()

  private lazy var pledgeCTAContainerView: PledgeViewCTAContainerView = {
    PledgeViewCTAContainerView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
      |> \.delegate .~ self
  }()

  private lazy var rootContainerView: UIView = {
    UIView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var rootScrollView: UIScrollView = {
    UIScrollView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var rootStackView: UIStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private var sessionStartedObserver: Any?
  private let viewModel: PledgeViewModelType = PledgeViewModel()

  // MARK: - Lifecycle

  func configureWith(project: Project, reward: Reward, refTag: RefTag?, context: PledgeViewContext) {
    self.viewModel.inputs.configureWith(project: project, reward: reward, refTag: refTag, context: context)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    _ = self
      |> \.extendedLayoutIncludesOpaqueBars .~ true

    self.messageBannerViewController = self.configureMessageBannerViewController(on: self)

    self.view.addGestureRecognizer(self.keyboardDimissingTapGestureRecognizer)

    self.configureChildViewControllers()
    self.setupConstraints()

    self.viewModel.inputs.viewDidLoad()
  }

  deinit {
    self.sessionStartedObserver.doIfSome(NotificationCenter.default.removeObserver)
  }

  // MARK: - Configuration

  private func configureChildViewControllers() {
    _ = (self.rootScrollView, self.view)
      |> ksr_addSubviewToParent()

    _ = (self.rootContainerView, self.rootScrollView)
      |> ksr_addSubviewToParent()

    _ = (self.rootStackView, self.rootContainerView)
      |> ksr_addSubviewToParent()

    _ = (self.pledgeCTAContainerView, self.view)
      |> ksr_addSubviewToParent()

    let childViewControllers = [
      self.pledgeAmountViewController,
      self.pledgeAmountSummaryViewController,
      self.shippingLocationViewController,
      self.summaryViewController,
      self.paymentMethodsViewController
    ]

    let arrangedSubviews = [
      self.descriptionSectionViews,
      self.inputsSectionViews,
      self.summarySectionViews,
      self.paymentMethodsSectionViews,
      self.confirmationSectionViews
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
    _ = (self.rootContainerView, self.rootScrollView)
      |> ksr_constrainViewToEdgesInParent()

    _ = (self.rootStackView, self.rootContainerView)
      |> ksr_constrainViewToMarginsInParent()

    NSLayoutConstraint.activate([
      self.rootScrollView.topAnchor.constraint(equalTo: self.view.topAnchor),
      self.rootScrollView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
      self.rootScrollView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
      self.rootScrollView.bottomAnchor.constraint(equalTo: self.pledgeCTAContainerView.topAnchor),
      self.pledgeCTAContainerView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
      self.pledgeCTAContainerView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
      self.pledgeCTAContainerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
      self.rootContainerView.widthAnchor.constraint(equalTo: self.view.widthAnchor)
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

    _ = self.pledgeDescriptionView
      |> roundedStyle(cornerRadius: Layout.Style.cornerRadius)

    _ = self.pledgeDisclaimerView
      |> pledgeDisclaimerViewStyle

    _ = self.rootContainerView
      |> rootContainerViewStyle

    _ = self.rootScrollView
      |> rootScrollViewStyle

    _ = self.rootStackView
      |> rootStackViewStyle

    _ = self.sectionSeparatorViews
      ||> separatorStyleDark

    _ = self.paymentMethodsViewController.view
      |> roundedStyle(cornerRadius: Layout.Style.cornerRadius)
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.beginSCAFlowWithClientSecret
      .observeForUI()
      .observeValues { [weak self] secret in
        self?.beginSCAFlow(withClientSecret: secret)
      }

    self.viewModel.outputs.configureStripeIntegration
      .observeForUI()
      .observeValues { merchantIdentifier, publishableKey in
        STPPaymentConfiguration.shared().publishableKey = publishableKey
        STPPaymentConfiguration.shared().appleMerchantIdentifier = merchantIdentifier
      }

    self.viewModel.outputs.configureWithData
      .observeForUI()
      .observeValues { [weak self] data in
        self?.pledgeDescriptionView.configureWith(value: data)
        self?.pledgeAmountViewController.configureWith(value: data)
        self?.shippingLocationViewController.configureWith(value: data)
      }

    self.viewModel.outputs.configurePledgeAmountSummaryViewControllerWithData
      .observeForUI()
      .observeValues { [weak self] data in
        self?.pledgeAmountSummaryViewController.configureWith(data)
      }

    self.viewModel.outputs.configurePledgeViewCTAContainerView
      .observeForUI()
      .observeValues { [weak self] value in
        self?.pledgeCTAContainerView.configureWith(value: value)
      }

    self.viewModel.outputs.notifyPledgeAmountViewControllerShippingAmountChanged
      .observeForUI()
      .observeValues { [weak self] amount in
        self?.pledgeAmountViewController.selectedShippingAmountChanged(to: amount)
      }

    self.viewModel.outputs.configureSummaryViewControllerWithData
      .observeForUI()
      .observeValues { [weak self] data in
        self?.summaryViewController.configure(with: data)
      }
    self.viewModel.outputs.configurePaymentMethodsViewControllerWithValue
      .observeForUI()
      .observeValues { [weak self] value in
        self?.paymentMethodsViewController.configure(with: value)
      }

    self.viewModel.outputs.goToLoginSignup
      .observeForControllerAction()
      .observeValues { [weak self] intent, project, reward in
        self?.goToLoginSignup(with: intent, project: project, reward: reward)
      }

    self.sessionStartedObserver = NotificationCenter.default
      .addObserver(forName: .ksr_sessionStarted, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.userSessionStarted()
      }

    self.viewModel.outputs.goToApplePayPaymentAuthorization
      .observeForControllerAction()
      .observeValues { [weak self] paymentAuthorizationData in
        self?.goToPaymentAuthorization(paymentAuthorizationData)
      }

    self.viewModel.outputs.goToThanks
      .observeForControllerAction()
      .observeValues { [weak self] data in
        generateNotificationSuccessFeedback()
        self?.goToThanks(data: data)
      }

    self.viewModel.outputs.notifyDelegateUpdatePledgeDidSucceedWithMessage
      .observeForUI()
      .observeValues { [weak self] message in
        guard let self = self else { return }
        self.delegate?.pledgeViewControllerDidUpdatePledge(self, message: message)
      }

    self.viewModel.outputs.popToRootViewController
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.navigationController?.popToRootViewController(animated: true)
      }

    Keyboard.change
      .observeForUI()
      .observeValues { [weak self] change in
        self?.rootScrollView.handleKeyboardVisibilityDidChange(change)
      }

    self.viewModel.outputs.sectionSeparatorsHidden
      .observeForUI()
      .observeValues { [weak self] hidden in self?.sectionSeparatorViews.forEach { $0.isHidden = hidden } }

    self.pledgeDescriptionView.rac.hidden = self.viewModel.outputs.descriptionViewHidden

    self.shippingLocationViewController.view.rac.hidden
      = self.viewModel.outputs.shippingLocationViewHidden
    self.paymentMethodsViewController.view.rac.hidden = self.viewModel.outputs.paymentMethodsViewHidden
    self.pledgeAmountViewController.view.rac.hidden = self.viewModel.outputs.pledgeAmountViewHidden
    self.pledgeAmountSummaryViewController.view.rac.hidden
      = self.viewModel.outputs.pledgeAmountSummaryViewHidden

    self.viewModel.outputs.title
      .observeForUI()
      .observeValues { [weak self] title in
        guard let self = self else { return }

        _ = self
          |> \.title %~ { _ in title }
      }

    self.viewModel.outputs.processingViewIsHidden
      .observeForUI()
      .observeValues { [weak self] isHidden in
        if isHidden {
          self?.hideProcessingView()
        } else {
          self?.showProcessingView()
        }
      }

    self.viewModel.outputs.showWebHelp
      .observeForControllerAction()
      .observeValues { [weak self] helpType in
        guard let self = self else { return }
        self.presentHelpWebViewController(with: helpType, presentationStyle: .formSheet)
      }

    // MARK: Errors

    self.viewModel.outputs.showErrorBannerWithMessage
      .observeForControllerAction()
      .observeValues { [weak self] errorMessage in
        self?.messageBannerViewController?.showBanner(with: .error, message: errorMessage)
      }

    self.viewModel.outputs.showApplePayAlert
      .observeForControllerAction()
      .observeValues { [weak self] title, message in
        self?.presentApplePayInvalidAmountAlert(title: title, message: message)
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

  private func goToThanks(data: ThanksPageData) {
    let thanksVC = ThanksViewController.configured(with: data)
    self.navigationController?.pushViewController(thanksVC, animated: true)
  }

  private func presentApplePayInvalidAmountAlert(title: String, message: String) {
    self.present(UIAlertController.alert(title, message: message), animated: true)
  }

  // MARK: - Actions

  @objc private func dismissKeyboard() {
    self.view.endEditing(true)
  }

  // MARK: - Functions

  private func goToLoginSignup(with intent: LoginIntent, project: Project, reward: Reward) {
    let loginSignupViewController = LoginToutViewController.configuredWith(
      loginIntent: intent,
      project: project,
      reward: reward
    )

    let navigationController = UINavigationController(rootViewController: loginSignupViewController)
    let navigationBarHeight = navigationController.navigationBar.bounds.height

    if #available(iOS 13.0, *) {
      self.present(navigationController, animated: true)
    } else {
      self.presentViewControllerWithSheetOverlay(navigationController, offset: navigationBarHeight)
    }
  }

  private func beginSCAFlow(withClientSecret secret: String) {
    STPPaymentHandler.shared().confirmSetupIntent(
      withParams: .init(clientSecret: secret),
      authenticationContext: self
    ) { [weak self] status, _, error in
      self?.viewModel.inputs.scaFlowCompleted(with: status, error: error)
    }
  }
}

// MARK: - STPAuthenticationContext

extension PledgeViewController: STPAuthenticationContext {
  func authenticationPresentingViewController() -> UIViewController {
    return self
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

// MARK: - PledgeScreenCTAContainerViewDelegate

extension PledgeViewController: PledgeViewCTAContainerViewDelegate {
  func goToLoginSignup() {
    self.viewModel.inputs.goToLoginSignupTapped()
  }

  func applePayButtonTapped() {
    self.viewModel.inputs.applePayButtonTapped()
  }

  func submitButtonTapped() {
    self.viewModel.inputs.submitButtonTapped()
  }

  func termsOfUseTapped(with helpType: HelpType) {
    self.viewModel.inputs.termsOfUseTapped(with: helpType)
  }
}

// MARK: - PledgeAmountViewControllerDelegate

extension PledgeViewController: PledgeAmountViewControllerDelegate {
  func pledgeAmountViewController(
    _: PledgeAmountViewController,
    didUpdateWith data: PledgeAmountData
  ) {
    self.viewModel.inputs.pledgeAmountViewControllerDidUpdate(with: data)
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
}

// MARK: - PledgeDisclaimerViewDelegate

extension PledgeViewController: PledgeDisclaimerViewDelegate {
  func pledgeDisclaimerViewDidTapLearnMore(_: PledgeDisclaimerView) {
    self.viewModel.inputs.pledgeDisclaimerViewDidTapLearnMore()
  }
}

// MARK: - Styles

private let pledgeDisclaimerViewStyle: ViewStyle = { view in
  view
    |> roundedStyle(cornerRadius: Layout.Style.cornerRadius)
}

private let rootScrollViewStyle: ScrollStyle = { scrollView in
  scrollView
    |> \.showsVerticalScrollIndicator .~ false
    |> \.alwaysBounceVertical .~ true
}

private let rootContainerViewStyle: ViewStyle = { view in
  view
    |> \.layoutMargins .~ UIEdgeInsets(
      topBottom: Layout.Margin.topBottom,
      leftRight: Layout.Margin.leftRight
    )
}

private let rootStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ NSLayoutConstraint.Axis.vertical
    |> \.spacing .~ Styles.grid(4)
}
