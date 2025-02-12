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

protocol PledgeViewControllerDelegate: AnyObject {
  func noShippingPledgeViewControllerDidUpdatePledge(
    _ viewController: PledgeViewController,
    message: String
  )
}

final class PledgeViewController: UIViewController,
  MessageBannerViewControllerPresenting, ProcessingViewPresenting {
  // MARK: - Properties

  private lazy var confirmationSectionViews = {
    [self.pledgeDisclaimerView]
  }()

  public weak var delegate: PledgeViewControllerDelegate?

  private var titleLabel: UILabel = { UILabel(frame: .zero) }()

  private var collectionPlanSectionLabel: UILabel = { UILabel(frame: .zero) }()

  private var paymentSectionLabel: UILabel = { UILabel(frame: .zero) }()

  internal var processingView: ProcessingView? = ProcessingView(frame: .zero)
  private lazy var pledgeDisclaimerView: PledgeDisclaimerView = {
    PledgeDisclaimerView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
      |> \.delegate .~ self
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

  private lazy var paymentPlansView: UIView = {
    self.paymentPlansViewController.view
  }()

  private lazy var paymentPlansViewController = {
    PledgePaymentPlansViewController.instantiate()
      |> \.delegate .~ self
  }()

  private lazy var localPickupLocationView = {
    PledgeLocalPickupView(frame: .zero)
  }()

  private lazy var pledgeRewardsSummaryViewController = {
    NoShippingPledgeRewardsSummaryViewController.instantiate()
  }()

  private lazy var estimatedShippingViewContainer =
    UIHostingController(rootView: EstimatedShippingCheckoutView(
      estimatedCost: "",
      aboutConversion: ""
    ))

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

  private lazy var estimatedShippingStackView: UIStackView = {
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

    self.collectionPlanSectionLabel.text = Strings.Collection_plan()
    self.paymentSectionLabel.text = Strings.Payment()

    self.messageBannerViewController = self.configureMessageBannerViewController(on: self)

    self.view.addGestureRecognizer(self.keyboardDimissingTapGestureRecognizer)

    self.configureChildViewControllers()
    self.configureDisclaimerView()
    self.setupConstraints()

    self.viewModel.inputs.viewDidLoad()

    // Sending `.pledgeInFull` as default option
    self.viewModel.inputs.paymentPlanSelected(.pledgeInFull)
  }

  deinit {
    self.sessionStartedObserver.doIfSome(NotificationCenter.default.removeObserver)
  }

  // MARK: - Configuration

  private func configureChildViewControllers() {
    self.view.addSubview(self.rootScrollView)
    self.view.addSubview(self.pledgeCTAContainerView)

    _ = (self.rootStackView, self.rootScrollView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    let childViewControllers = [
      self.pledgeRewardsSummaryViewController,
      self.paymentMethodsViewController,
      self.paymentPlansViewController
    ]

    self.paymentPlansView.isHidden = true

    let arrangedInsetSubviews = [
      [self.titleLabel],
      [self.paymentPlansView],
      self.paymentMethodsSectionViews,
      self.confirmationSectionViews
    ]
    .flatMap { $0 }
    .compact()

    self.rootStackView.addArrangedSubview(self.rootInsetStackView)

    arrangedInsetSubviews.forEach { view in
      self.rootInsetStackView.addArrangedSubview(view)
    }

    childViewControllers.forEach { viewController in
      self.addChild(viewController)
      viewController.didMove(toParent: self)
    }

    self.rootStackView.addArrangedSubview(self.pledgeRewardsSummaryViewController.view)

    self.rootStackView.addArrangedSubview(self.estimatedShippingStackView)

    self.titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    self.titleLabel.setContentHuggingPriority(.required, for: .vertical)
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.rootScrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
      self.rootScrollView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
      self.rootScrollView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
      self.rootScrollView.bottomAnchor.constraint(equalTo: self.pledgeCTAContainerView.topAnchor),
      self.pledgeCTAContainerView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
      self.pledgeCTAContainerView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
      self.pledgeCTAContainerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
      self.rootStackView.widthAnchor.constraint(equalTo: self.rootScrollView.widthAnchor)
    ])
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    self.view.backgroundColor = UIColor.ksr_support_100

    applyTitleLabelStyle(self.titleLabel)

    applySectionTitleLabelStyle(self.collectionPlanSectionLabel)
    applySectionTitleLabelStyle(self.paymentSectionLabel)

    applyRootScrollViewStyle(self.rootScrollView)

    applyRootStackViewStyle(self.rootStackView)

    applyRootInsetStackViewStyle(self.rootInsetStackView)

    applyRootInsetStackViewStyle(self.estimatedShippingStackView)

    roundedStyle(self.paymentMethodsViewController.view, cornerRadius: Layout.Style.cornerRadius)

    roundedStyle(self.paymentPlansView, cornerRadius: Layout.Style.cornerRadius)

    applyRoundedViewStyle(self.pledgeDisclaimerView, cornerRadius: Layout.Style.cornerRadius)
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

    self.paymentPlansView.rac.hidden = self.viewModel.outputs.showPledgeOverTimeUI.negate()

    self.viewModel.outputs.showPledgeOverTimeUI
      .observeForUI()
      .observeValues { [weak self] isVisible in
        self?.configurePledgeOverTimeUI(isVisible)
      }

    self.viewModel.outputs.pledgeOverTimeConfigData
      .observeForUI()
      .observeValues { [weak self] data in
        if let data = data {
          self?.paymentPlansViewController.configure(with: data)
        }
        self?.pledgeRewardsSummaryViewController.configureWith(pledgeOverTimeData: data)
      }

    self.viewModel.outputs.configurePledgeAmountSummaryViewControllerWithData
      .observeForUI()
      .observeValues { [weak self] data in
        self?.pledgeAmountSummaryViewController.configureWith(data)
      }

    self.viewModel.outputs.configureEstimatedShippingView
      .observeForUI()
      .observeValues { [weak self] estimatedShippingText, estimatedConversionText in
        guard let shippingText = estimatedShippingText else { return }

        self?.configureEstimatedShippingView(shippingText, estimatedConversionText)
      }

    self.viewModel.outputs.estimatedShippingViewHidden
      .observeForUI()
      .observeValues { [weak self] isHidden in
        self?.estimatedShippingViewContainer.view.isHidden = isHidden
      }

    self.viewModel.outputs.configurePledgeViewCTAContainerView
      .observeForUI()
      .observeValues { [weak self] value in
        self?.pledgeCTAContainerView.configureWith(value: value)
      }

    self.viewModel.outputs.configurePaymentMethodsViewControllerWithValue
      .observeForUI()
      .observeValues { [weak self] value in
        self?.paymentMethodsViewController.configure(with: value)
      }

    self.viewModel.outputs.goToLoginSignup
      .observeForControllerAction()
      .observeValues { [weak self] intent in
        self?.goToLoginSignup(with: intent)
      }

    self.sessionStartedObserver = NotificationCenter.default
      .addObserver(forName: .ksr_sessionStarted, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.userSessionDidChange()
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
  }

  private func goToPaymentAuthorization(_ paymentAuthorizationData: PaymentAuthorizationData) {
    let request = PKPaymentRequest
      .paymentRequest(
        for: paymentAuthorizationData.project,
        reward: paymentAuthorizationData.reward,
        allRewardsTotal: paymentAuthorizationData.allRewardsTotal,
        additionalPledgeAmount: paymentAuthorizationData.additionalPledgeAmount,
        allRewardsShippingTotal: paymentAuthorizationData.allRewardsShippingTotal,
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

  private func configureEstimatedShippingView(_ estimatedCost: String, _ aboutConversion: String?) {
    let estimatedShippingView = EstimatedShippingCheckoutView(
      estimatedCost: estimatedCost,
      aboutConversion: aboutConversion ?? ""
    )

    self.estimatedShippingViewContainer.rootView = estimatedShippingView
    self.estimatedShippingViewContainer.view.translatesAutoresizingMaskIntoConstraints = false
    self.estimatedShippingViewContainer.view.clipsToBounds = true
    self.estimatedShippingViewContainer.view.layer.masksToBounds = true
    self.estimatedShippingViewContainer.view.layer.cornerRadius = Layout.Style.cornerRadius

    self.estimatedShippingStackView.addArrangedSubview(self.estimatedShippingViewContainer.view)
    self.estimatedShippingViewContainer.didMove(toParent: self)

    self.estimatedShippingStackView.layoutIfNeeded()
  }

  private func goToLoginSignup(with intent: LoginIntent) {
    let loginSignupViewController = LoginToutViewController.configuredWith(
      loginIntent: intent
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

  private func configurePledgeOverTimeUI(_ isVisible: Bool) {
    guard isVisible else { return }

    let collectionPlanStackView = UIStackView(frame: .zero)
    applySectionStackViewStyle(collectionPlanStackView)

    let arrangedCollectionPlanSubviews = [
      self.collectionPlanSectionLabel,
      self.paymentPlansView
    ]

    arrangedCollectionPlanSubviews.forEach {
      collectionPlanStackView.addArrangedSubview($0)
    }

    let paymentStackView = UIStackView(frame: .zero)
    applySectionStackViewStyle(paymentStackView)

    let arrangedPaymentViewSubviews = [
      self.paymentSectionLabel,
      self.paymentMethodsViewController.view!
    ]

    arrangedPaymentViewSubviews.forEach {
      paymentStackView.addArrangedSubview($0)
    }

    let paymentSectionViews: [UIView] = [paymentStackView]

    let arrangedInsetSubviews: [UIView] = [
      [self.titleLabel],
      [collectionPlanStackView],
      paymentSectionViews,
      self.confirmationSectionViews
    ]
    .flatMap { $0 }

    arrangedInsetSubviews.forEach { view in
      self.rootInsetStackView.addArrangedSubview(view)
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

extension PledgeViewController: NoShippingPledgeViewCTAContainerViewDelegate {
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

extension PledgeViewController: PledgeViewControllerMessageDisplaying {
  func pledgeViewController(_: UIViewController, didErrorWith message: String, error _: Error?) {
    self.messageBannerViewController?.showBanner(with: .error, message: message)
  }

  func pledgeViewController(_: UIViewController, didSucceedWith message: String) {
    self.messageBannerViewController?.showBanner(with: .success, message: message)
  }
}

// MARK: - PledgePaymentMethodsViewControllerDelegate

extension PledgeViewController: PledgePaymentMethodsViewControllerDelegate {
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

extension PledgeViewController: PledgeDisclaimerViewDelegate {
  func pledgeDisclaimerView(_: PledgeDisclaimerView, didTapURL _: URL) {
    self.viewModel.inputs.pledgeDisclaimerViewDidTapLearnMore()
  }
}

// MARK: - Styles

private func applyRoundedViewStyle(_ view: UIView, cornerRadius: CGFloat) {
  view.clipsToBounds = true
  view.layer.masksToBounds = true
  view.layer.cornerRadius = cornerRadius
}

private func applyRootScrollViewStyle(_ scrollView: UIScrollView) {
  scrollView.showsVerticalScrollIndicator = false
  scrollView.alwaysBounceVertical = true
}

private func applyRootStackViewStyle(_ stackView: UIStackView) {
  stackView.axis = NSLayoutConstraint.Axis.vertical
  stackView.spacing = Styles.grid(2)
  stackView.isLayoutMarginsRelativeArrangement = true
  stackView.layoutMargins = UIEdgeInsets(
    topBottom: Layout.Margin.topBottom,
    leftRight: 0
  )
}

private func applyRootInsetStackViewStyle(_ stackView: UIStackView) {
  stackView.axis = NSLayoutConstraint.Axis.vertical
  stackView.spacing = Styles.grid(3)
  stackView.isLayoutMarginsRelativeArrangement = true
  stackView.layoutMargins = UIEdgeInsets(
    topBottom: Layout.Margin.topBottom,
    leftRight: Layout.Margin.leftRight
  )
}

private func applyTitleLabelStyle(_ label: UILabel) {
  label.numberOfLines = 1
  label.textColor = UIColor.ksr_support_700
  label.font = UIFont.ksr_title2().bolded
}

private func applySectionTitleLabelStyle(_ label: UILabel) {
  label.numberOfLines = 1
  label.textColor = UIColor.ksr_support_700
  label.font = UIFont.ksr_headline().bolded
}

private func applySectionStackViewStyle(_ stackView: UIStackView) {
  stackView.axis = .vertical
  stackView.spacing = Styles.grid(2)
}

// MARK: - PledgePaymentMethodsViewControllerDelegate

extension PledgeViewController: PledgePaymentPlansViewControllerDelegate {
  func pledgePaymentPlansViewController(
    _: PledgePaymentPlansViewController,
    didSelectPaymentPlan paymentPlan: PledgePaymentPlansType
  ) {
    self.viewModel.inputs.paymentPlanSelected(paymentPlan)
  }

  func pledgePaymentPlansViewController(
    _: PledgePaymentPlansViewController,
    didTapTermsOfUseWith helpType: HelpType
  ) {
    self.paymentMethodsViewController.cancelModalPresentation(true)
    self.viewModel.inputs.termsOfUseTapped(with: helpType)
  }
}
