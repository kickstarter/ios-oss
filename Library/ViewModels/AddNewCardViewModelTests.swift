import Prelude
import ReactiveSwift
import Result
import XCTest
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers

internal final class AddNewCardViewModelTests: TestCase {
  private let vm: AddNewCardViewModelType = AddNewCardViewModel()

  private let activityIndicatorShouldShow = TestObserver<Bool, NoError>()
  private let addNewCardFailure = TestObserver<String, NoError>()
  private let addNewCardSuccess = TestObserver<String, NoError>()
  private let creditCardValidationErrorContainerHidden = TestObserver<Bool, NoError>()
  private let cardholderNameBecomeFirstResponder = TestObserver<Void, NoError>()
  private let dismissKeyboard = TestObserver<Void, NoError>()
  private let cardholderName = TestObserver<String, NoError>()
  private let cardNumber = TestObserver<String, NoError>()
  private let cardExpMonth = TestObserver<Month, NoError>()
  private let cardExpYear = TestObserver<Year, NoError>()
  private let cardCVC = TestObserver<String, NoError>()
  private let paymentDetailsBecomeFirstResponder = TestObserver<Void, NoError>()
  private let saveButtonIsEnabled = TestObserver<Bool, NoError>()
  private let setStripePublishableKey = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()
    self.vm.outputs.activityIndicatorShouldShow.observe(activityIndicatorShouldShow.observer)
    self.vm.outputs.addNewCardFailure.observe(addNewCardFailure.observer)
    self.vm.outputs.addNewCardSuccess.observe(addNewCardSuccess.observer)
    self.vm.outputs.creditCardValidationErrorContainerHidden
      .observe(creditCardValidationErrorContainerHidden.observer)
    self.vm.outputs.cardholderNameBecomeFirstResponder.observe(cardholderNameBecomeFirstResponder.observer)
    self.vm.outputs.dismissKeyboard.observe(dismissKeyboard.observer)
    self.vm.outputs.paymentDetails.map { $0.0 }.observe(cardholderName.observer)
    self.vm.outputs.paymentDetails.map { $0.1 }.observe(cardNumber.observer)
    self.vm.outputs.paymentDetails.map { $0.2 }.observe(cardExpMonth.observer)
    self.vm.outputs.paymentDetails.map { $0.3 }.observe(cardExpYear.observer)
    self.vm.outputs.paymentDetails.map { $0.4 }.observe(cardCVC.observer)
    self.vm.outputs.paymentDetailsBecomeFirstResponder.observe(paymentDetailsBecomeFirstResponder.observer)
    self.vm.outputs.saveButtonIsEnabled.observe(saveButtonIsEnabled.observer)
    self.vm.outputs.setStripePublishableKey.observe(setStripePublishableKey.observer)
  }

  func testAddCard_Success() {
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.cardholderNameChanged("Native Squad")
    self.vm.inputs.cardholderNameTextFieldReturn()
    self.paymentDetailsBecomeFirstResponder.assertDidEmitValue()
    self.vm.inputs.creditCardChanged(cardDetails: ("4242 4242 4242 4242", 11, 99, "123"))
    self.vm.inputs.paymentInfo(isValid: true)
    self.vm.inputs.cardBrand(isValid: true)
    self.saveButtonIsEnabled.assertValues([true])

    self.vm.inputs.saveButtonTapped()
    self.activityIndicatorShouldShow.assertValues([true])

    self.vm.inputs.stripeCreated("stripe_deadbeef", stripeID: "stripe_deadbeefID")

    self.scheduler.advance()

    self.addNewCardSuccess.assertValues([Strings.Got_it_your_changes_have_been_saved()])
    self.activityIndicatorShouldShow.assertValues([true, false])
  }

  func testAddCardFailure_InvalidToken() {
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.cardholderNameChanged("Native Squad")
    self.vm.inputs.cardholderNameTextFieldReturn()
    self.paymentDetailsBecomeFirstResponder.assertDidEmitValue()

    self.vm.inputs.creditCardChanged(cardDetails: ("4242 4242 4242 4242", 11, 99, "123"))
    self.vm.inputs.paymentInfo(isValid: true)
    self.vm.inputs.cardBrand(isValid: true)
    self.saveButtonIsEnabled.assertValues([true])

    self.vm.inputs.saveButtonTapped()
    self.activityIndicatorShouldShow.assertValues([true])

    let error = NSError(domain: "deadbeef", code: 1, userInfo: nil)

    self.vm.inputs.stripeError(error)
    self.scheduler.advance()

    self.addNewCardFailure.assertValues([error.localizedDescription])
    self.activityIndicatorShouldShow.assertValues([true, false])
  }

  func testAddCardFailure_GraphError() {
    let error = GraphError.emptyResponse(nil)

    withEnvironment(apiService: MockService(addNewCreditCardError: error)) {
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.cardholderNameChanged("Native Squad")
      self.vm.inputs.cardholderNameTextFieldReturn()
      self.paymentDetailsBecomeFirstResponder
        .assertValueCount(1, "First responder after editing cardholder name.")

      self.vm.inputs.creditCardChanged(cardDetails: ("4242 4242 4242 4242", 11, 99, "123"))
      self.vm.inputs.paymentInfo(isValid: true)
      self.vm.inputs.cardBrand(isValid: true)
      self.saveButtonIsEnabled.assertValues([true])
      self.vm.inputs.saveButtonTapped()
      self.activityIndicatorShouldShow.assertValues([true])
      self.vm.inputs.stripeCreated("stripe_deadbeef", stripeID: "stripe_deadbeefID")

      self.scheduler.advance()

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

    self.cardholderNameBecomeFirstResponder
      .assertValueCount(1, "Cardholder name field is first responder when view loads.")
    self.paymentDetailsBecomeFirstResponder.assertDidNotEmitValue("Not first responder when view loads")
    self.vm.inputs.cardholderNameChanged("")
    self.vm.inputs.paymentInfo(isValid: false)
    self.vm.inputs.cardBrand(isValid: false)
    self.saveButtonIsEnabled.assertValues([false], "Disabled form is incomplete")

    self.vm.inputs.cardholderNameChanged("Native Squad")
    self.vm.inputs.cardholderNameTextFieldReturn()
    self.cardholderNameBecomeFirstResponder
      .assertValueCount(1, "Does not emit again.")
    self.paymentDetailsBecomeFirstResponder
      .assertValueCount(1, "First responder after editing cardholder name.")
    self.saveButtonIsEnabled.assertValues([false], "Remains disabled while form is incomplete.")

    self.vm.inputs.creditCardChanged(cardDetails: ("4242 4242 4242 4242", 11, 99, "123"))
    self.cardholderNameBecomeFirstResponder.assertValueCount(1, "Does not emit again.")
    self.paymentDetailsBecomeFirstResponder.assertValueCount(1, "Does not emit again.")
    self.vm.inputs.paymentInfo(isValid: true)
    self.vm.inputs.cardBrand(isValid: true)
    self.saveButtonIsEnabled.assertValues([false, true], "Enabled when form is valid.")
  }

  func testSaveButtonEnabled() {
    self.saveButtonIsEnabled.assertDidNotEmitValue()
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.cardholderNameChanged("")
    self.vm.inputs.paymentInfo(isValid: false)
    self.vm.inputs.cardBrand(isValid: false)
    self.saveButtonIsEnabled.assertValues([false], "Disabled form is incomplete")

    self.vm.inputs.cardholderNameChanged("Native Squad")
    self.vm.inputs.paymentInfo(isValid: true)
    self.vm.inputs.cardBrand(isValid: true)

    self.saveButtonIsEnabled.assertValues([false, true], "Enabled when form is valid.")

    self.vm.inputs.paymentInfo(isValid: true)
    self.vm.inputs.cardBrand(isValid: false)

    self.saveButtonIsEnabled.assertValues([false, true, false], "Disabled if card brand is invalid")
  }

  func testSetPublishableKey() {
    withEnvironment(config: .template |> Config.lens.stripePublishableKey .~ "stripePublishableKey") {
      self.setStripePublishableKey.assertDidNotEmitValue()

      self.vm.inputs.viewDidLoad()

      self.setStripePublishableKey.assertValue("stripePublishableKey")
    }
  }

  func testDismissKeyboard() {
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.cardholderNameChanged("Native Squad")
    self.vm.inputs.paymentInfo(isValid: true)

    self.vm.inputs.saveButtonTapped()
    self.dismissKeyboard.assertDidEmitValue()
  }

  func testPaymentDetails() {
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.cardholderNameChanged("Native Squad")
    self.vm.inputs.creditCardChanged(cardDetails: ("4242 4242 4242 4242", 11, 99, "123"))
    self.cardholderName.assertDidNotEmitValue()
    self.cardNumber.assertDidNotEmitValue()
    self.cardExpMonth.assertDidNotEmitValue()
    self.cardExpYear.assertDidNotEmitValue()
    self.cardCVC.assertDidNotEmitValue()

    self.vm.inputs.saveButtonTapped()

    self.cardholderName.assertValues(["Native Squad"])
    self.cardNumber.assertValues(["4242 4242 4242 4242"])
    self.cardExpMonth.assertValues([11])
    self.cardExpYear.assertValues([99])
    self.cardCVC.assertValues(["123"])
  }

  func testTrackViewedAddNewCard() {
    self.vm.inputs.viewWillAppear()

    XCTAssertEqual(["Viewed Add New Card"], self.trackingClient.events)
  }

  func testTrackSavedPaymentMethod() {
    self.vm.inputs.paymentInfo(isValid: true)
    self.vm.inputs.stripeCreated("stripe_deadbeef", stripeID: "stripe_deadbeefID")

    self.scheduler.advance()

    XCTAssertEqual(["Saved Payment Method"], self.trackingClient.events)
  }

  func testTrackFailedPaymentMethodCreation() {
    let error = GraphError.emptyResponse(nil)
    withEnvironment(apiService: MockService(addNewCreditCardError: error)) {
      self.vm.inputs.stripeCreated("stripe_deadbeef", stripeID: "stripe_deadbeefID")

      self.scheduler.advance()

      XCTAssertEqual(["Failed Payment Method Creation"], self.trackingClient.events)
    }
  }

  func testUnsupportedCardMessage_HiddenOnViewDidLoad() {
    self.vm.inputs.viewDidLoad()

    self.creditCardValidationErrorContainerHidden
      .assertValues([true], "Unsupported card message is hidden on viewDidLoad")
  }

  func testUnsupportedCardMessage_showsWithInvalidCardBrand_AndExistingCardNumber() {
    self.vm.inputs.viewDidLoad()

    self.creditCardValidationErrorContainerHidden
      .assertValues([true], "Unsupported card message is hidden on viewDidLoad")

    self.vm.inputs.cardBrand(isValid: false)
    self.vm.inputs.creditCardChanged(cardDetails: ("123", nil, nil, nil))

    self.creditCardValidationErrorContainerHidden
      .assertValues([true, false], "Unsupported card message shows")
  }

  func testUnsupportedCardMessage_hidesWithValidCardBrand_AndExistingCardNumber() {
    self.vm.inputs.viewDidLoad()

    self.creditCardValidationErrorContainerHidden
      .assertValues([true], "Unsupported card message is hidden on viewDidLoad")

    self.vm.inputs.cardBrand(isValid: true)
    self.vm.inputs.creditCardChanged(cardDetails: ("123", nil, nil, nil))

    self.creditCardValidationErrorContainerHidden
      .assertValues([true, true], "Unsupported card message hides with a valid card brand")
  }

  func testUnsupportedCardMessage_hidesWithEmptyOrInvalidCardNumber() {
    self.vm.inputs.viewDidLoad()

    self.creditCardValidationErrorContainerHidden
      .assertValues([true], "Unsupported card message is hidden on viewDidLoad")

    self.vm.inputs.cardBrand(isValid: false)
    self.vm.inputs.creditCardChanged(cardDetails: ("", nil, nil, nil))

    self.creditCardValidationErrorContainerHidden
      .assertValues([true, true], "Unsupported card message stays hidden when the card number is < 2 digits")
  }
}
