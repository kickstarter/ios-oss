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
  let editButtonIsEnabled = TestObserver<Bool, NoError>()
  let goToAddCardScreen = TestObserver<Void, NoError>()
  let paymentMethods = TestObserver<[GraphUserCreditCard.CreditCard], NoError>()
  let presentBanner = TestObserver<String, NoError>()
  let showAlert = TestObserver<String, NoError>()
  let tableViewIsEditing = TestObserver<Bool, NoError>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.editButtonIsEnabled.observe(self.editButtonIsEnabled.observer)
    self.vm.outputs.goToAddCardScreen.observe(self.goToAddCardScreen.observer)
    self.vm.outputs.paymentMethods.observe(self.paymentMethods.observer)
    self.vm.outputs.presentBanner.observe(self.presentBanner.observer)
    self.vm.outputs.showAlert.observe(self.showAlert.observer)
    self.vm.outputs.tableViewIsEditing.observe(self.tableViewIsEditing.observer)
  }

  func testPaymentMethodsFetch_OnViewDidLoad() {
    let response = UserEnvelope<GraphUserCreditCard>(
      me: GraphUserCreditCard.template
    )
    let apiService = MockService(fetchGraphCreditCardsResponse: response)
    withEnvironment(apiService: apiService) {

      self.vm.inputs.viewWillAppear()
      self.scheduler.advance()

      self.paymentMethods.assertValues([GraphUserCreditCard.template.storedCards.nodes])
    }
  }

  func testEditButtonIsNotEnabled_OnViewDidLoad() {

    self.editButtonIsEnabled.assertDidNotEmitValue()
    self.vm.viewDidLoad()
    self.editButtonIsEnabled.assertValue(false)
  }

  func testEditButtonIsEnabled_HasPaymentMethods() {
    let response = UserEnvelope<GraphUserCreditCard>(
      me: GraphUserCreditCard.template
    )
    let apiService = MockService(fetchGraphCreditCardsResponse: response)
    withEnvironment(apiService: apiService) {

      self.editButtonIsEnabled.assertDidNotEmitValue()

      self.vm.inputs.viewDidLoad()
      self.editButtonIsEnabled.assertValues([false])

      self.vm.inputs.viewWillAppear()
      self.scheduler.advance()

      self.editButtonIsEnabled.assertValues([false, true])
    }
  }

  func testEditButtonIsNotEnabled_NoPaymentMethods() {
    let response = UserEnvelope<GraphUserCreditCard>(
      me: GraphUserCreditCard.emptyTemplate
    )
    let apiService = MockService(fetchGraphCreditCardsResponse: response)
    withEnvironment(apiService: apiService) {

      self.editButtonIsEnabled.assertDidNotEmitValue()
      self.vm.inputs.viewDidLoad()

      self.editButtonIsEnabled.assertValues([false])

      self.vm.inputs.viewWillAppear()
      self.scheduler.advance()

      self.editButtonIsEnabled.assertValues([false, false])
    }
  }

  func testEditButtonNotEnabled_AfterDeleteLastPaymentMethod() {

    guard let card = GraphUserCreditCard.template.storedCards.nodes.first else {
      XCTFail("Card should exist")
      return
    }

    let apiService = MockService(deletePaymentMethodResult: .success(.init(totalCount: 0)))
    withEnvironment(apiService: apiService) {
      self.editButtonIsEnabled.assertDidNotEmitValue()
      self.vm.inputs.viewDidLoad()
      self.editButtonIsEnabled.assertValues([false])

      self.vm.inputs.didDelete(card)
      self.scheduler.advance()

      self.editButtonIsEnabled.assertValues([false, false])
    }
  }

  func testEditButtonEnabled_AfterDeletePaymentMethod() {

    guard let card = GraphUserCreditCard.template.storedCards.nodes.first else {
      XCTFail("Card should exist")
      return
    }

    let apiService = MockService(deletePaymentMethodResult: .success(.init(totalCount: 3)))
    withEnvironment(apiService: apiService) {
      self.editButtonIsEnabled.assertDidNotEmitValue()
      self.vm.inputs.viewDidLoad()
      self.editButtonIsEnabled.assertValues([false])

      self.vm.inputs.didDelete(card)
      self.scheduler.advance()

      self.editButtonIsEnabled.assertValues([false, true])
    }
  }

  func testGoToAddCardScreenEmits_WhenAddNewCardIsTapped() {
    self.goToAddCardScreen.assertValueCount(0)

    self.vm.inputs.paymentMethodsFooterViewDidTapAddNewCardButton()

    self.goToAddCardScreen.assertValueCount(1, "Should emit after tapping button")
  }

  func testTableViewIsEditing_isFalse_WhenAddNewCardIsTapped() {
    self.tableViewIsEditing.assertValueCount(0)

    self.vm.inputs.editButtonTapped()

    self.tableViewIsEditing.assertValues([true])

    self.vm.inputs.paymentMethodsFooterViewDidTapAddNewCardButton()

    self.tableViewIsEditing.assertValues([true, false])
  }

  func testPresentMessageBanner() {
    self.presentBanner.assertValues([])

    self.vm.inputs.cardAddedSuccessfully(Strings.Got_it_your_changes_have_been_saved())

    self.vm.inputs.viewWillAppear()

    self.presentBanner.assertValues([Strings.Got_it_your_changes_have_been_saved()])
  }

  func testDeletePaymentMethod() {
    guard let card = GraphUserCreditCard.template.storedCards.nodes.first else {
      XCTFail("Card should exist")
      return
    }

    let apiService = MockService(deletePaymentMethodResult: .success(.init(totalCount: 2)))
    withEnvironment(apiService: apiService) {

      self.vm.inputs.viewWillAppear()
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

      self.vm.inputs.viewWillAppear()
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
        "Something went wrong and we were unable to remove your payment method, please try again."])
      self.paymentMethods.assertValues(
        [GraphUserCreditCard.template.storedCards.nodes, GraphUserCreditCard.template.storedCards.nodes],
        "Emits again to reload the tableview after an error occurred"
      )
    }
  }

  func testTrackPaymentMethodsView() {
    XCTAssertEqual([], self.trackingClient.events)
    self.vm.inputs.viewWillAppear()
    XCTAssertEqual(["Viewed Payment Methods"], self.trackingClient.events)
  }

  func testTrackDeletePaymentMethods() {
    guard let card = GraphUserCreditCard.template.storedCards.nodes.first else {
      XCTFail("Card should exist")
      return
    }
    let apiService = MockService(deletePaymentMethodResult: .success(.init(totalCount: 2)))
    withEnvironment(apiService: apiService) {

      self.vm.inputs.viewDidLoad()

      self.vm.inputs.didDelete(card)
      self.scheduler.advance()

      XCTAssertEqual(["Deleted Payment Method"], self.trackingClient.events)
    }
  }

  func testTrackDeletePaymentMethodError() {
    guard let card = GraphUserCreditCard.template.storedCards.nodes.first else {
      XCTFail("Card should exist")
      return
    }
    let apiService = MockService(deletePaymentMethodResult: .failure(.invalidInput))
    withEnvironment(apiService: apiService) {

      self.vm.inputs.viewDidLoad()

      self.vm.inputs.didDelete(card)
      self.scheduler.advance()

      XCTAssertEqual(["Errored Delete Payment Method"], self.trackingClient.events)
    }
  }
}
