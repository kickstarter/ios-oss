import KsApi
import Library
import PassKit
import Prelude
import Stripe
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
  func pledgeViewControllerDidUpdatePledge(_ viewController: PledgeViewController, message: String)
}

protocol PaymentSheetAppearanceDelegate: AnyObject {
  func pledgeViewControllerPaymentSheet(_ viewController: PledgeViewController, hidden: Bool)
}

final class PledgeViewController: UIViewController,
  MessageBannerViewControllerPresenting, ProcessingViewPresenting {
  // MARK: - Properties

  private lazy var confirmationSectionViews = {
    [self.pledgeDisclaimerView]
  }()

  public weak var delegate: PledgeViewControllerDelegate?
  public weak var paymentSheetAppearanceDelegate: PaymentSheetAppearanceDelegate?

  private lazy var descriptionSectionSeparator: UIView = {
    UIView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var projectTitleLabel = UILabel(frame: .zero)

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
    [self.projectTitleLabel, self.descriptionSectionSeparator]
  }()

  private lazy var pledgeExpandableRewardsHeaderViewController = {
    PledgeExpandableRewardsHeaderViewController(nibName: nil, bundle: nil)
      |> \.animatingViewDelegate .~ self.view
  }()

  private lazy var inputsSectionViews = {
    [
      self.shippingLocationViewController.view,
      self.shippingSummaryView,
      self.localPickupLocationView,
      self.pledgeAmountViewController.view
    ]
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

  private lazy var localPickupLocationView = {
    PledgeLocalPickupView(frame: .zero)
  }()

  private lazy var shippingSummaryView: PledgeShippingSummaryView = {
    PledgeShippingSummaryView(frame: .zero)
  }()

  private lazy var summarySectionViews = {
    [
      self.summarySectionSeparator,
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
  private let viewModel: PledgeViewModelType = PledgeViewModel()

  // MARK: - Lifecycle

  func configure(with data: PledgeViewData) {
    self.viewModel.inputs.configure(with: data)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    _ = self
      |> \.extendedLayoutIncludesOpaqueBars .~ true

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
      self.pledgeExpandableRewardsHeaderViewController,
      self.pledgeAmountSummaryViewController,
      self.pledgeAmountViewController,
      self.shippingLocationViewController,
      self.summaryViewController,
      self.paymentMethodsViewController
    ]

    let arrangedSubviews = [
      self.pledgeExpandableRewardsHeaderViewController.view,
      self.rootInsetStackView
    ]
    .compact()

    let arrangedInsetSubviews = [
      self.descriptionSectionViews,
      [self.pledgeAmountSummaryViewController.view],
      self.inputsSectionViews,
      self.summarySectionViews,
      self.paymentMethodsSectionViews,
      isNativeRiskMessagingControlEnabled() ? self.confirmationSectionViews : []
    ]
    .flatMap { $0 }
    .compact()

    arrangedSubviews.forEach { view in
      self.rootStackView.addArrangedSubview(view)
    }

    arrangedInsetSubviews.forEach { view in
      self.rootInsetStackView.addArrangedSubview(view)
    }

    childViewControllers.forEach { viewController in
      self.addChild(viewController)
      viewController.didMove(toParent: self)
    }

    self.rootStackView
      .setCustomSpacing(Styles.grid(2), after: self.pledgeExpandableRewardsHeaderViewController.view)
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

    _ = self.pledgeDisclaimerView
      |> pledgeDisclaimerViewStyle

    _ = self.projectTitleLabel
      |> projectTitleLabelStyle

    _ = self.rootScrollView
      |> rootScrollViewStyle

    _ = self.rootStackView
      |> rootStackViewStyle

    _ = self.rootInsetStackView
      |> rootInsetStackViewStyle

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

    self.viewModel.outputs.configureShippingLocationViewWithData
      .observeForUI()
      .observeValues { [weak self] data in
        self?.shippingLocationViewController.configureWith(value: data)
      }

    self.viewModel.outputs.configureShippingSummaryViewWithData
      .observeForUI()
      .observeValues { [weak self] data in
        self?.shippingSummaryView.configure(with: data)
      }

    self.viewModel.outputs.configurePledgeAmountViewWithData
      .observeForUI()
      .observeValues { [weak self] data in
        self?.pledgeAmountViewController.configureWith(value: data)
      }

    self.viewModel.outputs.configureExpandableRewardsHeaderWithData
      .observeForUI()
      .observeValues { [weak self] data in
        self?.pledgeExpandableRewardsHeaderViewController.configure(with: data)
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

    self.viewModel.outputs.notifyPledgeAmountViewControllerUnavailableAmountChanged
      .observeForUI()
      .observeValues { [weak self] amount in
        self?.pledgeAmountViewController.unavailableAmountChanged(to: amount)
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
        self?.paymentSheetAppearanceDelegate = self?.paymentMethodsViewController
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

    self.viewModel.outputs.goToRiskMessagingModal
      .observeForControllerAction()
      .observeValues { [weak self] isApplePay in
        self?.goToRiskMessagingModal(isApplePay: isApplePay)
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

    self.projectTitleLabel.rac.text = self.viewModel.outputs.projectTitle
    self.projectTitleLabel.rac.hidden = self.viewModel.outputs.projectTitleLabelHidden
    self.descriptionSectionSeparator.rac.hidden = self.viewModel.outputs.descriptionSectionSeparatorHidden
    self.summarySectionSeparator.rac.hidden = self.viewModel.outputs.summarySectionSeparatorHidden

    self.viewModel.outputs.rootStackViewLayoutMargins
      .observeForUI()
      .observeValues { [weak self] margins in
        self?.rootStackView.layoutMargins = margins
      }

    self.localPickupLocationView.rac.hidden = self.viewModel.outputs.localPickupViewHidden
    self.shippingLocationViewController.view.rac.hidden
      = self.viewModel.outputs.shippingLocationViewHidden
    self.shippingSummaryView.rac.hidden
      = self.viewModel.outputs.shippingSummaryViewHidden
    self.paymentMethodsViewController.view.rac.hidden = self.viewModel.outputs.paymentMethodsViewHidden
    self.pledgeAmountViewController.view.rac.hidden = self.viewModel.outputs.pledgeAmountViewHidden
    self.pledgeAmountSummaryViewController.view.rac.hidden
      = self.viewModel.outputs.pledgeAmountSummaryViewHidden
    self.pledgeExpandableRewardsHeaderViewController.view.rac.hidden
      = self.viewModel.outputs.expandableRewardsHeaderViewHidden

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
        self.paymentSheetAppearanceDelegate?.pledgeViewControllerPaymentSheet(self, hidden: true)
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

  private func goToRiskMessagingModal(isApplePay: Bool) {
    let viewController = RiskMessagingViewController()
    viewController.configure(isApplePay: isApplePay)
    viewController.delegate = self
    let offset = self.view.bounds.height * Layout.Style.modalHeightMultiplier
    self.presentViewControllerWithSheetOverlay(viewController, offset: offset)
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
    guard let attributedText = attributedLearnMoreText() else { return }
    self.pledgeDisclaimerView.configure(with: ("icon-not-a-store", attributedText))
  }

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
    let setupIntentConfirmParams = STPSetupIntentConfirmParams(clientSecret: secret)

    STPPaymentHandler.shared()
      .confirmSetupIntent(setupIntentConfirmParams, with: self) { [weak self] status, _, error in
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

extension PledgeViewController: PledgeViewCTAContainerViewDelegate {
  func goToLoginSignup() {
    self.paymentSheetAppearanceDelegate?.pledgeViewControllerPaymentSheet(self, hidden: true)
    self.viewModel.inputs.goToLoginSignupTapped()
  }

  func applePayButtonTapped() {
    self.paymentSheetAppearanceDelegate?.pledgeViewControllerPaymentSheet(self, hidden: true)
    self.viewModel.inputs.applePayButtonTapped()
  }

  func submitButtonTapped() {
    self.paymentSheetAppearanceDelegate?.pledgeViewControllerPaymentSheet(self, hidden: true)
    self.viewModel.inputs.submitButtonTapped()
  }

  func termsOfUseTapped(with helpType: HelpType) {
    self.paymentSheetAppearanceDelegate?.pledgeViewControllerPaymentSheet(self, hidden: true)
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

  func pledgeShippingLocationViewControllerLayoutDidUpdate(_: PledgeShippingLocationViewController) {}
  func pledgeShippingLocationViewControllerFailedToLoad(_: PledgeShippingLocationViewController) {}
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

// MARK: - RiskMessagingViewControllerDelegate

extension PledgeViewController: RiskMessagingViewControllerDelegate {
  func riskMessagingViewControllerDismissed(_: RiskMessagingViewController, isApplePay: Bool) {
    self.viewModel.inputs.riskMessagingViewControllerDismissed(isApplePay: isApplePay)
  }
}

// MARK: - Styles

private let pledgeDisclaimerViewStyle: ViewStyle = { view in
  view
    |> roundedStyle(cornerRadius: Layout.Style.cornerRadius)
}

private let projectTitleLabelStyle: LabelStyle = { label in
  label
    |> \.font .~ UIFont.ksr_body().bolded
    |> \.numberOfLines .~ 0
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
}

private let rootInsetStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ NSLayoutConstraint.Axis.vertical
    |> \.spacing .~ Styles.grid(4)
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.layoutMargins .~ UIEdgeInsets(
      topBottom: 0,
      leftRight: Layout.Margin.leftRight
    )
}

// MARK: - Functions

private func attributedLearnMoreText() -> NSAttributedString? {
  guard let trustLink = HelpType.trust.url(
    withBaseUrl: AppEnvironment.current.apiService.serverConfig.webBaseUrl
  )?.absoluteString else { return nil }

  let paragraphStyle = NSMutableParagraphStyle()
  paragraphStyle.lineSpacing = 2

  let attributedLine1String = Strings.Kickstarter_is_not_a_store()
    .attributed(
      with: UIFont.ksr_footnote(),
      foregroundColor: .ksr_support_400,
      attributes: [.paragraphStyle: paragraphStyle],
      bolding: [Strings.Kickstarter_is_not_a_store()]
    )

  let line2String = Strings.Its_a_way_to_bring_creative_projects_to_life_Learn_more_about_accountability(
    trust_link: trustLink
  )

  guard let attributedLine2String = try? NSMutableAttributedString(
    data: Data(line2String.utf8),
    options: [
      .documentType: NSAttributedString.DocumentType.html,
      .characterEncoding: String.Encoding.utf8.rawValue
    ],
    documentAttributes: nil
  ) else { return nil }

  let attributes: String.Attributes = [
    .font: UIFont.ksr_footnote(),
    .foregroundColor: UIColor.ksr_support_400,
    .paragraphStyle: paragraphStyle,
    .underlineStyle: 0
  ]

  let fullRange = (attributedLine2String.string as NSString).range(of: attributedLine2String.string)
  attributedLine2String.addAttributes(attributes, range: fullRange)

  let attributedString = attributedLine1String + NSAttributedString(string: "\n") + attributedLine2String

  return attributedString
}
