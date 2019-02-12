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
  private let zipcode = TestObserver<String, NoError>()
  private let zipcodeTextFieldBecomeFirstResponder = TestObserver<Void, NoError>()

  override func setUp() {
    super.setUp()
    self.vm.outputs.activityIndicatorShouldShow.observe(self.activityIndicatorShouldShow.observer)
    self.vm.outputs.addNewCardFailure.observe(self.addNewCardFailure.observer)
    self.vm.outputs.addNewCardSuccess.observe(self.addNewCardSuccess.observer)
    self.vm.outputs.creditCardValidationErrorContainerHidden
      .observe(self.creditCardValidationErrorContainerHidden.observer)
    self.vm.outputs.cardholderNameBecomeFirstResponder
      .observe(self.cardholderNameBecomeFirstResponder.observer)
    self.vm.outputs.dismissKeyboard.observe(self.dismissKeyboard.observer)
    self.vm.outputs.paymentDetails.map { $0.0 }.observe(self.cardholderName.observer)
    self.vm.outputs.paymentDetails.map { $0.1 }.observe(self.cardNumber.observer)
    self.vm.outputs.paymentDetails.map { $0.2 }.observe(self.cardExpMonth.observer)
    self.vm.outputs.paymentDetails.map { $0.3 }.observe(self.cardExpYear.observer)
    self.vm.outputs.paymentDetails.map { $0.4 }.observe(self.cardCVC.observer)
    self.vm.outputs.paymentDetails.map { $0.5 }.observe(self.zipcode.observer)
  self.vm.outputs.paymentDetailsBecomeFirstResponder.observe(self.paymentDetailsBecomeFirstResponder.observer)
    self.vm.outputs.saveButtonIsEnabled.observe(self.saveButtonIsEnabled.observer)
    self.vm.outputs.setStripePublishableKey.observe(self.setStripePublishableKey.observer)
    self.vm.outputs.zipcodeTextFieldBecomeFirstResponder
      .observe(self.zipcodeTextFieldBecomeFirstResponder.observer)
  }

  func testZipcodeTextFieldReturn_submitsPaymentDetails() {
    withEnvironment(
      apiService: MockService(addNewCreditCardResult: .success(.paymentSourceSuccessTemplate))
    ) {
      self.vm.inputs.viewDidLoad()
      self.saveButtonIsEnabled.assertDidNotEmitValue()

      self.vm.inputs.cardholderNameChanged("Native Squad")
      self.vm.inputs.creditCardChanged(cardDetails: ("4242 4242 4242 4242", 11, 99, "123"))
      self.vm.inputs.paymentInfo(isValid: true)
      self.vm.inputs.cardBrand(isValid: true)
      self.vm.inputs.zipcodeChanged(zipcode: "123")

      self.saveButtonIsEnabled.assertValues([true])

      self.vm.inputs.zipcodeTextFieldDidEndEditing()

      self.activityIndicatorShouldShow.assertValues([true])

      self.vm.inputs.stripeCreated("stripe_deadbeef", stripeID: "stripe_deadbeefID")

      self.scheduler.advance()

      self.addNewCardSuccess.assertValues([Strings.Got_it_your_changes_have_been_saved()])
      self.activityIndicatorShouldShow.assertValues([true, false])
    }
  }

  func testAddCard_Success() {
    withEnvironment(
      apiService: MockService(addNewCreditCardResult: .success(.paymentSourceSuccessTemplate))
    ) {
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.cardholderNameChanged("Native Squad")
      self.vm.inputs.cardholderNameTextFieldReturn()
      self.paymentDetailsBecomeFirstResponder.assertDidEmitValue()
      self.vm.inputs.creditCardChanged(cardDetails: ("4242 4242 4242 4242", 11, 99, "123"))

      self.vm.inputs.paymentInfo(isValid: true)
      self.vm.inputs.cardBrand(isValid: true)
      self.vm.inputs.zipcodeChanged(zipcode: "123")
      self.saveButtonIsEnabled.assertValues([true])

      self.vm.inputs.saveButtonTapped()
      self.activityIndicatorShouldShow.assertValues([true])

      self.vm.inputs.stripeCreated("stripe_deadbeef", stripeID: "stripe_deadbeefID")

      self.scheduler.advance()

      self.addNewCardSuccess.assertValues([Strings.Got_it_your_changes_have_been_saved()])
      self.activityIndicatorShouldShow.assertValues([true, false])
    }
  }

  func testAddCardFailure_InvalidToken() {
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.cardholderNameChanged("Native Squad")
    self.vm.inputs.cardholderNameTextFieldReturn()
    self.paymentDetailsBecomeFirstResponder.assertDidEmitValue()

    self.vm.inputs.creditCardChanged(cardDetails: ("4242 4242 4242 4242", 11, 99, "123"))
    self.vm.inputs.paymentInfo(isValid: true)
    self.vm.inputs.cardBrand(isValid: true)
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

  func testAddCardFailure_GraphError() {
    let error = GraphError.emptyResponse(nil)

    withEnvironment(apiService: MockService(addNewCreditCardResult: .failure(.emptyResponse(nil)))) {
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.cardholderNameChanged("Native Squad")
      self.vm.inputs.cardholderNameTextFieldReturn()
      self.paymentDetailsBecomeFirstResponder
        .assertValueCount(1, "First responder after editing cardholder name.")

      self.vm.inputs.creditCardChanged(cardDetails: ("4242 4242 4242 4242", 11, 99, "123"))
      self.vm.inputs.paymentInfo(isValid: true)
      self.vm.inputs.cardBrand(isValid: true)
      self.vm.inputs.zipcodeChanged(zipcode: "123")
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
    self.zipcodeTextFieldBecomeFirstResponder.assertDidNotEmitValue()
    self.activityIndicatorShouldShow.assertDidNotEmitValue()
    self.saveButtonIsEnabled.assertDidNotEmitValue()

    self.vm.inputs.viewDidLoad()

    self.cardholderNameBecomeFirstResponder
      .assertValueCount(1, "Cardholder name field is first responder when view loads.")
    self.paymentDetailsBecomeFirstResponder.assertDidNotEmitValue("Not first responder when view loads")
    self.zipcodeTextFieldBecomeFirstResponder.assertDidNotEmitValue()
    self.vm.inputs.cardholderNameChanged("")
    self.vm.inputs.paymentInfo(isValid: false)
    self.vm.inputs.cardBrand(isValid: false)
    self.vm.inputs.zipcodeChanged(zipcode: "")
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
    self.vm.inputs.zipcodeChanged(zipcode: "123")
    self.saveButtonIsEnabled.assertValues([false, true], "Enabled when form is valid.")
  }

  func testSaveButtonEnabled() {
    self.saveButtonIsEnabled.assertDidNotEmitValue()
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.cardholderNameChanged("")
    self.saveButtonIsEnabled.assertDidNotEmitValue()

    self.vm.inputs.paymentInfo(isValid: false)
    self.vm.inputs.cardBrand(isValid: false)
    self.saveButtonIsEnabled.assertDidNotEmitValue()

    self.vm.inputs.zipcodeChanged(zipcode: "")
    self.saveButtonIsEnabled.assertValues([false], "Disabled form is incomplete")

    self.vm.inputs.cardholderNameChanged("Native Squad")
    self.vm.inputs.paymentInfo(isValid: true)
    self.vm.inputs.cardBrand(isValid: true)
    self.vm.inputs.zipcodeChanged(zipcode: "123")

    self.saveButtonIsEnabled.assertValues([false, true], "Enabled when form is valid.")

    self.vm.inputs.paymentInfo(isValid: true)
    self.vm.inputs.cardBrand(isValid: false)

    self.saveButtonIsEnabled.assertValues([false, true, false], "Disabled if card brand is invalid")

    self.vm.inputs.cardBrand(isValid: true)
    self.vm.inputs.zipcodeChanged(zipcode: "")

    self.saveButtonIsEnabled.assertValues([false, true, false, true, false], "Disabled if zipcode is empty")
  }

  func testSetPublishableKey() {
    self.setStripePublishableKey.assertDidNotEmitValue()

    self.vm.inputs.viewDidLoad()

    self.setStripePublishableKey.assertDidEmitValue()
  }

  func testDismissKeyboard() {
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.cardholderNameChanged("Native Squad")
    self.vm.inputs.paymentInfo(isValid: true)
    self.vm.inputs.cardBrand(isValid: true)
    self.vm.inputs.zipcodeChanged(zipcode: "123")

    self.vm.inputs.saveButtonTapped()
    self.dismissKeyboard.assertDidEmitValue()

    self.vm.inputs.zipcodeChanged(zipcode: "")

    self.vm.inputs.saveButtonTapped()
    self.dismissKeyboard.assertValueCount(1, "Keyboard does not dismiss if save button is disabled")

    self.vm.inputs.zipcodeChanged(zipcode: "123")
    self.vm.inputs.cardBrand(isValid: false)

    self.vm.inputs.saveButtonTapped()
    self.dismissKeyboard.assertValueCount(1, "Keyboard does not dismiss if save button is disabled")

    self.vm.inputs.cardBrand(isValid: true)

    self.vm.inputs.saveButtonTapped()
    self.dismissKeyboard.assertValueCount(2, "Keyboard dismisses when save button is enabled and tapped")
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

    self.vm.inputs.paymentInfo(isValid: true)
    self.vm.inputs.cardBrand(isValid: true)
    self.vm.inputs.zipcodeChanged(zipcode: "12345")

    self.vm.inputs.saveButtonTapped()

    self.cardholderName.assertValues(["Native Squad"])
    self.cardNumber.assertValues(["4242 4242 4242 4242"])
    self.cardExpMonth.assertValues([11])
    self.cardExpYear.assertValues([99])
    self.cardCVC.assertValues(["123"])
    self.zipcode.assertValues(["12345"])
  }

  func testTrackViewedAddNewCard() {
    self.vm.inputs.viewWillAppear()

    XCTAssertEqual(["Viewed Add New Card"], self.trackingClient.events)
  }

  func testTrackSavedPaymentMethod() {
    withEnvironment(
      apiService: MockService(addNewCreditCardResult: .success(.paymentSourceSuccessTemplate))
    ) {
      self.vm.inputs.paymentInfo(isValid: true)
      self.vm.inputs.stripeCreated("stripe_deadbeef", stripeID: "stripe_deadbeefID")

      self.scheduler.advance()

      XCTAssertEqual(["Saved Payment Method"], self.trackingClient.events)
    }
  }

  func testTrackFailedPaymentMethodCreation() {
    withEnvironment(apiService: MockService(addNewCreditCardResult: .failure(.emptyResponse(nil)))) {
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
