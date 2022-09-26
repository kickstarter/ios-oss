import Foundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
@testable import Stripe
import XCTest

internal final class PaymentMethodsViewModelTests: TestCase {
  private let vm = PaymentMethodsViewModel()
  private let userTemplate = GraphUser.template |> \.storedCards .~ UserCreditCards.template
  private let cancelLoadingState = TestObserver<Void, Never>()
  private let editButtonIsEnabled = TestObserver<Bool, Never>()
  private let editButtonTitle = TestObserver<String, Never>()
  private let errorLoadingPaymentMethodsOrSetupIntent = TestObserver<String, Never>()
  private let goToAddCardScreenWithIntent = TestObserver<AddNewCardIntent, Never>()
  private let goToPaymentSheet = TestObserver<PaymentSheetSetupData, Never>()
  private let paymentMethods = TestObserver<[UserCreditCards.CreditCard], Never>()
  private let presentBanner = TestObserver<String, Never>()
  private let reloadData = TestObserver<Void, Never>()
  private let setStripePublishableKey = TestObserver<String, Never>()
  private let showAlert = TestObserver<String, Never>()
  private let tableViewIsEditing = TestObserver<Bool, Never>()

  internal override func setUp() {
    super.setUp()

    self.vm.outputs.cancelAddNewCardLoadingState.observe(self.cancelLoadingState.observer)
    self.vm.outputs.editButtonIsEnabled.observe(self.editButtonIsEnabled.observer)
    self.vm.outputs.editButtonTitle.observe(self.editButtonTitle.observer)
    self.vm.outputs.errorLoadingPaymentMethodsOrSetupIntent
      .observe(self.errorLoadingPaymentMethodsOrSetupIntent.observer)
    self.vm.outputs.goToAddCardScreenWithIntent.observe(self.goToAddCardScreenWithIntent.observer)
    self.vm.outputs.goToPaymentSheet.observe(self.goToPaymentSheet.observer)
    self.vm.outputs.paymentMethods.observe(self.paymentMethods.observer)
    self.vm.outputs.presentBanner.observe(self.presentBanner.observer)
    self.vm.outputs.reloadData.observe(self.reloadData.observer)
    self.vm.outputs.setStripePublishableKey.observe(self.setStripePublishableKey.observer)
    self.vm.outputs.showAlert.observe(self.showAlert.observer)
    self.vm.outputs.tableViewIsEditing.observe(self.tableViewIsEditing.observer)
  }

  func testPaymentMethodsFetch_OnViewDidLoad() {
    let response = UserEnvelope<GraphUser>(me: userTemplate)
    let apiService = MockService(fetchGraphUserResult: .success(response))

    withEnvironment(apiService: apiService) {
      self.vm.inputs.viewDidLoad()

      self.reloadData.assertDidEmitValue()

      self.scheduler.advance()

      self.paymentMethods.assertValues([UserCreditCards.template.storedCards])
    }
  }

  func testSetStripePublishableKey_OnViewDidLoad_Success() {
    withEnvironment {
      self.setStripePublishableKey.assertDidNotEmitValue()

      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.setStripePublishableKey.assertDidEmitValue()
    }
  }

  func testPaymentMethodsFetch_errorFetchingPaymentMethods() {
    let apiService = MockService(fetchGraphUserResult: .failure(.couldNotParseJSON))

    withEnvironment(apiService: apiService) {
      self.vm.inputs.viewDidLoad()

      self.reloadData.assertDidEmitValue()

      self.scheduler.advance()

      self.errorLoadingPaymentMethodsOrSetupIntent
        .assertValue(ErrorEnvelope.couldNotParseJSON.localizedDescription)
      self.paymentMethods.assertDidNotEmitValue()
    }
  }

  func testPaymentMethodsFetch_errorFetchingSetupIntent() {
    let mockService = MockService(createStripeSetupIntentResult: .failure(.couldNotParseJSON))

    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.features .~ [
        OptimizelyFeature.settingsPaymentSheetEnabled.rawValue: true
      ]

    withEnvironment(
      apiService: mockService,
      optimizelyClient: mockOptimizelyClient
    ) {
      self.errorLoadingPaymentMethodsOrSetupIntent.assertDidNotEmitValue()

      self.vm.inputs.paymentMethodsFooterViewDidTapAddNewCardButton()

      self.scheduler.advance()

      self.errorLoadingPaymentMethodsOrSetupIntent
        .assertValue(ErrorEnvelope.couldNotParseJSON.localizedDescription)
    }
  }

  func testPaymentMethodsFetch_WhenSettingsPaymentSheetIsDisabled_OnAddNewCardSucceeded() {
    let response = UserEnvelope<GraphUser>(me: userTemplate)
    let apiService = MockService(fetchGraphUserResult: .success(response))
    let mockOptimizely = MockOptimizelyClient()
      |> \.features .~ [
        OptimizelyFeature.settingsPaymentSheetEnabled.rawValue: false
      ]

    withEnvironment(
      apiService: apiService,
      optimizelyClient: mockOptimizely
    ) {
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

  func testPaymentSheetDidAdd_WhenSettingsPaymentSheetIsEnabled_OnAddNewCardSucceeded() {
    let response = UserEnvelope<GraphUser>(me: userTemplate)
    let apiService = MockService(
      addPaymentSheetPaymentSourceResult: .success(.paymentSourceSuccessTemplate),
      fetchGraphUserResult: .success(response)
    )
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.features .~ [
        OptimizelyFeature.settingsPaymentSheetEnabled.rawValue: true
      ]

    withEnvironment(apiService: apiService, optimizelyClient: mockOptimizelyClient) {
      self.paymentMethods.assertValues([])

      guard let paymentMethod = STPPaymentMethod.visaStripePaymentMethod else {
        XCTFail("Should've created payment method.")

        return
      }

      let paymentOption = STPPaymentMethod.sampleStringPaymentOption(paymentMethod)
      let paymentOptionsDisplayData = STPPaymentMethod.samplePaymentOptionsDisplayData(paymentOption)

      self.vm.inputs
        .paymentSheetDidAdd(
          newCard: paymentOptionsDisplayData,
          setupIntent: "seti_1LVlHO4VvJ2PtfhK43R6p7FI_secret_MEDiGbxfYVnHGsQy8v8TbZJTQhlNKLZ"
        )

      self.paymentMethods.assertValueCount(0)
      self.errorLoadingPaymentMethodsOrSetupIntent.assertDidNotEmitValue()

      self.scheduler.advance()

      self.paymentMethods.assertValueCount(1)
      self.errorLoadingPaymentMethodsOrSetupIntent.assertDidNotEmitValue()
    }
  }

  func testCancelLoadingState_Success() {
    let response = UserEnvelope<GraphUser>(me: userTemplate)
    let apiService = MockService(
      fetchGraphUserResult: .success(response)
    )

    withEnvironment(apiService: apiService) {
      self.cancelLoadingState.assertDidNotEmitValue()

      self.vm.inputs
        .shouldCancelPaymentSheetAppearance(state: false)

      self.scheduler.advance()

      self.cancelLoadingState.assertDidNotEmitValue()

      self.vm.inputs
        .shouldCancelPaymentSheetAppearance(state: true)

      self.scheduler.advance()

      self.cancelLoadingState.assertDidEmitValue()
    }
  }

  func testPaymentSheetDidAdd_WhenSettingsPaymentSheetIsDisabled_OnAddNewCardFailed_ErrorShown() {
    let response = UserEnvelope<GraphUser>(me: userTemplate)
    let apiService = MockService(
      addPaymentSheetPaymentSourceResult: .failure(.couldNotParseJSON),
      fetchGraphUserResult: .success(response)
    )
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.features .~ [
        OptimizelyFeature.settingsPaymentSheetEnabled.rawValue: true
      ]

    withEnvironment(apiService: apiService, optimizelyClient: mockOptimizelyClient) {
      self.paymentMethods.assertValues([])

      guard let paymentMethod = STPPaymentMethod.visaStripePaymentMethod else {
        XCTFail("Should've created payment method.")

        return
      }

      let paymentOption = STPPaymentMethod.sampleStringPaymentOption(paymentMethod)
      let paymentOptionsDisplayData = STPPaymentMethod.samplePaymentOptionsDisplayData(paymentOption)

      self.errorLoadingPaymentMethodsOrSetupIntent.assertDidNotEmitValue()

      self.vm.inputs
        .paymentSheetDidAdd(
          newCard: paymentOptionsDisplayData,
          setupIntent: "seti_1LVlHO4VvJ2PtfhK43R6p7FI_secret_MEDiGbxfYVnHGsQy8v8TbZJTQhlNKLZ"
        )

      self.paymentMethods.assertValueCount(0)

      self.scheduler.advance()

      self.paymentMethods.assertValueCount(0)
      self.errorLoadingPaymentMethodsOrSetupIntent.assertDidEmitValue()
    }
  }

  func testPaymentMethodsFetch_OnAddNewCardDismissed() {
    let response = UserEnvelope<GraphUser>(me: userTemplate)
    let apiService = MockService(fetchGraphUserResult: .success(response))

    withEnvironment(apiService: apiService) {
      self.paymentMethods.assertValues([])

      self.vm.inputs.addNewCardDismissed()

      self.scheduler.advance()

      self.paymentMethods.assertValues([UserCreditCards.template.storedCards])
    }
  }

  func testEditButtonIsNotEnabled_OnViewDidLoad() {
    self.editButtonIsEnabled.assertDidNotEmitValue()
    self.vm.viewDidLoad()
    self.editButtonIsEnabled.assertValue(false)
  }

  func testEditButtonIsEnabledAndTitle_HasPaymentMethods() {
    let response = UserEnvelope<GraphUser>(me: GraphUser.template)
    let apiService = MockService(fetchGraphUserResult: .success(response))
    withEnvironment(apiService: apiService) {
      self.editButtonIsEnabled.assertDidNotEmitValue()
      self.editButtonTitle.assertDidNotEmitValue()

      self.vm.inputs.viewDidLoad()
      self.editButtonIsEnabled.assertValues([false])
      self.editButtonTitle.assertValues(["Edit"])

      self.scheduler.advance()

      self.editButtonIsEnabled.assertValues([false, true])
      self.editButtonTitle.assertValues(["Edit"])

      self.vm.inputs.editButtonTapped()
      self.editButtonIsEnabled.assertValues([false, true])
      self.editButtonTitle.assertValues(["Edit", "Done"])

      self.vm.inputs.editButtonTapped()
      self.editButtonIsEnabled.assertValues([false, true])
      self.editButtonTitle.assertValues(["Edit", "Done", "Edit"])
    }
  }

  func testEditButtonIsNotEnabled_NoPaymentMethods() {
    let emptyTemplate = GraphUser.template |> \.storedCards .~ .emptyTemplate
    let response = UserEnvelope<GraphUser>(me: emptyTemplate)
    let apiService = MockService(fetchGraphUserResult: .success(response))
    withEnvironment(apiService: apiService) {
      self.editButtonIsEnabled.assertDidNotEmitValue()
      self.vm.inputs.viewDidLoad()

      self.editButtonIsEnabled.assertValues([false])

      self.scheduler.advance()

      self.editButtonIsEnabled.assertValues([false])
    }
  }

  func testEditButtonEnabled_AfterDeletePaymentMethod() {
    guard let card = UserCreditCards.template.storedCards.first else {
      XCTFail("Card should exist")
      return
    }

    let result = DeletePaymentMethodEnvelope(storedCards: [card])
    let response = UserEnvelope<GraphUser>(me: userTemplate)
    let apiService = MockService(
      deletePaymentMethodResult: .success(result),
      fetchGraphUserResult: .success(response)
    )
    withEnvironment(apiService: apiService) {
      self.editButtonIsEnabled.assertDidNotEmitValue()

      self.vm.inputs.viewDidLoad()

      self.editButtonIsEnabled.assertValues([false])

      self.scheduler.advance()

      self.editButtonIsEnabled.assertValues([false, true])

      self.vm.inputs.didDelete(card, visibleCellCount: 1)

      self.editButtonIsEnabled.assertValues([false, true])

      self.scheduler.advance()

      self.editButtonIsEnabled.assertValues([false, true])
    }
  }

  func testEditButtonNotEnabled_AfterDeleteLastPaymentMethod() {
    guard let card = UserCreditCards.template.storedCards.first else {
      XCTFail("Card should exist")
      return
    }

    let result = DeletePaymentMethodEnvelope(storedCards: [])
    let response = UserEnvelope<GraphUser>(me: userTemplate)
    let apiService = MockService(
      deletePaymentMethodResult: .success(result),
      fetchGraphUserResult: .success(response)
    )
    withEnvironment(apiService: apiService) {
      self.editButtonIsEnabled.assertDidNotEmitValue()

      self.vm.inputs.viewDidLoad()

      self.editButtonIsEnabled.assertValues([false])

      self.scheduler.advance()

      self.editButtonIsEnabled.assertValues([false, true])

      self.vm.inputs.didDelete(card, visibleCellCount: 0)

      self.editButtonIsEnabled.assertValues([false, true, false])

      self.scheduler.advance()

      self.editButtonIsEnabled.assertValues([false, true, false])
    }
  }

  func testGoToAddCardScreenEmits_WhenAddNewCardIsTapped_PaymentSheetFlagFalse_Success() {
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.features .~ [
        OptimizelyFeature.settingsPaymentSheetEnabled.rawValue: false
      ]

    withEnvironment(optimizelyClient: mockOptimizelyClient) {
      self.goToAddCardScreenWithIntent.assertValueCount(0)

      self.vm.inputs.paymentMethodsFooterViewDidTapAddNewCardButton()

      self.scheduler.advance()

      self.goToAddCardScreenWithIntent.assertValues([.settings], "Should emit after tapping button")
    }
  }

  func testGoToAddCardScreenEmits_WhenAddNewCardIsTapped_PaymentSheetFlagTrue_Failure() {
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.features .~ [
        OptimizelyFeature.settingsPaymentSheetEnabled.rawValue: true
      ]

    withEnvironment(optimizelyClient: mockOptimizelyClient) {
      self.goToAddCardScreenWithIntent.assertValueCount(0)

      self.vm.inputs.paymentMethodsFooterViewDidTapAddNewCardButton()

      self.scheduler.advance()

      self.goToAddCardScreenWithIntent.assertValueCount(0)
    }
  }

  func testGoToPaymentSheet_WhenAddNewCardIsTapped_PaymentSheetFlagTrue_Success() {
    let envelope = ClientSecretEnvelope(clientSecret: "UHJvamVjdC0yMzEyODc5ODc")
    let mockService = MockService(createStripeSetupIntentResult: .success(envelope))
    let mockOptimizelyClient = MockOptimizelyClient()
      |> \.features .~ [
        OptimizelyFeature.settingsPaymentSheetEnabled.rawValue: true
      ]

    withEnvironment(
      apiService: mockService,
      optimizelyClient: mockOptimizelyClient
    ) {
      self.goToAddCardScreenWithIntent.assertValueCount(0)
      self.goToPaymentSheet.assertValueCount(0)

      self.vm.inputs.paymentMethodsFooterViewDidTapAddNewCardButton()

      self.scheduler.advance(by: .seconds(1))

      self.goToAddCardScreenWithIntent.assertValueCount(0)
      self.goToPaymentSheet.assertValueCount(1)
    }
  }

  func testTableViewIsEditing_isFalse_WhenAddNewCardIsPresented() {
    self.tableViewIsEditing.assertValueCount(0)

    self.vm.inputs.viewDidLoad()
    self.vm.inputs.editButtonTapped()

    self.tableViewIsEditing.assertValues([false, true])

    self.vm.inputs.addNewCardPresented()

    self.tableViewIsEditing.assertValues([false, true, false])
  }

  func testPresentMessageBanner() {
    self.presentBanner.assertValues([])

    self.vm.inputs.addNewCardSucceeded(with: Strings.Got_it_your_changes_have_been_saved())

    self.presentBanner.assertValues([Strings.Got_it_your_changes_have_been_saved()])
  }

  func testDeletePaymentMethod() {
    guard let card = UserCreditCards.template.storedCards.first else {
      XCTFail("Card should exist")
      return
    }

    let result = DeletePaymentMethodEnvelope(storedCards: UserCreditCards.template.storedCards)
    let response = UserEnvelope<GraphUser>(me: userTemplate)
    let apiService = MockService(
      deletePaymentMethodResult: .success(result),
      fetchGraphUserResult: .success(response)
    )
    withEnvironment(apiService: apiService) {
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.tableViewIsEditing.assertValues([false])
      self.showAlert.assertValues([])
      self.paymentMethods.assertValues([UserCreditCards.template.storedCards])

      self.vm.inputs.editButtonTapped()

      self.tableViewIsEditing.assertValues([false, true], "Editing mode enabled")
      self.showAlert.assertValues([])
      self.paymentMethods.assertValues([UserCreditCards.template.storedCards])

      self.vm.inputs.didDelete(card, visibleCellCount: 1)
      self.scheduler.advance()

      self.tableViewIsEditing.assertValues([false, true], "Editing mode remains enabled")
      self.showAlert.assertValues([], "No errors emitted")
      self.paymentMethods.assertValues(
        [UserCreditCards.template.storedCards],
        "Emits once"
      )
    }
  }

  func testDeletePaymentMethod_Error() {
    guard let card = UserCreditCards.template.storedCards.first else {
      XCTFail("Card should exist")
      return
    }

    let response = UserEnvelope<GraphUser>(me: userTemplate)
    let apiService = MockService(
      deletePaymentMethodResult: .failure(.couldNotParseJSON),
      fetchGraphUserResult: .success(response)
    )
    withEnvironment(apiService: apiService) {
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.tableViewIsEditing.assertValues([false])
      self.showAlert.assertValues([])
      self.paymentMethods.assertValues([UserCreditCards.template.storedCards])

      self.vm.inputs.editButtonTapped()

      self.tableViewIsEditing.assertValues([false, true], "Editing mode enabled")
      self.showAlert.assertValues([])
      self.paymentMethods.assertValues([UserCreditCards.template.storedCards])

      self.vm.inputs.didDelete(card, visibleCellCount: 1)
      self.scheduler.advance()

      self.tableViewIsEditing.assertValues([false, true], "Editing mode remains enabled")
      self.showAlert.assertValues([
        "Something went wrong and we were unable to remove your payment method, please try again."
      ])
      self.paymentMethods.assertValues(
        [UserCreditCards.template.storedCards, UserCreditCards.template.storedCards],
        "Emits again to reload the tableview after an error occurred"
      )
    }
  }

  func testDeletePaymentMethod_SuccessThenError() {
    guard let card = UserCreditCards.template.storedCards.first else {
      XCTFail("Card should exist")
      return
    }

    let result1 = DeletePaymentMethodEnvelope(storedCards: [card, card])
    let response = UserEnvelope<GraphUser>(me: userTemplate)
    let apiService1 = MockService(
      deletePaymentMethodResult: .success(result1),
      fetchGraphUserResult: .success(response)
    )
    withEnvironment(apiService: apiService1) {
      self.vm.inputs.viewDidLoad()

      self.scheduler.advance()

      self.tableViewIsEditing.assertValues([false])
      self.showAlert.assertValues([])
      self.paymentMethods.assertValues([UserCreditCards.template.storedCards])
      self.editButtonIsEnabled.assertValues([false, true], "Edit button enabled, we have cards")

      self.vm.inputs.editButtonTapped()

      self.tableViewIsEditing.assertValues([false, true], "Editing mode enabled")
      self.showAlert.assertValues([])
      self.paymentMethods.assertValues([UserCreditCards.template.storedCards])

      self.vm.inputs.didDelete(card, visibleCellCount: 1)
      self.editButtonIsEnabled.assertValues([false, true], "Editing button remains enabled")

      self.scheduler.advance()

      self.tableViewIsEditing.assertValues([false, true], "Editing mode remains enabled")
      self.showAlert.assertValues([])
    }

    let response2 = UserEnvelope<GraphUser>(me: userTemplate)
    let apiService2 = MockService(
      deletePaymentMethodResult: .failure(.couldNotParseJSON),
      fetchGraphUserResult: .success(response2)
    )

    withEnvironment(apiService: apiService2) {
      self.vm.inputs.didDelete(card, visibleCellCount: 0)

      self.editButtonIsEnabled.assertValues(
        [false, true, false], "Editing button disabled as last card removed"
      )
      self.tableViewIsEditing.assertValues([false, true, false], "Editing mode disabled as last card removed")

      self.scheduler.advance()
      self.showAlert.assertValues([
        "Something went wrong and we were unable to remove your payment method, please try again."
      ])
      self.paymentMethods.assertValues(
        [UserCreditCards.template.storedCards, result1.storedCards],
        "Emits again with the results from the last successful deletion to reload the tableview after an error occurred"
      )

      self.vm.addNewCardDismissed()
      self.scheduler.advance()

      self.editButtonIsEnabled.assertValues(
        [false, true, false, true], "Editing mode disabled as last card removal failed"
      )
      self.tableViewIsEditing.assertValues(
        [false, true, false], "Editing mode reenabled as last card removal failed"
      )
      self.paymentMethods.assertValues(
        [
          UserCreditCards.template.storedCards,
          result1.storedCards,
          UserCreditCards.template.storedCards
        ],
        "Cards are refreshed normally"
      )
    }
  }
}
