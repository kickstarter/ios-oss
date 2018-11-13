import Foundation
import XCTest
import ReactiveSwift
import Result
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers
import Prelude

internal final class PaymentMethodsViewModelTests: TestCase {

  let vm = PaymentMethodsViewModel()
  let goToAddCardScreen = TestObserver<Void, NoError>()
  let paymentMethods = TestObserver<[GraphUserCreditCard.CreditCard], NoError>()
  let showAlert = TestObserver<String, NoError>()
  let tableViewIsEditing = TestObserver<Bool, NoError>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.goToAddCardScreen.observe(self.goToAddCardScreen.observer)
    self.vm.outputs.paymentMethods.observe(self.paymentMethods.observer)
    self.vm.outputs.showAlert.observe(self.showAlert.observer)
    self.vm.outputs.tableViewIsEditing.observe(self.tableViewIsEditing.observer)
  }

  func testPaymentMethodsFetch_OnViewDidLoad() {
    let response = UserEnvelope<GraphUserCreditCard>(
      me: GraphUserCreditCard.template
    )
    let apiService = MockService(fetchGraphCreditCardsResponse: response)
    withEnvironment(apiService: apiService) {

      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.paymentMethods.assertValues([GraphUserCreditCard.template.storedCards.nodes])
    }
  }

  func testGoToAddCardScreenEmits_WhenAddNewCardIsTapped() {

    self.goToAddCardScreen.assertValueCount(0)

    self.vm.inputs.paymentMethodsFooterViewDidTapAddNewCardButton()

    self.goToAddCardScreen.assertValueCount(1, "Should emit after tapping button")
  }

  func testDeletePaymentMethod() {
    guard let card = GraphUserCreditCard.template.storedCards.nodes.first else {
      XCTFail("Card should exist")
      return
    }

    let apiService = MockService(deletePaymentMethodResult: .success(GraphMutationEmptyResponseEnvelope()))
    withEnvironment(apiService: apiService) {

      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.tableViewIsEditing.assertValues([])
      self.showAlert.assertValues([])
      self.paymentMethods.assertValues([GraphUserCreditCard.template.storedCards.nodes])

      self.vm.inputs.editButtonTapped()

      self.tableViewIsEditing.assertValues([true], "Editing mode enabled")
      self.showAlert.assertValues([])
      self.paymentMethods.assertValues([GraphUserCreditCard.template.storedCards.nodes])

      self.vm.inputs.didDelete(card)
      self.scheduler.advance()

      self.tableViewIsEditing.assertValues([true], "Editing mode remains enabled")
      self.showAlert.assertValues([], "No errors emitted")
      self.paymentMethods.assertValues(
        [GraphUserCreditCard.template.storedCards.nodes],
        "Emits once"
      )
    }
  }

  func testDeletePaymentMethod_Error() {
    guard let card = GraphUserCreditCard.template.storedCards.nodes.first else {
      XCTFail("Card should exist")
      return
    }

    let apiService = MockService(deletePaymentMethodResult: .failure(.invalidInput))
    withEnvironment(apiService: apiService) {

      self.vm.inputs.viewDidLoad()
      self.scheduler.advance()

      self.tableViewIsEditing.assertValues([])
      self.showAlert.assertValues([])
      self.paymentMethods.assertValues([GraphUserCreditCard.template.storedCards.nodes])

      self.vm.inputs.editButtonTapped()

      self.tableViewIsEditing.assertValues([true], "Editing mode enabled")
      self.showAlert.assertValues([])
      self.paymentMethods.assertValues([GraphUserCreditCard.template.storedCards.nodes])

      self.vm.inputs.didDelete(card)
      self.scheduler.advance()

      self.tableViewIsEditing.assertValues([true], "Editing mode remains enabled")
      self.showAlert.assertValues([
        "Something went wrong and we were unable to remove your credit card, please try again."
      ], "Error occurred")
      self.paymentMethods.assertValues(
        [GraphUserCreditCard.template.storedCards.nodes, GraphUserCreditCard.template.storedCards.nodes],
        "Emits again to reload the tableview after an error occurred"
      )
    }
  }
}
