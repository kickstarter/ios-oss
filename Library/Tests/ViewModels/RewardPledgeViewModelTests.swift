import PassKit
import Prelude
import ReactiveCocoa
import ReactiveExtensions
import Result
import XCTest
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers

private let locations: [Location] = [
  .usa,
  .canada,
  .greatBritain,
  .australia
]

private let shippingRules = locations
  .enumerate()
  .map { idx, location in
    .template
      |> ShippingRule.lens.location .~ location
      |> ShippingRule.lens.cost .~ Double(idx + 1)
}

private let sortedShippingRules = shippingRules
  .sort { lhs, rhs in lhs.location.displayableName < rhs.location.displayableName }

internal final class RewardPledgeViewModelTests: TestCase {
  private let vm: RewardPledgeViewModelType = RewardPledgeViewModel()

  private let applePayButtonHidden = TestObserver<Bool, NoError>()
  private let continueToPaymentsButtonHidden = TestObserver<Bool, NoError>()
  private let conversionLabelHidden = TestObserver<Bool, NoError>()
  private let conversionLabelText = TestObserver<String, NoError>()
  private let countryLabelText = TestObserver<String, NoError>()
  private let descriptionLabelText = TestObserver<String, NoError>()
  private let differentPaymentMethodButtonHidden = TestObserver<Bool, NoError>()
  private let estimatedDeliveryDateLabelText = TestObserver<String, NoError>()
  private let expandRewardDescription = TestObserver<(), NoError>()
  private let fulfillmentAndShippingFooterStackViewHidden = TestObserver<Bool, NoError>()
  private let goToCheckoutRequest = TestObserver<String, NoError>() // todo
  private let goToCheckoutProject = TestObserver<Project, NoError>() // todo
  private let goToLoginTout = TestObserver<(), NoError>()
  private let goToPaymentAuthorization = TestObserver<NSDictionary, NoError>()
  private let goToShippingPickerProject = TestObserver<Project, NoError>()
  private let goToShippingPickerShippingRules = TestObserver<[ShippingRule], NoError>()
  private let goToShippingPickerSelectedShippingRule = TestObserver<ShippingRule, NoError>()
  private let goToThanks = TestObserver<Project, NoError>()
  private let items = TestObserver<[String], NoError>()
  private let itemsContainerHidden = TestObserver<Bool, NoError>()
  private let minimumLabelText = TestObserver<String, NoError>()
  private let navigationTitle = TestObserver<String, NoError>()
  private let payButtonsEnabled = TestObserver<Bool, NoError>()
  private let pledgeCurrencyLabelText = TestObserver<String, NoError>()
  private let pledgeTextFieldText = TestObserver<String, NoError>()
  private let readMoreContainerViewHidden = TestObserver<Bool, NoError>()
  private let setStripeAppleMerchantIdentifier = TestObserver<String, NoError>()
  private let setStripePublishableKey = TestObserver<String, NoError>()
  private let shippingAmountLabelText = TestObserver<String, NoError>()
  private let shippingInputStackViewHidden = TestObserver<Bool, NoError>()
  private let shippingLocationsLabelText = TestObserver<String, NoError>()
  private let showAlert = TestObserver<String, NoError>() // todo
  private let titleLabelHidden = TestObserver<Bool, NoError>()
  private let titleLabelText = TestObserver<String, NoError>()

  // todo koala tracking testing

  override func setUp() {
    super.setUp()

    self.vm.outputs.applePayButtonHidden.observe(self.applePayButtonHidden.observer)
    self.vm.outputs.continueToPaymentsButtonHidden.observe(self.continueToPaymentsButtonHidden.observer)
    self.vm.outputs.conversionLabelHidden.observe(self.conversionLabelHidden.observer)
    self.vm.outputs.conversionLabelText.observe(self.conversionLabelText.observer)
    self.vm.outputs.countryLabelText.observe(self.countryLabelText.observer)
    self.vm.outputs.descriptionLabelText.observe(self.descriptionLabelText.observer)
    self.vm.outputs.differentPaymentMethodButtonHidden
      .observe(self.differentPaymentMethodButtonHidden.observer)
    self.vm.outputs.estimatedDeliveryDateLabelText.observe(self.estimatedDeliveryDateLabelText.observer)
    self.vm.outputs.expandRewardDescription.observe(self.expandRewardDescription.observer)
    self.vm.outputs.fulfillmentAndShippingFooterStackViewHidden
      .observe(self.fulfillmentAndShippingFooterStackViewHidden.observer)
    self.vm.outputs.goToCheckout.map(first).map { optionalize(optionalize($0.URL)?.absoluteString) }
      .ignoreNil()
      .observe(self.goToCheckoutRequest.observer)
    self.vm.outputs.goToCheckout.map(second).observe(self.goToCheckoutProject.observer)
    self.vm.outputs.goToLoginTout.observe(self.goToLoginTout.observer)
    self.vm.outputs.goToPaymentAuthorization.map { $0.encode() as NSDictionary }
      .observe(self.goToPaymentAuthorization.observer)
    self.vm.outputs.goToShippingPicker.map(first).observe(self.goToShippingPickerProject.observer)
    self.vm.outputs.goToShippingPicker.map(second).observe(self.goToShippingPickerShippingRules.observer)
    self.vm.outputs.goToShippingPicker.map { $2 }
      .observe(self.goToShippingPickerSelectedShippingRule.observer)
    self.vm.outputs.goToThanks.observe(self.goToThanks.observer)
    self.vm.outputs.items.observe(self.items.observer)
    self.vm.outputs.itemsContainerHidden.observe(self.itemsContainerHidden.observer)
    self.vm.outputs.minimumLabelText.observe(self.minimumLabelText.observer)
    self.vm.outputs.navigationTitle.observe(self.navigationTitle.observer)
    self.vm.outputs.payButtonsEnabled.observe(self.payButtonsEnabled.observer)
    self.vm.outputs.pledgeCurrencyLabelText.observe(self.pledgeCurrencyLabelText.observer)
    self.vm.outputs.pledgeTextFieldText.observe(self.pledgeTextFieldText.observer)
    self.vm.outputs.readMoreContainerViewHidden.observe(self.readMoreContainerViewHidden.observer)
    self.vm.outputs.setStripeAppleMerchantIdentifier.observe(self.setStripeAppleMerchantIdentifier.observer)
    self.vm.outputs.setStripePublishableKey.observe(self.setStripePublishableKey.observer)
    self.vm.outputs.shippingAmountLabelText.observe(self.shippingAmountLabelText.observer)
    self.vm.outputs.shippingInputStackViewHidden.observe(self.shippingInputStackViewHidden.observer)
    self.vm.outputs.shippingLocationsLabelText.observe(self.shippingLocationsLabelText.observer)
    self.vm.outputs.showAlert.observe(self.showAlert.observer)
    self.vm.outputs.titleLabelHidden.observe(self.titleLabelHidden.observer)
    self.vm.outputs.titleLabelText.observe(self.titleLabelText.observer)

    AppEnvironment.pushEnvironment(currentUser: .template)
  }

  override func tearDown() {
    AppEnvironment.popEnvironment()
    super.tearDown()
  }

  func testApplePayButtonHidden_ApplePayCapable() {
    self.vm.inputs.configureWith(project: .template, reward: .template, applePayCapable: true)
    self.vm.inputs.viewDidLoad()

    self.applePayButtonHidden.assertValues([false])
  }

  func testApplePayButtonHidden_NotApplePayCapable() {
    self.vm.inputs.configureWith(project: .template, reward: .template, applePayCapable: false)
    self.vm.inputs.viewDidLoad()

    self.applePayButtonHidden.assertValues([true])
  }

  func testContinueToPaymentsButtonHidden_ApplePayCapable() {
    self.vm.inputs.configureWith(project: .template, reward: .template, applePayCapable: true)
    self.vm.inputs.viewDidLoad()

    self.continueToPaymentsButtonHidden.assertValues([true])
  }

  func testContinueToPaymentsButtonHidden_NotApplePayCapable() {
    self.vm.inputs.configureWith(project: .template, reward: .template, applePayCapable: false)
    self.vm.inputs.viewDidLoad()

    self.continueToPaymentsButtonHidden.assertValues([false])
  }

  func testConversionLabel_NotShown() {
    let project = .template
      |> Project.lens.country .~ .US

    withEnvironment(config: .template |> Config.lens.countryCode .~ "US") {
      self.vm.inputs.configureWith(project: project, reward: .template, applePayCapable: false)
      self.vm.inputs.viewDidLoad()

      self.conversionLabelHidden.assertValues([true])
      self.conversionLabelText.assertValueCount(0)
    }
  }

  func testConversionLabel_Shown() {
    let project = .template
      |> Project.lens.country .~ .GB
      |> Project.lens.stats.staticUsdRate .~ 2
    let reward = .template
      |> Reward.lens.minimum .~ 1_000

    withEnvironment(config: .template |> Config.lens.countryCode .~ "US") {
      self.vm.inputs.configureWith(project: project, reward: reward, applePayCapable: false)
      self.vm.inputs.viewDidLoad()

      self.conversionLabelHidden.assertValues([false], "US user viewing non-US project sees conversion.")
      self.conversionLabelText.assertValues([
        Strings.rewards_title_about_amount_usd(reward_amount: Format.currency(2_000, country: .US))
        ])
    }
  }

  func testCountryAndShippingAmountLabelText_WithRecognizedCountry() {
    withEnvironment(
      apiService: MockService(fetchShippingRulesResponse: shippingRules),
      config: .template |> Config.lens.countryCode .~ "AU") {

        self.vm.inputs.configureWith(project: .template, reward: .template, applePayCapable: false)
        self.vm.inputs.viewDidLoad()

        self.countryLabelText.assertValues([""])
        self.shippingAmountLabelText.assertValues([""])

        self.scheduler.advance()

        self.countryLabelText.assertValues(["", "Australia"])
        self.shippingAmountLabelText.assertValues(["", "+$4"])
    }
  }

  func testCountryAndShippingAmountLabelText_WithUnrecognizedCountry() {
    withEnvironment(
      apiService: MockService(fetchShippingRulesResponse: shippingRules),
      config: .template |> Config.lens.countryCode .~ "XYZ") {

        self.vm.inputs.configureWith(project: .template, reward: .template, applePayCapable: false)
        self.vm.inputs.viewDidLoad()

        self.countryLabelText.assertValues([""])
        self.shippingAmountLabelText.assertValues([""])

        self.scheduler.advance()

        self.countryLabelText.assertValues(["", "United States"])
        self.shippingAmountLabelText.assertValues(["", "+$1"])
    }
  }

  func testCountryAndShippingAmount_PickerFlow() {
    let project = Project.template
    let reward = Reward.template
    let defaultShippingRule = shippingRules.last!
    let otherShippingRule = shippingRules.first!

    withEnvironment(
      apiService: MockService(fetchShippingRulesResponse: shippingRules),
      config: .template |> Config.lens.countryCode .~ defaultShippingRule.location.country) {

        self.vm.inputs.configureWith(project: project, reward: reward, applePayCapable: false)
        self.vm.inputs.viewDidLoad()

        self.countryLabelText.assertValues([""])
        self.shippingAmountLabelText.assertValues([""])

        self.scheduler.advance()

        self.countryLabelText.assertValues(["", defaultShippingRule.location.displayableName])
        self.shippingAmountLabelText.assertValues([
          "", "+" + Format.currency(Int(defaultShippingRule.cost), country: project.country)
          ])

        self.vm.inputs.shippingButtonTapped()
        self.vm.inputs.change(shippingRule: otherShippingRule)

        self.countryLabelText.assertValues([
          "", defaultShippingRule.location.displayableName, otherShippingRule.location.displayableName
          ])
        self.shippingAmountLabelText.assertValues([
          "",
          "+" + Format.currency(Int(defaultShippingRule.cost), country: project.country),
          "+" + Format.currency(Int(otherShippingRule.cost), country: project.country)
          ])
    }
  }

  func testDescriptionLabelText() {
    let reward = Reward.template
    self.vm.inputs.configureWith(project: .template, reward: reward, applePayCapable: false)
    self.vm.inputs.viewDidLoad()

    self.descriptionLabelText.assertValues([reward.description])
  }

  func testDifferentPaymentMethodButtonHidden_ApplePayCapable() {
    self.vm.inputs.configureWith(project: .template, reward: .template, applePayCapable: true)
    self.vm.inputs.viewDidLoad()

    self.differentPaymentMethodButtonHidden.assertValues([false])
  }

  func testDifferentPaymentMethodButtonHidden_NotApplePayCapable() {
    self.vm.inputs.configureWith(project: .template, reward: .template, applePayCapable: false)
    self.vm.inputs.viewDidLoad()

    self.differentPaymentMethodButtonHidden.assertValues([true])
  }

  func testEstimatedDeliveryDateLabelText() {
    let reward = .template |> Reward.lens.estimatedDeliveryOn .~ NSDate().timeIntervalSince1970
    self.vm.inputs.configureWith(project: .template, reward: reward, applePayCapable: false)
    self.vm.inputs.viewDidLoad()

    self.estimatedDeliveryDateLabelText.assertValues([
      Format.date(secondsInUTC: reward.estimatedDeliveryOn!, dateFormat: "MMM yyyy")
    ])
  }

  func testExpandRewardDescription() {
    self.vm.inputs.configureWith(project: .template, reward: .template, applePayCapable: false)
    self.vm.inputs.viewDidLoad()

    self.expandRewardDescription.assertValueCount(0)

    self.vm.inputs.descriptionLabelTapped()

    self.expandRewardDescription.assertValueCount(1)
  }

  func testFulfillmentAndShippingFooterStackViewHidden_ShippingEnabled() {
    let reward = .template |> Reward.lens.shipping.enabled .~ true
    self.vm.inputs.configureWith(project: .template, reward: reward, applePayCapable: false)
    self.vm.inputs.viewDidLoad()

    self.fulfillmentAndShippingFooterStackViewHidden.assertValues([false])
  }

  func testFulfillmentAndShippingFooterStackViewHidden_ShippingDisabled() {
    let reward = .template |> Reward.lens.shipping.enabled .~ false
    self.vm.inputs.configureWith(project: .template, reward: reward, applePayCapable: false)
    self.vm.inputs.viewDidLoad()

    self.fulfillmentAndShippingFooterStackViewHidden.assertValues([true])
  }

  func testGoToPaymentAuthorization_NoShipping_NoRewardTitle() {
    let project = Project.template
    let reward = Reward.template

    withEnvironment(apiService: MockService(fetchShippingRulesResponse: [])) {
      self.vm.inputs.configureWith(project: project, reward: reward, applePayCapable: true)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.applePayButtonHidden.assertValues([false])
      self.goToPaymentAuthorization.assertValues([])

      self.vm.inputs.applePayButtonTapped()

      let paymentRequest: NSDictionary =  [
        "countryCode": project.country.countryCode,
        "currencyCode": project.country.currencyCode,
        "merchantCapabilities": [PKMerchantCapability.Capability3DS.rawValue],
        "merchantIdentifier": PKPaymentAuthorizationViewController.merchantIdentifier,
        "supportedNetworks": PKPaymentAuthorizationViewController.supportedNetworks,
        "shippingType": PKShippingType.Shipping.rawValue,
        "paymentSummaryItems": [
          [
            "label": project.name,
            "amount": NSDecimalNumber(long: reward.minimum),
            "type": PKPaymentSummaryItemType.Final.rawValue
          ],
          [
            "label": "Kickstarter (if funded)",
            "amount": NSDecimalNumber(long: reward.minimum),
            "type": PKPaymentSummaryItemType.Final.rawValue
          ]
        ]
      ]

      self.goToPaymentAuthorization.assertValues([paymentRequest])
      self.goToCheckoutRequest.assertValueCount(0)
      self.goToCheckoutProject.assertValues([])
    }
  }

  func testGoToPaymentAuthorization_NoShipping_WithRewardTitle() {
    let project = Project.template
    let reward = Reward.template |> Reward.lens.title .~ "The thing!"

    withEnvironment(apiService: MockService(fetchShippingRulesResponse: [])) {
      self.vm.inputs.configureWith(project: project, reward: reward, applePayCapable: true)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.applePayButtonHidden.assertValues([false])
      self.goToPaymentAuthorization.assertValues([])

      self.vm.inputs.applePayButtonTapped()

      let paymentRequest: NSDictionary =  [
        "countryCode": project.country.countryCode,
        "currencyCode": project.country.currencyCode,
        "merchantCapabilities": [PKMerchantCapability.Capability3DS.rawValue],
        "merchantIdentifier": PKPaymentAuthorizationViewController.merchantIdentifier,
        "supportedNetworks": PKPaymentAuthorizationViewController.supportedNetworks,
        "shippingType": PKShippingType.Shipping.rawValue,
        "paymentSummaryItems": [
          [
            "label": reward.title!,
            "amount": NSDecimalNumber(long: reward.minimum),
            "type": PKPaymentSummaryItemType.Final.rawValue
          ],
          [
            "label": "Kickstarter (if funded)",
            "amount": NSDecimalNumber(long: reward.minimum),
            "type": PKPaymentSummaryItemType.Final.rawValue
          ]
        ]
      ]

      self.goToPaymentAuthorization.assertValues([paymentRequest])
      self.goToCheckoutRequest.assertValueCount(0)
      self.goToCheckoutProject.assertValues([])
    }
  }

  func testGoToPaymentAuthorization_ZeroCostShipping() {
    let project = Project.template
    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true
    let shippingRule = .template |> ShippingRule.lens.cost .~ 0

    withEnvironment(apiService: MockService(fetchShippingRulesResponse: [shippingRule])) {
      self.vm.inputs.configureWith(project: project, reward: reward, applePayCapable: true)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.applePayButtonHidden.assertValues([false])
      self.goToPaymentAuthorization.assertValues([])

      self.vm.inputs.applePayButtonTapped()

      let paymentRequest: NSDictionary =  [
        "countryCode": project.country.countryCode,
        "currencyCode": project.country.currencyCode,
        "merchantCapabilities": [PKMerchantCapability.Capability3DS.rawValue],
        "merchantIdentifier": PKPaymentAuthorizationViewController.merchantIdentifier,
        "supportedNetworks": PKPaymentAuthorizationViewController.supportedNetworks,
        "shippingType": PKShippingType.Shipping.rawValue,
        "paymentSummaryItems": [
          [
            "label": project.name,
            "amount": NSDecimalNumber(long: reward.minimum),
            "type": PKPaymentSummaryItemType.Final.rawValue
          ],
          [
            "label": "Kickstarter (if funded)",
            "amount": NSDecimalNumber(long: reward.minimum),
            "type": PKPaymentSummaryItemType.Final.rawValue
          ]
        ]
      ]

      self.goToPaymentAuthorization.assertValues([paymentRequest])
      self.goToCheckoutRequest.assertValueCount(0)
      self.goToCheckoutProject.assertValues([])
    }
  }

  func testGoToPaymentAuthorization_WithShipping() {
    let project = Project.template
    let reward = .template
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.minimum .~ 42
    let defaultShippingRule = shippingRules.last!

    withEnvironment(
      apiService: MockService(fetchShippingRulesResponse: shippingRules),
      config: .template |> Config.lens.countryCode .~ defaultShippingRule.location.country) {

        self.vm.inputs.configureWith(project: project, reward: reward, applePayCapable: true)
        self.vm.inputs.viewDidLoad()
        self.scheduler.advance()

        self.applePayButtonHidden.assertValues([false])
        self.goToPaymentAuthorization.assertValues([])

        self.vm.inputs.applePayButtonTapped()

        let paymentRequest: NSDictionary =  [
          "countryCode": project.country.countryCode,
          "currencyCode": project.country.currencyCode,
          "merchantCapabilities": [PKMerchantCapability.Capability3DS.rawValue],
          "merchantIdentifier": PKPaymentAuthorizationViewController.merchantIdentifier,
          "supportedNetworks": PKPaymentAuthorizationViewController.supportedNetworks,
          "shippingType": PKShippingType.Shipping.rawValue,
          "paymentSummaryItems": [
            [
              "label": project.name,
              "amount": NSDecimalNumber(long: reward.minimum),
              "type": PKPaymentSummaryItemType.Final.rawValue
            ],
            [
              "label": "Shipping",
              "amount": NSDecimalNumber(double: defaultShippingRule.cost),
              "type": PKPaymentSummaryItemType.Final.rawValue
            ],
            [
              "label": "Kickstarter (if funded)",
              "amount": NSDecimalNumber(long: Int(defaultShippingRule.cost) + reward.minimum),
              "type": PKPaymentSummaryItemType.Final.rawValue
            ]
          ]
        ]

        self.goToPaymentAuthorization.assertValues([paymentRequest])
        self.goToCheckoutRequest.assertValueCount(0)
        self.goToCheckoutProject.assertValues([])
    }
  }

  func testGoToPaymentAuthorization_ChangingMinimumPledge() {
    let project = Project.template
    let reward = .template
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.minimum .~ 42
    let defaultShippingRule = shippingRules.last!

    withEnvironment(
      apiService: MockService(fetchShippingRulesResponse: shippingRules),
      config: .template |> Config.lens.countryCode .~ defaultShippingRule.location.country) {

        self.vm.inputs.configureWith(project: project, reward: reward, applePayCapable: true)
        self.vm.inputs.viewDidLoad()
        self.scheduler.advance()

        self.applePayButtonHidden.assertValues([false])
        self.goToPaymentAuthorization.assertValues([])

        self.vm.inputs.pledgeTextFieldChanged("50")
        self.vm.inputs.applePayButtonTapped()

        let paymentRequest: NSDictionary =  [
          "countryCode": project.country.countryCode,
          "currencyCode": project.country.currencyCode,
          "merchantCapabilities": [PKMerchantCapability.Capability3DS.rawValue],
          "merchantIdentifier": PKPaymentAuthorizationViewController.merchantIdentifier,
          "supportedNetworks": PKPaymentAuthorizationViewController.supportedNetworks,
          "shippingType": PKShippingType.Shipping.rawValue,
          "paymentSummaryItems": [
            [
              "label": project.name,
              "amount": NSDecimalNumber(long: 50),
              "type": PKPaymentSummaryItemType.Final.rawValue
            ],
            [
              "label": "Shipping",
              "amount": NSDecimalNumber(double: defaultShippingRule.cost),
              "type": PKPaymentSummaryItemType.Final.rawValue
            ],
            [
              "label": "Kickstarter (if funded)",
              "amount": NSDecimalNumber(long: Int(defaultShippingRule.cost) + 50),
              "type": PKPaymentSummaryItemType.Final.rawValue
            ]
          ]
        ]

        self.goToPaymentAuthorization.assertValues([paymentRequest])
        self.goToCheckoutRequest.assertValueCount(0)
        self.goToCheckoutProject.assertValues([])
    }
  }

  func testGoToPaymentAuthorization_ChangingShipping() {
    let project = Project.template
    let reward = .template
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.minimum .~ 42
    let defaultShippingRule = shippingRules.last!
    let changedShippingRule = shippingRules.first!

    withEnvironment(
      apiService: MockService(fetchShippingRulesResponse: shippingRules),
      config: .template |> Config.lens.countryCode .~ defaultShippingRule.location.country) {

        self.vm.inputs.configureWith(project: project, reward: reward, applePayCapable: true)
        self.vm.inputs.viewDidLoad()
        self.scheduler.advance()

        self.applePayButtonHidden.assertValues([false])
        self.goToPaymentAuthorization.assertValues([])

        self.vm.inputs.shippingButtonTapped()
        self.vm.inputs.change(shippingRule: changedShippingRule)
        self.vm.inputs.applePayButtonTapped()

        let paymentRequest: NSDictionary =  [
          "countryCode": project.country.countryCode,
          "currencyCode": project.country.currencyCode,
          "merchantCapabilities": [PKMerchantCapability.Capability3DS.rawValue],
          "merchantIdentifier": PKPaymentAuthorizationViewController.merchantIdentifier,
          "supportedNetworks": PKPaymentAuthorizationViewController.supportedNetworks,
          "shippingType": PKShippingType.Shipping.rawValue,
          "paymentSummaryItems": [
            [
              "label": project.name,
              "amount": NSDecimalNumber(long: reward.minimum),
              "type": PKPaymentSummaryItemType.Final.rawValue
            ],
            [
              "label": "Shipping",
              "amount": NSDecimalNumber(double: changedShippingRule.cost),
              "type": PKPaymentSummaryItemType.Final.rawValue
            ],
            [
              "label": "Kickstarter (if funded)",
              "amount": NSDecimalNumber(long: Int(changedShippingRule.cost) + reward.minimum),
              "type": PKPaymentSummaryItemType.Final.rawValue
            ]
          ]
        ]

        self.goToPaymentAuthorization.assertValues([paymentRequest])
        self.goToCheckoutRequest.assertValueCount(0)
        self.goToCheckoutProject.assertValues([])
    }
  }

  func testApplePay_SuccessfulFlow() {
    let project = Project.template
    self.vm.inputs.configureWith(project: project, reward: .template, applePayCapable: true)
    self.vm.inputs.viewDidLoad()
    self.scheduler.advance()

    self.applePayButtonHidden.assertValues([false])

    self.vm.inputs.applePayButtonTapped()
    self.vm.inputs.paymentAuthorizationWillAuthorizePayment()

    self.vm.inputs.paymentAuthorization(
      didAuthorizePayment: .init(
        tokenData: .init(
          paymentMethodData: .init(displayName: "AmEx", network: "AmEx", type: .Credit),
          transactionIdentifier: "apple_pay_deadbeef"
        )
      )
    )
    self.vm.inputs.paymentAuthorizationDidFinish()
    let status = self.vm.inputs.stripeCreatedToken(stripeToken: "stripe_deadbeef", error: nil)

    XCTAssertEqual(PKPaymentAuthorizationStatus.Success.rawValue, status.rawValue)

    self.goToThanks.assertValues([project])
  }

  func testApplePay_LoggedOutFlow() {
    withEnvironment(currentUser: nil) {
      let project = Project.template
      self.vm.inputs.configureWith(project: project, reward: .template, applePayCapable: true)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.applePayButtonHidden.assertValues([false])

      self.vm.inputs.applePayButtonTapped()

      self.goToPaymentAuthorization.assertValueCount(0)
      self.goToLoginTout.assertValueCount(1)

      withEnvironment(currentUser: .template) {
        self.vm.inputs.userSessionStarted()

        self.goToPaymentAuthorization.assertValueCount(1)
        self.goToLoginTout.assertValueCount(1)

        self.vm.inputs.paymentAuthorizationWillAuthorizePayment()
        self.vm.inputs.paymentAuthorization(
          didAuthorizePayment: .init(
            tokenData: .init(
              paymentMethodData: .init(displayName: "AmEx", network: "AmEx", type: .Credit),
              transactionIdentifier: "apple_pay_deadbeef"
            )
          )
        )
        self.vm.inputs.paymentAuthorizationDidFinish()
        let status = self.vm.inputs.stripeCreatedToken(stripeToken: "stripe_deadbeef", error: nil)

        XCTAssertEqual(PKPaymentAuthorizationStatus.Success.rawValue, status.rawValue)

        self.goToThanks.assertValues([project])
      }
    }
  }

  func testGoToCheckout_ContinueToPaymentMethod() {
    let project = Project.template

    self.vm.inputs.configureWith(project: project, reward: .template, applePayCapable: false)
    self.vm.inputs.viewDidLoad()
    self.scheduler.advance()

    self.continueToPaymentsButtonHidden.assertValues([false])
    self.differentPaymentMethodButtonHidden.assertValues([true])

    self.vm.inputs.continueToPaymentsButtonTapped()

    self.goToCheckoutProject.assertValues([project])
    self.goToCheckoutRequest.assertValueCount(1)
  }

  func testGoToCheckout_LoggedOut_ContinueToPaymentMethod() {
    let project = Project.template

    withEnvironment(currentUser: nil) {
      self.vm.inputs.configureWith(project: project, reward: .template, applePayCapable: false)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.continueToPaymentsButtonHidden.assertValues([false])
      self.differentPaymentMethodButtonHidden.assertValues([true])

      self.vm.inputs.continueToPaymentsButtonTapped()

      self.goToCheckoutProject.assertValues([])
      self.goToCheckoutRequest.assertValueCount(0)
      self.goToLoginTout.assertValueCount(1)

      withEnvironment(currentUser: .template) {
        self.vm.inputs.userSessionStarted()

        self.goToCheckoutProject.assertValues([project])
        self.goToCheckoutRequest.assertValueCount(1)
      }
    }
  }

  func testGoToCheckout_DifferentPaymentMethod() {
    let project = Project.template

    self.vm.inputs.configureWith(project: project, reward: .template, applePayCapable: true)
    self.vm.inputs.viewDidLoad()
    self.scheduler.advance()

    self.continueToPaymentsButtonHidden.assertValues([true])
    self.differentPaymentMethodButtonHidden.assertValues([false])

    self.vm.inputs.differentPaymentMethodButtonTapped()

    self.goToCheckoutProject.assertValues([project])
    self.goToCheckoutRequest.assertValueCount(1)
  }

  func testGoToCheckout_LoggedOut_DifferentPaymentMethod() {
    let project = Project.template

    withEnvironment(currentUser: nil) {
      self.vm.inputs.configureWith(project: project, reward: .template, applePayCapable: true)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.continueToPaymentsButtonHidden.assertValues([true])
      self.differentPaymentMethodButtonHidden.assertValues([false])

      self.vm.inputs.differentPaymentMethodButtonTapped()

      self.goToCheckoutProject.assertValues([])
      self.goToCheckoutRequest.assertValueCount(0)
      self.goToLoginTout.assertValueCount(1)

      withEnvironment(currentUser: .template) {
        self.vm.inputs.userSessionStarted()

        self.goToCheckoutProject.assertValues([project])
        self.goToCheckoutRequest.assertValueCount(1)
      }
    }
  }

  func testGoToShippingPickerFlow() {
    let project = Project.template
    let reward = .template |> Reward.lens.shipping.enabled .~ true
    let defaultShippingRule = shippingRules.last!
    let otherShippingRule = shippingRules.first!

    withEnvironment(
      apiService: MockService(fetchShippingRulesResponse: shippingRules),
      config: .template |> Config.lens.countryCode .~ defaultShippingRule.location.country) {

        self.vm.inputs.configureWith(project: project, reward: reward, applePayCapable: false)
        self.vm.inputs.viewDidLoad()
        self.scheduler.advance()
        self.vm.inputs.shippingButtonTapped()

        self.goToShippingPickerProject.assertValues([project])
        self.goToShippingPickerShippingRules.assertValues([shippingRules])
        self.goToShippingPickerSelectedShippingRule.assertValues([defaultShippingRule])

        self.vm.inputs.change(shippingRule: otherShippingRule)

        self.vm.inputs.shippingButtonTapped()

        self.goToShippingPickerProject.assertValues([project, project])
        self.goToShippingPickerShippingRules.assertValues([shippingRules, shippingRules])
        self.goToShippingPickerSelectedShippingRule.assertValues([defaultShippingRule, otherShippingRule])
    }
  }

  func testItems() {
    let reward = .template
      |> Reward.lens.rewardsItems .~ [
        .template
          |> RewardsItem.lens.item .~ (
            .template
              |> Item.lens.name .~ "The thing"
        ),
        .template
          |> RewardsItem.lens.quantity .~ 1_000
          |> RewardsItem.lens.item .~ (
            .template
              |> Item.lens.name .~ "The other thing"
        ),
    ]

    self.vm.inputs.configureWith(project: .template, reward: reward, applePayCapable: false)
    self.vm.inputs.viewDidLoad()

    self.items.assertValues([["The thing", "(1,000) The other thing"]])
  }

  func testItemsContainerHidden() {
    self.vm.inputs.configureWith(project: .template, reward: .template, applePayCapable: false)
    self.vm.inputs.viewDidLoad()

    self.itemsContainerHidden.assertValues([true])

    self.vm.inputs.descriptionLabelTapped()

    self.itemsContainerHidden.assertValues([true, false])
  }

  func testMinimumLabelText() {
    let reward = Reward.template
    let project = Project.template
    self.vm.inputs.configureWith(project: project, reward: reward, applePayCapable: false)
    self.vm.inputs.viewDidLoad()

    self.minimumLabelText.assertValues([
      Format.currency(reward.minimum, country: project.country)
      ])
  }

  func testNavigationTitle_NonBacker_NoReward() {
    let reward = Reward.noReward
    let project = Project.template
    self.vm.inputs.configureWith(project: project, reward: reward, applePayCapable: false)
    self.vm.inputs.viewDidLoad()

    self.navigationTitle.assertValues(["Make a pledge without a reward"])
  }

  func testNavigationTitle_NonBacker_Reward() {
    let reward = .template |> Reward.lens.minimum .~ 50
    let project = Project.template
    self.vm.inputs.configureWith(project: project, reward: reward, applePayCapable: false)
    self.vm.inputs.viewDidLoad()

    self.navigationTitle.assertValues([
      Strings.rewards_title_pledge_reward_currency_or_more(
        reward_currency: Format.currency(50, country: project.country)
      )
      ])
  }

  func testNavigationTitle_Backer_ManageSameReward() {
    let reward = .template |> Reward.lens.minimum .~ 50
    let project = .template
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.reward .~ reward
    )
    self.vm.inputs.configureWith(project: project, reward: reward, applePayCapable: false)
    self.vm.inputs.viewDidLoad()

    self.navigationTitle.assertValues(["Manage your reward"])
  }

  func testNavigationTitle_Backer_ManageDifferentReward() {
    let reward = .template |> Reward.lens.minimum .~ 50
    let project = .template
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.reward .~ (reward |> Reward.lens.id %~ { $0 + 1 })
    )
    self.vm.inputs.configureWith(project: project, reward: reward, applePayCapable: false)
    self.vm.inputs.viewDidLoad()

    self.navigationTitle.assertValues(["Manage your reward"])
  }

  func testNavigationTitle_BackerWithNoReward_ManageDifferentReward() {
    let reward = .template |> Reward.lens.minimum .~ 50
    let project = .template
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.reward .~ Reward.noReward
    )
    self.vm.inputs.configureWith(project: project, reward: reward, applePayCapable: false)
    self.vm.inputs.viewDidLoad()

    self.navigationTitle.assertValues(["Manage your reward"])
  }

  func testNavigationTitle_BackerWithNoReward_ManageNoReward() {
    let reward = Reward.noReward
    let project = .template
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.reward .~ Reward.noReward
    )
    self.vm.inputs.configureWith(project: project, reward: reward, applePayCapable: false)
    self.vm.inputs.viewDidLoad()

    self.navigationTitle.assertValues(["Manage your pledge"])
  }

  func testNavigationTitle_BackerWithReward_ManageNoReward() {
    let reward = Reward.noReward
    let project = .template
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.reward .~ .template
    )
    self.vm.inputs.configureWith(project: project, reward: reward, applePayCapable: false)
    self.vm.inputs.viewDidLoad()

    self.navigationTitle.assertValues(["Manage your pledge"])
  }

  func testPayButtonsEnabled_WithReward() {
    let reward = .template |> Reward.lens.minimum .~ 42
    let project = Project.template
    self.vm.inputs.configureWith(project: project, reward: reward, applePayCapable: false)
    self.vm.inputs.viewDidLoad()

    self.payButtonsEnabled.assertValues([true])

    self.vm.inputs.pledgeTextFieldChanged(String(reward.minimum + 10))

    self.payButtonsEnabled.assertValues([true])

    self.vm.inputs.pledgeTextFieldChanged(String(reward.minimum - 1))

    self.payButtonsEnabled.assertValues([true, false])

    self.vm.inputs.pledgeTextFieldChanged(String(project.country.maxPledge! + 1))

    self.payButtonsEnabled.assertValues([true, false])

    self.vm.inputs.pledgeTextFieldDidEndEditing()

    self.payButtonsEnabled.assertValues([true, false, true])
  }

  func testPayButtonsEnabled_NoReward() {
    let reward = Reward.noReward
    let project = .template |> Project.lens.country .~ .DK
    self.vm.inputs.configureWith(project: project, reward: reward, applePayCapable: false)
    self.vm.inputs.viewDidLoad()

    self.payButtonsEnabled.assertValues([true])

    self.vm.inputs.pledgeTextFieldChanged(String(reward.minimum + 10))

    self.payButtonsEnabled.assertValues([true])

    self.vm.inputs.pledgeTextFieldChanged(String(reward.minimum - 1))

    self.payButtonsEnabled.assertValues([true, false])

    self.vm.inputs.pledgeTextFieldChanged(String(project.country.maxPledge! + 1))

    self.payButtonsEnabled.assertValues([true, false])

    self.vm.inputs.pledgeTextFieldDidEndEditing()

    self.payButtonsEnabled.assertValues([true, false, true])
  }

  func testPledgeCurrencyLabelText_USProject_USBacker() {
    withEnvironment(config: .template |> Config.lens.countryCode .~ "US") {
      let project = .template |> Project.lens.country .~ .US
      self.vm.inputs.configureWith(project: project, reward: .template, applePayCapable: false)
      self.vm.inputs.viewDidLoad()

      self.pledgeCurrencyLabelText.assertValues([Project.Country.US.currencySymbol])
    }
  }

  func testPledgeCurrencyLabelText_GBProject_USBacker() {
    withEnvironment(config: .template |> Config.lens.countryCode .~ "US") {
      let project = .template |> Project.lens.country .~ .GB
      self.vm.inputs.configureWith(project: project, reward: .template, applePayCapable: false)
      self.vm.inputs.viewDidLoad()

      self.pledgeCurrencyLabelText.assertValues([Project.Country.GB.currencySymbol])
    }
  }

  func testPledgeCurrencyLabelText_FRProject_USBacker() {
    withEnvironment(config: .template |> Config.lens.countryCode .~ "US") {
      let project = .template |> Project.lens.country .~ .FR
      self.vm.inputs.configureWith(project: project, reward: .template, applePayCapable: false)
      self.vm.inputs.viewDidLoad()

      self.pledgeCurrencyLabelText.assertValues([Project.Country.FR.currencySymbol])
    }
  }

  func testPledgeCurrencyLabelText_CAProject_USBacker() {
    withEnvironment(config: .template |> Config.lens.countryCode .~ "US") {
      let project = .template |> Project.lens.country .~ .CA
      self.vm.inputs.configureWith(project: project, reward: .template, applePayCapable: false)
      self.vm.inputs.viewDidLoad()

      self.pledgeCurrencyLabelText.assertValues([
        Project.Country.CA.currencyCode + " " + Project.Country.CA.currencySymbol
        ])
    }
  }

  func testPledgeCurrencyLabelText_USProject_NonUSBacker() {
    withEnvironment(config: .template |> Config.lens.countryCode .~ "GB") {
      let project = .template |> Project.lens.country .~ .US
      self.vm.inputs.configureWith(project: project, reward: .template, applePayCapable: false)
      self.vm.inputs.viewDidLoad()

      self.pledgeCurrencyLabelText.assertValues([
        Project.Country.US.currencyCode + " " + Project.Country.US.currencySymbol
      ])
    }
  }

  func testPledgeCurrencyLabelText_GBProject_NonUSBacker() {
    withEnvironment(config: .template |> Config.lens.countryCode .~ "GB") {
      let project = .template |> Project.lens.country .~ .GB
      self.vm.inputs.configureWith(project: project, reward: .template, applePayCapable: false)
      self.vm.inputs.viewDidLoad()

      self.pledgeCurrencyLabelText.assertValues([Project.Country.GB.currencySymbol])
    }
  }

  func testPledgeCurrencyLabelText_FRProject_NonUSBacker() {
    withEnvironment(config: .template |> Config.lens.countryCode .~ "GB") {
      let project = .template |> Project.lens.country .~ .FR
      self.vm.inputs.configureWith(project: project, reward: .template, applePayCapable: false)
      self.vm.inputs.viewDidLoad()

      self.pledgeCurrencyLabelText.assertValues([Project.Country.FR.currencySymbol])
    }
  }

  func testPledgeCurrencyLabelText_CAProject_NonUSBacker() {
    withEnvironment(config: .template |> Config.lens.countryCode .~ "GB") {
      let project = .template |> Project.lens.country .~ .CA
      self.vm.inputs.configureWith(project: project, reward: .template, applePayCapable: false)
      self.vm.inputs.viewDidLoad()

      self.pledgeCurrencyLabelText.assertValues([
        Project.Country.CA.currencyCode + " " + Project.Country.CA.currencySymbol
        ])
    }
  }

  func testPledgeTextFieldText() {
    let project = Project.template
    let reward = .template |> Reward.lens.minimum .~ 42
    self.vm.inputs.configureWith(project: project, reward: reward, applePayCapable: false)
    self.vm.inputs.viewDidLoad()

    self.pledgeTextFieldText.assertValues([String(reward.minimum)],
                                          "Sets initial value of pledge text field.")

    self.vm.inputs.pledgeTextFieldChanged("48")

    self.pledgeTextFieldText.assertValues([String(reward.minimum)],
                                          "Pledge field isn't set while editing.")

    self.vm.inputs.pledgeTextFieldDidEndEditing()

    self.pledgeTextFieldText.assertValues([String(reward.minimum)],
                                          "Pledge field isn't set when done editing with valid value.")

    self.vm.inputs.pledgeTextFieldChanged("20")

    self.pledgeTextFieldText.assertValues([String(reward.minimum)],
                                          "Pledge field isn't set while editing.")

    self.vm.inputs.pledgeTextFieldDidEndEditing()

    self.pledgeTextFieldText.assertValues([String(reward.minimum), String(reward.minimum)],
                                          "Pledge field is reset when done editing with invalid value.")
  }

  func testPledgeTextFieldText_ManageReward_NoShipping() {
    let reward = .template |> Reward.lens.minimum .~ 42
    let project = .template
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.amount .~ reward.minimum
          |> Backing.lens.shippingAmount .~ nil
          |> Backing.lens.reward .~ reward

    )
    self.vm.inputs.configureWith(project: project, reward: reward, applePayCapable: false)
    self.vm.inputs.viewDidLoad()

    self.pledgeTextFieldText.assertValues([String(reward.minimum)],
                                          "Sets initial value of pledge text field.")
  }

  func testPledgeTextFieldText_ManageReward_PledgedExtra_NoShipping() {
    let reward = .template |> Reward.lens.minimum .~ 42
    let project = .template
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.amount .~ reward.minimum + 10
          |> Backing.lens.shippingAmount .~ nil
          |> Backing.lens.reward .~ reward

    )
    self.vm.inputs.configureWith(project: project, reward: reward, applePayCapable: false)
    self.vm.inputs.viewDidLoad()

    self.pledgeTextFieldText.assertValues([String(reward.minimum + 10)],
                                          "Sets initial value of pledge text field.")
  }

  func testPledgeTextFieldText_ManageReward_WithShipping() {
    let reward = .template |> Reward.lens.minimum .~ 42
    let project = .template
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.amount .~ reward.minimum + 10
          |> Backing.lens.shippingAmount .~ 10
          |> Backing.lens.reward .~ reward

    )
    self.vm.inputs.configureWith(project: project, reward: reward, applePayCapable: false)
    self.vm.inputs.viewDidLoad()

    self.pledgeTextFieldText.assertValues([String(reward.minimum)],
                                          "Sets initial value of pledge text field.")
  }

  func testPledgeTextFieldText_ManageReward_PledgedExtra_WithShipping() {
    let reward = .template |> Reward.lens.minimum .~ 42
    let project = .template
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.amount .~ reward.minimum + 20 + 10
          |> Backing.lens.shippingAmount .~ 10
          |> Backing.lens.reward .~ reward

    )
    self.vm.inputs.configureWith(project: project, reward: reward, applePayCapable: false)
    self.vm.inputs.viewDidLoad()

    self.pledgeTextFieldText.assertValues([String(reward.minimum + 20)],
                                          "Sets initial value of pledge text field.")
  }

  func testReadMoreContainerViewHidden() {
    self.vm.inputs.configureWith(project: .template, reward: .template, applePayCapable: false)
    self.vm.inputs.viewDidLoad()

    self.readMoreContainerViewHidden.assertValues([false])

    self.vm.inputs.descriptionLabelTapped()

    self.readMoreContainerViewHidden.assertValues([false, true])
  }

  func testSetStripeAppleMerchantIdentifier_NotApplePayCapable() {
    self.vm.inputs.configureWith(project: .template, reward: .template, applePayCapable: false)
    self.vm.inputs.viewDidLoad()

    self.setStripeAppleMerchantIdentifier.assertValues([])
  }

  func testSetStripeAppleMerchantIdentifier_ApplePayCapable() {
    self.vm.inputs.configureWith(project: .template, reward: .template, applePayCapable: true)
    self.vm.inputs.viewDidLoad()

    self.setStripeAppleMerchantIdentifier.assertValues(
      [PKPaymentAuthorizationViewController.merchantIdentifier]
    )
  }

  func testSetStripePublishableKey_NotApplePayCapable() {
    withEnvironment(config: .template |> Config.lens.stripePublishableKey .~ "deadbeef") {
      self.vm.inputs.configureWith(project: .template, reward: .template, applePayCapable: false)
      self.vm.inputs.viewDidLoad()

      self.setStripePublishableKey.assertValues([])
    }
  }

  func testSetStripePublishableKey_ApplePayCapable() {
    withEnvironment(config: .template |> Config.lens.stripePublishableKey .~ "deadbeef") {
      self.vm.inputs.configureWith(project: .template, reward: .template, applePayCapable: true)
      self.vm.inputs.viewDidLoad()

      self.setStripePublishableKey.assertValues(["deadbeef"])
    }
  }

  func testShippingInputStackViewHidden_WithNoShipping() {
    withEnvironment(apiService: MockService(fetchShippingRulesResponse: [])) {
      self.vm.inputs.configureWith(project: .template, reward: .template, applePayCapable: false)
      self.vm.inputs.viewDidLoad()

      self.shippingInputStackViewHidden.assertValues([true])

      self.scheduler.advance()

      self.shippingInputStackViewHidden.assertValues([true])
    }
  }

  func testShippingInputStackViewHidden_WithShipping() {
    let reward = .template |> Reward.lens.shipping.enabled .~ true

    withEnvironment(apiService: MockService(fetchShippingRulesResponse: shippingRules)) {
      self.vm.inputs.configureWith(project: .template, reward: reward, applePayCapable: false)
      self.vm.inputs.viewDidLoad()

      self.shippingInputStackViewHidden.assertValues([false])

      self.scheduler.advance()

      self.shippingInputStackViewHidden.assertValues([false])
    }
  }

  func testShippingLocationsLabelText() {
    let project = Project.template
    let shippingSummary = "Ships to all the places"
    let reward = .template |> Reward.lens.shipping.summary .~ shippingSummary
    self.vm.inputs.configureWith(project: project, reward: reward, applePayCapable: false)
    self.vm.inputs.viewDidLoad()

    self.shippingLocationsLabelText.assertValues([shippingSummary])
  }

  func testTitleLabel_WithTitle() {
    self.vm.inputs.configureWith(project: .template,
                                 reward: .template |> Reward.lens.title .~ "Howdy!",
                                 applePayCapable: false)
    self.vm.inputs.viewDidLoad()

    self.titleLabelText.assertValues(["Howdy!"])
    self.titleLabelHidden.assertValues([false])
  }

  func testTitleLabel_WithoutTitle() {
    self.vm.inputs.configureWith(project: .template,
                                 reward: .template |> Reward.lens.title .~ nil,
                                 applePayCapable: false)
    self.vm.inputs.viewDidLoad()

    self.titleLabelText.assertValues([""])
    self.titleLabelHidden.assertValues([true])
  }
}
