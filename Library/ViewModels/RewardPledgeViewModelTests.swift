// swiftlint:disable force_unwrapping
import PassKit
import Prelude
import ReactiveSwift
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
  .enumerated()
  .map { idx, location in
    .template
      |> ShippingRule.lens.location .~ location
      |> ShippingRule.lens.cost .~ Double(idx + 1)
} ||> ShippingRule.lens.location..Location.lens.localizedName %~ { "Local " + $0 }

private let sortedShippingRules = shippingRules
  .sorted { lhs, rhs in lhs.location.displayableName < rhs.location.displayableName }

internal final class RewardPledgeViewModelTests: TestCase {
  fileprivate let vm: RewardPledgeViewModelType = RewardPledgeViewModel()

  fileprivate let applePayButtonHidden = TestObserver<Bool, NoError>()
  fileprivate let cancelPledgeButtonHidden = TestObserver<Bool, NoError>()
  fileprivate let changePaymentMethodButtonHidden = TestObserver<Bool, NoError>()
  fileprivate let continueToPaymentsButtonHidden = TestObserver<Bool, NoError>()
  fileprivate let conversionLabelHidden = TestObserver<Bool, NoError>()
  fileprivate let conversionLabelText = TestObserver<String, NoError>()
  fileprivate let countryLabelText = TestObserver<String, NoError>()
  fileprivate let descriptionLabelText = TestObserver<String, NoError>()
  fileprivate let differentPaymentMethodButtonHidden = TestObserver<Bool, NoError>()
  fileprivate let dismissViewController = TestObserver<(), NoError>()
  fileprivate let estimatedDeliveryDateLabelText = TestObserver<String, NoError>()
  private let estimatedFulfillmentStackViewHidden = TestObserver<Bool, NoError>()
  fileprivate let expandRewardDescription = TestObserver<(), NoError>()
  fileprivate let fulfillmentAndShippingFooterStackViewHidden = TestObserver<Bool, NoError>()
  fileprivate let goToCheckoutRequest = TestObserver<String, NoError>() // todo
  fileprivate let goToCheckoutProject = TestObserver<Project, NoError>() // todo
  fileprivate let goToLoginTout = TestObserver<(), NoError>()
  fileprivate let goToPaymentAuthorization = TestObserver<NSDictionary, NoError>()
  fileprivate let goToShippingPickerProject = TestObserver<Project, NoError>()
  fileprivate let goToShippingPickerShippingRules = TestObserver<[ShippingRule], NoError>()
  fileprivate let goToShippingPickerSelectedShippingRule = TestObserver<ShippingRule, NoError>()
  fileprivate let goToThanks = TestObserver<Project, NoError>()
  fileprivate let items = TestObserver<[String], NoError>()
  fileprivate let itemsContainerHidden = TestObserver<Bool, NoError>()
  fileprivate let loadingOverlayIsHidden = TestObserver<Bool, NoError>()
  fileprivate let minimumLabelText = TestObserver<String, NoError>()
  fileprivate let navigationTitle = TestObserver<String, NoError>()
  fileprivate let orLabelHidden = TestObserver<Bool, NoError>()
  private let paddingViewHeightConstant = TestObserver<CGFloat, NoError>()
  fileprivate let pledgeCurrencyLabelText = TestObserver<String, NoError>()
  fileprivate let pledgeIsLoading = TestObserver<Bool, NoError>()
  fileprivate let pledgeTextFieldText = TestObserver<String, NoError>()
  fileprivate let readMoreContainerViewHidden = TestObserver<Bool, NoError>()
  fileprivate let setStripeAppleMerchantIdentifier = TestObserver<String, NoError>()
  fileprivate let setStripePublishableKey = TestObserver<String, NoError>()
  fileprivate let shippingAmountLabelText = TestObserver<String, NoError>()
  fileprivate let shippingInputStackViewHidden = TestObserver<Bool, NoError>()
  fileprivate let shippingIsLoading = TestObserver<Bool, NoError>()
  fileprivate let shippingLocationsLabelText = TestObserver<String, NoError>()
  private let shippingStackViewHidden = TestObserver<Bool, NoError>()
  fileprivate let showAlertMessage = TestObserver<String, NoError>()
  fileprivate let showAlertShouldDismiss = TestObserver<Bool, NoError>()
  fileprivate let titleLabelHidden = TestObserver<Bool, NoError>()
  fileprivate let titleLabelText = TestObserver<String, NoError>()
  fileprivate let updatePledgeButtonHidden = TestObserver<Bool, NoError>()

  // todo koala tracking testing

  override func setUp() {
    super.setUp()

    self.vm.outputs.applePayButtonHidden.observe(self.applePayButtonHidden.observer)
    self.vm.outputs.cancelPledgeButtonHidden.observe(self.cancelPledgeButtonHidden.observer)
    self.vm.outputs.changePaymentMethodButtonHidden.observe(self.changePaymentMethodButtonHidden.observer)
    self.vm.outputs.continueToPaymentsButtonHidden.observe(self.continueToPaymentsButtonHidden.observer)
    self.vm.outputs.conversionLabelHidden.observe(self.conversionLabelHidden.observer)
    self.vm.outputs.conversionLabelText.observe(self.conversionLabelText.observer)
    self.vm.outputs.countryLabelText.observe(self.countryLabelText.observer)
    self.vm.outputs.descriptionLabelText.observe(self.descriptionLabelText.observer)
    self.vm.outputs.differentPaymentMethodButtonHidden
      .observe(self.differentPaymentMethodButtonHidden.observer)
    self.vm.outputs.dismissViewController.observe(self.dismissViewController.observer)
    self.vm.outputs.estimatedDeliveryDateLabelText.observe(self.estimatedDeliveryDateLabelText.observer)
    self.vm.outputs.estimatedFulfillmentStackViewHidden
      .observe(self.estimatedFulfillmentStackViewHidden.observer)
    self.vm.outputs.expandRewardDescription.observe(self.expandRewardDescription.observer)
    self.vm.outputs.fulfillmentAndShippingFooterStackViewHidden
      .observe(self.fulfillmentAndShippingFooterStackViewHidden.observer)
    self.vm.outputs.goToCheckout.map(first).map { $0.url?.absoluteString }
      .skipNil()
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
    self.vm.outputs.loadingOverlayIsHidden.observe(self.loadingOverlayIsHidden.observer)
    self.vm.outputs.minimumLabelText.observe(self.minimumLabelText.observer)
    self.vm.outputs.navigationTitle.observe(self.navigationTitle.observer)
    self.vm.outputs.orLabelHidden.observe(self.orLabelHidden.observer)
    self.vm.outputs.paddingViewHeightConstant.observe(self.paddingViewHeightConstant.observer)
    self.vm.outputs.pledgeCurrencyLabelText.observe(self.pledgeCurrencyLabelText.observer)
    self.vm.outputs.pledgeIsLoading.observe(self.pledgeIsLoading.observer)
    self.vm.outputs.pledgeTextFieldText.observe(self.pledgeTextFieldText.observer)
    self.vm.outputs.readMoreContainerViewHidden.observe(self.readMoreContainerViewHidden.observer)
    self.vm.outputs.setStripeAppleMerchantIdentifier.observe(self.setStripeAppleMerchantIdentifier.observer)
    self.vm.outputs.setStripePublishableKey.observe(self.setStripePublishableKey.observer)
    self.vm.outputs.shippingAmountLabelText.observe(self.shippingAmountLabelText.observer)
    self.vm.outputs.shippingInputStackViewHidden.observe(self.shippingInputStackViewHidden.observer)
    self.vm.outputs.shippingIsLoading.observe(self.shippingIsLoading.observer)
    self.vm.outputs.shippingLocationsLabelText.observe(self.shippingLocationsLabelText.observer)
    self.vm.outputs.shippingStackViewHidden.observe(self.shippingStackViewHidden.observer)
    self.vm.outputs.showAlert.map(first).observe(self.showAlertMessage.observer)
    self.vm.outputs.showAlert.map(second).observe(self.showAlertShouldDismiss.observer)
    self.vm.outputs.titleLabelHidden.observe(self.titleLabelHidden.observer)
    self.vm.outputs.titleLabelText.observe(self.titleLabelText.observer)
    self.vm.outputs.updatePledgeButtonHidden.observe(self.updatePledgeButtonHidden.observer)

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

  func testApplePayButtonHidden_UnsupportedApplePayCountry() {
    let unsupportedCountry = Project.Country(countryCode: "ZZ",
                                             currencyCode: "ZZD",
                                             currencySymbol: "µ",
                                             maxPledge: 10_000,
                                             minPledge: 1,
                                             trailingCode: true)
    let project = .template
      |> Project.lens.country .~ unsupportedCountry

    self.vm.inputs.configureWith(project: project, reward: .template, applePayCapable: true)
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
      |> Project.lens.country .~ .us

    withEnvironment(config: .template |> Config.lens.countryCode .~ "US") {
      self.vm.inputs.configureWith(project: project, reward: .template, applePayCapable: false)
      self.vm.inputs.viewDidLoad()

      self.conversionLabelHidden.assertValues([true])
      self.conversionLabelText.assertValueCount(0)
    }
  }

  func testConversionLabel_Shown() {
    let project = .template
      |> Project.lens.country .~ .gb
      |> Project.lens.stats.staticUsdRate .~ 2
      |> Project.lens.stats.currentCurrency .~ "USD"
      |> Project.lens.stats.currentCurrencyRate .~ 2
    let reward = .template
      |> Reward.lens.minimum .~ 1_000

    withEnvironment(config: .template |> Config.lens.countryCode .~ "US") {
      self.vm.inputs.configureWith(project: project, reward: reward, applePayCapable: false)
      self.vm.inputs.viewDidLoad()

      self.conversionLabelHidden.assertValues([false], "US user viewing non-US project sees conversion.")
      self.conversionLabelText.assertValues(["About $2,000"])
    }
  }

  func testConversionLabel_Shown_WithoutCurrentCurrency() {
    let project = .template
      |> Project.lens.country .~ .gb
      |> Project.lens.stats.staticUsdRate .~ 2
      |> Project.lens.stats.currentCurrency .~ nil
      |> Project.lens.stats.currentCurrencyRate .~ nil
    let reward = .template
      |> Reward.lens.minimum .~ 1_000

    withEnvironment(config: .template |> Config.lens.countryCode .~ "US") {
      self.vm.inputs.configureWith(project: project, reward: reward, applePayCapable: false)
      self.vm.inputs.viewDidLoad()

      self.conversionLabelHidden.assertValues([false], "US user viewing non-US project sees conversion.")
      self.conversionLabelText.assertValues(["About $2,000"])
    }
  }

  func testCountryAndShippingAmountLabelText_WithRecognizedCountry() {
    withEnvironment(
      apiService: MockService(fetchShippingRulesResult: Result(shippingRules)),
      config: .template |> Config.lens.countryCode .~ "AU") {

        self.vm.inputs.configureWith(project: .template, reward: .template, applePayCapable: false)
        self.vm.inputs.viewDidLoad()

        self.countryLabelText.assertValues([""])
        self.shippingAmountLabelText.assertValues([""])

        self.scheduler.advance()

        self.countryLabelText.assertValues(["", "Local Australia"])
        self.shippingAmountLabelText.assertValues(["", "+$4"])
    }
  }

  func testCountryAndShippingAmountLabelText_WithUnrecognizedCountry() {
    withEnvironment(
      apiService: MockService(fetchShippingRulesResult: Result(shippingRules)),
      config: .template |> Config.lens.countryCode .~ "XYZ") {

        self.vm.inputs.configureWith(project: .template, reward: .template, applePayCapable: false)
        self.vm.inputs.viewDidLoad()

        self.countryLabelText.assertValues([""])
        self.shippingAmountLabelText.assertValues([""])

        self.scheduler.advance()

        self.countryLabelText.assertValues(["", "Local United States"])
        self.shippingAmountLabelText.assertValues(["", "+$1"])
    }
  }

  func testCountryAndShippingAmount_PickerFlow() {
    let project = Project.template
    let reward = Reward.template
    let defaultShippingRule = shippingRules.last!
    let otherShippingRule = shippingRules.first!

    withEnvironment(
      apiService: MockService(fetchShippingRulesResult: Result(shippingRules)),
      config: .template |> Config.lens.countryCode .~ defaultShippingRule.location.country) {

        self.vm.inputs.configureWith(project: project, reward: reward, applePayCapable: false)
        self.vm.inputs.viewDidLoad()

        self.countryLabelText.assertValues([""])
        self.shippingAmountLabelText.assertValues([""])

        self.scheduler.advance()

        self.countryLabelText.assertValues(["", defaultShippingRule.location.localizedName])
        self.shippingAmountLabelText.assertValues([
          "", "+" + Format.currency(Int(defaultShippingRule.cost), country: project.country)
          ])

        self.vm.inputs.shippingButtonTapped()
        self.vm.inputs.change(shippingRule: otherShippingRule)

        self.countryLabelText.assertValues([
          "", defaultShippingRule.location.localizedName, otherShippingRule.location.localizedName
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

  func testDismissViewController() {
    self.vm.inputs.configureWith(project: .template, reward: .template, applePayCapable: false)
    self.vm.inputs.viewDidLoad()

    self.dismissViewController.assertValueCount(0)
    XCTAssertEqual(["Reward Checkout", "Selected Reward"], self.trackingClient.events)

    self.vm.inputs.closeButtonTapped()

    self.dismissViewController.assertValueCount(1)

    XCTAssertEqual(["Reward Checkout", "Selected Reward", "Closed Reward"], self.trackingClient.events)
  }

  func testEstimatedDeliveryDateLabelText() {
    let reward = .template |> Reward.lens.estimatedDeliveryOn .~ Date().timeIntervalSince1970
    self.vm.inputs.configureWith(project: .template, reward: reward, applePayCapable: false)
    self.vm.inputs.viewDidLoad()

    self.estimatedDeliveryDateLabelText.assertValues([
      Format.date(secondsInUTC: reward.estimatedDeliveryOn!, template: "MMMyyyy", timeZone: UTCTimeZone)
    ])

    self.estimatedFulfillmentStackViewHidden.assertValues([false])
  }

  func testExpandRewardDescription() {
    self.vm.inputs.configureWith(project: .template, reward: .template, applePayCapable: false)

    XCTAssertEqual([], self.trackingClient.events)

    self.vm.inputs.viewDidLoad()

    self.expandRewardDescription.assertValueCount(0)
    XCTAssertEqual(["Reward Checkout", "Selected Reward"], self.trackingClient.events)

    self.vm.inputs.expandDescriptionTapped()

    self.expandRewardDescription.assertValueCount(1)

    XCTAssertEqual(["Reward Checkout", "Selected Reward", "Expanded Reward Description"],
                   self.trackingClient.events)
    XCTAssertEqual(["new_pledge", "new_pledge", "new_pledge"],
                   self.trackingClient.properties(forKey: "pledge_context", as: String.self))
  }

  func testFulfillmentAndShippingFooterStackViewHidden_ShippingEnabled() {
    let reward = .template |> Reward.lens.shipping.enabled .~ true
    self.vm.inputs.configureWith(project: .template, reward: reward, applePayCapable: false)
    self.vm.inputs.viewDidLoad()

    self.fulfillmentAndShippingFooterStackViewHidden.assertValues([false], "Show the container stack.")
    self.estimatedFulfillmentStackViewHidden.assertValues([false], "Show the delivery label.")
    self.shippingStackViewHidden.assertValues([false], "Show the shipping label.")
  }

  func testFulfillmentAndShippingFooterStackViewHidden_ShippingDisabled() {
    let reward = .template |> Reward.lens.shipping.enabled .~ false
    self.vm.inputs.configureWith(project: .template, reward: reward, applePayCapable: false)
    self.vm.inputs.viewDidLoad()

    self.fulfillmentAndShippingFooterStackViewHidden.assertValues([false], "Show the container stack.")
    self.estimatedFulfillmentStackViewHidden.assertValues([false], "Show the delivery label.")
    self.shippingStackViewHidden.assertValues([true], "Hide the shipping label.")
  }

  func testFulfillmentAndShippingFooterStackViewHidden_NoDelivery() {
    let reward = .template
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.estimatedDeliveryOn .~ nil
    self.vm.inputs.configureWith(project: .template, reward: reward, applePayCapable: false)
    self.vm.inputs.viewDidLoad()

    self.fulfillmentAndShippingFooterStackViewHidden.assertValues([false], "Show the container stack.")
    self.estimatedFulfillmentStackViewHidden.assertValues([true], "Hide the delivery label.")
    self.shippingStackViewHidden.assertValues([false], "Show the shipping label.")
  }

  func testFulfillmentAndShippingFooterStackViewHidden_NoDeliveryOrShipping() {
    let reward = .template
      |> Reward.lens.shipping.enabled .~ false
      |> Reward.lens.estimatedDeliveryOn .~ nil
    self.vm.inputs.configureWith(project: .template, reward: reward, applePayCapable: false)
    self.vm.inputs.viewDidLoad()

    self.fulfillmentAndShippingFooterStackViewHidden.assertValues([true], "Hide the entire stack.")
    self.estimatedFulfillmentStackViewHidden.assertValues([true])
  }

  func testCancelPledge() {
    let reward = Reward.template
    let project = .template
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.reward .~ reward
    )

    self.vm.inputs.configureWith(project: project, reward: reward, applePayCapable: false)
    self.vm.inputs.viewDidLoad()
    self.scheduler.advance()

    self.cancelPledgeButtonHidden.assertValues([false])

    self.vm.inputs.cancelPledgeButtonTapped()

    XCTAssertEqual(["Reward Checkout", "Selected Reward", "Clicked Reward Pledge Button"],
                   self.trackingClient.events)
    XCTAssertEqual(
      [nil, nil, "cancel"],
      self.trackingClient.properties(forKey: "type", as: String.self)
    )

    self.goToCheckoutProject.assertValues([project])
  }

  func testGoToPaymentAuthorization_NoShipping_NoRewardTitle() {
    let project = Project.template
    let reward = Reward.template

    withEnvironment(apiService: MockService(fetchShippingRulesResult: Result([]))) {
      self.vm.inputs.configureWith(project: project, reward: reward, applePayCapable: true)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.applePayButtonHidden.assertValues([false])
      self.goToPaymentAuthorization.assertValues([])

      self.vm.inputs.applePayButtonTapped()

      let paymentRequest: NSDictionary =  [
        "countryCode": project.country.countryCode,
        "currencyCode": project.country.currencyCode,
        "merchantCapabilities": [PKMerchantCapability.capability3DS.rawValue],
        "merchantIdentifier": PKPaymentAuthorizationViewController.merchantIdentifier,
        "supportedNetworks": PKPaymentAuthorizationViewController.supportedNetworks,
        "shippingType": PKShippingType.shipping.rawValue,
        "paymentSummaryItems": [
          [
            "label": project.name,
            "amount": NSDecimalNumber(value: reward.minimum),
            "type": PKPaymentSummaryItemType.final.rawValue
          ],
          [
            "label": "Kickstarter (if funded)",
            "amount": NSDecimalNumber(value: reward.minimum),
            "type": PKPaymentSummaryItemType.final.rawValue
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

    withEnvironment(apiService: MockService(fetchShippingRulesResult: Result([]))) {
      self.vm.inputs.configureWith(project: project, reward: reward, applePayCapable: true)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.applePayButtonHidden.assertValues([false])
      self.goToPaymentAuthorization.assertValues([])

      self.vm.inputs.applePayButtonTapped()

      let paymentRequest: NSDictionary =  [
        "countryCode": project.country.countryCode,
        "currencyCode": project.country.currencyCode,
        "merchantCapabilities": [PKMerchantCapability.capability3DS.rawValue],
        "merchantIdentifier": PKPaymentAuthorizationViewController.merchantIdentifier,
        "supportedNetworks": PKPaymentAuthorizationViewController.supportedNetworks,
        "shippingType": PKShippingType.shipping.rawValue,
        "paymentSummaryItems": [
          [
            "label": reward.title!,
            "amount": NSDecimalNumber(value: reward.minimum),
            "type": PKPaymentSummaryItemType.final.rawValue
          ],
          [
            "label": "Kickstarter (if funded)",
            "amount": NSDecimalNumber(value: reward.minimum),
            "type": PKPaymentSummaryItemType.final.rawValue
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

    withEnvironment(apiService: MockService(fetchShippingRulesResult: Result([shippingRule]))) {
      self.vm.inputs.configureWith(project: project, reward: reward, applePayCapable: true)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.applePayButtonHidden.assertValues([false])
      self.goToPaymentAuthorization.assertValues([])

      self.vm.inputs.applePayButtonTapped()

      let paymentRequest: NSDictionary =  [
        "countryCode": project.country.countryCode,
        "currencyCode": project.country.currencyCode,
        "merchantCapabilities": [PKMerchantCapability.capability3DS.rawValue],
        "merchantIdentifier": PKPaymentAuthorizationViewController.merchantIdentifier,
        "supportedNetworks": PKPaymentAuthorizationViewController.supportedNetworks,
        "shippingType": PKShippingType.shipping.rawValue,
        "paymentSummaryItems": [
          [
            "label": project.name,
            "amount": NSDecimalNumber(value: reward.minimum),
            "type": PKPaymentSummaryItemType.final.rawValue
          ],
          [
            "label": "Kickstarter (if funded)",
            "amount": NSDecimalNumber(value: reward.minimum),
            "type": PKPaymentSummaryItemType.final.rawValue
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
      apiService: MockService(fetchShippingRulesResult: Result(shippingRules)),
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
          "merchantCapabilities": [PKMerchantCapability.capability3DS.rawValue],
          "merchantIdentifier": PKPaymentAuthorizationViewController.merchantIdentifier,
          "supportedNetworks": PKPaymentAuthorizationViewController.supportedNetworks,
          "shippingType": PKShippingType.shipping.rawValue,
          "paymentSummaryItems": [[String: Any]].init(arrayLiteral:
            [
              "label": project.name,
              "amount": NSDecimalNumber(value: reward.minimum),
              "type": PKPaymentSummaryItemType.final.rawValue
            ],
            [
              "label": "Shipping",
              "amount": NSDecimalNumber(value: defaultShippingRule.cost),
              "type": PKPaymentSummaryItemType.final.rawValue
            ],
            [
              "label": "Kickstarter (if funded)",
              "amount": NSDecimalNumber(value: Int(defaultShippingRule.cost) + reward.minimum),
              "type": PKPaymentSummaryItemType.final.rawValue
            ]
          )
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
      apiService: MockService(fetchShippingRulesResult: Result(shippingRules)),
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
          "merchantCapabilities": [PKMerchantCapability.capability3DS.rawValue],
          "merchantIdentifier": PKPaymentAuthorizationViewController.merchantIdentifier,
          "supportedNetworks": PKPaymentAuthorizationViewController.supportedNetworks,
          "shippingType": PKShippingType.shipping.rawValue,
          "paymentSummaryItems": [[String: Any]].init(arrayLiteral:
            [
              "label": project.name,
              "amount": NSDecimalNumber(value: 50),
              "type": PKPaymentSummaryItemType.final.rawValue
            ],
            [
              "label": "Shipping",
              "amount": NSDecimalNumber(value: defaultShippingRule.cost),
              "type": PKPaymentSummaryItemType.final.rawValue
            ],
            [
              "label": "Kickstarter (if funded)",
              "amount": NSDecimalNumber(value: Int(defaultShippingRule.cost) + 50),
              "type": PKPaymentSummaryItemType.final.rawValue
            ]
          )
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
      apiService: MockService(fetchShippingRulesResult: Result(shippingRules)),
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
          "merchantCapabilities": [PKMerchantCapability.capability3DS.rawValue],
          "merchantIdentifier": PKPaymentAuthorizationViewController.merchantIdentifier,
          "supportedNetworks": PKPaymentAuthorizationViewController.supportedNetworks,
          "shippingType": PKShippingType.shipping.rawValue,
          "paymentSummaryItems": [[String: Any]].init(arrayLiteral:
            [
              "label": project.name,
              "amount": NSDecimalNumber(value: reward.minimum),
              "type": PKPaymentSummaryItemType.final.rawValue
            ],
            [
              "label": "Shipping",
              "amount": NSDecimalNumber(value: changedShippingRule.cost),
              "type": PKPaymentSummaryItemType.final.rawValue
            ],
            [
              "label": "Kickstarter (if funded)",
              "amount": NSDecimalNumber(value: Int(changedShippingRule.cost) + reward.minimum),
              "type": PKPaymentSummaryItemType.final.rawValue
            ]
          )
        ]

        self.goToPaymentAuthorization.assertValues([paymentRequest])
        self.goToCheckoutRequest.assertValueCount(0)
        self.goToCheckoutProject.assertValues([])
    }
  }

  func testApplePay_CancelFlow() {
    let project = Project.template
    self.vm.inputs.configureWith(project: project, reward: .template, applePayCapable: true)

    self.loadingOverlayIsHidden.assertValueCount(0)

    self.vm.inputs.viewDidLoad()
    self.scheduler.advance()

    self.applePayButtonHidden.assertValues([false])
    XCTAssertEqual(["Reward Checkout", "Selected Reward"], self.trackingClient.events)

    self.vm.inputs.applePayButtonTapped()
    self.vm.inputs.paymentAuthorizationWillAuthorizePayment()

    XCTAssertEqual(
      ["Reward Checkout", "Selected Reward", "Clicked Reward Pledge Button", "Apple Pay Show Sheet",
        "Showed Apple Pay Sheet"],
      self.trackingClient.events
    )

    self.vm.inputs.paymentAuthorizationDidFinish()

    XCTAssertEqual(
      ["Reward Checkout", "Selected Reward", "Clicked Reward Pledge Button", "Apple Pay Show Sheet",
        "Showed Apple Pay Sheet", "Apple Pay Canceled", "Canceled Apple Pay"],
      self.trackingClient.events
    )
    XCTAssertEqual(
      ["new_pledge", "new_pledge", "new_pledge", "new_pledge", "new_pledge", "new_pledge",
        "new_pledge"],
      self.trackingClient.properties(forKey: "pledge_context", as: String.self)
    )
    XCTAssertEqual([nil, nil, "apple_pay", nil, nil, nil, nil],
                   self.trackingClient.properties(forKey: "type", as: String.self))
    XCTAssertEqual([nil, nil, "Reward Selection", nil, nil, nil, nil],
                   self.trackingClient.properties(forKey: "context", as: String.self))

    self.pledgeIsLoading.assertValueCount(0)
    self.loadingOverlayIsHidden.assertValues([true])
  }

  func testApplePay_SuccessfulFlow() {
    let project = Project.template
    self.vm.inputs.configureWith(project: project, reward: .template, applePayCapable: true)
    self.vm.inputs.viewDidLoad()
    self.scheduler.advance()

    self.applePayButtonHidden.assertValues([false])
    self.loadingOverlayIsHidden.assertValues([true])
    XCTAssertEqual(["Reward Checkout", "Selected Reward"], self.trackingClient.events)

    self.vm.inputs.applePayButtonTapped()
    self.vm.inputs.paymentAuthorizationWillAuthorizePayment()

    XCTAssertEqual(
      ["Reward Checkout", "Selected Reward", "Clicked Reward Pledge Button", "Apple Pay Show Sheet",
        "Showed Apple Pay Sheet"],
      self.trackingClient.events
    )

    self.vm.inputs.paymentAuthorization(
      didAuthorizePayment: .init(
        tokenData: .init(
          paymentMethodData: .init(displayName: "AmEx", network: .amex, type: .credit),
          transactionIdentifier: "apple_pay_deadbeef"
        )
      )
    )

    XCTAssertEqual(
      ["Reward Checkout", "Selected Reward", "Clicked Reward Pledge Button", "Apple Pay Show Sheet",
        "Showed Apple Pay Sheet", "Apple Pay Authorized", "Authorized Apple Pay"],
      self.trackingClient.events
    )

    XCTAssertEqual(
      ["Reward Checkout", "Selected Reward", "Clicked Reward Pledge Button", "Apple Pay Show Sheet",
        "Showed Apple Pay Sheet", "Apple Pay Authorized", "Authorized Apple Pay"],
      self.trackingClient.events
    )

    self.pledgeIsLoading.assertValueCount(0)
    self.loadingOverlayIsHidden.assertValues([true])

    let status = self.vm.inputs.stripeCreatedToken(stripeToken: "stripe_deadbeef", error: nil)

    self.scheduler.advance()

    self.pledgeIsLoading.assertValues([true, false])
    self.loadingOverlayIsHidden.assertValues([true, false, true])

    XCTAssertEqual(
      ["Reward Checkout", "Selected Reward", "Clicked Reward Pledge Button", "Apple Pay Show Sheet",
        "Showed Apple Pay Sheet", "Apple Pay Authorized", "Authorized Apple Pay",
        "Apple Pay Stripe Token Created", "Created Apple Pay Stripe Token"],
      self.trackingClient.events
    )

    XCTAssertEqual(PKPaymentAuthorizationStatus.success.rawValue, status.rawValue)

    self.vm.inputs.paymentAuthorizationDidFinish()

    self.scheduler.advance()

    self.goToThanks.assertValues([project])

    XCTAssertEqual(
      ["Reward Checkout", "Selected Reward", "Clicked Reward Pledge Button", "Apple Pay Show Sheet",
        "Showed Apple Pay Sheet", "Apple Pay Authorized", "Authorized Apple Pay",
        "Apple Pay Stripe Token Created", "Created Apple Pay Stripe Token", "Apple Pay Finished"],
      self.trackingClient.events
    )

    XCTAssertEqual(
      ["new_pledge", "new_pledge", "new_pledge", "new_pledge", "new_pledge", "new_pledge", "new_pledge",
        "new_pledge", "new_pledge", "new_pledge"],
      self.trackingClient.properties(forKey: "pledge_context", as: String.self)
    )
  }

  func testApplePay_StripeErrorFlow() {
    let project = Project.template
    self.vm.inputs.configureWith(project: project, reward: .template, applePayCapable: true)
    self.vm.inputs.viewDidLoad()
    self.scheduler.advance()

    self.applePayButtonHidden.assertValues([false])
    self.loadingOverlayIsHidden.assertValues([true])
    XCTAssertEqual(["Reward Checkout", "Selected Reward"], self.trackingClient.events)

    self.vm.inputs.applePayButtonTapped()
    self.vm.inputs.paymentAuthorizationWillAuthorizePayment()

    XCTAssertEqual(
      ["Reward Checkout", "Selected Reward", "Clicked Reward Pledge Button", "Apple Pay Show Sheet",
        "Showed Apple Pay Sheet"],
      self.trackingClient.events
    )

    self.vm.inputs.paymentAuthorization(
      didAuthorizePayment: .init(
        tokenData: .init(
          paymentMethodData: .init(displayName: "AmEx", network: .amex, type: .credit),
          transactionIdentifier: "apple_pay_deadbeef"
        )
      )
    )

    XCTAssertEqual(
      ["Reward Checkout", "Selected Reward", "Clicked Reward Pledge Button", "Apple Pay Show Sheet",
        "Showed Apple Pay Sheet", "Apple Pay Authorized", "Authorized Apple Pay"],
      self.trackingClient.events
    )

    let status = self.vm.inputs.stripeCreatedToken(
      stripeToken: nil, error: NSError(domain: "deadbeef", code: 1, userInfo: nil)
    )

    XCTAssertEqual(
      ["Reward Checkout", "Selected Reward", "Clicked Reward Pledge Button", "Apple Pay Show Sheet",
        "Showed Apple Pay Sheet", "Apple Pay Authorized", "Authorized Apple Pay",
        "Apple Pay Stripe Token Errored", "Errored Apple Pay Stripe Token"],
      self.trackingClient.events
    )

    XCTAssertEqual(PKPaymentAuthorizationStatus.failure.rawValue, status.rawValue)

    self.vm.inputs.paymentAuthorizationDidFinish()

    XCTAssertEqual(
      ["Reward Checkout", "Selected Reward", "Clicked Reward Pledge Button", "Apple Pay Show Sheet",
        "Showed Apple Pay Sheet", "Apple Pay Authorized", "Authorized Apple Pay",
        "Apple Pay Stripe Token Errored", "Errored Apple Pay Stripe Token", "Apple Pay Canceled",
        "Canceled Apple Pay"],
      self.trackingClient.events
    )
    XCTAssertEqual(
      ["new_pledge", "new_pledge", "new_pledge", "new_pledge", "new_pledge", "new_pledge", "new_pledge",
        "new_pledge", "new_pledge", "new_pledge", "new_pledge"],
      self.trackingClient.properties(forKey: "pledge_context", as: String.self)
    )

    self.goToThanks.assertValues([])
    self.pledgeIsLoading.assertValueCount(0)
    self.loadingOverlayIsHidden.assertValues([true])
  }

  func testDiscoverCard_NotAvailable_ProjectsOutsideUS() {

    let project = Project.template
      |> Project.lens.country .~ Project.Country.au
    let user = User.template

    withEnvironment(currentUser: user) {

      XCTAssertFalse(PKPaymentAuthorizationViewController.supportedNetworks(for: project).contains(.discover))
    }
  }

  func testDiscoverCard_NotAvailable_ProjectsInsideUS_UserOutsideUS() {

    let env = Environment.init(countryCode: "AU")
    let project = Project.template

    withEnvironment(env) {

      XCTAssertFalse(PKPaymentAuthorizationViewController.supportedNetworks(for: project).contains(.discover))
    }
  }

  func testDiscoverCard_Available_ProjectsInsideUS_UserInUS() {

    let project = Project.template
    let user = User.template
    let config = Config.template
      |> Config.lens.countryCode .~ "AU"

    withEnvironment(config: config, currentUser: user) {
      XCTAssertTrue(PKPaymentAuthorizationViewController.supportedNetworks(for: project).contains(.discover))
    }
  }

  func testApplePay_LoggedOutFlow() {
    withEnvironment(currentUser: nil) {
      let project = Project.template
      self.vm.inputs.configureWith(project: project, reward: .template, applePayCapable: true)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.applePayButtonHidden.assertValues([false])
      self.loadingOverlayIsHidden.assertValues([true])

      self.vm.inputs.applePayButtonTapped()

      self.goToPaymentAuthorization.assertValueCount(0)
      self.goToLoginTout.assertValueCount(1)

      withEnvironment(currentUser: .template) {
        self.vm.inputs.userSessionStarted()

        self.goToPaymentAuthorization.assertValueCount(0, "Apple Pay flow does not start immediately.")
        self.goToLoginTout.assertValueCount(1)

        self.scheduler.advance(by: .seconds(1))

        self.goToPaymentAuthorization.assertValueCount(1, "Apple Pay flow starts after waiting a bit.")

        self.vm.inputs.paymentAuthorizationWillAuthorizePayment()
        self.vm.inputs.paymentAuthorization(
          didAuthorizePayment: .init(
            tokenData: .init(
              paymentMethodData: .init(displayName: "AmEx", network: .amex, type: .credit),
              transactionIdentifier: "apple_pay_deadbeef"
            )
          )
        )
        self.vm.inputs.paymentAuthorizationDidFinish()

        self.pledgeIsLoading.assertValueCount(0)
        self.loadingOverlayIsHidden.assertValues([true])

        let status = self.vm.inputs.stripeCreatedToken(stripeToken: "stripe_deadbeef", error: nil)

        self.scheduler.advance()

        self.pledgeIsLoading.assertValues([true, false])
        self.loadingOverlayIsHidden.assertValues([true, false, true])
        XCTAssertEqual(PKPaymentAuthorizationStatus.success.rawValue, status.rawValue)

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
    self.loadingOverlayIsHidden.assertValues([true])
    self.pledgeIsLoading.assertValueCount(0)

    self.vm.inputs.continueToPaymentsButtonTapped()

    self.loadingOverlayIsHidden.assertValues([true, false])

    self.scheduler.advance()

    self.goToCheckoutProject.assertValues([project])
    self.goToCheckoutRequest.assertValueCount(1)
    self.pledgeIsLoading.assertValues([true, false])
    self.loadingOverlayIsHidden.assertValues([true, false, true])
  }

  func testGoToCheckout_LoggedOut_ContinueToPaymentMethod() {
    let project = Project.template

    withEnvironment(currentUser: nil) {
      self.vm.inputs.configureWith(project: project, reward: .template, applePayCapable: false)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.continueToPaymentsButtonHidden.assertValues([false])
      self.differentPaymentMethodButtonHidden.assertValues([true])
      self.loadingOverlayIsHidden.assertValues([true])

      self.vm.inputs.continueToPaymentsButtonTapped()

      self.goToCheckoutProject.assertValues([])
      self.goToCheckoutRequest.assertValueCount(0)
      self.goToLoginTout.assertValueCount(1)
      self.pledgeIsLoading.assertValueCount(0)
      self.loadingOverlayIsHidden.assertValues([true])

      withEnvironment(currentUser: .template) {
        self.vm.inputs.userSessionStarted()

        self.loadingOverlayIsHidden.assertValues([true, false])

        self.scheduler.advance()

        self.goToCheckoutProject.assertValues([project])
        self.goToCheckoutRequest.assertValueCount(1)
        self.pledgeIsLoading.assertValues([true, false])
        self.loadingOverlayIsHidden.assertValues([true, false, true])
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
    self.loadingOverlayIsHidden.assertValues([true])
    self.pledgeIsLoading.assertValueCount(0)

    self.vm.inputs.differentPaymentMethodButtonTapped()

    self.loadingOverlayIsHidden.assertValues([true, false])

    self.scheduler.advance()

    self.goToCheckoutProject.assertValues([project])
    self.goToCheckoutRequest.assertValueCount(1)
    self.pledgeIsLoading.assertValues([true, false])
    self.loadingOverlayIsHidden.assertValues([true, false, true])
  }

  func testGoToCheckout_LoggedOut_DifferentPaymentMethod() {
    let project = Project.template

    withEnvironment(currentUser: nil) {
      self.vm.inputs.configureWith(project: project, reward: .template, applePayCapable: true)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.continueToPaymentsButtonHidden.assertValues([true])
      self.differentPaymentMethodButtonHidden.assertValues([false])
      self.loadingOverlayIsHidden.assertValues([true])

      self.vm.inputs.differentPaymentMethodButtonTapped()

      self.goToCheckoutProject.assertValues([])
      self.goToCheckoutRequest.assertValueCount(0)
      self.goToLoginTout.assertValueCount(1)
      self.pledgeIsLoading.assertValueCount(0)
      self.loadingOverlayIsHidden.assertValues([true])

      withEnvironment(currentUser: .template) {
        self.vm.inputs.userSessionStarted()

        self.loadingOverlayIsHidden.assertValues([true, false])

        self.scheduler.advance()

        self.goToCheckoutProject.assertValues([project])
        self.goToCheckoutRequest.assertValueCount(1)
        self.pledgeIsLoading.assertValues([true, false])
        self.loadingOverlayIsHidden.assertValues([true, false, true])
      }
    }
  }

  func testGoToCheckout_ChangeReward_NeedsPaymentsUpdate() {
    let oldReward = Reward.template
      |> Reward.lens.id .~ 1
    let newReward = Reward.template
      |> Reward.lens.id .~ 2
    let project = .template
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.reward .~ oldReward
          |> Backing.lens.rewardId .~ oldReward.id
    )

    self.vm.inputs.configureWith(project: project, reward: newReward, applePayCapable: true)
    self.vm.inputs.viewDidLoad()
    self.scheduler.advance()

    self.applePayButtonHidden.assertValues([true])
    self.cancelPledgeButtonHidden.assertValues([true])
    self.changePaymentMethodButtonHidden.assertValues([true])
    self.continueToPaymentsButtonHidden.assertValues([true])
    self.differentPaymentMethodButtonHidden.assertValues([true])
    self.loadingOverlayIsHidden.assertValues([true])
    self.updatePledgeButtonHidden.assertValues([false])
    self.pledgeIsLoading.assertValueCount(0)

    // Updating pledge response comes back with a checkout url when we need a further webview checkout step
    let updatePledgeResponse = UpdatePledgeEnvelope(
      newCheckoutUrl: "http://kickstarter.com/checkout", status: 200
    )

    withEnvironment(apiService: MockService(updatePledgeResult: Result(updatePledgeResponse))) {
      self.vm.inputs.updatePledgeButtonTapped()

      self.loadingOverlayIsHidden.assertValues([true, false])

      self.scheduler.advance()

      self.goToCheckoutProject.assertValues([project])
      self.goToCheckoutRequest.assertValueCount(1)
      self.goToThanks.assertValues([])
      self.pledgeIsLoading.assertValues([true, false])
      self.loadingOverlayIsHidden.assertValues([true, false, true])
    }
  }

  func testGoToCheckout_ManageReward_NeedsPaymentsUpdate() {
    let reward = Reward.template
    let project = .template
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.amount .~ reward.minimum
          |> Backing.lens.shippingAmount .~ 0
          |> Backing.lens.reward .~ reward
          |> Backing.lens.rewardId .~ reward.id
    )

    self.vm.inputs.configureWith(project: project, reward: reward, applePayCapable: true)
    self.vm.inputs.viewDidLoad()
    self.scheduler.advance()

    self.applePayButtonHidden.assertValues([true])
    self.cancelPledgeButtonHidden.assertValues([false])
    self.changePaymentMethodButtonHidden.assertValues([false])
    self.continueToPaymentsButtonHidden.assertValues([true])
    self.differentPaymentMethodButtonHidden.assertValues([true])
    self.loadingOverlayIsHidden.assertValues([true])
    self.updatePledgeButtonHidden.assertValues([false])
    self.pledgeIsLoading.assertValueCount(0)

    // Updating pledge response comes back with a checkout url when we need a further webview checkout step
    let updatePledgeResponse = UpdatePledgeEnvelope(
      newCheckoutUrl: "http://kickstarter.com/checkout", status: 200
    )

    withEnvironment(apiService: MockService(updatePledgeResult: Result(updatePledgeResponse))) {
      self.vm.inputs.updatePledgeButtonTapped()

      self.loadingOverlayIsHidden.assertValues([true, false])

      self.scheduler.advance()

      self.goToCheckoutProject.assertValues([project])
      self.goToCheckoutRequest.assertValueCount(1)
      self.goToThanks.assertValues([])
      self.pledgeIsLoading.assertValues([true, false])
      self.loadingOverlayIsHidden.assertValues([true, false, true])
    }
  }

  func testGoToCheckout_AfterValidationError() {
    withEnvironment(currentUser: .template) {
      let dkCountry = Project.Country(countryCode: "DK", currencyCode: "DKK", currencySymbol: "kr",
                                      maxPledge: nil, minPledge: nil, trailingCode: true)
      let project = .template
        |> Project.lens.country .~ dkCountry
      let reward = .template
        |> Reward.lens.minimum .~ 20

      self.vm.inputs.configureWith(project: project, reward: reward, applePayCapable: false)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.loadingOverlayIsHidden.assertValues([true])
      XCTAssertEqual(["Reward Checkout", "Selected Reward"], self.trackingClient.events)

      self.vm.inputs.pledgeTextFieldChanged("1")

      XCTAssertEqual(
        ["Reward Checkout", "Selected Reward", "Checkout Amount Changed", "Changed Pledge Amount"],
        self.trackingClient.events
      )

      self.pledgeIsLoading.assertValueCount(0)
      self.loadingOverlayIsHidden.assertValues([true])

      self.vm.inputs.continueToPaymentsButtonTapped()
      self.vm.inputs.pledgeTextFieldDidEndEditing()

      XCTAssertEqual(
        ["Reward Checkout", "Selected Reward", "Checkout Amount Changed", "Changed Pledge Amount",
          "Clicked Reward Pledge Button"],
        self.trackingClient.events
      )
      self.loadingOverlayIsHidden.assertValues([true, false])

      self.scheduler.advance()

      self.showAlertMessage.assertValues(["Please enter an amount of DKK 20 or more."])
      self.showAlertShouldDismiss.assertValues([false])
      XCTAssertEqual(
        ["Reward Checkout", "Selected Reward", "Checkout Amount Changed", "Changed Pledge Amount",
          "Clicked Reward Pledge Button", "Errored Reward Pledge Button Click"],
        self.trackingClient.events
      )

      self.vm.inputs.errorAlertTappedOK(shouldDismiss: false)

      self.dismissViewController.assertValueCount(0)

      self.pledgeIsLoading.assertValues([true, false])
      self.loadingOverlayIsHidden.assertValues([true, false, true])

      self.vm.inputs.continueToPaymentsButtonTapped()
      self.vm.inputs.pledgeTextFieldDidEndEditing()

      self.loadingOverlayIsHidden.assertValues([true, false, true, false])

      self.scheduler.advance()

      self.showAlertMessage.assertValues(["Please enter an amount of DKK 20 or more."])
      self.showAlertShouldDismiss.assertValues([false])
      XCTAssertEqual(
        ["Reward Checkout", "Selected Reward", "Checkout Amount Changed", "Changed Pledge Amount",
          "Clicked Reward Pledge Button", "Errored Reward Pledge Button Click",
          "Clicked Reward Pledge Button"],
        self.trackingClient.events
      )

      self.goToCheckoutProject.assertValues([project])
      self.goToCheckoutRequest.assertValueCount(1)
      self.pledgeIsLoading.assertValues([true, false, true, false])
      self.loadingOverlayIsHidden.assertValues([true, false, true, false, true])
    }
  }

  func testGoToThanks_ChangeReward() {
    let oldReward = Reward.template
      |> Reward.lens.id .~ 1
    let newReward = Reward.template
      |> Reward.lens.id .~ 2
    let project = .template
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.reward .~ oldReward
          |> Backing.lens.rewardId .~ oldReward.id
    )

    self.vm.inputs.configureWith(project: project, reward: newReward, applePayCapable: true)
    self.vm.inputs.viewDidLoad()
    self.scheduler.advance()

    self.applePayButtonHidden.assertValues([true])
    self.updatePledgeButtonHidden.assertValues([false])
    self.cancelPledgeButtonHidden.assertValues([true])
    self.continueToPaymentsButtonHidden.assertValues([true])
    self.differentPaymentMethodButtonHidden.assertValues([true])
    self.loadingOverlayIsHidden.assertValues([true])
    self.pledgeIsLoading.assertValueCount(0)

    // Updating pledge response comes back with no checkout url when everything completed successfully
    let updatePledgeResponse = UpdatePledgeEnvelope(newCheckoutUrl: nil, status: 200)

    withEnvironment(apiService: MockService(updatePledgeResult: Result(updatePledgeResponse))) {
      self.vm.inputs.updatePledgeButtonTapped()

      self.loadingOverlayIsHidden.assertValues([true, false])

      self.scheduler.advance()

      self.goToCheckoutProject.assertValues([])
      self.goToCheckoutRequest.assertValueCount(0)
      self.goToThanks.assertValues([project])
      self.pledgeIsLoading.assertValues([true, false])
      self.loadingOverlayIsHidden.assertValues([true, false, true])
    }
  }

  func testGoToThanks_ManageReward() {
    let reward = Reward.template
    let project = .template
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.amount .~ reward.minimum
          |> Backing.lens.shippingAmount .~ 0
          |> Backing.lens.reward .~ reward
          |> Backing.lens.rewardId .~ reward.id
    )

    self.vm.inputs.configureWith(project: project, reward: reward, applePayCapable: true)
    self.vm.inputs.viewDidLoad()
    self.scheduler.advance()

    self.applePayButtonHidden.assertValues([true])
    self.cancelPledgeButtonHidden.assertValues([false])
    self.changePaymentMethodButtonHidden.assertValues([false])
    self.continueToPaymentsButtonHidden.assertValues([true])
    self.differentPaymentMethodButtonHidden.assertValues([true])
    self.updatePledgeButtonHidden.assertValues([false])
    self.loadingOverlayIsHidden.assertValues([true])
    self.pledgeIsLoading.assertValueCount(0)

    // Updating pledge response comes back with no checkout url when everything completed successfully
    let updatePledgeResponse = UpdatePledgeEnvelope(newCheckoutUrl: nil, status: 200)

    withEnvironment(apiService: MockService(updatePledgeResult: Result(updatePledgeResponse))) {
      self.vm.inputs.updatePledgeButtonTapped()

      self.loadingOverlayIsHidden.assertValues([true, false])

      self.scheduler.advance()

      self.goToCheckoutProject.assertValues([])
      self.goToCheckoutRequest.assertValueCount(0)
      self.goToThanks.assertValues([project])
      self.pledgeIsLoading.assertValues([true, false])
      self.loadingOverlayIsHidden.assertValues([true, false, true])
    }
  }

  func testGoToShippingPickerFlow() {
    let project = Project.template
    let reward = .template |> Reward.lens.shipping.enabled .~ true
    let defaultShippingRule = shippingRules.last!
    let otherShippingRule = shippingRules.first!

    withEnvironment(
      apiService: MockService(fetchShippingRulesResult: Result(shippingRules)),
      config: .template |> Config.lens.countryCode .~ defaultShippingRule.location.country) {

        self.vm.inputs.configureWith(project: project, reward: reward, applePayCapable: false)
        self.vm.inputs.viewDidLoad()
        self.scheduler.advance()
        self.vm.inputs.shippingButtonTapped()

        self.goToShippingPickerProject.assertValues([project])
        self.goToShippingPickerShippingRules.assertValues([shippingRules])
        self.goToShippingPickerSelectedShippingRule.assertValues([defaultShippingRule])
        XCTAssertEqual(["Reward Checkout", "Selected Reward"], self.trackingClient.events)

        self.vm.inputs.change(shippingRule: otherShippingRule)

        XCTAssertEqual(
          ["Reward Checkout", "Selected Reward", "Checkout Location Changed",
            "Selected Shipping Destination"],
          self.trackingClient.events
        )
        XCTAssertEqual(["new_pledge", "new_pledge", "new_pledge", "new_pledge"],
                       self.trackingClient.properties(forKey: "pledge_context", as: String.self))

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

  func testItemsContainerHidden_NoItems() {
    self.vm.inputs.configureWith(project: .template, reward: .template, applePayCapable: false)

    self.itemsContainerHidden.assertValueCount(0)
    self.paddingViewHeightConstant.assertValueCount(0)

    self.vm.inputs.viewDidLoad()

    // NB: At runtime, viewDidLayoutSubviews is calling this method when the view loads and then again after
    // the description stackview is resized.
    self.vm.inputs.descriptionLabelIsTruncated(false)
    self.vm.inputs.descriptionLabelIsTruncated(true)

    self.itemsContainerHidden.assertValues([true], "Hide container with zero items.")
    self.readMoreContainerViewHidden.assertValues([false])
    self.paddingViewHeightConstant.assertValues([18.0])

    self.vm.inputs.expandDescriptionTapped()

    self.itemsContainerHidden.assertValues([true], "Hidden container does not emit again.")
  }

  func testItemsContainerHidden_Items_NotTruncated() {
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

    self.itemsContainerHidden.assertValueCount(0)

    self.vm.inputs.viewDidLoad()

    // NB: At runtime, viewDidLayoutSubviews is calling this method when the view loads and then again after
    // the description stackview is resized.
    self.vm.inputs.descriptionLabelIsTruncated(false)
    self.vm.inputs.descriptionLabelIsTruncated(false)

    self.itemsContainerHidden.assertValues([false], "Show container with rewards.")
    self.readMoreContainerViewHidden.assertValues([true])
    self.paddingViewHeightConstant.assertValues([0.0])
  }

  func testItemsContainerHidden_Items_Truncated() {
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

    self.itemsContainerHidden.assertValueCount(0)
    self.paddingViewHeightConstant.assertValueCount(0)

    self.vm.inputs.viewDidLoad()

    // NB: At runtime, viewDidLayoutSubviews is calling this method when the view loads and then again after
    // the description stackview is resized.
    self.vm.inputs.descriptionLabelIsTruncated(false)
    self.vm.inputs.descriptionLabelIsTruncated(true)

    self.itemsContainerHidden.assertValues([true], "Don't show container when description is truncated.")
    self.readMoreContainerViewHidden.assertValues([false])
    self.paddingViewHeightConstant.assertValues([18.0])

    self.vm.inputs.expandDescriptionTapped()

    self.itemsContainerHidden.assertValues([true, false], "Show items container on expanded view.")
    self.readMoreContainerViewHidden.assertValues([false, true])
    self.paddingViewHeightConstant.assertValues([18.0, 0.0])
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

  func testMinimumLabelText_NoReward() {
    let reward = Reward.noReward
    let project = Project.template
    self.vm.inputs.configureWith(project: project, reward: reward, applePayCapable: false)

    self.vm.inputs.viewDidLoad()

    self.shippingIsLoading.assertValues([false], "Shipping loader emits false on no reward.")

    self.minimumLabelText.assertValues(["Pledge $1 or more"])

    self.scheduler.advance()

    self.shippingIsLoading.assertValues([false], "Shipping loader does not emit.")
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

  func testNavigationTitle_BackerWithReward_ManageDifferentReward() {
    let reward = .template |> Reward.lens.minimum .~ 50
    let project = .template
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.rewardId .~ 42
          |> Backing.lens.reward .~ (reward |> Reward.lens.id .~ 42)
    )
    self.vm.inputs.configureWith(project: project, reward: reward, applePayCapable: false)
    self.vm.inputs.viewDidLoad()

    self.navigationTitle.assertValues(["Select this reward instead"])
  }

  func testNavigationTitle_BackerWithNoReward_ManageNoReward() {
    let reward = Reward.noReward
    let project = .template
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.rewardId .~ 0
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

  func testOrLabelHidden() {
    //todo
    //orLabelHidden
  }

  func testPledgeCurrencyLabelText_USProject_USBacker() {
    withEnvironment(config: .template |> Config.lens.countryCode .~ "US") {
      let project = .template |> Project.lens.country .~ .us
      self.vm.inputs.configureWith(project: project, reward: .template, applePayCapable: false)
      self.vm.inputs.viewDidLoad()

      self.pledgeCurrencyLabelText.assertValues([Project.Country.us.currencySymbol])
    }
  }

  func testPledgeCurrencyLabelText_GBProject_USBacker() {
    withEnvironment(config: .template |> Config.lens.countryCode .~ "US") {
      let project = .template |> Project.lens.country .~ .gb
      self.vm.inputs.configureWith(project: project, reward: .template, applePayCapable: false)
      self.vm.inputs.viewDidLoad()

      self.pledgeCurrencyLabelText.assertValues([Project.Country.gb.currencySymbol])
    }
  }

  func testPledgeCurrencyLabelText_FRProject_USBacker() {
    withEnvironment(config: .template |> Config.lens.countryCode .~ "US") {
      let project = .template |> Project.lens.country .~ .fr
      self.vm.inputs.configureWith(project: project, reward: .template, applePayCapable: false)
      self.vm.inputs.viewDidLoad()

      self.pledgeCurrencyLabelText.assertValues([Project.Country.fr.currencySymbol])
    }
  }

  func testPledgeCurrencyLabelText_CAProject_USBacker() {
    withEnvironment(countryCode: "US") {
      let project = .template |> Project.lens.country .~ .ca
      self.vm.inputs.configureWith(project: project, reward: .template, applePayCapable: false)
      self.vm.inputs.viewDidLoad()

      self.pledgeCurrencyLabelText.assertValues(["CA$"])
    }
  }

  func testPledgeCurrencyLabelText_USProject_NonUSBacker() {
    withEnvironment(countryCode: "GB") {
      let project = .template |> Project.lens.country .~ .us
      self.vm.inputs.configureWith(project: project, reward: .template, applePayCapable: false)
      self.vm.inputs.viewDidLoad()

      self.pledgeCurrencyLabelText.assertValues(["US$"])
    }
  }

  func testPledgeCurrencyLabelText_GBProject_NonUSBacker() {
    withEnvironment(countryCode: "GB") {
      let project = .template |> Project.lens.country .~ .gb
      self.vm.inputs.configureWith(project: project, reward: .template, applePayCapable: false)
      self.vm.inputs.viewDidLoad()

      self.pledgeCurrencyLabelText.assertValues([Project.Country.gb.currencySymbol])
    }
  }

  func testPledgeCurrencyLabelText_FRProject_NonUSBacker() {
    withEnvironment(countryCode: "GB") {
      let project = .template |> Project.lens.country .~ .fr
      self.vm.inputs.configureWith(project: project, reward: .template, applePayCapable: false)
      self.vm.inputs.viewDidLoad()

      self.pledgeCurrencyLabelText.assertValues([Project.Country.fr.currencySymbol])
    }
  }

  func testPledgeCurrencyLabelText_CAProject_NonUSBacker() {
    withEnvironment(countryCode: "GB") {
      let project = .template |> Project.lens.country .~ .ca
      self.vm.inputs.configureWith(project: project, reward: .template, applePayCapable: false)
      self.vm.inputs.viewDidLoad()

      self.pledgeCurrencyLabelText.assertValues(["CA$"])
    }
  }

  func testPledgeTextFieldText() {
    let project = Project.template
    let reward = .template
      |> Reward.lens.minimum .~ 42
      |> Reward.lens.id .~ 24
    self.vm.inputs.configureWith(project: project, reward: reward, applePayCapable: false)
    self.vm.inputs.viewDidLoad()

    self.pledgeTextFieldText.assertValues([String(reward.minimum)],
                                          "Sets initial value of pledge text field.")
    XCTAssertEqual(["Reward Checkout", "Selected Reward"], self.trackingClient.events)

    self.vm.inputs.pledgeTextFieldChanged("48")

    self.pledgeTextFieldText.assertValues([String(reward.minimum)],
                                          "Pledge field isn't set while editing.")
    XCTAssertEqual(["Reward Checkout", "Selected Reward", "Checkout Amount Changed", "Changed Pledge Amount"],
                   self.trackingClient.events)

    self.vm.inputs.pledgeTextFieldDidEndEditing()

    self.pledgeTextFieldText.assertValues([String(reward.minimum)],
                                          "Pledge field isn't set when done editing with valid value.")
    XCTAssertEqual(["Reward Checkout", "Selected Reward", "Checkout Amount Changed", "Changed Pledge Amount"],
                   self.trackingClient.events)

    self.vm.inputs.pledgeTextFieldChanged("20")

    self.pledgeTextFieldText.assertValues([String(reward.minimum)],
                                          "Pledge field isn't set while editing.")
    XCTAssertEqual(
      ["Reward Checkout", "Selected Reward", "Checkout Amount Changed", "Changed Pledge Amount",
        "Checkout Amount Changed", "Changed Pledge Amount"],
      self.trackingClient.events
    )

    self.vm.inputs.pledgeTextFieldDidEndEditing()

    self.pledgeTextFieldText.assertValues([String(reward.minimum), String(reward.minimum)],
                                          "Pledge field is reset when done editing with invalid value.")

    XCTAssertEqual(
      ["Reward Checkout", "Selected Reward", "Checkout Amount Changed", "Changed Pledge Amount",
        "Checkout Amount Changed", "Changed Pledge Amount"],
      self.trackingClient.events
    )
    XCTAssertEqual(
      ["new_pledge", "new_pledge", "new_pledge", "new_pledge", "new_pledge", "new_pledge"],
      self.trackingClient.properties(forKey: "pledge_context", as: String.self)
    )
    XCTAssertEqual(
      [reward.id, reward.id, reward.id, reward.id, reward.id, reward.id],
      self.trackingClient.properties(forKey: "backer_reward_id", as: Int.self)
    )
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
          |> Backing.lens.amount .~ (reward.minimum + 10)
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
          |> Backing.lens.amount .~ (reward.minimum + 10)
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
          |> Backing.lens.amount .~ (reward.minimum + 20 + 10)
          |> Backing.lens.shippingAmount .~ 10
          |> Backing.lens.reward .~ reward

    )
    self.vm.inputs.configureWith(project: project, reward: reward, applePayCapable: false)
    self.vm.inputs.viewDidLoad()

    self.pledgeTextFieldText.assertValues([String(reward.minimum + 20)],
                                          "Sets initial value of pledge text field.")
  }

  func testPledgeTextFieldText_ManageNoReward() {
    let reward = Reward.noReward
    let project = .template
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.amount .~ 123
          |> Backing.lens.shippingAmount .~ nil
          |> Backing.lens.reward .~ nil
          |> Backing.lens.rewardId .~ nil

    )
    self.vm.inputs.configureWith(project: project, reward: reward, applePayCapable: false)
    self.vm.inputs.viewDidLoad()

    self.pledgeTextFieldText.assertValues(["123"], "Sets initial value of pledge text field.")
  }

  func testPledgeTextFieldText_Pledge_NoReward() {
    let reward = Reward.noReward
    let project = .template |> Project.lens.country .~ .us

    self.vm.inputs.configureWith(project: project, reward: reward, applePayCapable: false)
    self.vm.inputs.viewDidLoad()

    self.pledgeTextFieldText.assertValues(["1"])
  }

  func testPledgeTextFieldText_Pledge_NoReward_DK() {
    let reward = Reward.noReward
    let project = .template |> Project.lens.country .~ .dk

    self.vm.inputs.configureWith(project: project, reward: reward, applePayCapable: false)
    self.vm.inputs.viewDidLoad()

    self.pledgeTextFieldText.assertValues(["5"])
  }

  func testReadMoreContainerViewHidden_descriptionTruncated() {
    self.vm.inputs.configureWith(project: .template, reward: .template, applePayCapable: false)
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.descriptionLabelIsTruncated(true)

    self.readMoreContainerViewHidden.assertDidNotEmitValue()

    self.vm.inputs.descriptionLabelIsTruncated(true)

    self.readMoreContainerViewHidden.assertValues([false])
  }

  func testReadMoreContainerViewHidden() {
    self.vm.inputs.configureWith(project: .template, reward: .template, applePayCapable: false)
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.descriptionLabelIsTruncated(false)

    self.readMoreContainerViewHidden.assertDidNotEmitValue()

    self.vm.inputs.descriptionLabelIsTruncated(false)

    self.readMoreContainerViewHidden.assertValues([true])
  }

  func testReadMoreContainerViewHidden_NoReward() {
    self.vm.inputs.configureWith(project: .template, reward: Reward.noReward, applePayCapable: false)
    self.vm.inputs.viewDidLoad()

    self.readMoreContainerViewHidden.assertValues([true])
  }

  func testSetStripeAppleMerchantIdentifier_NotApplePayCapable() {
    self.vm.inputs.configureWith(project: .template, reward: .template, applePayCapable: false)
    self.vm.inputs.viewDidLoad()

    self.setStripeAppleMerchantIdentifier.assertValueCount(0)
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

      self.setStripePublishableKey.assertValueCount(0)
    }
  }

  func testSetStripePublishableKey_ApplePayCapable() {
    withEnvironment(config: .template |> Config.lens.stripePublishableKey .~ "deadbeef") {
      self.vm.inputs.configureWith(project: .template, reward: .template, applePayCapable: true)
      self.vm.inputs.viewDidLoad()

      self.setStripePublishableKey.assertValues(["deadbeef"])
    }
  }

  func testShippingAmountLabelText_USUser_CAProject() {
    let apiService = MockService(fetchShippingRulesResult: Result(shippingRules))
    let config = .template |> Config.lens.countryCode .~ "US"
    let project = .template |> Project.lens.country .~ .ca

    withEnvironment(apiService: apiService, config: config) {
      self.vm.inputs.configureWith(project: project, reward: .template, applePayCapable: false)
      self.vm.inputs.viewDidLoad()

      self.shippingAmountLabelText.assertValues([""])

      self.scheduler.advance()

      self.shippingAmountLabelText.assertValues(["", "+CA$ 1"])
    }
  }

  func testShippingAmountLabelText_CAUser_CAProject() {
    let apiService = MockService(fetchShippingRulesResult: Result(shippingRules))
    let config = .template |> Config.lens.countryCode .~ "CA"
    let project = .template |> Project.lens.country .~ .ca

    withEnvironment(apiService: apiService, config: config) {
      self.vm.inputs.configureWith(project: project, reward: .template, applePayCapable: false)
      self.vm.inputs.viewDidLoad()

      self.shippingAmountLabelText.assertValues([""])

      self.scheduler.advance()

      self.shippingAmountLabelText.assertValues(["", "+CA$ 2"])
    }
  }

  func testShippingAmountLabelText_USUser_DKProject() {
    let apiService = MockService(fetchShippingRulesResult: Result(shippingRules))
    let config = .template |> Config.lens.countryCode .~ "US"
    let project = .template |> Project.lens.country .~ .dk

    withEnvironment(apiService: apiService, config: config) {
      self.vm.inputs.configureWith(project: project, reward: .template, applePayCapable: false)
      self.vm.inputs.viewDidLoad()

      self.shippingAmountLabelText.assertValues([""])

      self.scheduler.advance()

      self.shippingAmountLabelText.assertValues(["", "+DKK 1"])
    }
  }

  func testShippingInputStackViewHidden_WithNoShipping() {
    withEnvironment(apiService: MockService(fetchShippingRulesResult: Result([]))) {
      self.vm.inputs.configureWith(project: .template, reward: .template, applePayCapable: false)
      self.vm.inputs.viewDidLoad()

      self.shippingInputStackViewHidden.assertValues([true])

      self.scheduler.advance()

      self.shippingInputStackViewHidden.assertValues([true])
    }
  }

  func testShippingInputStackViewHidden_WithShipping() {
    let reward = .template |> Reward.lens.shipping.enabled .~ true

    withEnvironment(apiService: MockService(fetchShippingRulesResult: Result(shippingRules))) {
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

  func testShowAlert_WithReward() {
    withEnvironment(currentUser: .template) {
      let dkCountry = Project.Country(countryCode: "DK", currencyCode: "DKK", currencySymbol: "kr",
                                      maxPledge: nil, minPledge: nil, trailingCode: true)
      let project = .template
        |> Project.lens.country .~ dkCountry
      let reward = .template
        |> Reward.lens.minimum .~ 20

      self.vm.inputs.configureWith(project: project, reward: reward, applePayCapable: false)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      XCTAssertEqual(["Reward Checkout", "Selected Reward"], self.trackingClient.events)

      self.vm.inputs.pledgeTextFieldChanged("1")

      XCTAssertEqual(
        ["Reward Checkout", "Selected Reward", "Checkout Amount Changed", "Changed Pledge Amount"],
        self.trackingClient.events
      )

      self.vm.inputs.continueToPaymentsButtonTapped()

      XCTAssertEqual(
        ["Reward Checkout", "Selected Reward", "Checkout Amount Changed", "Changed Pledge Amount",
          "Clicked Reward Pledge Button"],
        self.trackingClient.events
      )

      self.scheduler.advance()

      self.showAlertMessage.assertValues(["Please enter an amount of DKK 20 or more."])
      self.showAlertShouldDismiss.assertValues([false])
      XCTAssertEqual(
        ["Reward Checkout", "Selected Reward", "Checkout Amount Changed", "Changed Pledge Amount",
        "Clicked Reward Pledge Button", "Errored Reward Pledge Button Click"],
        self.trackingClient.events
      )

      self.vm.inputs.errorAlertTappedOK(shouldDismiss: false)

      self.dismissViewController.assertValueCount(0)

      self.vm.inputs.pledgeTextFieldChanged("100000")

      XCTAssertEqual(
        ["Reward Checkout", "Selected Reward", "Checkout Amount Changed", "Changed Pledge Amount",
          "Clicked Reward Pledge Button", "Errored Reward Pledge Button Click", "Checkout Amount Changed",
          "Changed Pledge Amount"],
        self.trackingClient.events
      )

      self.vm.inputs.continueToPaymentsButtonTapped()

      XCTAssertEqual(
        ["Reward Checkout", "Selected Reward", "Checkout Amount Changed", "Changed Pledge Amount",
          "Clicked Reward Pledge Button", "Errored Reward Pledge Button Click", "Checkout Amount Changed",
          "Changed Pledge Amount", "Clicked Reward Pledge Button"],
        self.trackingClient.events
      )

      self.scheduler.advance()

      self.showAlertMessage.assertValues([
        "Please enter an amount of DKK 20 or more.",
        "Please enter an amount of DKK 65,000 or less."
        ])
      self.showAlertShouldDismiss.assertValues([false, false])

      self.vm.inputs.errorAlertTappedOK(shouldDismiss: false)

      self.dismissViewController.assertValueCount(0)

      XCTAssertEqual(
        ["Reward Checkout", "Selected Reward", "Checkout Amount Changed", "Changed Pledge Amount",
          "Clicked Reward Pledge Button", "Errored Reward Pledge Button Click", "Checkout Amount Changed",
          "Changed Pledge Amount", "Clicked Reward Pledge Button", "Errored Reward Pledge Button Click"],
        self.trackingClient.events
      )

      XCTAssertEqual(
        [nil, nil, nil, nil, "payment_methods", "MINIMUM_AMOUNT", nil, nil, "payment_methods",
          "MAXIMUM_AMOUNT"],
        self.trackingClient.properties(forKey: "type", as: String.self)
      )
    }
  }

  func testShowAlert_WithNoReward() {
    withEnvironment(currentUser: .template) {
      let dkCountry = Project.Country(countryCode: "DK", currencyCode: "DKK", currencySymbol: "kr",
                                      maxPledge: nil, minPledge: nil, trailingCode: true)
      let project = .template
        |> Project.lens.country .~ dkCountry
      let reward = Reward.noReward

      self.vm.inputs.configureWith(project: project, reward: reward, applePayCapable: false)
      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.vm.inputs.pledgeTextFieldChanged("1")
      self.vm.inputs.continueToPaymentsButtonTapped()

      self.scheduler.advance()

      self.showAlertMessage.assertValues(["Please enter an amount of DKK 5 or more."])
      self.showAlertShouldDismiss.assertValues([false])

      self.vm.inputs.errorAlertTappedOK(shouldDismiss: false)

      self.dismissViewController.assertValueCount(0)

      self.vm.inputs.pledgeTextFieldChanged("100000")
      self.vm.inputs.continueToPaymentsButtonTapped()

      self.scheduler.advance()

      self.showAlertMessage.assertValues([
        "Please enter an amount of DKK 5 or more.",
        "Please enter an amount of DKK 65,000 or less."
        ])
      self.showAlertShouldDismiss.assertValues([false, false])

      self.vm.inputs.errorAlertTappedOK(shouldDismiss: false)

      self.dismissViewController.assertValueCount(0)
    }
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

  func testTrackChangedPledgeAmount_Pledging() {
    let project = Project.template
    let reward = Reward.template
    self.vm.inputs.configureWith(project: project, reward: reward, applePayCapable: false)
    self.vm.inputs.viewDidLoad()

    XCTAssertEqual(["Reward Checkout", "Selected Reward"], self.trackingClient.events)

    self.vm.inputs.pledgeTextFieldChanged("48")

    XCTAssertEqual(
      ["Reward Checkout", "Selected Reward", "Checkout Amount Changed", "Changed Pledge Amount"],
      self.trackingClient.events
    )
    XCTAssertEqual(["new_pledge", "new_pledge", "new_pledge", "new_pledge"],
                   self.trackingClient.properties(forKey: "pledge_context", as: String.self))
  }

  func testTrackChangedPledgeAmount_ManagingPledge() {
    let reward = .template |> Reward.lens.minimum .~ 50
    let project = .template
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.reward .~ reward
    )
    self.vm.inputs.configureWith(project: project, reward: reward, applePayCapable: false)
    self.vm.inputs.viewDidLoad()

    XCTAssertEqual(["Reward Checkout", "Selected Reward"], self.trackingClient.events)

    self.vm.inputs.pledgeTextFieldChanged("48")

    XCTAssertEqual(["Reward Checkout", "Selected Reward", "Checkout Amount Changed", "Changed Pledge Amount"],
                   self.trackingClient.events)
    XCTAssertEqual(["manage_reward", "manage_reward", "manage_reward", "manage_reward"],
                   self.trackingClient.properties(forKey: "pledge_context", as: String.self))
  }

  func testTrackChangedPledgeAmount_ManagingReward() {
    let newReward = .template
      |> Reward.lens.minimum .~ 50
      |> Reward.lens.id .~ 42
    let oldReward = .template
      |> Reward.lens.id .~ 24
    let project = .template
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.reward .~ oldReward
    )
    self.vm.inputs.configureWith(project: project, reward: newReward, applePayCapable: false)
    self.vm.inputs.viewDidLoad()

    XCTAssertEqual(["Reward Checkout", "Selected Reward"], self.trackingClient.events)

    self.vm.inputs.pledgeTextFieldChanged("48")

    XCTAssertEqual(["Reward Checkout", "Selected Reward", "Checkout Amount Changed", "Changed Pledge Amount"],
                   self.trackingClient.events)
    XCTAssertEqual(["change_reward", "change_reward", "change_reward", "change_reward"],
                   self.trackingClient.properties(forKey: "pledge_context", as: String.self))
  }

  func testShippingRulesErrored() {
    let error = ErrorEnvelope(
      errorMessages: ["Something went wrong yo."],
      ksrCode: .UnknownCode,
      httpCode: 400,
      exception: nil
    )

    let defaultShippingRule = shippingRules.last!

    withEnvironment(
      apiService: MockService(fetchShippingRulesResult: Result(error: error)),
      config: .template |> Config.lens.countryCode .~ defaultShippingRule.location.country) {

        self.vm.inputs.configureWith(project: .template, reward: .template, applePayCapable: false)
        self.vm.inputs.viewDidLoad()

        self.shippingIsLoading.assertValues([true])
        self.showAlertMessage.assertValueCount(0)

        self.scheduler.advance()

        self.shippingIsLoading.assertValues([true, false])
        self.showAlertMessage.assertValues([Strings.We_were_unable_to_load_the_shipping_destinations()])
        self.showAlertShouldDismiss.assertValues([true])
        self.dismissViewController.assertValueCount(0)

        self.vm.inputs.errorAlertTappedOK(shouldDismiss: true)

        self.dismissViewController.assertValueCount(1)
    }
  }

  func testCreatePledgeErrors() {
    let errorUnknown = ErrorEnvelope(
      errorMessages: ["Something went wrong yo."],
      ksrCode: .UnknownCode,
      httpCode: 400,
      exception: nil
    )

    let errorEmptyMessage = ErrorEnvelope(
      errorMessages: [],
      ksrCode: nil,
      httpCode: 400,
      exception: nil
    )

    let defaultShippingRule = shippingRules.last!

    withEnvironment(
      apiService: MockService(createPledgeResult: Result(error: errorUnknown)),
      config: .template |> Config.lens.countryCode .~ defaultShippingRule.location.country) {

        self.vm.inputs.configureWith(project: .template, reward: .template, applePayCapable: false)
        self.vm.inputs.viewDidLoad()

        self.scheduler.advance()

        self.vm.inputs.continueToPaymentsButtonTapped()

        self.showAlertMessage.assertValueCount(0)

        self.scheduler.advance()

        self.showAlertMessage.assertValues(["Something went wrong yo."])
        self.showAlertShouldDismiss.assertValues([true])
        self.dismissViewController.assertValueCount(0)

        self.vm.inputs.errorAlertTappedOK(shouldDismiss: true)

        self.dismissViewController.assertValueCount(1)

        withEnvironment(
          apiService: MockService(createPledgeResult: Result(error: errorEmptyMessage)),
          config: .template |> Config.lens.countryCode .~ defaultShippingRule.location.country) {

            self.vm.inputs.configureWith(project: .template, reward: .template, applePayCapable: false)
            self.vm.inputs.viewDidLoad()

            self.scheduler.advance()

            self.vm.inputs.continueToPaymentsButtonTapped()

            self.showAlertMessage.assertValueCount(1)

            self.scheduler.advance()

            self.showAlertMessage.assertValues(
              ["Something went wrong yo.", Strings.general_error_something_wrong()]
            )
            self.showAlertShouldDismiss.assertValues([true, true])
            self.dismissViewController.assertValueCount(1)

            self.vm.inputs.errorAlertTappedOK(shouldDismiss: true)

            self.dismissViewController.assertValueCount(2)
        }
    }
  }

  func testChangePaymentMethodErrors() {
    let errorUnknown = ErrorEnvelope(
      errorMessages: ["Something went wrong yo."],
      ksrCode: .UnknownCode,
      httpCode: 400,
      exception: nil
    )

    let errorEmptyMessage = ErrorEnvelope(
      errorMessages: [],
      ksrCode: nil,
      httpCode: 400,
      exception: nil
    )

    let defaultShippingRule = shippingRules.last!

    withEnvironment(
      apiService: MockService(changePaymentMethodResult: Result(error: errorUnknown)),
      config: .template |> Config.lens.countryCode .~ defaultShippingRule.location.country) {

        self.vm.inputs.configureWith(project: .template, reward: .template, applePayCapable: false)
        self.vm.inputs.viewDidLoad()

        self.scheduler.advance()

        self.vm.inputs.changePaymentMethodButtonTapped()

        self.showAlertMessage.assertValueCount(0)

        self.scheduler.advance()

        self.showAlertMessage.assertValues(["Something went wrong yo."])
        self.showAlertShouldDismiss.assertValues([true])
        self.dismissViewController.assertValueCount(0)

        self.vm.inputs.errorAlertTappedOK(shouldDismiss: true)

        self.dismissViewController.assertValueCount(1)

        withEnvironment(
          apiService: MockService(changePaymentMethodResult: Result(error: errorEmptyMessage)),
          config: .template |> Config.lens.countryCode .~ defaultShippingRule.location.country) {

            self.vm.inputs.configureWith(project: .template, reward: .template, applePayCapable: false)
            self.vm.inputs.viewDidLoad()

            self.scheduler.advance()

            self.vm.inputs.changePaymentMethodButtonTapped()

            self.showAlertMessage.assertValueCount(1)

            self.scheduler.advance()

            self.showAlertMessage.assertValues(
              ["Something went wrong yo.", Strings.general_error_something_wrong()]
            )
            self.showAlertShouldDismiss.assertValues([true, true])
            self.dismissViewController.assertValueCount(1)

            self.vm.inputs.errorAlertTappedOK(shouldDismiss: true)

            self.dismissViewController.assertValueCount(2)
        }
    }
  }

  func testUpdatePledgeErrors() {
    let errorUnknown = ErrorEnvelope(
      errorMessages: ["Something went wrong yo."],
      ksrCode: .UnknownCode,
      httpCode: 400,
      exception: nil
    )

    let errorEmptyMessage = ErrorEnvelope(
      errorMessages: [],
      ksrCode: nil,
      httpCode: 400,
      exception: nil
    )

    let defaultShippingRule = shippingRules.last!

    withEnvironment(
      apiService: MockService(updatePledgeResult: Result(error: errorUnknown)),
      config: .template |> Config.lens.countryCode .~ defaultShippingRule.location.country) {

        self.vm.inputs.configureWith(project: .template, reward: .template, applePayCapable: false)
        self.vm.inputs.viewDidLoad()

        self.scheduler.advance()

        self.vm.inputs.updatePledgeButtonTapped()

        self.showAlertMessage.assertValueCount(0)

        self.scheduler.advance()

        self.showAlertMessage.assertValues(["Something went wrong yo."])
        self.showAlertShouldDismiss.assertValues([true])
        self.dismissViewController.assertValueCount(0)

        self.vm.inputs.errorAlertTappedOK(shouldDismiss: true)

        self.dismissViewController.assertValueCount(1)

        withEnvironment(
          apiService: MockService(updatePledgeResult: Result(error: errorEmptyMessage)),
          config: .template |> Config.lens.countryCode .~ defaultShippingRule.location.country) {

            self.vm.inputs.configureWith(project: .template, reward: .template, applePayCapable: false)
            self.vm.inputs.viewDidLoad()

            self.scheduler.advance()

            self.vm.inputs.updatePledgeButtonTapped()

            self.showAlertMessage.assertValueCount(1)

            self.scheduler.advance()

            self.showAlertMessage.assertValues(
              ["Something went wrong yo.", Strings.general_error_something_wrong()]
            )
            self.showAlertShouldDismiss.assertValues([true, true])
            self.dismissViewController.assertValueCount(1)

            self.vm.inputs.errorAlertTappedOK(shouldDismiss: true)

            self.dismissViewController.assertValueCount(2)
        }
    }
  }

  func testApplePayPledgeErrors() {
    let errorUnknown = ErrorEnvelope(
      errorMessages: ["Something went wrong yo."],
      ksrCode: .UnknownCode,
      httpCode: 400,
      exception: nil
    )

    let errorEmptyMessage = ErrorEnvelope(
      errorMessages: [],
      ksrCode: nil,
      httpCode: 400,
      exception: nil
    )

    let defaultShippingRule = shippingRules.last!

    withEnvironment(
      apiService: MockService(createPledgeResult: Result(error: errorUnknown)),
      config: .template |> Config.lens.countryCode .~ defaultShippingRule.location.country) {

        self.vm.inputs.configureWith(project: .template, reward: .template, applePayCapable: true)
        self.vm.inputs.viewDidLoad()

        self.scheduler.advance()

        self.vm.inputs.applePayButtonTapped()
        self.vm.inputs.paymentAuthorizationWillAuthorizePayment()
        self.vm.inputs.paymentAuthorization(
          didAuthorizePayment: .init(
            tokenData: .init(
              paymentMethodData: .init(displayName: "AmEx", network: .amex, type: .credit),
              transactionIdentifier: "apple_pay_deadbeef"
            )
          )
        )
        _ = self.vm.inputs.stripeCreatedToken(stripeToken: "stripe_deadbeef", error: nil)

        self.showAlertMessage.assertValueCount(0)

        self.scheduler.advance()

        self.showAlertMessage.assertValues(["Something went wrong yo."])
        self.showAlertShouldDismiss.assertValues([true])
        self.dismissViewController.assertValueCount(0)

        self.vm.inputs.errorAlertTappedOK(shouldDismiss: true)

        self.dismissViewController.assertValueCount(1)

        withEnvironment(
          apiService: MockService(createPledgeResult: Result(error: errorEmptyMessage)),
          config: .template |> Config.lens.countryCode .~ defaultShippingRule.location.country) {

            self.vm.inputs.configureWith(project: .template, reward: .template, applePayCapable: false)
            self.vm.inputs.viewDidLoad()

            self.scheduler.advance()

            self.vm.inputs.applePayButtonTapped()
            self.vm.inputs.paymentAuthorizationWillAuthorizePayment()
            self.vm.inputs.paymentAuthorization(
              didAuthorizePayment: .init(
                tokenData: .init(
                  paymentMethodData: .init(displayName: "AmEx", network: .amex, type: .credit),
                  transactionIdentifier: "apple_pay_deadbeef"
                )
              )
            )
            _ = self.vm.inputs.stripeCreatedToken(stripeToken: "stripe_deadbeef", error: nil)

            self.showAlertMessage.assertValueCount(1)

            self.scheduler.advance()

            self.showAlertMessage.assertValues(
              ["Something went wrong yo.", Strings.general_error_something_wrong()]
            )
            self.showAlertShouldDismiss.assertValues([true, true])
            self.dismissViewController.assertValueCount(1)

            self.vm.inputs.errorAlertTappedOK(shouldDismiss: true)

            self.dismissViewController.assertValueCount(2)
        }
    }
  }

  func testNilShippingSummaryEmitsEmpty() {
    let reward = .template
      |> Reward.lens.shipping.summary .~ nil
    self.vm.inputs.configureWith(project: .template, reward: reward, applePayCapable: false)
    self.vm.inputs.viewDidLoad()

    self.shippingLocationsLabelText.assertValues([""])
  }
}
