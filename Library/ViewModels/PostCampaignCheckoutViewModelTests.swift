import Apollo
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

final class PostCampaignCheckoutViewModelTests: TestCase {
  fileprivate let vm = PostCampaignCheckoutViewModel()
  fileprivate let goToApplePayPaymentAuthorization = TestObserver<
    PostCampaignPaymentAuthorizationData,
    Never
  >()
  fileprivate let checkoutComplete = TestObserver<ThanksPageData, Never>()
  fileprivate let processingViewIsHidden = TestObserver<Bool, Never>()
  fileprivate let validateCheckoutSuccess = TestObserver<PaymentSourceValidation, Never>()

  private let configurePledgeViewCTAContainerViewIsLoggedIn = TestObserver<Bool, Never>()
  private let configurePledgeViewCTAContainerViewIsEnabled = TestObserver<Bool, Never>()
  private let configurePledgeViewCTAContainerViewContext = TestObserver<PledgeViewContext, Never>()

  override func setUp() {
    super.setUp()
    self.vm.goToApplePayPaymentAuthorization.observe(self.goToApplePayPaymentAuthorization.observer)
    self.vm.checkoutComplete.observe(self.checkoutComplete.observer)
    self.vm.processingViewIsHidden.observe(self.processingViewIsHidden.observer)
    self.vm.validateCheckoutSuccess.observe(self.validateCheckoutSuccess.observer)

    self.vm.outputs.configurePledgeViewCTAContainerView.map { $0.0 }
      .observe(self.configurePledgeViewCTAContainerViewIsLoggedIn.observer)
    self.vm.outputs.configurePledgeViewCTAContainerView.map { $0.1 }
      .observe(self.configurePledgeViewCTAContainerViewIsEnabled.observer)
    self.vm.outputs.configurePledgeViewCTAContainerView.map { $0.2 }
      .observe(self.configurePledgeViewCTAContainerViewContext.observer)
  }

  func testApplePayAuthorization_noReward_isCorrect() {
    let project = Project.cosmicSurgery
    let reward = Reward.noReward |> Reward.lens.minimum .~ 5

    let data = PostCampaignCheckoutData(
      project: project,
      baseReward: reward,
      rewards: [reward],
      selectedQuantities: [:],
      bonusAmount: 0,
      total: 5,
      shipping: nil,
      refTag: nil,
      context: .pledge,
      checkoutId: "0"
    )

    let paymentIntent = PaymentIntentEnvelope(clientSecret: "foo")
    let mockService = MockService(createPaymentIntentResult: .success(paymentIntent))

    withEnvironment(apiService: mockService) {
      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()
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
    }
  }

  func testApplePayAuthorization_reward_isCorrect() {
    let project = Project.cosmicSurgery
    let reward = project.rewards.first!

    XCTAssertEqual(reward.minimum, 6)

    let data = PostCampaignCheckoutData(
      project: project,
      baseReward: reward,
      rewards: [reward],
      selectedQuantities: [reward.id: 3],
      bonusAmount: 0,
      total: 18,
      shipping: nil,
      refTag: nil,
      context: .pledge,
      checkoutId: "0"
    )

    let paymentIntent = PaymentIntentEnvelope(clientSecret: "foo")
    let mockService = MockService(createPaymentIntentResult: .success(paymentIntent))

    withEnvironment(apiService: mockService) {
      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

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
    }
  }

  func testApplePayAuthorization_rewardAndShipping_isCorrect() {
    let project = Project.cosmicSurgery
    let reward = project.rewards.first!

    XCTAssertEqual(reward.minimum, 6)

    let data = PostCampaignCheckoutData(
      project: project,
      baseReward: reward,
      rewards: [reward],
      selectedQuantities: [reward.id: 3],
      bonusAmount: 0,
      total: 90,
      shipping: PledgeShippingSummaryViewData(
        locationName: "Somewhere",
        omitUSCurrencyCode: false,
        projectCountry: project.country,
        total: 72
      ),
      refTag: nil,
      context: .pledge,
      checkoutId: "0"
    )

    let paymentIntent = PaymentIntentEnvelope(clientSecret: "foo")
    let mockService = MockService(createPaymentIntentResult: .success(paymentIntent))

    withEnvironment(apiService: mockService) {
      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.vm.inputs.applePayButtonTapped()

      self.scheduler.run()

      self.goToApplePayPaymentAuthorization.assertValueCount(1)
      let output = self.goToApplePayPaymentAuthorization.lastValue!

      XCTAssertEqual(output.project, project)
      XCTAssertEqual(output.hasNoReward, false)
      XCTAssertEqual(output.subtotal, 18)
      XCTAssertEqual(output.bonus, 0)
      XCTAssertEqual(output.shipping, 72)
      XCTAssertEqual(output.total, 90)
    }
  }

  func testApplePayAuthorization_rewardAndShippingAndBonus_isCorrect() {
    let project = Project.cosmicSurgery
    let reward1 = project.rewards[0]
    let reward2 = project.rewards[1]

    XCTAssertEqual(reward1.minimum, 6)
    XCTAssertEqual(reward2.minimum, 25)

    let data = PostCampaignCheckoutData(
      project: project,
      baseReward: reward1,
      rewards: [reward1, reward2],
      selectedQuantities: [reward1.id: 1, reward2.id: 2],
      bonusAmount: 5,
      total: 133,
      shipping: PledgeShippingSummaryViewData(
        locationName: "Somewhere",
        omitUSCurrencyCode: false,
        projectCountry: project.country,
        total: 72
      ),
      refTag: nil,
      context: .pledge,
      checkoutId: "0"
    )

    let paymentIntent = PaymentIntentEnvelope(clientSecret: "foo")
    let mockService = MockService(createPaymentIntentResult: .success(paymentIntent))

    withEnvironment(apiService: mockService) {
      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.vm.inputs.applePayButtonTapped()

      self.scheduler.run()

      self.goToApplePayPaymentAuthorization.assertValueCount(1)
      let output = self.goToApplePayPaymentAuthorization.lastValue!

      XCTAssertEqual(output.project, project)
      XCTAssertEqual(output.hasNoReward, false)
      XCTAssertEqual(output.subtotal, 56)
      XCTAssertEqual(output.bonus, 5)
      XCTAssertEqual(output.shipping, 72)
      XCTAssertEqual(output.total, 133)
    }
  }

  func testTapApplePayButton_createsPaymentIntent_beforePresentingAuthorizationController() {
    let paymentIntent = PaymentIntentEnvelope(clientSecret: "foo")
    let mockService = MockService(createPaymentIntentResult: .success(paymentIntent))

    let project = Project.cosmicSurgery
    let reward = Reward.noReward |> Reward.lens.minimum .~ 5

    let data = PostCampaignCheckoutData(
      project: project,
      baseReward: reward,
      rewards: [reward],
      selectedQuantities: [:],
      bonusAmount: 0,
      total: 5,
      shipping: nil,
      refTag: nil,
      context: .pledge,
      checkoutId: "0"
    )

    withEnvironment(apiService: mockService) {
      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.applePayButtonTapped()
      self.scheduler.run()
      self.goToApplePayPaymentAuthorization.assertDidEmitValue()

      let output = self.goToApplePayPaymentAuthorization.lastValue!
      XCTAssertEqual(output.paymentIntent, "foo")
    }
  }

  func testApplePay_completesCheckoutFlow() {
    // Mock data for API requests
    let paymentIntent = PaymentIntentEnvelope(clientSecret: "foo")
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
      createPaymentIntentResult: .success(paymentIntent)
    )

    let project = Project.cosmicSurgery
    let reward = Reward.noReward |> Reward.lens.minimum .~ 5

    let data = PostCampaignCheckoutData(
      project: project,
      baseReward: reward,
      rewards: [reward],
      selectedQuantities: [:],
      bonusAmount: 0,
      total: 5,
      shipping: nil,
      refTag: nil,
      context: .pledge,
      checkoutId: "0"
    )

    withEnvironment(apiService: mockService) {
      self.vm.configure(with: data)
      self.vm.viewDidLoad()

      self.vm.inputs.applePayButtonTapped()

      self.scheduler.run()

      self.processingViewIsHidden.assertLastValue(false)
      self.goToApplePayPaymentAuthorization.assertDidEmitValue()

      let params = ApplePayParams(
        paymentInstrumentName: "Fake Instrument",
        paymentNetwork: "Fake Payment Network",
        transactionIdentifier: "Fake transaction identifier",
        token: "tok_abc123def"
      )
      self.vm.inputs.applePayContextDidCreatePayment(params: params)

      self.checkoutComplete.assertDidNotEmitValue()
      self.processingViewIsHidden.assertLastValue(false)

      self.vm.inputs.applePayContextDidComplete()

      self.checkoutComplete.assertDidEmitValue()
      self.processingViewIsHidden.assertLastValue(true)
    }
  }

  func testApplePay_paymentIntentFails() {
    // Mock data for API requests
    let mockService = MockService(
      createPaymentIntentResult: .failure(.couldNotParseErrorEnvelopeJSON)
    )

    let project = Project.cosmicSurgery
    let reward = Reward.noReward |> Reward.lens.minimum .~ 5

    let data = PostCampaignCheckoutData(
      project: project,
      baseReward: reward,
      rewards: [reward],
      selectedQuantities: [:],
      bonusAmount: 0,
      total: 5,
      shipping: nil,
      refTag: nil,
      context: .pledge,
      checkoutId: "0"
    )

    withEnvironment(apiService: mockService) {
      self.vm.configure(with: data)
      self.vm.viewDidLoad()

      self.vm.inputs.applePayButtonTapped()

      self.processingViewIsHidden.assertLastValue(false)

      self.scheduler.run()

      self.goToApplePayPaymentAuthorization.assertDidNotEmitValue()
      self.processingViewIsHidden.assertValues([false, true])
    }
  }

  func testPledge_completesCheckoutFlow() {
    // Mock data for API requests
    let validateCheckout = ValidateCheckoutEnvelope(valid: true, messages: ["message"])
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
    let mockService = MockService(
      completeOnSessionCheckoutResult: .success(completeSessionData),
      validateCheckoutResult: .success(validateCheckout)
    )

    let project = Project.cosmicSurgery
    let reward = Reward.noReward |> Reward.lens.minimum .~ 5

    let data = PostCampaignCheckoutData(
      project: project,
      baseReward: reward,
      rewards: [reward],
      selectedQuantities: [:],
      bonusAmount: 0,
      total: 5,
      shipping: nil,
      refTag: nil,
      context: .latePledge,
      checkoutId: "0"
    )

    withEnvironment(apiService: mockService) {
      self.vm.configure(with: data)
      self.vm.viewDidLoad()

      let paymentSource = PaymentSourceSelected.paymentIntentClientSecret("123")

      self.vm.inputs
        .creditCardSelected(source: paymentSource, paymentMethodId: "123", isNewPaymentMethod: true)

      self.configurePledgeViewCTAContainerViewIsLoggedIn.assertValues([false, false])
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
    let mockService = MockService(
      validateCheckoutResult: .failure(.couldNotParseErrorEnvelopeJSON)
    )

    let project = Project.cosmicSurgery
    let reward = Reward.noReward |> Reward.lens.minimum .~ 5

    let data = PostCampaignCheckoutData(
      project: project,
      baseReward: reward,
      rewards: [reward],
      selectedQuantities: [:],
      bonusAmount: 0,
      total: 5,
      shipping: nil,
      refTag: nil,
      context: .latePledge,
      checkoutId: "0"
    )

    withEnvironment(apiService: mockService) {
      self.vm.configure(with: data)
      self.vm.viewDidLoad()

      let paymentSource = PaymentSourceSelected.paymentIntentClientSecret("123")
      self.vm.inputs
        .creditCardSelected(source: paymentSource, paymentMethodId: "123", isNewPaymentMethod: true)

      self.configurePledgeViewCTAContainerViewIsLoggedIn.assertValues([false, false])
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
    let validateCheckout = ValidateCheckoutEnvelope(valid: true, messages: ["message"])
    let mockService = MockService(
      validateCheckoutResult: .success(validateCheckout)
    )

    let project = Project.cosmicSurgery
    let reward = Reward.noReward |> Reward.lens.minimum .~ 5

    let data = PostCampaignCheckoutData(
      project: project,
      baseReward: reward,
      rewards: [reward],
      selectedQuantities: [:],
      bonusAmount: 0,
      total: 5,
      shipping: nil,
      refTag: nil,
      context: .latePledge,
      checkoutId: "0"
    )

    withEnvironment(apiService: mockService) {
      self.vm.configure(with: data)
      self.vm.viewDidLoad()

      let paymentSource = PaymentSourceSelected.paymentIntentClientSecret("123")
      self.vm.inputs
        .creditCardSelected(source: paymentSource, paymentMethodId: "123", isNewPaymentMethod: true)

      self.configurePledgeViewCTAContainerViewIsLoggedIn.assertValues([false, false])
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

  func testPledgeViewCTAEnabled_afterSelectingNewPaymentMethod_LoggedIn() {
    let mockService = MockService(serverConfig: ServerConfig.staging)

    withEnvironment(apiService: mockService, currentUser: .template) {
      let project = Project.cosmicSurgery
      let reward = Reward.noReward |> Reward.lens.minimum .~ 5

      let data = PostCampaignCheckoutData(
        project: project,
        baseReward: reward,
        rewards: [reward],
        selectedQuantities: [:],
        bonusAmount: 0,
        total: 5,
        shipping: nil,
        refTag: nil,
        context: .latePledge,
        checkoutId: "0"
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      let paymentSource = PaymentSourceSelected.paymentIntentClientSecret("123")
      self.vm.inputs
        .creditCardSelected(source: paymentSource, paymentMethodId: "123", isNewPaymentMethod: true)

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

      let data = PostCampaignCheckoutData(
        project: project,
        baseReward: reward,
        rewards: [reward],
        selectedQuantities: [:],
        bonusAmount: 0,
        total: 5,
        shipping: nil,
        refTag: nil,
        context: .latePledge,
        checkoutId: "0"
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.configurePledgeViewCTAContainerViewIsLoggedIn.assertValues([true])
      self.configurePledgeViewCTAContainerViewIsEnabled.assertValues([false])
      self.configurePledgeViewCTAContainerViewContext.assertValues([.latePledge])
    }
  }

  func testTapSubmitButton_SignedInAfterPageLoads_canValidateExistingCard() {
    let paymentIntent = PaymentIntentEnvelope(clientSecret: "foo")
    let validateCheckout = ValidateCheckoutEnvelope(valid: true, messages: ["message"])
    let fetchedUser = GraphUser.template

    withEnvironment(currentUser: nil) {
      let project = Project.cosmicSurgery
      let reward = Reward.noReward |> Reward.lens.minimum .~ 5

      let data = PostCampaignCheckoutData(
        project: project,
        baseReward: reward,
        rewards: [reward],
        selectedQuantities: [:],
        bonusAmount: 0,
        total: 5,
        shipping: nil,
        refTag: nil,
        context: .latePledge,
        checkoutId: "0"
      )

      self.vm.inputs.configure(with: data)
      self.vm.inputs.viewDidLoad()

      self.configurePledgeViewCTAContainerViewIsLoggedIn.assertLastValue(false)

      withEnvironment(
        apiService: MockService(
          createPaymentIntentResult: .success(paymentIntent),
          fetchGraphUserResult: .success(UserEnvelope(me: fetchedUser)),
          validateCheckoutResult: .success(validateCheckout)
        ),
        currentUser: .template
      ) {
        self.vm.inputs.userSessionStarted()
        self.configurePledgeViewCTAContainerViewIsLoggedIn.assertLastValue(true)

        self.vm.inputs.creditCardSelected(
          source: .savedCreditCard(UserCreditCards.amex.id),
          paymentMethodId: UserCreditCards.amex.id,
          isNewPaymentMethod: false
        )

        self.scheduler.run()

        self.vm.inputs.submitButtonTapped()

        self.scheduler.run()

        self.validateCheckoutSuccess.assertDidEmitValue()
      }
    }
  }
}
