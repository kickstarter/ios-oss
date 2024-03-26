import KsApi
import Library
import Prelude
import Stripe
import UIKit

private enum PostCampaignCheckoutLayout {
  enum Style {
    static let cornerRadius: CGFloat = Styles.grid(2)
  }
}

final class PostCampaignCheckoutViewController: UIViewController, MessageBannerViewControllerPresenting {
  // MARK: - Properties

  internal var messageBannerViewController: MessageBannerViewController?

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

  private let viewModel: PostCampaignCheckoutViewModelType = PostCampaignCheckoutViewModel()

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

    self.configureChildViewControllers()
    self.setupConstraints()

    if let attributedText = PledgeViewControllerHelpers.attributedLearnMoreText() {
      self.pledgeDisclaimerView.configure(with: ("icon-not-a-store", attributedText))
    }

    self.viewModel.inputs.viewDidLoad()
  }

  deinit {
    self.sessionStartedObserver.doIfSome(NotificationCenter.default.removeObserver)
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

    self.viewModel.outputs.showWebHelp
      .observeForControllerAction()
      .observeValues { [weak self] helpType in
        guard let self = self else { return }
        self.presentHelpWebViewController(with: helpType, presentationStyle: .formSheet)
      }

    self.viewModel.outputs.validateCheckoutSuccess
      .observeForControllerAction()
      .observeValues { [weak self] _ in
        guard let self else { return }

        // TODO: Confirm paymentIntent using Stripe.confirmPayment()
      }

    self.viewModel.outputs.showErrorBannerWithMessage
      .observeForControllerAction()
      .observeValues { [weak self] errorMessage in
        self?.messageBannerViewController?.showBanner(with: .error, message: errorMessage)
      }

    self.sessionStartedObserver = NotificationCenter.default
      .addObserver(forName: .ksr_sessionStarted, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.userSessionStarted()
      }

    self.paymentMethodsViewController.view.rac.hidden = self.viewModel.outputs.paymentMethodsViewHidden

    self.viewModel.outputs.configureStripeIntegration
      .observeForUI()
      .observeValues { merchantIdentifier, publishableKey in
        STPAPIClient.shared.publishableKey = publishableKey
        STPAPIClient.shared.configuration.appleMerchantIdentifier = merchantIdentifier
      }
  }

  // MARK: - Functions

  private func goToLoginSignup(with intent: LoginIntent, project: Project, reward: Reward?) {
    let loginSignupViewController = LoginToutViewController.configuredWith(
      loginIntent: intent,
      project: project,
      reward: reward
    )

    let navigationController = UINavigationController(rootViewController: loginSignupViewController)
    let navigationBarHeight = navigationController.navigationBar.bounds.height

    self.present(navigationController, animated: true)
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
    self.viewModel.inputs.goToLoginSignupTapped()
  }

  func applePayButtonTapped() {
    self.paymentMethodsViewController.cancelModalPresentation(true)
    // TODO: Respond to button tap
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
    switch paymentSource {
    case let .paymentIntentClientSecret(clientSecret):
      return STPAPIClient.shared.retrievePaymentIntent(withClientSecret: clientSecret) { intent, _ in
        guard let intent = intent else {
          self.messageBannerViewController?
            .showBanner(with: .error, message: Strings.Something_went_wrong_please_try_again())
          return
        }

        let stripeCardId = intent.stripeId
        let paymentIntentClientSecret = paymentSource.paymentIntentClientSecret ?? ""

        self.viewModel.inputs.creditCardSelected(with: (stripeCardId, paymentIntentClientSecret))
      }
    default:
      break
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

extension PostCampaignCheckoutViewController: MessageBannerViewControllerDelegate {
  func messageBannerViewDidHide(type: MessageBannerType) {
    switch type {
    case .error:
      self.navigationController?.popViewController(animated: true)
    default:
      break
    }
  }
}
