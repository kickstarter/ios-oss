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
  }

  enum Margin {
    static let topBottom: CGFloat = Styles.grid(3)
    static let leftRight: CGFloat = CheckoutConstants.PledgeView.Inset.leftRight
  }
}

final class NoShippingPostCampaignCheckoutViewController: UIViewController,
  MessageBannerViewControllerPresenting,
  ProcessingViewPresenting {
  // MARK: - Properties

  internal var messageBannerViewController: MessageBannerViewController?

  fileprivate var applePayPaymentIntent: String?

  private lazy var titleLabel = UILabel(frame: .zero)

  private lazy var paymentMethodsViewController = {
    PledgePaymentMethodsViewController.instantiate()
      |> \.messageDisplayingDelegate .~ self
      |> \.delegate .~ self
  }()

  private lazy var estimatedShippingViewContainer =
    UIHostingController(rootView: EstimatedShippingCheckoutView(
      estimatedCost: "",
      aboutConversion: ""
    ))

  private lazy var pledgeCTAContainerView: PledgeViewCTAContainerView = {
    PledgeViewCTAContainerView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
      |> \.delegate .~ self
  }()

  private lazy var pledgeDisclaimerView: PledgeDisclaimerView = {
    PledgeDisclaimerView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
      |> \.delegate .~ self
  }()

  private lazy var pledgeRewardsSummaryViewController = {
    PostCampaignPledgeRewardsSummaryViewController.instantiate()
  }()

  internal var processingView: ProcessingView? = ProcessingView(frame: .zero)

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

  private let viewModel: NoShippingPostCampaignCheckoutViewModelType =
    NoShippingPostCampaignCheckoutViewModel(stripeIntentService: StripeIntentService())

  // MARK: - Lifecycle

  func configure(with data: PledgeViewData) {
    self.viewModel.inputs.configure(with: data)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.navigationItem
      .backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)

    _ = self
      |> \.extendedLayoutIncludesOpaqueBars .~ true

    self.title = Strings.Back_this_project()

    self.messageBannerViewController = self.configureMessageBannerViewController(on: self)

    self.configureChildViewControllers()
    self.setupConstraints()

    if let attributedText = PledgeViewControllerHelpers.attributedLearnMoreText() {
      self.pledgeDisclaimerView.configure(with: ("icon-not-a-store", attributedText))
    }

    self.viewModel.inputs.viewDidLoad()
  }

  deinit {
    self.hideProcessingView()
    self.sessionStartedObserver.doIfSome(NotificationCenter.default.removeObserver)
  }

  // MARK: - Configuration

  private func configureChildViewControllers() {
    self.view.addSubview(self.rootScrollView)
    self.view.addSubview(self.pledgeCTAContainerView)

    _ = (self.rootStackView, self.rootScrollView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    self.rootStackView.addArrangedSubview(self.rootInsetStackView)

    let arrangedInsetSubviews = [
      self.titleLabel,
      self.paymentMethodsViewController.view,
      self.pledgeDisclaimerView
    ]
    .compactMap { $0 }
    .compact()

    arrangedInsetSubviews.forEach { view in
      self.rootInsetStackView.addArrangedSubview(view)
    }

    self.rootStackView.addArrangedSubview(self.pledgeRewardsSummaryViewController.view)

    self.rootStackView.addArrangedSubview(self.estimatedShippingStackView)

    self.addChild(self.paymentMethodsViewController)
    self.paymentMethodsViewController.didMove(toParent: self)

    self.addChild(self.pledgeRewardsSummaryViewController)
    self.pledgeRewardsSummaryViewController.didMove(toParent: self)
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

    _ = self.view
      |> checkoutBackgroundStyle

    self.titleLabel.text = Strings.Checkout()
    self.titleLabel.numberOfLines = 1
    self.titleLabel.textColor = UIColor.ksr_support_700
    self.titleLabel.font = UIFont.ksr_title2().bolded
    self.titleLabel.layoutMargins = UIEdgeInsets(
      topBottom: Layout.Margin.topBottom,
      leftRight: Styles.grid(3)
    )

    self.rootScrollView.showsVerticalScrollIndicator = false
    self.rootScrollView.alwaysBounceVertical = true

    self.rootStackView.axis = NSLayoutConstraint.Axis.vertical
    self.rootStackView.spacing = Styles.grid(1)
    self.rootStackView.isLayoutMarginsRelativeArrangement = true
    self.rootStackView.layoutMargins = UIEdgeInsets(
      topBottom: ConfirmDetailsLayout.Margin.topBottom,
      leftRight: 0
    )

    rootInsetStackViewStyle(self.rootInsetStackView)
    rootInsetStackViewStyle(self.estimatedShippingStackView)

    roundedStyle(self.paymentMethodsViewController.view, cornerRadius: Layout.Style.cornerRadius)

    roundedStyle(self.pledgeDisclaimerView, cornerRadius: Layout.Style.cornerRadius)
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.paymentMethodsViewController.view.rac.hidden = self.viewModel.outputs.paymentMethodsViewHidden

    self.viewModel.outputs.configurePledgeRewardsSummaryViewWithData
      .observeForUI()
      .observeValues { [weak self] rewardsData, bonusAmount, pledgeData in
        self?.pledgeRewardsSummaryViewController
          .configureWith(rewardsData: rewardsData, bonusAmount: bonusAmount, pledgeData: pledgeData)
      }

    self.viewModel.outputs.configurePledgeViewCTAContainerView
      .observeForUI()
      .observeValues { [weak self] value in
        self?.pledgeCTAContainerView.configureWith(value: value)
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

    self.viewModel.outputs.configurePaymentMethodsViewControllerWithValue
      .observeForUI()
      .observeValues { [weak self] value in
        self?.paymentMethodsViewController.configure(with: value)
      }

    self.viewModel.outputs.estimatedShippingViewHidden
      .observeForUI()
      .observeValues { [weak self] isHidden in
        self?.estimatedShippingViewContainer.view.isHidden = isHidden
      }

    self.viewModel.outputs.configureEstimatedShippingView
      .observeForUI()
      .observeValues { [weak self] estimatedShippingText, estimatedConversionText in
        guard let shippingText = estimatedShippingText else { return }

        self?.configureEstimatedShippingView(shippingText, estimatedConversionText)
      }

    self.viewModel.outputs.showWebHelp
      .observeForControllerAction()
      .observeValues { [weak self] helpType in
        guard let self = self else { return }
        self.presentHelpWebViewController(with: helpType, presentationStyle: .formSheet)
      }

    self.sessionStartedObserver = NotificationCenter.default
      .addObserver(forName: .ksr_sessionStarted, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.userSessionStarted()
      }

    self.viewModel.outputs.goToLoginSignup
      .observeForControllerAction()
      .observeValues { [weak self] intent in
        self?.goToLoginSignup(with: intent)
      }

    self.viewModel.outputs.validateCheckoutSuccess
      .observeForControllerAction()
      .observeValues { [weak self] validation in
        guard let self else { return }

        self.confirmPayment(with: validation)
      }

    self.viewModel.outputs.showErrorBannerWithMessage
      .observeForControllerAction()
      .observeValues { [weak self] errorMessage in
        self?.messageBannerViewController?.showBanner(
          with: .error,
          message: errorMessage,
          dismissType: .bannerAndViewController
        )
      }

    self.viewModel.outputs.configureStripeIntegration
      .observeForUI()
      .observeValues { merchantIdentifier, publishableKey in
        STPAPIClient.shared.publishableKey = publishableKey
        STPAPIClient.shared.configuration.appleMerchantIdentifier = merchantIdentifier
      }

    self.viewModel.outputs.goToApplePayPaymentAuthorization
      .observeForControllerAction()
      .observeValues { [weak self] paymentAuthorizationData in
        self?.goToPaymentAuthorization(paymentAuthorizationData)
      }

    self.viewModel.outputs.checkoutComplete
      .observeForUI()
      .observeValues { [weak self] thanksPageData in
        let thanksVC = ThanksViewController.configured(with: thanksPageData)
        self?.navigationController?.pushViewController(thanksVC, animated: true)
      }

    self.viewModel.outputs.checkoutError
      .observeForUI()
      .observeValues { [weak self] error in

        #if DEBUG
          let serverError = error.errorMessages.first ?? "Unknown server error"
          let message = "\(Strings.Something_went_wrong_please_try_again())\n\(serverError)"
        #else
          let message = Strings.Something_went_wrong_please_try_again()
        #endif

        self?.messageBannerViewController?
          .showBanner(with: .error, message: message, dismissType: .bannerAndViewController)
      }
  }

  // MARK: - Functions

  private func goToLoginSignup(with intent: LoginIntent) {
    let loginSignupViewController = LoginToutViewController.configuredWith(
      loginIntent: intent
    )

    let navigationController = UINavigationController(rootViewController: loginSignupViewController)
    let navigationBarHeight = navigationController.navigationBar.bounds.height

    self.present(navigationController, animated: true)
  }

  private func confirmPayment(with validation: PaymentSourceValidation) {
    guard validation.requiresConfirmation else {
      // Short circuit for payment intents that have already been validated
      self.viewModel.inputs.confirmPaymentSuccessful(clientSecret: validation.paymentIntentClientSecret)
      return
    }

    let paymentParams = STPPaymentIntentParams(clientSecret: validation.paymentIntentClientSecret)

    if let id = validation.selectedCardStripeCardId {
      paymentParams.paymentMethodId = id
    }

    STPPaymentHandler.shared()
      .confirmPayment(paymentParams, with: self) { status, _, error in
        guard error == nil, status == .succeeded else {
          // Only show error banner if confirmation failed instead of being canceled.
          if status == .failed {
            self.messageBannerViewController?
              .showBanner(
                with: .error,
                message: Strings.Something_went_wrong_please_try_again(),
                dismissType: .bannerAndViewController
              )
          }
          self.viewModel.inputs.checkoutTerminated()
          return
        }

        self.viewModel.inputs.confirmPaymentSuccessful(clientSecret: validation.paymentIntentClientSecret)
      }
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

  private func goToPaymentAuthorization(_ paymentAuthorizationData: PostCampaignPaymentAuthorizationData) {
    let request = PKPaymentRequest.paymentRequest(for: paymentAuthorizationData)
    guard let applePayContext = STPApplePayContext(paymentRequest: request, delegate: self) else {
      self.viewModel.inputs.checkoutTerminated()
      return
    }

    self.applePayPaymentIntent = paymentAuthorizationData.paymentIntent
    applePayContext.presentApplePay()
  }
}

// MARK: - STPAuthenticationContext

extension NoShippingPostCampaignCheckoutViewController: STPAuthenticationContext {
  func authenticationPresentingViewController() -> UIViewController {
    return self
  }
}

// MARK: - PledgeDisclaimerViewDelegate

extension NoShippingPostCampaignCheckoutViewController: PledgeDisclaimerViewDelegate {
  func pledgeDisclaimerView(_: PledgeDisclaimerView, didTapURL _: URL) {
    self.viewModel.inputs.pledgeDisclaimerViewDidTapLearnMore()
  }
}

// MARK: - PledgeViewCTAContainerViewDelegate

extension NoShippingPostCampaignCheckoutViewController: PledgeViewCTAContainerViewDelegate {
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

// MARK: - PledgePaymentMethodsViewControllerDelegate

extension NoShippingPostCampaignCheckoutViewController: PledgePaymentMethodsViewControllerDelegate {
  func pledgePaymentMethodsViewController(
    _: PledgePaymentMethodsViewController,
    didSelectCreditCard paymentSource: PaymentSourceSelected
  ) {
    self.viewModel.inputs.creditCardSelected(source: paymentSource)
  }
}

// MARK: - PledgeViewControllerMessageDisplaying

extension NoShippingPostCampaignCheckoutViewController: PledgeViewControllerMessageDisplaying {
  func pledgeViewController(_: UIViewController, didErrorWith message: String, error: Error?) {
    // If the error is a stripe error from attempting to add a new card, dismiss the banner only
    // instead of restarting the checkout flow.
    let stripeError = error as? NSError
    let dismissBannerOnly = stripeError?.domain == STPError.stripeDomain &&
      stripeError?.code == STPErrorCode.cardError.rawValue

    self.messageBannerViewController?.showBanner(
      with: .error,
      message: message,
      dismissType: dismissBannerOnly ? .bannerOnly : .bannerAndViewController
    )
  }

  func pledgeViewController(_: UIViewController, didSucceedWith message: String) {
    self.messageBannerViewController?.showBanner(with: .success, message: message)
  }
}

// MARK: - STPApplePayContextDelegate

extension NoShippingPostCampaignCheckoutViewController: STPApplePayContextDelegate {
  func applePayContext(
    _: StripeApplePay.STPApplePayContext,
    didCreatePaymentMethod paymentMethod: StripePayments.STPPaymentMethod,
    paymentInformation _: PKPayment,
    completion: @escaping StripeApplePay.STPIntentClientSecretCompletionBlock
  ) {
    guard let paymentIntentClientSecret = self.applePayPaymentIntent else {
      completion(
        nil,
        PostCampaignCheckoutApplePayError.missingPaymentIntent("Missing PaymentIntent")
      )
      return
    }

    self.viewModel.inputs.applePayContextDidCreatePayment(with: paymentMethod.stripeId)
    completion(paymentIntentClientSecret, nil)
  }

  func applePayContext(
    _: StripeApplePay.STPApplePayContext,
    didCompleteWith status: StripePayments.STPPaymentStatus,
    error _: Error?
  ) {
    switch status {
    case .success:
      self.viewModel.inputs.applePayContextDidComplete()
    case .error:
      self.viewModel.inputs.checkoutTerminated()
      self.messageBannerViewController?
        .showBanner(
          with: .error,
          message: Strings.Something_went_wrong_please_try_again(),
          dismissType: .bannerAndViewController
        )
    case .userCancellation:
      // User canceled the payment
      self.viewModel.inputs.checkoutTerminated()
      break
    @unknown default:
      self.viewModel.inputs.checkoutTerminated()
      fatalError()
    }
  }
}

private func rootInsetStackViewStyle(_ stackView: UIStackView) {
  stackView.axis = NSLayoutConstraint.Axis.vertical
  stackView.spacing = Styles.grid(4)
  stackView.isLayoutMarginsRelativeArrangement = true
  stackView.layoutMargins = UIEdgeInsets(
    topBottom: ConfirmDetailsLayout.Margin.topBottom,
    leftRight: ConfirmDetailsLayout.Margin.leftRight
  )
}

public func roundedStyle(_ view: UIView, cornerRadius: CGFloat = Styles.cornerRadius) {
  view.clipsToBounds = true
  view.layer.masksToBounds = true
  view.layer.cornerRadius = cornerRadius
}
