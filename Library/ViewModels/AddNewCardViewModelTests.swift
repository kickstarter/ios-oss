@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class AddNewCardViewModelTests: TestCase {
  private let vm: AddNewCardViewModelType = AddNewCardViewModel()

  private let activityIndicatorShouldShow = TestObserver<Bool, Never>()
  private let addNewCardFailure = TestObserver<String, Never>()
  private let creditCardValidationErrorContainerHidden = TestObserver<Bool, Never>()
  private let cardholderNameBecomeFirstResponder = TestObserver<Void, Never>()
  private let dismissKeyboard = TestObserver<Void, Never>()
  private let cardholderName = TestObserver<String, Never>()
  private let cardNumber = TestObserver<String, Never>()
  private let cardExpMonth = TestObserver<Month, Never>()
  private let cardExpYear = TestObserver<Year, Never>()
  private let cardCVC = TestObserver<String, Never>()
  private let newCardAddedCard = TestObserver<UserCreditCards.CreditCard, Never>()
  private let newCardAddedMessage = TestObserver<String, Never>()
  private let paymentDetailsBecomeFirstResponder = TestObserver<Void, Never>()
  private let rememberThisCardToggleViewControllerContainerIsHidden = TestObserver<Bool, Never>()
  private let rememberThisCardToggleViewControllerIsOn = TestObserver<Bool, Never>()
  private let saveButtonIsEnabled = TestObserver<Bool, Never>()
  private let setStripePublishableKey = TestObserver<String, Never>()
  private let unsupportedCardBrandErrorText = TestObserver<String, Never>()
  private let zipcode = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()
    self.vm.outputs.activityIndicatorShouldShow.observe(self.activityIndicatorShouldShow.observer)
    self.vm.outputs.addNewCardFailure.observe(self.addNewCardFailure.observer)
    self.vm.outputs.creditCardValidationErrorContainerHidden
      .observe(self.creditCardValidationErrorContainerHidden.observer)
    self.vm.outputs.cardholderNameBecomeFirstResponder
      .observe(self.cardholderNameBecomeFirstResponder.observer)
    self.vm.outputs.dismissKeyboard.observe(self.dismissKeyboard.observer)
    self.vm.outputs.newCardAddedWithMessage.map(first).observe(self.newCardAddedCard.observer)
    self.vm.outputs.newCardAddedWithMessage.map(second).observe(self.newCardAddedMessage.observer)
    self.vm.outputs.paymentDetails.map { $0.0 }.observe(self.cardholderName.observer)
    self.vm.outputs.paymentDetails.map { $0.1 }.observe(self.cardNumber.observer)
    self.vm.outputs.paymentDetails.map { $0.2 }.observe(self.cardExpMonth.observer)
    self.vm.outputs.paymentDetails.map { $0.3 }.observe(self.cardExpYear.observer)
    self.vm.outputs.paymentDetails.map { $0.4 }.observe(self.cardCVC.observer)
    self.vm.outputs.paymentDetails.map { $0.5 }.observe(self.zipcode.observer)
    self.vm.outputs.paymentDetailsBecomeFirstResponder
      .observe(self.paymentDetailsBecomeFirstResponder.observer)
    self.vm.outputs.rememberThisCardToggleViewControllerContainerIsHidden
      .observe(self.rememberThisCardToggleViewControllerContainerIsHidden.observer)
    self.vm.outputs.rememberThisCardToggleViewControllerIsOn
      .observe(self.rememberThisCardToggleViewControllerIsOn.observer)
    self.vm.outputs.saveButtonIsEnabled.observe(self.saveButtonIsEnabled.observer)
    self.vm.outputs.setStripePublishableKey.observe(self.setStripePublishableKey.observer)
    self.vm.outputs.unsupportedCardBrandErrorText.observe(self.unsupportedCardBrandErrorText.observer)
  }

  func testZipcodeTextFieldReturn_submitsPaymentDetails() {
    withEnvironment(
      apiService: MockService(addNewCreditCardResult: .success(.paymentSourceSuccessTemplate))
    ) {
      self.vm.inputs.configure(with: .settings, project: nil)
      self.vm.inputs.viewDidLoad()
      self.saveButtonIsEnabled.assertDidNotEmitValue()

      self.vm.inputs.cardholderNameChanged("Native Squad")
      self.vm.inputs.paymentInfo(isValid: true)
      self.vm.inputs.creditCardChanged(cardDetails: ("3782 822463 10005", 11, 99, "123", .visa))
      self.vm.inputs.zipcodeChanged(zipcode: "123")

      self.saveButtonIsEnabled.assertValues([true])

      self.vm.inputs.zipcodeTextFieldDidEndEditing()

      self.activityIndicatorShouldShow.assertValues([true])

      self.vm.inputs.stripeCreated("stripe_deadbeef", stripeID: "stripe_deadbeefID")

      self.scheduler.advance()

      self.newCardAddedCard.assertValues([UserCreditCards.amex])
      self.newCardAddedMessage.assertValues([Strings.Got_it_your_changes_have_been_saved()])
      self.activityIndicatorShouldShow.assertValues([true, false])
    }
  }

  func testAddCard_Success() {
    withEnvironment(
      apiService: MockService(addNewCreditCardResult: .success(.paymentSourceSuccessTemplate))
    ) {
      self.vm.inputs.configure(with: .settings, project: nil)
      self.vm.inputs.viewDidLoad()

      self.vm.inputs.cardholderNameChanged("Native Squad")
      self.vm.inputs.cardholderNameTextFieldReturn()
      self.paymentDetailsBecomeFirstResponder.assertDidEmitValue()
      self.vm.inputs.creditCardChanged(cardDetails: ("3782 822463 10005", 11, 99, "123", .amex))

      self.vm.inputs.paymentInfo(isValid: true)
      self.vm.inputs.zipcodeChanged(zipcode: "123")
      self.saveButtonIsEnabled.assertValues([true])

      self.vm.inputs.saveButtonTapped()
      self.activityIndicatorShouldShow.assertValues([true])

      self.vm.inputs.stripeCreated("stripe_deadbeef", stripeID: "stripe_deadbeefID")

      self.scheduler.advance()

      self.newCardAddedCard.assertValues([UserCreditCards.amex])
      self.newCardAddedMessage.assertValues([Strings.Got_it_your_changes_have_been_saved()])
      self.activityIndicatorShouldShow.assertValues([true, false])
    }
  }

  func testAddCardFailure_InvalidToken() {
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.configure(with: .settings, project: nil)
    self.vm.inputs.cardholderNameChanged("Native Squad")
    self.vm.inputs.cardholderNameTextFieldReturn()
    self.paymentDetailsBecomeFirstResponder.assertDidEmitValue()

    self.vm.inputs.creditCardChanged(cardDetails: ("4242 4242 4242 4242", 11, 99, "123", .visa))
    self.vm.inputs.paymentInfo(isValid: true)
    self.vm.inputs.zipcodeChanged(zipcode: "123")
    self.saveButtonIsEnabled.assertValues([true])

    self.vm.inputs.saveButtonTapped()
    self.activityIndicatorShouldShow.assertValues([true])

    let error = NSError(domain: "deadbeef", code: 1, userInfo: nil)

    self.vm.inputs.stripeError(error)
    self.scheduler.advance()

    self.addNewCardFailure.assertValues([error.localizedDescription])
    self.activityIndicatorShouldShow.assertValues([true, false])
  }

  func testAddCardFailure_ErrorEnvelope() {
    let error = ErrorEnvelope.couldNotParseJSON

    withEnvironment(apiService: MockService(addNewCreditCardResult: .failure(.couldNotParseJSON))) {
      self.vm.inputs.configure(with: .settings, project: nil)
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.cardholderNameChanged("Native Squad")
      self.vm.inputs.cardholderNameTextFieldReturn()
      self.paymentDetailsBecomeFirstResponder
        .assertValueCount(1, "First responder after editing cardholder name.")

      self.vm.inputs.creditCardChanged(cardDetails: ("4242 4242 4242 4242", 11, 99, "123", .visa))
      self.vm.inputs.paymentInfo(isValid: true)
      self.vm.inputs.zipcodeChanged(zipcode: "123")
      self.saveButtonIsEnabled.assertValues([true])
      self.vm.inputs.saveButtonTapped()
      self.activityIndicatorShouldShow.assertValues([true])
      self.vm.inputs.stripeCreated("stripe_deadbeef", stripeID: "stripe_deadbeefID")

      self.scheduler.advance()

      self.newCardAddedCard.assertValues([])
      self.newCardAddedMessage.assertValues([])
      self.addNewCardFailure.assertValues([error.localizedDescription])
      self.activityIndicatorShouldShow.assertValues([true, false])
    }
  }

  func testBecomeFirstResponder() {
    self.cardholderNameBecomeFirstResponder.assertDidNotEmitValue()
    self.paymentDetailsBecomeFirstResponder.assertDidNotEmitValue()
    self.activityIndicatorShouldShow.assertDidNotEmitValue()
    self.saveButtonIsEnabled.assertDidNotEmitValue()

    self.vm.inputs.viewDidLoad()
    self.vm.inputs.configure(with: .settings, project: nil)

    self.cardholderNameBecomeFirstResponder
      .assertValueCount(1, "Cardholder name field is first responder when view loads.")
    self.paymentDetailsBecomeFirstResponder.assertDidNotEmitValue("Not first responder when view loads")
    self.vm.inputs.cardholderNameChanged("")
    self.vm.inputs.paymentInfo(isValid: false)
    self.vm.inputs.zipcodeChanged(zipcode: "")
    self.saveButtonIsEnabled.assertDidNotEmitValue()

    self.vm.inputs.cardholderNameChanged("Native Squad")
    self.vm.inputs.cardholderNameTextFieldReturn()
    self.cardholderNameBecomeFirstResponder
      .assertValueCount(1, "Does not emit again.")
    self.paymentDetailsBecomeFirstResponder
      .assertValueCount(1, "First responder after editing cardholder name.")
    self.saveButtonIsEnabled.assertDidNotEmitValue()

    self.vm.inputs.creditCardChanged(cardDetails: ("4242 4242 4242 4242", 11, 99, "123", .visa))
    self.saveButtonIsEnabled.assertValues([false], "Disabled form is incomplete")
    self.cardholderNameBecomeFirstResponder.assertValueCount(1, "Does not emit again.")
    self.paymentDetailsBecomeFirstResponder.assertValueCount(1, "Does not emit again.")
    self.vm.inputs.paymentInfo(isValid: true)
    self.vm.inputs.zipcodeChanged(zipcode: "123")
    self.saveButtonIsEnabled.assertValues([false, true], "Enabled when form is valid.")
  }

  func testSaveButtonEnabled() {
    self.saveButtonIsEnabled.assertDidNotEmitValue()
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.configure(with: .settings, project: nil)

    self.vm.inputs.cardholderNameChanged("")
    self.saveButtonIsEnabled.assertDidNotEmitValue()

    self.vm.inputs.paymentInfo(isValid: false)
    self.saveButtonIsEnabled.assertDidNotEmitValue()

    self.vm.inputs.zipcodeChanged(zipcode: "")

    self.vm.inputs.cardholderNameChanged("Native Squad")
    self.vm.inputs.paymentInfo(isValid: false)
    self.vm.inputs.creditCardChanged(cardDetails: ("6200 0000 0000 0005", 11, 99, "123", .unionPay))
    self.saveButtonIsEnabled.assertValues([false], "Disabled form is incomplete")

    self.vm.inputs.zipcodeChanged(zipcode: "123")
    self.vm.inputs.paymentInfo(isValid: true)
    self.vm.inputs.creditCardChanged(cardDetails: ("4242 4242 4242 4242", 11, 99, "123", .visa))

    self.saveButtonIsEnabled.assertValues([false, true], "Enabled when form is valid.")
  }

  func testSetPublishableKey() {
    self.setStripePublishableKey.assertDidNotEmitValue()

    self.vm.inputs.viewDidLoad()

    self.setStripePublishableKey.assertDidEmitValue()
  }

  func testDismissKeyboard() {
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.configure(with: .settings, project: nil)

    self.vm.inputs.cardholderNameChanged("Native Squad")
    self.vm.inputs.paymentInfo(isValid: true)
    self.vm.inputs.creditCardChanged(cardDetails: ("4242 4242 4242 4242", 11, 99, "123", .visa))
    self.vm.inputs.zipcodeChanged(zipcode: "123")

    self.vm.inputs.saveButtonTapped()
    self.dismissKeyboard.assertDidEmitValue()

    self.vm.inputs.zipcodeChanged(zipcode: "")

    self.vm.inputs.saveButtonTapped()
    self.dismissKeyboard.assertValueCount(1, "Keyboard does not dismiss if save button is disabled")

    self.vm.inputs.zipcodeChanged(zipcode: "123")

    self.vm.inputs.saveButtonTapped()
    self.dismissKeyboard.assertValueCount(2, "Keyboard does not dismiss if save button is disabled")

    self.vm.inputs.saveButtonTapped()
    self.dismissKeyboard.assertValueCount(3, "Keyboard dismisses when save button is enabled and tapped")
  }

  func testPaymentDetails() {
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.configure(with: .settings, project: nil)

    self.vm.inputs.cardholderNameChanged("Native Squad")
    self.vm.inputs.creditCardChanged(cardDetails: ("4242 4242 4242 4242", 11, 99, "123", .visa))
    self.cardholderName.assertDidNotEmitValue()
    self.cardNumber.assertDidNotEmitValue()
    self.cardExpMonth.assertDidNotEmitValue()
    self.cardExpYear.assertDidNotEmitValue()
    self.cardCVC.assertDidNotEmitValue()

    self.vm.inputs.paymentInfo(isValid: true)
    self.vm.inputs.zipcodeChanged(zipcode: "12345")

    self.vm.inputs.saveButtonTapped()

    self.cardholderName.assertValues(["Native Squad"])
    self.cardNumber.assertValues(["4242 4242 4242 4242"])
    self.cardExpMonth.assertValues([11])
    self.cardExpYear.assertValues([99])
    self.cardCVC.assertValues(["123"])
    self.zipcode.assertValues(["12345"])
  }

  func testUnsupportedCardMessage_HiddenOnViewDidLoad_withPledgeIntent() {
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.configure(with: .pledge, project: Project.template)

    self.creditCardValidationErrorContainerHidden
      .assertValues([true], "Unsupported card message is hidden on viewDidLoad")
    self.unsupportedCardBrandErrorText.assertDidNotEmitValue()
  }

  func testUnsupportedCardMessage_HiddenOnViewDidLoad_withSettingsIntent() {
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.configure(with: .settings, project: nil)

    self.creditCardValidationErrorContainerHidden
      .assertValues([true], "Unsupported card message is hidden on viewDidLoad")
    self.unsupportedCardBrandErrorText.assertDidNotEmitValue()
  }

  func testUnsupportedCardMessage_showsWithInvalidCardBrand_AndExistingCardNumber_withPledgeIntent() {
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.configure(with: .pledge, project: Project.template)

    self.creditCardValidationErrorContainerHidden
      .assertValues([true], "Unsupported card message is hidden on viewDidLoad")

    self.vm.inputs.creditCardChanged(cardDetails: ("123", nil, nil, nil, .generic))

    self.creditCardValidationErrorContainerHidden
      .assertValues([true, false], "Unsupported card message shows")
    self.unsupportedCardBrandErrorText
      .assertValues(
        ["You can’t use this credit card to back a project from Brooklyn, NY."],
        "Card is unsupported"
      )
  }

  func testUnsupportedCardMessage_showsWithInvalidCardBrand_AndExistingCardNumber_withSettingsIntent() {
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.configure(with: .settings, project: nil)

    self.creditCardValidationErrorContainerHidden
      .assertValues([true], "Unsupported card message is hidden on viewDidLoad")

    self.vm.inputs.creditCardChanged(cardDetails: ("123", nil, nil, nil, .generic))

    self.creditCardValidationErrorContainerHidden
      .assertValues([true, false], "Unsupported card message shows")
    self.unsupportedCardBrandErrorText
      .assertValues(
        ["We don't accept this card type. Please try again with another one."],
        "Card is unsupported"
      )
  }

  func testUnsupportedCardMessage_hidesWithValidCardBrand_AndExistingCardNumber_withPledgeIntent() {
    let project = Project.template
      |> Project.lens.location .~ .australia
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.configure(with: .pledge, project: project)

    self.creditCardValidationErrorContainerHidden
      .assertValues([true], "Unsupported card message is hidden on viewDidLoad")

    self.vm.inputs.creditCardChanged(cardDetails: ("424", nil, nil, nil, .visa))

    self.creditCardValidationErrorContainerHidden
      .assertValues([true, true], "Unsupported card message hides with a valid card brand")
  }

  func testUnsupportedCardMessage_hidesWithValidCardBrand_AndExistingCardNumber_withSettingsIntent() {
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.configure(with: .settings, project: nil)

    self.creditCardValidationErrorContainerHidden
      .assertValues([true], "Unsupported card message is hidden on viewDidLoad")

    self.vm.inputs.creditCardChanged(cardDetails: ("424", nil, nil, nil, .visa))

    self.creditCardValidationErrorContainerHidden
      .assertValues([true, true], "Unsupported card message hides with a valid card brand")
  }

  func testUnsupportedCardMessage_hidesWithEmptyOrInvalidCardNumber_withPledgeIntent() {
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.configure(with: .pledge, project: Project.template)

    self.creditCardValidationErrorContainerHidden
      .assertValues([true], "Unsupported card message is hidden on viewDidLoad")

    self.vm.inputs.creditCardChanged(cardDetails: ("1", nil, nil, nil, .generic))

    self.creditCardValidationErrorContainerHidden
      .assertValues([true, true], "Unsupported card message stays hidden when the card number is < 2 digits")
    self.unsupportedCardBrandErrorText.assertValueCount(1)
  }

  func testUnsupportedCardMessage_hidesWithEmptyOrInvalidCardNumber_withSettingsIntent() {
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.configure(with: .settings, project: nil)

    self.creditCardValidationErrorContainerHidden
      .assertValues([true], "Unsupported card message is hidden on viewDidLoad")

    self.vm.inputs.creditCardChanged(cardDetails: ("1", nil, nil, nil, .generic))

    self.creditCardValidationErrorContainerHidden
      .assertValues([true, true], "Unsupported card message stays hidden when the card number is < 2 digits")
    self.unsupportedCardBrandErrorText.assertValueCount(1)
  }

  func testReusableCardSwitchIsHidden() {
    self.rememberThisCardToggleViewControllerContainerIsHidden.assertValueCount(0)

    self.vm.inputs.viewDidLoad()

    self.rememberThisCardToggleViewControllerContainerIsHidden.assertValueCount(0)

    self.vm.inputs.configure(with: .settings, project: nil)

    self.rememberThisCardToggleViewControllerContainerIsHidden.assertValues([true])

    self.vm.inputs.configure(with: .pledge, project: Project.template)

    self.rememberThisCardToggleViewControllerContainerIsHidden.assertValues([true, false])
  }

  func testReusableCardSwitchisOffByDefault_Pledge() {
    self.rememberThisCardToggleViewControllerIsOn.assertDidNotEmitValue()

    self.vm.inputs.configure(with: .pledge, project: Project.template)
    self.vm.inputs.viewDidLoad()

    self.rememberThisCardToggleViewControllerIsOn.assertValues([false])
  }

  func testReusableCardSwitchisOnByDefault_Settings() {
    self.rememberThisCardToggleViewControllerIsOn.assertDidNotEmitValue()

    self.vm.inputs.configure(with: .settings, project: nil)
    self.vm.inputs.viewDidLoad()

    self.rememberThisCardToggleViewControllerIsOn.assertValues([true])
  }

  func testUnsupportedCardBrandsError_withPledgeIntent() {
    let project = Project.cosmicSurgery
      |> Project.lens.availableCardTypes .~ [
        "AMEX",
        "MASTERCARD",
        "VISA",
        "UNION_PAY"
      ]

    self.vm.inputs.viewDidLoad()
    self.vm.inputs.configure(with: .pledge, project: project)

    self.creditCardValidationErrorContainerHidden
      .assertValues([true], "Unsupported card message is hidden on viewDidLoad")

    self.vm.inputs.creditCardChanged(cardDetails: ("3566", nil, nil, nil, .jcb))

    self.creditCardValidationErrorContainerHidden
      .assertValues([true, false], "Unsupported card message hides with a valid card brand")
    self.unsupportedCardBrandErrorText
      .assertValues(
        ["You can’t use this credit card to back a project from Hastings, UK."],
        "Card is unsupported"
      )
  }
}
