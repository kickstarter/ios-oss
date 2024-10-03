import Apollo
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

final class NoShippingPostCampaignCheckoutViewModelTests: TestCase {
  private var vm = NoShippingPostCampaignCheckoutViewModel(stripeIntentService: MockStripeIntentService())
  private let mockStripeIntentService = MockStripeIntentService()

  private let checkoutResponse = CreateCheckoutEnvelope(
    checkout: CreateCheckoutEnvelope.Checkout(id: "19", paymentUrl: "fake", backingId: "93")
  )

  private let goToApplePayPaymentAuthorization = TestObserver<
    PostCampaignPaymentAuthorizationData,
    Never
  >()
  private let checkoutComplete = TestObserver<ThanksPageData, Never>()
  private let processingViewIsHidden = TestObserver<Bool, Never>()
  private let validateCheckoutSuccess = TestObserver<PaymentSourceValidation, Never>()
  private let showErrorBannerWithMessage = TestObserver<(String, Bool), Never>()
  private let goToLoginSignup = TestObserver<(LoginIntent, Project, Reward), Never>()

  private let configurePaymentMethodsViewControllerWithUser = TestObserver<User, Never>()
  private let configurePaymentMethodsViewControllerWithProject = TestObserver<Project, Never>()
  private let configurePaymentMethodsViewControllerWithCheckoutId = TestObserver<String, Never>()
  private let configurePaymentMethodsViewControllerWithReward = TestObserver<Reward, Never>()
  private let configurePaymentMethodsViewControllerWithContext = TestObserver<PledgeViewContext, Never>()

  private let configurePledgeViewCTAContainerViewIsLoggedIn = TestObserver<Bool, Never>()
  private let configurePledgeViewCTAContainerViewIsEnabled = TestObserver<Bool, Never>()
  private let configurePledgeViewCTAContainerViewContext = TestObserver<PledgeViewContext, Never>()

  private let configureStripeIntegrationMerchantId = TestObserver<String, Never>()
  private let configureStripeIntegrationPublishableKey = TestObserver<String, Never>()

  private let showWebHelp = TestObserver<HelpType, Never>()

  override func setUp() {
    super.setUp()

    self.vm = NoShippingPostCampaignCheckoutViewModel(stripeIntentService: self.mockStripeIntentService)

    self.vm.goToApplePayPaymentAuthorization.observe(self.goToApplePayPaymentAuthorization.observer)
    self.vm.checkoutComplete.observe(self.checkoutComplete.observer)
    self.vm.processingViewIsHidden.observe(self.processingViewIsHidden.observer)
    self.vm.validateCheckoutSuccess.observe(self.validateCheckoutSuccess.observer)
    self.vm.showErrorBannerWithMessage.observe(self.showErrorBannerWithMessage.observer)
    self.vm.goToLoginSignup.observe(self.goToLoginSignup.observer)

    self.vm.outputs.configurePaymentMethodsViewControllerWithValue.map { $0.0 }
      .observe(self.configurePaymentMethodsViewControllerWithUser.observer)
    self.vm.outputs.configurePaymentMethodsViewControllerWithValue.map { $0.1 }
      .observe(self.configurePaymentMethodsViewControllerWithProject.observer)
    self.vm.outputs.configurePaymentMethodsViewControllerWithValue.map { $0.2 }
      .observe(self.configurePaymentMethodsViewControllerWithCheckoutId.observer)
    self.vm.outputs.configurePaymentMethodsViewControllerWithValue.map { $0.3 }
      .observe(self.configurePaymentMethodsViewControllerWithReward.observer)
    self.vm.outputs.configurePaymentMethodsViewControllerWithValue.map { $0.4 }
      .observe(self.configurePaymentMethodsViewControllerWithContext.observer)

    self.vm.outputs.configurePledgeViewCTAContainerView.map { $0.0 }
      .observe(self.configurePledgeViewCTAContainerViewIsLoggedIn.observer)
    self.vm.outputs.configurePledgeViewCTAContainerView.map { $0.1 }
      .observe(self.configurePledgeViewCTAContainerViewIsEnabled.observer)
    self.vm.outputs.configurePledgeViewCTAContainerView.map { $0.2 }
      .observe(self.configurePledgeViewCTAContainerViewContext.observer)

    self.vm.outputs.configureStripeIntegration.map(first)
      .observe(self.configureStripeIntegrationMerchantId.observer)
    self.vm.outputs.configureStripeIntegration.map(second)
      .observe(self.configureStripeIntegrationPublishableKey.observer)

    self.vm.outputs.showWebHelp.observe(self.showWebHelp.observer)
  }

  // MARK: - Web Help

  func testShowWebHelp() {
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.termsOfUseTapped(with: .terms)

    self.showWebHelp.assertValues([HelpType.terms])
  }

  func testShowWebHelpLearnMore() {
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.pledgeDisclaimerViewDidTapLearnMore()

    self.showWebHelp.assertValues([HelpType.trust])
  }

  // MARK: - Stripe

  func testStripeConfiguration_StagingEnvironment() {
    let mockService = MockService(serverConfig: ServerConfig.staging)

    withEnvironment(apiService: mockService) {
      self.configureStripeIntegrationMerchantId.assertDidNotEmitValue()
      self.configureStripeIntegrationPublishableKey.assertDidNotEmitValue()

      let project = Project.template
      let reward = Reward.template

      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        bonusSupport: 0,
        selectedShippingRule: nil,
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: nil,
        context: .latePledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.configureStripeIntegrationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])
      self.configureStripeIntegrationPublishableKey.assertValues([Secrets.StripePublishableKey.staging])
    }
  }

  func testStripeConfiguration_ProductionEnvironment() {
    let mockService = MockService(serverConfig: ServerConfig.production)

    withEnvironment(apiService: mockService) {
      self.configureStripeIntegrationMerchantId.assertDidNotEmitValue()

      let project = Project.template
      let reward = Reward.template

      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        bonusSupport: 0,
        selectedShippingRule: nil,
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: nil,
        context: .latePledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.configureStripeIntegrationMerchantId.assertValues([Secrets.ApplePay.merchantIdentifier])
      self.configureStripeIntegrationPublishableKey.assertValues([Secrets.StripePublishableKey.production])
    }
  }

  // MARK: - Apple Pay

  func testApplePayAuthorization_noReward_isCorrect() {
    let project = Project.cosmicSurgery
    let reward = Reward.noReward

    let data = PledgeViewData(
      project: project,
      rewards: [reward],
      bonusSupport: 5,
      selectedShippingRule: nil,
      selectedQuantities: [reward.id: 1],
      selectedLocationId: nil,
      refTag: nil,
      context: .latePledge
    )

    let paymentIntent = PaymentIntentEnvelope(clientSecret: "foo")
    let mockService = MockService(
      createCheckoutResult: .success(self.checkoutResponse),
      createPaymentIntentResult: .success(paymentIntent)
    )

    withEnvironment(apiService: mockService, currentUser: User.template) {
      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.scheduler.run()

      self.vm.inputs.applePayButtonTapped()

      self.scheduler.run()

      self.goToApplePayPaymentAuthorization.assertValueCount(1)
      let output = self.goToApplePayPaymentAuthorization.lastValue!

      XCTAssertEqual(output.project, project)
      XCTAssertEqual(output.hasNoReward, true)
      XCTAssertEqual(output.subtotal, 5)
      XCTAssertEqual(output.bonus, 0)
      XCTAssertEqual(output.shipping, 0)
      XCTAssertEqual(output.total, 5)

      XCTAssertEqual(self.mockStripeIntentService.paymentIntentRequests, 1)
      XCTAssertEqual(self.mockStripeIntentService.setupIntentRequests, 0)
    }
  }

  func testApplePayAuthorization_reward_isCorrect() {
    let project = Project.cosmicSurgery
    let reward = project.rewards.first!

    XCTAssertEqual(reward.minimum, 6)

    let data = PledgeViewData(
      project: project,
      rewards: [reward],
      bonusSupport: 0,
      selectedShippingRule: nil,
      selectedQuantities: [reward.id: 3],
      selectedLocationId: nil,
      refTag: nil,
      context: .latePledge
    )

    let paymentIntent = PaymentIntentEnvelope(clientSecret: "foo")
    let mockService = MockService(
      createCheckoutResult: .success(self.checkoutResponse),
      createPaymentIntentResult: .success(paymentIntent)
    )

    withEnvironment(apiService: mockService, currentUser: User.template) {
      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.scheduler.run()

      self.vm.inputs.applePayButtonTapped()

      self.scheduler.run()

      self.goToApplePayPaymentAuthorization.assertValueCount(1)
      let output = self.goToApplePayPaymentAuthorization.lastValue!

      XCTAssertEqual(output.project, project)
      XCTAssertEqual(output.hasNoReward, false)
      XCTAssertEqual(output.subtotal, 18)
      XCTAssertEqual(output.bonus, 0)
      XCTAssertEqual(output.shipping, 0)
      XCTAssertEqual(output.total, 18)

      XCTAssertEqual(self.mockStripeIntentService.paymentIntentRequests, 1)
      XCTAssertEqual(self.mockStripeIntentService.setupIntentRequests, 0)
    }
  }

  func testApplePayAuthorization_rewardAndShipping_isCorrect() {
    let project = Project.cosmicSurgery
    let reward = project.rewards.first!
      |> Reward.lens.shippingRules .~ [ShippingRule.template]
      |> Reward.lens.shipping.enabled .~ true

    XCTAssertEqual(reward.minimum, 6)

    let data = PledgeViewData(
      project: project,
      rewards: [reward],
      bonusSupport: 0,
      selectedShippingRule: ShippingRule.template,
      selectedQuantities: [reward.id: 3],
      selectedLocationId: nil,
      refTag: nil,
      context: .latePledge
    )

    let paymentIntent = PaymentIntentEnvelope(clientSecret: "foo")
    let mockService = MockService(
      createCheckoutResult: .success(self.checkoutResponse),
      createPaymentIntentResult: .success(paymentIntent)
    )

    withEnvironment(apiService: mockService, currentUser: User.template) {
      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.scheduler.run()

      self.vm.inputs.applePayButtonTapped()

      self.scheduler.run()

      self.goToApplePayPaymentAuthorization.assertValueCount(1)
      let output = self.goToApplePayPaymentAuthorization.lastValue!

      XCTAssertEqual(output.project, project)
      XCTAssertEqual(output.hasNoReward, false)
      XCTAssertEqual(output.subtotal, 18)
      XCTAssertEqual(output.bonus, 0)
      XCTAssertEqual(output.shipping, 15)
      XCTAssertEqual(output.total, 33)

      XCTAssertEqual(self.mockStripeIntentService.paymentIntentRequests, 1)
      XCTAssertEqual(self.mockStripeIntentService.setupIntentRequests, 0)
    }
  }

  func testApplePayAuthorization_rewardAndShippingAndBonus_isCorrect() {
    let shippingRule = ShippingRule.template
    var project = Project.cosmicSurgery
    let reward1 = project.rewards[0]
      |> Reward.lens.shippingRules .~ [shippingRule]
      |> Reward.lens.shipping.enabled .~ true
    let reward2 = project.rewards[1]
      |> Reward.lens.shippingRules .~ [shippingRule]
      |> Reward.lens.shipping.enabled .~ true

    XCTAssertEqual(reward1.minimum, 6)
    XCTAssertEqual(reward2.minimum, 25)

    let data = PledgeViewData(
      project: project,
      rewards: [reward1, reward2],
      bonusSupport: 5,
      selectedShippingRule: shippingRule,
      selectedQuantities: [reward1.id: 1, reward2.id: 2],
      selectedLocationId: nil,
      refTag: nil,
      context: .latePledge
    )

    let paymentIntent = PaymentIntentEnvelope(clientSecret: "foo")
    let mockService = MockService(
      createCheckoutResult: .success(self.checkoutResponse),
      createPaymentIntentResult: .success(paymentIntent)
    )

    withEnvironment(apiService: mockService, currentUser: User.template) {
      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.scheduler.run()

      self.vm.inputs.applePayButtonTapped()

      self.scheduler.run()

      self.goToApplePayPaymentAuthorization.assertValueCount(1)
      let output = self.goToApplePayPaymentAuthorization.lastValue!

      XCTAssertEqual(output.project, project)
      XCTAssertEqual(output.hasNoReward, false)
      XCTAssertEqual(output.subtotal, 56)
      XCTAssertEqual(output.bonus, 5)
      XCTAssertEqual(output.shipping, 15)
      XCTAssertEqual(output.total, 76)

      XCTAssertEqual(self.mockStripeIntentService.paymentIntentRequests, 1)
      XCTAssertEqual(self.mockStripeIntentService.setupIntentRequests, 0)
    }
  }

  func testTapApplePayButton_createsPaymentIntent_beforePresentingAuthorizationController() {
    let paymentIntent = PaymentIntentEnvelope(clientSecret: "foo")
    let mockService = MockService(
      createCheckoutResult: .success(self.checkoutResponse),
      createPaymentIntentResult: .success(paymentIntent)
    )

    let project = Project.cosmicSurgery
    let reward = Reward.noReward |> Reward.lens.minimum .~ 5

    let data = PledgeViewData(
      project: project,
      rewards: [reward],
      bonusSupport: 0,
      selectedShippingRule: nil,
      selectedQuantities: [reward.id: 1],
      selectedLocationId: nil,
      refTag: nil,
      context: .latePledge
    )

    withEnvironment(apiService: mockService, currentUser: User.template) {
      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()
      self.scheduler.run()
      self.vm.inputs.applePayButtonTapped()
      self.scheduler.run()
      self.goToApplePayPaymentAuthorization.assertDidEmitValue()

      let output = self.goToApplePayPaymentAuthorization.lastValue!
      XCTAssertEqual(output.paymentIntent, "foo")

      XCTAssertEqual(self.mockStripeIntentService.paymentIntentRequests, 1)
      XCTAssertEqual(self.mockStripeIntentService.setupIntentRequests, 0)
    }
  }

  func testApplePay_completesCheckoutFlow() {
    // Mock data for API requests
    let paymentIntent = PaymentIntentEnvelope(clientSecret: "foo")
    let validateCheckout = ValidateCheckoutEnvelope(messages: ["message"])
    let completeSessionJsonString = """
    {
      "completeOnSessionCheckout": {
        "__typename": "CompleteOnSessionCheckoutPayload",
        "checkout": {
          "__typename": "Checkout",
          "id": "Q2hlY2tvdXQtMTk4MzM2OTIz",
          "state": "successful",
          "backing": {
            "requiresAction": false,
            "clientSecret": "super-secret",
            "__typename": "Backing"
          }
        }
      }
    }
    """
    let completeSessionData = try! GraphAPI.CompleteOnSessionCheckoutMutation
      .Data(jsonString: completeSessionJsonString)
    let mockService = MockService(
      completeOnSessionCheckoutResult: .success(completeSessionData),
      createCheckoutResult: .success(self.checkoutResponse),
      createPaymentIntentResult: .success(paymentIntent),
      validateCheckoutResult: .success(validateCheckout)
    )

    let project = Project.cosmicSurgery
    let reward = Reward.noReward |> Reward.lens.minimum .~ 5

    let data = PledgeViewData(
      project: project,
      rewards: [reward],
      bonusSupport: 0,
      selectedShippingRule: nil,
      selectedQuantities: [reward.id: 1],
      selectedLocationId: nil,
      refTag: nil,
      context: .latePledge
    )

    withEnvironment(apiService: mockService, currentUser: User.template) {
      self.vm.configure(with: data)
      self.vm.viewDidLoad()

      self.scheduler.run()

      self.vm.inputs.applePayButtonTapped()

      self.scheduler.run()

      self.processingViewIsHidden.assertLastValue(false)
      self.goToApplePayPaymentAuthorization.assertDidEmitValue()

      self.vm.inputs.applePayContextDidCreatePayment(with: "Fake Payment Method id")

      self.checkoutComplete.assertDidNotEmitValue()
      self.processingViewIsHidden.assertLastValue(false)

      self.vm.inputs.applePayContextDidComplete()

      self.scheduler.run()

      self.checkoutComplete.assertDidEmitValue()
      self.processingViewIsHidden.assertLastValue(true)

      XCTAssertEqual(self.mockStripeIntentService.paymentIntentRequests, 1)
      XCTAssertEqual(self.mockStripeIntentService.setupIntentRequests, 0)
    }
  }

  func testApplePay_paymentIntentFails() {
    // Mock data for API requests
    let mockService = MockService(
      createCheckoutResult: .success(self.checkoutResponse),
      createPaymentIntentResult: .failure(.couldNotParseErrorEnvelopeJSON)
    )

    let project = Project.cosmicSurgery
    let reward = Reward.noReward |> Reward.lens.minimum .~ 5

    let data = PledgeViewData(
      project: project,
      rewards: [reward],
      bonusSupport: 0,
      selectedShippingRule: nil,
      selectedQuantities: [reward.id: 1],
      selectedLocationId: nil,
      refTag: nil,
      context: .latePledge
    )

    withEnvironment(apiService: mockService, currentUser: User.template) {
      self.vm.configure(with: data)
      self.vm.viewDidLoad()

      self.scheduler.run()

      self.vm.inputs.applePayButtonTapped()

      self.processingViewIsHidden.assertLastValue(false)

      self.scheduler.run()

      self.goToApplePayPaymentAuthorization.assertDidNotEmitValue()
      self.processingViewIsHidden.assertValues([true, false])

      XCTAssertEqual(self.mockStripeIntentService.setupIntentRequests, 0)
      XCTAssertEqual(self.mockStripeIntentService.setupIntentRequests, 0)
    }
  }

  // MARK: - Pledge

  func testPledge_completesCheckoutFlow() {
    // Mock data for API requests
    let validateCheckout = ValidateCheckoutEnvelope(messages: ["message"])
    let completeSessionJsonString = """
    {
      "completeOnSessionCheckout": {
        "__typename": "CompleteOnSessionCheckoutPayload",
        "checkout": {
          "__typename": "Checkout",
          "id": "Q2hlY2tvdXQtMTk4MzM2OTIz",
          "state": "successful",
          "backing": {
            "requiresAction": false,
            "clientSecret": "super-secret",
            "__typename": "Backing"
          }
        }
      }
    }
    """
    let completeSessionJson = try! JSONSerialization
      .jsonObject(with: completeSessionJsonString.data(using: .utf8)!)
    let completeSessionData = try! GraphAPI.CompleteOnSessionCheckoutMutation
      .Data(jsonObject: completeSessionJson as! JSONObject)
    let paymentIntent = PaymentIntentEnvelope(clientSecret: "foo")
    let graphUser = GraphUser.template |> \.storedCards .~ UserCreditCards.withCards([UserCreditCards.visa])
    let userResponse = UserEnvelope<GraphUser>(me: graphUser)

    let mockService = MockService(
      completeOnSessionCheckoutResult: .success(completeSessionData),
      createCheckoutResult: .success(self.checkoutResponse),
      createPaymentIntentResult: .success(paymentIntent),
      fetchGraphUserResult: .success(userResponse),
      validateCheckoutResult: .success(validateCheckout)
    )

    let project = Project.cosmicSurgery
    let reward = Reward.noReward |> Reward.lens.minimum .~ 5

    let data = PledgeViewData(
      project: project,
      rewards: [reward],
      bonusSupport: 0,
      selectedShippingRule: nil,
      selectedQuantities: [reward.id: 1],
      selectedLocationId: nil,
      refTag: nil,
      context: .latePledge
    )

    withEnvironment(apiService: mockService, currentUser: User.template) {
      self.vm.configure(with: data)
      self.vm.viewDidLoad()

      scheduler.run()

      self.vm.inputs
        .creditCardSelected(
          source: .savedCreditCard(UserCreditCards.visa.id, "pm_fake")
        )

      self.scheduler.run()

      self.configurePledgeViewCTAContainerViewIsLoggedIn.assertValues([true, true])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true])
      self.configurePledgeViewCTAContainerViewContext.assertValues([.latePledge, .latePledge])

      self.vm.inputs.submitButtonTapped()

      self.processingViewIsHidden.assertLastValue(false)

      self.scheduler.run()

      self.validateCheckoutSuccess.assertDidEmitValue()
      self.checkoutComplete.assertDidNotEmitValue()

      self.vm.inputs.confirmPaymentSuccessful(clientSecret: "super-secret")

      self.checkoutComplete.assertDidEmitValue()
      self.processingViewIsHidden.assertLastValue(true)
    }
  }

  func testPledge_validationFails() {
    // Mock data for API requests
    let paymentIntent = PaymentIntentEnvelope(clientSecret: "foo")
    let graphUser = GraphUser.template |> \.storedCards .~ UserCreditCards.withCards([UserCreditCards.visa])
    let userResponse = UserEnvelope<GraphUser>(me: graphUser)

    let mockService = MockService(
      createCheckoutResult: .success(self.checkoutResponse),
      createPaymentIntentResult: .success(paymentIntent),
      fetchGraphUserResult: .success(userResponse),
      validateCheckoutResult: .failure(.couldNotParseErrorEnvelopeJSON)
    )

    let project = Project.cosmicSurgery
    let reward = Reward.noReward |> Reward.lens.minimum .~ 5

    let data = PledgeViewData(
      project: project,
      rewards: [reward],
      bonusSupport: 0,
      selectedShippingRule: nil,
      selectedQuantities: [reward.id: 1],
      selectedLocationId: nil,
      refTag: nil,
      context: .latePledge
    )

    withEnvironment(apiService: mockService, currentUser: User.template) {
      self.vm.configure(with: data)
      self.vm.viewDidLoad()
      self.scheduler.run()

      self.vm.inputs
        .creditCardSelected(
          source: .savedCreditCard(UserCreditCards.visa.id, "pm_fake")
        )

      self.configurePledgeViewCTAContainerViewIsLoggedIn.assertValues([true, true])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true])
      self.configurePledgeViewCTAContainerViewContext.assertValues([.latePledge, .latePledge])

      self.vm.inputs.submitButtonTapped()

      self.processingViewIsHidden.assertLastValue(false)

      self.scheduler.run()

      self.validateCheckoutSuccess.assertDidNotEmitValue()
      self.processingViewIsHidden.assertValues([false, true])
    }
  }

  func testCheckoutTerminated_cancelsCheckoutFlow() {
    // Mock data for API requests
    let validateCheckout = ValidateCheckoutEnvelope(messages: ["message"])
    let paymentIntent = PaymentIntentEnvelope(clientSecret: "foo")

    let mockService = MockService(
      createCheckoutResult: .success(self.checkoutResponse),
      createPaymentIntentResult: .success(paymentIntent),
      validateCheckoutResult: .success(validateCheckout)
    )

    let project = Project.cosmicSurgery
    let reward = Reward.noReward |> Reward.lens.minimum .~ 5

    let data = PledgeViewData(
      project: project,
      rewards: [reward],
      bonusSupport: 0,
      selectedShippingRule: nil,
      selectedQuantities: [reward.id: 1],
      selectedLocationId: nil,
      refTag: nil,
      context: .latePledge
    )

    withEnvironment(apiService: mockService, currentUser: User.template) {
      self.vm.configure(with: data)
      self.vm.viewDidLoad()
      self.scheduler.run()

      self.vm.inputs
        .creditCardSelected(
          source: .savedCreditCard(UserCreditCards.visa.id, "pm_fake")
        )

      self.configurePledgeViewCTAContainerViewIsLoggedIn.assertValues([true, true])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true])
      self.configurePledgeViewCTAContainerViewContext.assertValues([.latePledge, .latePledge])

      self.vm.inputs.submitButtonTapped()

      self.processingViewIsHidden.assertLastValue(false)

      self.scheduler.run()

      self.validateCheckoutSuccess.assertDidEmitValue()

      self.vm.inputs.checkoutTerminated()

      self.checkoutComplete.assertDidNotEmitValue()
      self.processingViewIsHidden.assertLastValue(true)
    }
  }

  // MARK: - Login

  func testPledgeViewCTAEnabled_afterSelectingNewPaymentMethod_LoggedIn() {
    let paymentIntent = PaymentIntentEnvelope(clientSecret: "foo")
    let mockService = MockService(
      serverConfig: ServerConfig.staging,
      createCheckoutResult: .success(self.checkoutResponse),
      createPaymentIntentResult: .success(paymentIntent)
    )

    withEnvironment(apiService: mockService, currentUser: .template) {
      let project = Project.cosmicSurgery
      let reward = Reward.noReward |> Reward.lens.minimum .~ 5

      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        bonusSupport: 0,
        selectedShippingRule: nil,
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: nil,
        context: .latePledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()
      self.scheduler.run()

      self.vm.inputs
        .creditCardSelected(
          source: .savedCreditCard(UserCreditCards.visa.id, "pm_fake")
        )

      self.configurePledgeViewCTAContainerViewIsLoggedIn.assertValues([true, true])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false, true])
      self.configurePledgeViewCTAContainerViewContext.assertValues([.latePledge, .latePledge])
    }
  }

  func testPledgeViewCTADisabled_onViewDidLoad_LoggedIn() {
    let mockService = MockService(serverConfig: ServerConfig.staging)

    withEnvironment(apiService: mockService, currentUser: .template) {
      let project = Project.cosmicSurgery
      let reward = Reward.noReward |> Reward.lens.minimum .~ 5

      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        bonusSupport: 0,
        selectedShippingRule: nil,
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: nil,
        context: .latePledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()
      self.scheduler.run()

      self.configurePledgeViewCTAContainerViewIsLoggedIn.assertValues([true])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.configurePledgeViewCTAContainerViewContext.assertValues([.latePledge])
    }
  }

  func testPledgeViewCTADisabled_onViewDidLoad_LoggedOut() {
    let mockService = MockService(serverConfig: ServerConfig.staging)

    withEnvironment(apiService: mockService) {
      let project = Project.cosmicSurgery
      let reward = Reward.noReward |> Reward.lens.minimum .~ 5

      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        bonusSupport: 0,
        selectedShippingRule: nil,
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil,
        refTag: nil,
        context: .latePledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()
      self.scheduler.run()

      self.configurePledgeViewCTAContainerViewIsLoggedIn.assertValues([false])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.configurePledgeViewCTAContainerViewContext.assertValues([.latePledge])
    }
  }

  func testGoToLoginSignup_emitsWhenLoggedOut_CheckoutErrorDoesNotEmit() {
    let mockService = MockService(createCheckoutResult: .failure(.couldNotParseJSON))

    withEnvironment(apiService: mockService, currentUser: nil) {
      let data = PledgeViewData(
        project: Project.template,
        rewards: [Reward.template],
        selectedShippingRule: nil,
        selectedQuantities: [Reward.template.id: 1],
        selectedLocationId: nil,
        refTag: .projectPage,
        context: .latePledge
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.vm.inputs.goToLoginSignupTapped()

      self.goToLoginSignup.assertDidEmitValue()
      self.showErrorBannerWithMessage.assertDidNotEmitValue()
    }
  }
}
