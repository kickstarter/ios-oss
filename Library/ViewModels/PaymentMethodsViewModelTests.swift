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
  let reloadData = TestObserver<Void, NoError>()
  let showAlert = TestObserver<String, NoError>()
  let tableViewIsEditing = TestObserver<Bool, NoError>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.editButtonIsEnabled.observe(self.editButtonIsEnabled.observer)
    self.vm.outputs.goToAddCardScreen.observe(self.goToAddCardScreen.observer)
    self.vm.outputs.paymentMethods.observe(self.paymentMethods.observer)
    self.vm.outputs.presentBanner.observe(self.presentBanner.observer)
    self.vm.outputs.reloadData.observe(self.reloadData.observer)
    self.vm.outputs.showAlert.observe(self.showAlert.observer)
    self.vm.outputs.tableViewIsEditing.observe(self.tableViewIsEditing.observer)
  }

  func testPaymentMethodsFetch_OnViewDidLoad() {
    let response = UserEnvelope<GraphUserCreditCard>(me: GraphUserCreditCard.template)
    let apiService = MockService(fetchGraphCreditCardsResponse: response)

    withEnvironment(apiService: apiService) {
      self.vm.inputs.viewDidLoad()

      self.reloadData.assertDidEmitValue()

      self.scheduler.advance()

      self.paymentMethods.assertValues([GraphUserCreditCard.template.storedCards.nodes])
    }
  }

  func testPaymentMethodsFetch_OnAddNewCardSucceeded() {
    let response = UserEnvelope<GraphUserCreditCard>(me: GraphUserCreditCard.template)
    let apiService = MockService(fetchGraphCreditCardsResponse: response)

    withEnvironment(apiService: apiService) {
      self.paymentMethods.assertValues([])

      self.vm.inputs.addNewCardSucceeded(with: "First card added successfully")

      self.scheduler.advance()

      self.paymentMethods.assertValueCount(1)

      withEnvironment(apiService: apiService) {
        self.vm.inputs.addNewCardSucceeded(with: "Second card added successfully")

        self.scheduler.advance()

        self.paymentMethods.assertValueCount(2)
      }
    }
  }

  func testPaymentMethodsFetch_OnAddNewCardDismissed() {
    let response = UserEnvelope<GraphUserCreditCard>(me: GraphUserCreditCard.template)
    let apiService = MockService(fetchGraphCreditCardsResponse: response)

    withEnvironment(apiService: apiService) {
      self.paymentMethods.assertValues([])

      self.vm.inputs.addNewCardDismissed()

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

  func testEditButtonEnabled_AfterDeletePaymentMethod() {
    guard let card = GraphUserCreditCard.template.storedCards.nodes.first else {
      XCTFail("Card should exist")
      return
    }

    let result = DeletePaymentMethodEnvelope.init(storedCards: [card])
    
    let apiService = MockService(deletePaymentMethodResult: .success(result))
    withEnvironment(apiService: apiService) {
      self.editButtonIsEnabled.assertDidNotEmitValue()

      self.vm.inputs.viewDidLoad()

      self.editButtonIsEnabled.assertValues([false])

      self.scheduler.advance()

      self.editButtonIsEnabled.assertValues([false, true])

      self.vm.inputs.didDelete(card, visibleCellCount: 1)

      self.editButtonIsEnabled.assertValues([false, true, true])

      self.scheduler.advance()

      self.editButtonIsEnabled.assertValues([false, true, true, true])
    }
  }

  func testEditButtonNotEnabled_AfterDeleteLastPaymentMethod() {

    guard let card = GraphUserCreditCard.template.storedCards.nodes.first else {
      XCTFail("Card should exist")
      return
    }

    let result = DeletePaymentMethodEnvelope.init(storedCards: [])

    let apiService = MockService(deletePaymentMethodResult: .success(result))
    withEnvironment(apiService: apiService) {
      self.editButtonIsEnabled.assertDidNotEmitValue()

      self.vm.inputs.viewDidLoad()

      self.editButtonIsEnabled.assertValues([false])

      self.scheduler.advance()

      self.editButtonIsEnabled.assertValues([false, true])

      self.vm.inputs.didDelete(card, visibleCellCount: 0)

      self.editButtonIsEnabled.assertValues([false, true, false])

      self.scheduler.advance()

      self.editButtonIsEnabled.assertValues([false, true, false, false])
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

    self.vm.inputs.addNewCardSucceeded(with: Strings.Got_it_your_changes_have_been_saved())

    self.vm.inputs.viewWillAppear()

    self.presentBanner.assertValues([Strings.Got_it_your_changes_have_been_saved()])
  }

  func testDeletePaymentMethod() {
    guard let card = GraphUserCreditCard.template.storedCards.nodes.first else {
      XCTFail("Card should exist")
      return
    }

    let result = DeletePaymentMethodEnvelope.init(storedCards: GraphUserCreditCard.template.storedCards.nodes)

    let apiService = MockService(deletePaymentMethodResult: .success(result))
    withEnvironment(apiService: apiService) {

      self.vm.inputs.viewDidLoad()
      self.vm.inputs.viewWillAppear()

      self.scheduler.advance()

      self.tableViewIsEditing.assertValues([false])
      self.showAlert.assertValues([])
      self.paymentMethods.assertValues([GraphUserCreditCard.template.storedCards.nodes])

      self.vm.inputs.editButtonTapped()

      self.tableViewIsEditing.assertValues([false, true], "Editing mode enabled")
      self.showAlert.assertValues([])
      self.paymentMethods.assertValues([GraphUserCreditCard.template.storedCards.nodes])

      self.vm.inputs.didDelete(card, visibleCellCount: 1)
      self.scheduler.advance()

      self.tableViewIsEditing.assertValues([false, true], "Editing mode remains enabled")
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
      self.vm.inputs.viewWillAppear()

      self.scheduler.advance()

      self.tableViewIsEditing.assertValues([false])
      self.showAlert.assertValues([])
      self.paymentMethods.assertValues([GraphUserCreditCard.template.storedCards.nodes])

      self.vm.inputs.editButtonTapped()

      self.tableViewIsEditing.assertValues([false, true], "Editing mode enabled")
      self.showAlert.assertValues([])
      self.paymentMethods.assertValues([GraphUserCreditCard.template.storedCards.nodes])

      self.vm.inputs.didDelete(card, visibleCellCount: 1)
      self.scheduler.advance()

      self.tableViewIsEditing.assertValues([false, true], "Editing mode remains enabled")
      self.showAlert.assertValues([
        "Something went wrong and we were unable to remove your payment method, please try again."])
      self.paymentMethods.assertValues(
        [GraphUserCreditCard.template.storedCards.nodes, GraphUserCreditCard.template.storedCards.nodes],
        "Emits again to reload the tableview after an error occurred"
      )
    }
  }

  func testDeletePaymentMethod_SuccessThenError() {
    guard let card = GraphUserCreditCard.template.storedCards.nodes.first else {
      XCTFail("Card should exist")
      return
    }

    let result1 = DeletePaymentMethodEnvelope.init(storedCards: [card, card])

    let apiService1 = MockService(deletePaymentMethodResult: .success(result1))
    withEnvironment(apiService: apiService1) {

      self.vm.inputs.viewDidLoad()
      self.vm.inputs.viewWillAppear()

      self.scheduler.advance()

      self.tableViewIsEditing.assertValues([false])
      self.showAlert.assertValues([])
      self.paymentMethods.assertValues([GraphUserCreditCard.template.storedCards.nodes])
      self.editButtonIsEnabled.assertValues([false, true], "Edit button enabled, we have cards")

      self.vm.inputs.editButtonTapped()

      self.tableViewIsEditing.assertValues([false, true], "Editing mode enabled")
      self.showAlert.assertValues([])
      self.paymentMethods.assertValues([GraphUserCreditCard.template.storedCards.nodes])

      self.vm.inputs.didDelete(card, visibleCellCount: 1)
      self.editButtonIsEnabled.assertValues([false, true, true], "Editing button remains enabled")

      self.scheduler.advance()

      self.tableViewIsEditing.assertValues([false, true], "Editing mode remains enabled")
      self.showAlert.assertValues([])
    }

    let apiService2 = MockService(deletePaymentMethodResult: .failure(.invalidInput))
    withEnvironment(apiService: apiService2) {
      self.vm.inputs.didDelete(card, visibleCellCount: 0)

      self.editButtonIsEnabled.assertValues(
        [false, true, true, true, false], "Editing button disabled as last card removed"
      )
      self.tableViewIsEditing.assertValues([false, true, false], "Editing mode disabled as last card removed")

      self.scheduler.advance()
      self.showAlert.assertValues([
        "Something went wrong and we were unable to remove your payment method, please try again."])
      self.paymentMethods.assertValues(
        [GraphUserCreditCard.template.storedCards.nodes, result1.storedCards],
        // swiftlint:disable:next line_length
        "Emits again with the results from the last successful deletion to reload the tableview after an error occurred"
      )

      self.vm.addNewCardDismissed()
      self.scheduler.advance()

      self.editButtonIsEnabled.assertValues(
        [false, true, true, true, false, true, true], "Editing mode disabled as last card removal failed"
      )
      self.tableViewIsEditing.assertValues(
        [false, true, false], "Editing mode reenabled as last card removal failed"
      )
      self.paymentMethods.assertValues(
        [GraphUserCreditCard.template.storedCards.nodes,
         result1.storedCards,
         GraphUserCreditCard.template.storedCards.nodes],
        "Cards are refreshed normally"
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

    let result = DeletePaymentMethodEnvelope.init(storedCards: GraphUserCreditCard.template.storedCards.nodes)

    let apiService = MockService(deletePaymentMethodResult: .success(result))
    withEnvironment(apiService: apiService) {

      self.vm.inputs.viewDidLoad()

      self.vm.inputs.didDelete(card, visibleCellCount: 1)
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

      self.vm.inputs.didDelete(card, visibleCellCount: 1)
      self.scheduler.advance()

      XCTAssertEqual(["Errored Delete Payment Method"], self.trackingClient.events)
    }
  }
}
