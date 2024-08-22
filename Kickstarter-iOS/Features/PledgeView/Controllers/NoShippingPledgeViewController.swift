import KsApi
import Library
import PassKit
import Prelude
import Stripe
import SwiftUI
import UIKit

private enum Layout {
  enum Style {
    static let cornerRadius: CGFloat = Styles.grid(2)
    static let modalHeightMultiplier: CGFloat = 0.65
  }

  enum Margin {
    static let topBottom: CGFloat = Styles.grid(3)
    static let leftRight: CGFloat = CheckoutConstants.PledgeView.Inset.leftRight
  }
}

protocol NoShippingPledgeViewControllerDelegate: AnyObject {
  func noShippingPledgeViewControllerDidUpdatePledge(
    _ viewController: NoShippingPledgeViewController,
    message: String
  )
}

final class NoShippingPledgeViewController: UIViewController,
  MessageBannerViewControllerPresenting, ProcessingViewPresenting {
  // MARK: - Properties

  private lazy var confirmationSectionViews = {
    [self.pledgeDisclaimerView]
  }()

  public weak var delegate: NoShippingPledgeViewControllerDelegate?

  private var titleLabel: UILabel = { UILabel(frame: .zero) }()

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

  fileprivate lazy var keyboardDimissingTapGestureRecognizer: UITapGestureRecognizer = {
    UITapGestureRecognizer(
      target: self,
      action: #selector(NoShippingPledgeViewController.dismissKeyboard)
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

  private lazy var localPickupLocationView = {
    PledgeLocalPickupView(frame: .zero)
  }()

  private lazy var pledgeRewardsSummaryViewController = {
    NoShippingPledgeRewardsSummaryTotalViewController.instantiate()
  }()

  private lazy var pledgeCTAContainerView: NoShippingPledgeViewCTAContainerView = {
    NoShippingPledgeViewCTAContainerView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
      |> \.delegate .~ self
  }()

  private lazy var rootScrollView: UIScrollView = {
    UIScrollView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var rootStackView: UIStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var rootInsetStackView: UIStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private var sessionStartedObserver: Any?
  private let viewModel: NoShippingPledgeViewModelType = NoShippingPledgeViewModel()

  // MARK: - Lifecycle

  func configure(with data: PledgeViewData) {
    self.viewModel.inputs.configure(with: data)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    _ = self
      |> \.extendedLayoutIncludesOpaqueBars .~ true

    self.titleLabel.text = Strings.Checkout()

    self.messageBannerViewController = self.configureMessageBannerViewController(on: self)

    self.view.addGestureRecognizer(self.keyboardDimissingTapGestureRecognizer)

    self.configureChildViewControllers()
    self.configureDisclaimerView()
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

    _ = (self.rootStackView, self.rootScrollView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = (self.pledgeCTAContainerView, self.view)
      |> ksr_addSubviewToParent()

    let childViewControllers = [
      self.pledgeRewardsSummaryViewController,
      self.paymentMethodsViewController
    ]

    let arrangedInsetSubviews = [
      self.paymentMethodsSectionViews,
      self.confirmationSectionViews,
      [self.pledgeRewardsSummaryViewController.view]
    ]
    .flatMap { $0 }
    .compact()

    _ = ([self.titleLabel, self.rootInsetStackView], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    arrangedInsetSubviews.forEach { view in
      self.rootInsetStackView.addArrangedSubview(view)
    }

    childViewControllers.forEach { viewController in
      self.addChild(viewController)
      viewController.didMove(toParent: self)
    }

    self.titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    self.titleLabel.setContentHuggingPriority(.required, for: .vertical)
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.rootScrollView.topAnchor.constraint(
        equalTo: self.view.safeAreaLayoutGuide.topAnchor,
        constant: Styles.grid(1)
      ),
      self.rootScrollView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
      self.rootScrollView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
      self.rootScrollView.bottomAnchor.constraint(
        equalTo: self.pledgeCTAContainerView.topAnchor,
        constant: -Styles.grid(3)
      ),
      self.pledgeCTAContainerView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
      self.pledgeCTAContainerView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
      self.pledgeCTAContainerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
      self.rootStackView.widthAnchor.constraint(equalTo: self.view.widthAnchor)
    ])
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.view
      |> checkoutBackgroundStyle

    _ = self.titleLabel
      |> titleLabelStyle

    _ = self.pledgeDisclaimerView
      |> pledgeDisclaimerViewStyle

    _ = self.rootScrollView
      |> rootScrollViewStyle

    _ = self.rootStackView
      |> rootStackViewStyle

    _ = self.rootInsetStackView
      |> rootInsetStackViewStyle

    _ = self.paymentMethodsViewController.view
      |> roundedStyle(cornerRadius: Layout.Style.cornerRadius)
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.title
      .observeForUI()
      .observeValues { [weak self] title in
        _ = self
          ?|> \.title .~ title
      }

    self.viewModel.outputs.beginSCAFlowWithClientSecret
      .observeForUI()
      .observeValues { [weak self] secret in
        self?.beginSCAFlow(withClientSecret: secret)
      }

    self.viewModel.outputs.configureLocalPickupViewWithData
      .observeForUI()
      .observeValues { [weak self] data in
        self?.localPickupLocationView.configure(with: data)
      }

    self.viewModel.outputs.configureStripeIntegration
      .observeForUI()
      .observeValues { merchantIdentifier, publishableKey in
        STPAPIClient.shared.publishableKey = publishableKey
        STPAPIClient.shared.configuration.appleMerchantIdentifier = merchantIdentifier
      }

    self.viewModel.outputs.configurePledgeRewardsSummaryViewWithData
      .observeForUI()
      .observeValues { [weak self] rewardsData, bonusAmount, pledgeData in
        self?.pledgeRewardsSummaryViewController
          .configureWith(rewardsData: rewardsData, bonusAmount: bonusAmount, pledgeData: pledgeData)
      }

    self.viewModel.outputs.configurePledgeAmountViewWithData
      .observeForUI()
      .observeValues { [weak self] data in
        self?.pledgeAmountViewController.configureWith(value: data)
      }

    self.viewModel.outputs.configurePledgeAmountSummaryViewControllerWithData
      .observeForUI()
      .observeValues { [weak self] data in
        self?.pledgeAmountSummaryViewController.configureWith(data)
      }

    self.viewModel.outputs.configureEstimatedShippingView
      .observeForUI()
      .observeValues { [weak self] strings in
        self?.configureEstimatedShippingView(with: strings)
      }

    self.viewModel.outputs.configurePledgeViewCTAContainerView
      .observeForUI()
      .observeValues { [weak self] value in
        self?.pledgeCTAContainerView.configureWith(value: value)
      }

    self.viewModel.outputs.notifyPledgeAmountViewControllerUnavailableAmountChanged
      .observeForUI()
      .observeValues { [weak self] amount in
        self?.pledgeAmountViewController.unavailableAmountChanged(to: amount)
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
        self.delegate?.noShippingPledgeViewControllerDidUpdatePledge(self, message: message)
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

    self.localPickupLocationView.rac.hidden = self.viewModel.outputs.localPickupViewHidden
    self.paymentMethodsViewController.view.rac.hidden = self.viewModel.outputs.paymentMethodsViewHidden
    self.pledgeAmountViewController.view.rac.hidden = self.viewModel.outputs.pledgeAmountViewHidden

    self.viewModel.outputs.title
      .observeForUI()
      .observeValues { [weak self] title in
        guard let self else { return }
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
        self.paymentMethodsViewController.cancelModalPresentation(true)
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

  private func goToPaymentAuthorization(_ paymentAuthorizationData: PaymentAuthorizationDataNoShipping) {
    let request = PKPaymentRequest
      .paymentRequest(
        for: paymentAuthorizationData.project,
        reward: paymentAuthorizationData.reward,
        allRewardsTotal: paymentAuthorizationData.allRewardsTotal,
        additionalPledgeAmount: paymentAuthorizationData.additionalPledgeAmount,
        allRewardsShippingTotal: 0,
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

  private func configureDisclaimerView() {
    guard let attributedText = PledgeViewControllerHelpers.attributedLearnMoreText() else {
      return
    }
    self.pledgeDisclaimerView.configure(with: ("icon-not-a-store", attributedText))
  }

  private func configureEstimatedShippingView(with strings: (String, String)) {
    let (estimatedCost, aboutConversion) = strings

    let estimatedShippingView = UIHostingController(rootView: EstimatedShippingCheckoutView(
      estimatedCost: estimatedCost,
      aboutConversion: aboutConversion
    ))
    estimatedShippingView.view.clipsToBounds = true
    estimatedShippingView.view.layer.masksToBounds = true
    estimatedShippingView.view.layer.cornerRadius = Layout.Style.cornerRadius

    self.rootInsetStackView.addArrangedSubview(estimatedShippingView.view)
  }

  private func goToLoginSignup(with intent: LoginIntent, project: Project, reward: Reward) {
    let loginSignupViewController = LoginToutViewController.configuredWith(
      loginIntent: intent,
      project: project,
      reward: reward
    )

    let navigationController = UINavigationController(rootViewController: loginSignupViewController)

    self.present(navigationController, animated: true)
  }

  private func beginSCAFlow(withClientSecret secret: String) {
    let setupIntentConfirmParams = STPSetupIntentConfirmParams(clientSecret: secret)

    STPPaymentHandler.shared()
      .confirmSetupIntent(setupIntentConfirmParams, with: self) { [weak self] status, _, error in
        self?.viewModel.inputs.scaFlowCompleted(with: status, error: error)
      }
  }
}

// MARK: - PledgeAmountViewControllerDelegate

extension NoShippingPledgeViewController: PledgeAmountViewControllerDelegate {
  func pledgeAmountViewController(
    _: PledgeAmountViewController,
    didUpdateWith data: PledgeAmountData
  ) {
    self.viewModel.inputs.pledgeAmountViewControllerDidUpdate(with: data)
  }
}

// MARK: - STPAuthenticationContext

extension NoShippingPledgeViewController: STPAuthenticationContext {
  func authenticationPresentingViewController() -> UIViewController {
    return self
  }
}

// MARK: - PKPaymentAuthorizationViewControllerDelegate

extension NoShippingPledgeViewController: PKPaymentAuthorizationViewControllerDelegate {
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

    STPAPIClient.shared.createToken(with: payment) { [weak self] token, error in
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

extension NoShippingPledgeViewController: NoShippingPledgeViewCTAContainerViewDelegate {
  func goToLoginSignup() {
    self.paymentMethodsViewController.cancelModalPresentation(true)
    self.viewModel.inputs.goToLoginSignupTapped()
  }

  func applePayButtonTapped() {
    self.paymentMethodsViewController.cancelModalPresentation(true)
    self.viewModel.inputs.applePayButtonTapped()
  }

  func submitButtonTapped() {
    self.paymentMethodsViewController.cancelModalPresentation(true)
    self.viewModel.inputs.submitButtonTapped()
  }

  func termsOfUseTapped(with helpType: HelpType) {
    self.paymentMethodsViewController.cancelModalPresentation(true)
    self.viewModel.inputs.termsOfUseTapped(with: helpType)
  }
}

// MARK: - NoShippingPledgeViewControllerMessageDisplaying

extension NoShippingPledgeViewController: PledgeViewControllerMessageDisplaying {
  func pledgeViewController(_: UIViewController, didErrorWith message: String, error _: Error?) {
    self.messageBannerViewController?.showBanner(with: .error, message: message)
  }

  func pledgeViewController(_: UIViewController, didSucceedWith message: String) {
    self.messageBannerViewController?.showBanner(with: .success, message: message)
  }
}

// MARK: - PledgePaymentMethodsViewControllerDelegate

extension NoShippingPledgeViewController: PledgePaymentMethodsViewControllerDelegate {
  func pledgePaymentMethodsViewController(
    _: PledgePaymentMethodsViewController,
    didSelectCreditCard paymentSource: PaymentSourceSelected
  ) {
    self.viewModel.inputs.creditCardSelected(with: paymentSource)
  }

  func pledgePaymentMethodsViewController(_: PledgePaymentMethodsViewController, loading flag: Bool) {
    if flag {
      self.showProcessingView()
    } else {
      self.hideProcessingView()
    }
  }
}

// MARK: - PledgeDisclaimerViewDelegate

extension NoShippingPledgeViewController: PledgeDisclaimerViewDelegate {
  func pledgeDisclaimerView(_: PledgeDisclaimerView, didTapURL _: URL) {
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

private let rootStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ NSLayoutConstraint.Axis.vertical
    |> \.spacing .~ Styles.grid(4)
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.layoutMargins .~ UIEdgeInsets(
      topBottom: 0,
      leftRight: Layout.Margin.leftRight
    )
}

private let rootInsetStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ NSLayoutConstraint.Axis.vertical
    |> \.spacing .~ Styles.grid(4)
    |> \.isLayoutMarginsRelativeArrangement .~ true
}

public func titleLabelStyle(_ label: UILabel) {
  label.numberOfLines = 1
  label.textColor = UIColor.ksr_support_700
  label.font = UIFont.ksr_title2().bolded
  label.layoutMargins = UIEdgeInsets(topBottom: Layout.Margin.topBottom, leftRight: Styles.grid(3))
}
