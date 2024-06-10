import KsApi
import Library
import PassKit
import Prelude
import Stripe
import UIKit

private enum PostCampaignCheckoutLayout {
  enum Style {
    static let cornerRadius: CGFloat = Styles.grid(2)
  }
}

final class PostCampaignCheckoutViewController: UIViewController,
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

  private let viewModel: PostCampaignCheckoutViewModelType =
    PostCampaignCheckoutViewModel(stripeIntentService: StripeIntentService())

  // MARK: - Lifecycle

  func configure(with data: PostCampaignCheckoutData) {
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
    self.messageBannerViewController?.delegate = self

    self.configureChildViewControllers()
    self.setupConstraints()

    if let attributedText = PledgeViewControllerHelpers.attributedLearnMoreText() {
      self.pledgeDisclaimerView.configure(with: ("icon-not-a-store", attributedText))
    }

    self.viewModel.inputs.viewDidLoad()
  }

  deinit {
    self.hideProcessingView()
  }

  // MARK: - Configuration

  private func configureChildViewControllers() {
    _ = (self.rootScrollView, self.view)
      |> ksr_addSubviewToParent()

    self.view.addSubview(self.rootScrollView)
    self.view.addSubview(self.pledgeCTAContainerView)

    _ = (self.rootStackView, self.rootScrollView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    // Configure root stack view.
    self.rootStackView.addArrangedSubview(self.rootInsetStackView)

    self.rootStackView.addArrangedSubview(self.pledgeRewardsSummaryViewController.view)
    self.addChild(self.pledgeRewardsSummaryViewController)
    self.pledgeRewardsSummaryViewController.didMove(toParent: self)

    // Configure inset views.
    self.rootInsetStackView.addArrangedSubview(self.titleLabel)

    self.rootInsetStackView.addArrangedSubview(self.paymentMethodsViewController.view)
    self.addChild(self.paymentMethodsViewController)
    self.paymentMethodsViewController.didMove(toParent: self)

    self.rootInsetStackView.addArrangedSubview(self.pledgeDisclaimerView)
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.rootScrollView.topAnchor.constraint(equalTo: self.view.topAnchor),
      self.rootScrollView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
      self.rootScrollView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
      self.rootScrollView.bottomAnchor.constraint(equalTo: self.pledgeCTAContainerView.topAnchor),
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

    self.titleLabel.text = Strings.Checkout()
    self.titleLabel.font = UIFont.ksr_title2().bolded
    self.titleLabel.numberOfLines = 0

    self.rootScrollView.showsVerticalScrollIndicator = false
    self.rootScrollView.alwaysBounceVertical = true

    self.rootStackView.axis = NSLayoutConstraint.Axis.vertical
    self.rootStackView.spacing = Styles.grid(1)

    self.rootInsetStackView.axis = NSLayoutConstraint.Axis.vertical
    self.rootInsetStackView.spacing = Styles.grid(4)
    self.rootInsetStackView.isLayoutMarginsRelativeArrangement = true
    self.rootInsetStackView.layoutMargins = UIEdgeInsets(
      topBottom: ConfirmDetailsLayout.Margin.topBottom,
      leftRight: ConfirmDetailsLayout.Margin.leftRight
    )

    _ = self.paymentMethodsViewController.view
      |> roundedStyle(cornerRadius: PostCampaignCheckoutLayout.Style.cornerRadius)

    _ = self.pledgeDisclaimerView
      |> roundedStyle(cornerRadius: PostCampaignCheckoutLayout.Style.cornerRadius)
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

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

    self.viewModel.outputs.showWebHelp
      .observeForControllerAction()
      .observeValues { [weak self] helpType in
        guard let self = self else { return }
        self.presentHelpWebViewController(with: helpType, presentationStyle: .formSheet)
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
        self?.messageBannerViewController?.showBanner(with: .error, message: errorMessage)
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
          let serverError = error.errorMessages.first ?? ""
          let message = "\(Strings.Something_went_wrong_please_try_again())\n\(serverError)"
        #else
          let message = Strings.Something_went_wrong_please_try_again()
        #endif

        self?.messageBannerViewController?
          .showBanner(with: .error, message: message)
      }
  }

  // MARK: - Functions

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
              .showBanner(with: .error, message: Strings.Something_went_wrong_please_try_again())
          }
          self.viewModel.inputs.checkoutTerminated()
          return
        }

        self.viewModel.inputs.confirmPaymentSuccessful(clientSecret: validation.paymentIntentClientSecret)
      }
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

extension PostCampaignCheckoutViewController: STPAuthenticationContext {
  func authenticationPresentingViewController() -> UIViewController {
    return self
  }
}

// MARK: - PledgeDisclaimerViewDelegate

extension PostCampaignCheckoutViewController: PledgeDisclaimerViewDelegate {
  func pledgeDisclaimerView(_: PledgeDisclaimerView, didTapURL _: URL) {
    self.viewModel.inputs.pledgeDisclaimerViewDidTapLearnMore()
  }
}

// MARK: - PledgeViewCTAContainerViewDelegate

extension PostCampaignCheckoutViewController: PledgeViewCTAContainerViewDelegate {
  func goToLoginSignup() {
    self.paymentMethodsViewController.cancelModalPresentation(true)
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

extension PostCampaignCheckoutViewController: PledgePaymentMethodsViewControllerDelegate {
  func pledgePaymentMethodsViewController(
    _: PledgePaymentMethodsViewController,
    didSelectCreditCard paymentSource: PaymentSourceSelected
  ) {
    self.viewModel.inputs.creditCardSelected(source: paymentSource)
  }
}

// MARK: - PledgeViewControllerMessageDisplaying

extension PostCampaignCheckoutViewController: PledgeViewControllerMessageDisplaying {
  func pledgeViewController(_: UIViewController, didErrorWith message: String) {
    self.messageBannerViewController?.showBanner(with: .error, message: message)
  }

  func pledgeViewController(_: UIViewController, didSucceedWith message: String) {
    self.messageBannerViewController?.showBanner(with: .success, message: message)
  }
}

// MARK: - MessageBannerViewControllerDelegate

extension PostCampaignCheckoutViewController: MessageBannerViewControllerDelegate {
  func messageBannerViewDidHide(type: MessageBannerType) {
    switch type {
    case .error:
      // Pop view controller in order to start checkout flow from the beginning,
      // starting with generating a new checkout id.
      self.navigationController?.popViewController(animated: true)
    default:
      break
    }
  }
}

// MARK: - STPApplePayContextDelegate

enum PostCampaignCheckoutApplePayError: Error {
  case missingPaymentMethodInfo(String)
  case missingPaymentIntent(String)
}

extension PostCampaignCheckoutViewController: STPApplePayContextDelegate {
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
        .showBanner(with: .error, message: Strings.Something_went_wrong_please_try_again())
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
