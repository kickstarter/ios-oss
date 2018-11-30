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
  private let notifyMessageBannerPresent = TestObserver<String, NoError>()
  private let cardholderNameBecomeFirstResponder = TestObserver<Void, NoError>()
  private let dismissKeyboard = TestObserver<Void, NoError>()
  private let cardholderName = TestObserver<String, NoError>()
  private let cardNumber = TestObserver<String, NoError>()
  private let cardExpMonth = TestObserver<Int, NoError>()
  private let cardExpYear = TestObserver<Int, NoError>()
  private let cardCVC = TestObserver<String, NoError>()
  private let paymentDetailsBecomeFirstResponder = TestObserver<Void, NoError>()
  private let saveButtonIsEnabled = TestObserver<Bool, NoError>()
  private let setStripePublishableKey = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()
    self.vm.outputs.activityIndicatorShouldShow.observe(activityIndicatorShouldShow.observer)
    self.vm.outputs.addNewCardFailure.observe(addNewCardFailure.observer)
    self.vm.outputs.addNewCardSuccess.observe(addNewCardSuccess.observer)
    self.vm.outputs.notifyMessageBannerPresent.observe(notifyMessageBannerPresent.observer)
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

  func testBecomeFirstResponderAndSaveEnabled() {
    self.cardholderNameBecomeFirstResponder.assertDidNotEmitValue()
    self.paymentDetailsBecomeFirstResponder.assertDidNotEmitValue()
    self.saveButtonIsEnabled.assertDidNotEmitValue()

    self.vm.inputs.viewDidLoad()

    self.cardholderNameBecomeFirstResponder
      .assertValueCount(1, "Cardholder name field is first responder when view loads.")
    self.paymentDetailsBecomeFirstResponder.assertDidNotEmitValue("Not first responder when view loads")
    self.vm.inputs.cardholderNameChanged("")
    self.vm.inputs.paymentInfo(valid: false)
    self.saveButtonIsEnabled.assertValues([false], "Disabled form is incomplete")

    self.vm.inputs.cardholderNameChanged("Native Squad")
    self.vm.inputs.cardholderNameTextFieldReturn()
    self.cardholderNameBecomeFirstResponder
      .assertValueCount(1, "Does not emit again.")
    self.paymentDetailsBecomeFirstResponder
      .assertValueCount(1, "First responder after editing cardholder name.")
    self.saveButtonIsEnabled.assertValues([false, false], "Disabled while form is incomplete.")

    self.vm.inputs.paymentCardChanged(cardNumber: "4242 4242 4242 4242", expMonth: 11, expYear: 99, cvc: "123")
    self.vm.inputs.paymentCardTextFieldReturn()
    self.cardholderNameBecomeFirstResponder.assertValueCount(1, "Does not emit again.")
    self.paymentDetailsBecomeFirstResponder.assertValueCount(1, "Does not emit again.")
    self.vm.inputs.paymentInfo(valid: true)
    self.saveButtonIsEnabled.assertValues([false, false, true], "Enabled when form is valid.")
  }

  func testAddCard_Success() {
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.cardholderNameChanged("Native Squad")
    self.vm.inputs.cardholderNameTextFieldReturn()
    self.paymentDetailsBecomeFirstResponder.assertDidEmitValue()
    self.vm.inputs.paymentCardChanged(cardNumber: "4242 4242 4242 4242", expMonth: 11, expYear: 99, cvc: "123")
    self.vm.inputs.paymentInfo(valid: true)
    self.saveButtonIsEnabled.assertValues([true])

    self.vm.inputs.paymentCardTextFieldReturn()
    self.vm.inputs.saveButtonTapped()


    self.addNewCardSuccess.assertValues(["Got It!"])
    self.addNewCardFailure.assertValues(["Got It!"])
  }

}
