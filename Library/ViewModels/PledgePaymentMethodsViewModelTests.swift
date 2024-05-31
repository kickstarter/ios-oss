import Foundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
@testable import StripePaymentSheet
import XCTest

final class PledgePaymentMethodsViewModelTests: TestCase {
  private var vm: PledgePaymentMethodsViewModelType =
    PledgePaymentMethodsViewModel(stripeIntentService: MockStripeIntentService())
  private var mockStripeIntentService = MockStripeIntentService()

  private let userTemplate = GraphUser.template |> \.storedCards .~ UserCreditCards.template

  private let goToAddStripeCardIntent = TestObserver<PaymentSheetSetupData, Never>()
  private let goToProject = TestObserver<Project, Never>()
  private let notifyDelegateCreditCardSelected = TestObserver<PaymentSourceSelected, Never>()
  private let notifyDelegateLoadPaymentMethodsError = TestObserver<String, Never>()

  private let reloadPaymentMethodsCards = TestObserver<[UserCreditCards.CreditCard], Never>()
  private let reloadPaymentSheetPaymentMethodsCards = TestObserver<
    [PledgePaymentMethodCellData],
    Never
  >()
  private let reloadPaymentMethodsAvailableCardTypes = TestObserver<[Bool], Never>()
  private let reloadPaymentMethodsIsLoading = TestObserver<Bool, Never>()
  private let reloadPaymentMethodsIsSelected = TestObserver<[Bool], Never>()
  private let reloadPaymentMethodsProjectCountry = TestObserver<[String], Never>()
  private let reloadPaymentMethodsSelectedCardId = TestObserver<String?, Never>()
  private let reloadPaymentMethodsShouldReload = TestObserver<Bool, Never>()
  private let addNewCardLoadingState = TestObserver<Bool, Never>()

  override func setUp() {
    super.setUp()

    self.vm = PledgePaymentMethodsViewModel(stripeIntentService: self.mockStripeIntentService)

    self.vm.outputs.notifyDelegateCreditCardSelected
      .observe(self.notifyDelegateCreditCardSelected.observer)
    self.vm.outputs.notifyDelegateLoadPaymentMethodsError
      .observe(self.notifyDelegateLoadPaymentMethodsError.observer)

    // swiftlint:disable line_length
    self.vm.outputs.reloadPaymentMethods.map { $0.existingPaymentMethods }.map { $0.map { $0.card } }
      .observe(self.reloadPaymentMethodsCards.observer)
    self.vm.outputs.reloadPaymentMethods.map { $0.existingPaymentMethods }.map { $0.map { $0.isEnabled } }
      .observe(self.reloadPaymentMethodsAvailableCardTypes.observer)
    self.vm.outputs.reloadPaymentMethods.map { $0.existingPaymentMethods }.map { $0.map { $0.isSelected } }
      .observe(self.reloadPaymentMethodsIsSelected.observer)
    self.vm.outputs.reloadPaymentMethods.map { $0.existingPaymentMethods }
      .map { $0.map { $0.projectCountry } }
      .observe(self.reloadPaymentMethodsProjectCountry.observer)
    self.vm.outputs.reloadPaymentMethods.map { $0.newPaymentMethods }
      .observe(self.reloadPaymentSheetPaymentMethodsCards.observer)
    self.vm.outputs.reloadPaymentMethods.map { data in data.selectedPaymentMethod?.savedCreditCardId }
      .observe(self.reloadPaymentMethodsSelectedCardId.observer)
    self.vm.outputs.reloadPaymentMethods.map { $0.shouldReload }
      .observe(self.reloadPaymentMethodsShouldReload.observer)
    self.vm.outputs.reloadPaymentMethods.map { $0.isLoading }
      .observe(self.reloadPaymentMethodsIsLoading.observer)
    self.vm.outputs.updateAddNewCardLoading.map { $0 }.observe(self.addNewCardLoadingState.observer)
    self.vm.outputs.goToAddCardViaStripeScreen.map { $0 }.observe(self.goToAddStripeCardIntent.observer)
    // swiftlint:enable line_length
  }

  // MARK: - New card added

  func testReloadPaymentMethods_NewCardAdded_UnavailableIsLast() {
    let sampleSetupIntent = "seti_1LVlHO4VvJ2PtfhK43R6p7FI_secret_MEDiGbxfYVnHGsQy8v8TbZJTQhlNKLZ"

    let response = UserEnvelope<GraphUser>(me: userTemplate)
    let addPaymentSheetResponse = CreatePaymentSourceEnvelope.paymentSourceSuccessTemplateWithId("999")

    let mockService = MockService(
      addPaymentSheetPaymentSourceResult: .success(addPaymentSheetResponse),
      fetchGraphUserResult: .success(response)
    )

    withEnvironment(apiService: mockService, currentUser: User.template) {
      self.reloadPaymentMethodsCards.assertDidNotEmitValue()
      self.reloadPaymentMethodsAvailableCardTypes.assertDidNotEmitValue()
      self.reloadPaymentMethodsIsSelected.assertDidNotEmitValue()
      self.reloadPaymentMethodsProjectCountry.assertDidNotEmitValue()
      self.reloadPaymentMethodsSelectedCardId.assertDidNotEmitValue()
      self.reloadPaymentMethodsShouldReload.assertDidNotEmitValue()
      self.reloadPaymentMethodsIsLoading.assertDidNotEmitValue()

      self.vm.inputs
        .configure(with: (
          User.template,
          Project.template,
          "checkoutID",
          Reward.template,
          .pledge,
          .discovery
        ))
      self.vm.inputs.viewDidLoad()

      self.scheduler.run()

      self.reloadPaymentMethodsCards.assertValues([[], response.me.storedCards.storedCards])
      self.reloadPaymentMethodsAvailableCardTypes.assertValues([
        [],
        [true, true, true, true, true, true, true, false]
      ])
      self.reloadPaymentMethodsIsSelected.assertValues([
        [],
        [true, false, false, false, false, false, false, false]
      ], "First card is selected")
      self.reloadPaymentMethodsProjectCountry.assertValues([
        [],
        (0...response.me.storedCards.storedCards.count - 1).map { _ in "Brooklyn, NY" }
      ], "One card is unavailable")
      self.reloadPaymentMethodsSelectedCardId
        .assertValues([nil, response.me.storedCards.storedCards.first?.id])
      self.reloadPaymentMethodsShouldReload.assertValues([true, true])
      self.reloadPaymentMethodsIsLoading.assertValues([true, false])

      XCTAssertEqual(self.reloadPaymentSheetPaymentMethodsCards.values.count, 2)
      XCTAssertTrue(
        self.reloadPaymentSheetPaymentMethodsCards.values[0].isEmpty
      )
      XCTAssertTrue(
        self.reloadPaymentSheetPaymentMethodsCards.values[1].isEmpty
      )

      guard let paymentMethod = STPPaymentMethod.visaStripePaymentMethod else {
        XCTFail("Should've created payment method.")

        return
      }
      let paymentOption = STPPaymentMethod.sampleStringPaymentOption(paymentMethod)
      let paymentOptionsDisplayData = STPPaymentMethod.samplePaymentOptionsDisplayData(paymentOption)

      self.scheduler.advance(by: .seconds(1))

      self.vm.inputs
        .paymentSheetDidAdd(
          clientSecret: sampleSetupIntent,
          paymentMethod: "pm_fake"
        )

      self.scheduler.advance(by: .seconds(1))

      XCTAssertEqual(self.reloadPaymentSheetPaymentMethodsCards.values.count, 3)
      XCTAssertTrue(
        self.reloadPaymentSheetPaymentMethodsCards.values[0].isEmpty
      )
      XCTAssertTrue(
        self.reloadPaymentSheetPaymentMethodsCards.values[1].isEmpty
      )
      XCTAssertNotNil(self.reloadPaymentSheetPaymentMethodsCards.lastValue?.last?.card)
      XCTAssertEqual(
        self.reloadPaymentSheetPaymentMethodsCards.lastValue?.last?.card.lastFour,
        addPaymentSheetResponse.createPaymentSource.paymentSource.lastFour
      )
      XCTAssertEqual(
        self.reloadPaymentMethodsSelectedCardId.lastValue!,
        addPaymentSheetResponse.createPaymentSource.paymentSource.id
      )

      self.reloadPaymentMethodsCards.assertValues(
        [
          [],
          [
            UserCreditCards.amex,
            UserCreditCards.masterCard,
            UserCreditCards.visa,
            UserCreditCards.diners,
            UserCreditCards.jcb,
            UserCreditCards.discover,
            UserCreditCards.unionPay,
            UserCreditCards.generic
          ], [
            UserCreditCards.amex,
            UserCreditCards.masterCard,
            UserCreditCards.visa,
            UserCreditCards.diners,
            UserCreditCards.jcb,
            UserCreditCards.discover,
            UserCreditCards.unionPay,
            UserCreditCards.generic
          ]
        ]
      )
      self.reloadPaymentMethodsAvailableCardTypes.assertValues([
        [],
        [true, true, true, true, true, true, true, false],
        [true, true, true, true, true, true, true, false]
      ])
      self.reloadPaymentMethodsIsSelected.assertValues([
        [],
        [true, false, false, false, false, false, false, false],
        [false, false, false, false, false, false, false, false]
      ], "Deselect pre-existing card.")
      self.reloadPaymentMethodsProjectCountry.assertValues([
        [],
        (0...response.me.storedCards.storedCards.count - 1).map { _ in "Brooklyn, NY" },
        (0...response.me.storedCards.storedCards.count - 1).map { _ in "Brooklyn, NY" }
      ], "No changes")
      self.reloadPaymentMethodsSelectedCardId.assertValues([
        nil,
        response.me.storedCards.storedCards.first?.id,
        addPaymentSheetResponse.createPaymentSource.paymentSource.id
      ])
      self.reloadPaymentMethodsShouldReload.assertValues([true, true, true])
    }
  }

  func testReloadPaymentMethods_NewCardAdded_ProjectHasBacking() {
    let setupIntent = "seti_1LVlHO4VvJ2PtfhK43R6p7FI_secret_MEDiGbxfYVnHGsQy8v8TbZJTQhlNKLZ"
    let cards = UserCreditCards.withCards([
      UserCreditCards.amex,
      UserCreditCards.visa,
      UserCreditCards.masterCard,
      UserCreditCards.diners,
      UserCreditCards.generic
    ])
    let graphUser = GraphUser.template |> \.storedCards .~ cards
    let response = UserEnvelope<GraphUser>(me: graphUser)
    let addPaymentSheetResponse = CreatePaymentSourceEnvelope.paymentSourceSuccessTemplateWithId("999")

    let mockService = MockService(
      addPaymentSheetPaymentSourceResult: .success(addPaymentSheetResponse),
      fetchGraphUserResult: .success(response)
    )

    self.reloadPaymentMethodsCards.assertDidNotEmitValue()
    self.reloadPaymentMethodsAvailableCardTypes.assertDidNotEmitValue()
    self.reloadPaymentMethodsIsSelected.assertDidNotEmitValue()
    self.reloadPaymentMethodsProjectCountry.assertDidNotEmitValue()
    self.reloadPaymentMethodsSelectedCardId.assertDidNotEmitValue()
    self.reloadPaymentMethodsShouldReload.assertDidNotEmitValue()
    self.reloadPaymentMethodsIsLoading.assertDidNotEmitValue()

    withEnvironment(apiService: mockService, currentUser: User.template) {
      let paymentSource = Backing.PaymentSource.template
        |> \.id .~ "2" // Matches UserCreditCards.visa template id

      let project = Project.template
        |> Project.lens.personalization.backing .~ (
          Backing.template
            |> Backing.lens.paymentSource .~ paymentSource
        )

      self.vm.inputs
        .configure(with: (
          User.template,
          project,
          "checkoutID",
          .template,
          .pledge,
          .discovery
        ))
      self.vm.inputs.viewDidLoad()

      self.scheduler.run()

      self.reloadPaymentMethodsCards.assertValues([
        [],
        [
          UserCreditCards.visa,
          UserCreditCards.amex,
          UserCreditCards.masterCard,
          UserCreditCards.diners,
          UserCreditCards.generic
        ]
      ], "Card used for backing is first")
      self.reloadPaymentMethodsAvailableCardTypes.assertValues([
        [],
        [true, true, true, true, false]
      ])
      self.reloadPaymentMethodsIsSelected.assertValues([
        [],
        [true, false, false, false, false]
      ], "First card is selected")
      self.reloadPaymentMethodsProjectCountry.assertValues([
        [],
        (0...response.me.storedCards.storedCards.count - 1).map { _ in "Brooklyn, NY" }
      ], "One card is unavailable")
      self.reloadPaymentMethodsSelectedCardId.assertValues(
        [nil, UserCreditCards.visa.id],
        "Card used for backing is selected"
      )
      self.reloadPaymentMethodsShouldReload.assertValues([true, true])

      XCTAssertEqual(self.reloadPaymentSheetPaymentMethodsCards.values.count, 2)
      XCTAssertTrue(
        self.reloadPaymentSheetPaymentMethodsCards.values[0].isEmpty
      )
      XCTAssertTrue(
        self.reloadPaymentSheetPaymentMethodsCards.values[1].isEmpty
      )

      guard let paymentMethod = STPPaymentMethod.visaStripePaymentMethod else {
        XCTFail("Should've created payment method.")

        return
      }
      let paymentOption = STPPaymentMethod.sampleStringPaymentOption(paymentMethod)
      let paymentOptionsDisplayData = STPPaymentMethod.samplePaymentOptionsDisplayData(paymentOption)

      self.scheduler.advance(by: .seconds(1))

      self.vm.inputs
        .paymentSheetDidAdd(
          clientSecret: "seti_1LVlHO4VvJ2PtfhK43R6p7FI_secret_MEDiGbxfYVnHGsQy8v8TbZJTQhlNKLZ",
          paymentMethod: "pm_fake"
        )

      self.scheduler.advance(by: .seconds(1))

      XCTAssertEqual(self.reloadPaymentSheetPaymentMethodsCards.values.count, 3)
      XCTAssertTrue(
        self.reloadPaymentSheetPaymentMethodsCards.values[0].isEmpty
      )
      XCTAssertTrue(
        self.reloadPaymentSheetPaymentMethodsCards.values[1].isEmpty
      )
      XCTAssertNotNil(self.reloadPaymentSheetPaymentMethodsCards.lastValue?.last?.card)
      XCTAssertEqual(
        self.reloadPaymentSheetPaymentMethodsCards.lastValue?.last?.card.lastFour,
        addPaymentSheetResponse.createPaymentSource.paymentSource.lastFour
      )
      XCTAssertEqual(
        self.reloadPaymentMethodsSelectedCardId.lastValue!,
        addPaymentSheetResponse.createPaymentSource.paymentSource.id
      )

      self.reloadPaymentMethodsCards.assertValues([
        [],
        [
          UserCreditCards.visa,
          UserCreditCards.amex,
          UserCreditCards.masterCard,
          UserCreditCards.diners,
          UserCreditCards.generic
        ],
        [
          UserCreditCards.visa,
          UserCreditCards.amex,
          UserCreditCards.masterCard,
          UserCreditCards.diners,
          UserCreditCards.generic
        ]
      ], "No new card added to payment methods.")
      self.reloadPaymentMethodsAvailableCardTypes.assertValues([
        [],
        [true, true, true, true, false],
        [true, true, true, true, false]
      ])
      self.reloadPaymentMethodsIsSelected.assertValues([
        [],
        [true, false, false, false, false],
        [false, false, false, false, false]
      ], "Deselect previously selected card.")
      self.reloadPaymentMethodsProjectCountry.assertValues([
        [],
        (0...response.me.storedCards.storedCards.count - 1).map { _ in "Brooklyn, NY" },
        (0...response.me.storedCards.storedCards.count - 1).map { _ in "Brooklyn, NY" }
      ], "No changes")
      self.reloadPaymentMethodsSelectedCardId.assertValues(
        [
          nil,
          UserCreditCards.visa.id,
          addPaymentSheetResponse.createPaymentSource.paymentSource.id
        ],
        "No changes"
      )
      self.reloadPaymentMethodsShouldReload.assertValues([true, true, true])
    }
  }

  func testReloadPaymentMethods_NewCardAdded_NoStoredCards() {
    let emptyTemplate = GraphUser.template |> \.storedCards .~ .emptyTemplate
    let response = UserEnvelope<GraphUser>(me: emptyTemplate)
    let addPaymentSheetResponse = CreatePaymentSourceEnvelope.paymentSourceSuccessTemplateWithId("999")

    let mockService = MockService(
      addPaymentSheetPaymentSourceResult: .success(addPaymentSheetResponse),
      fetchGraphUserResult: .success(response)
    )

    withEnvironment(apiService: mockService, currentUser: User.template) {
      self.reloadPaymentMethodsCards.assertDidNotEmitValue()
      self.reloadPaymentMethodsCards.assertDidNotEmitValue()
      self.reloadPaymentSheetPaymentMethodsCards.assertDidNotEmitValue()
      self.reloadPaymentMethodsAvailableCardTypes.assertDidNotEmitValue()
      self.reloadPaymentMethodsIsSelected.assertDidNotEmitValue()
      self.reloadPaymentMethodsProjectCountry.assertDidNotEmitValue()
      self.reloadPaymentMethodsSelectedCardId.assertDidNotEmitValue()
      self.reloadPaymentMethodsShouldReload.assertDidNotEmitValue()
      self.reloadPaymentMethodsIsLoading.assertDidNotEmitValue()

      self.vm.inputs
        .configure(with: (
          User.template,
          Project.template,
          "checkoutID",
          Reward.template,
          .pledge,
          .discovery
        ))
      self.vm.inputs.viewDidLoad()

      self.scheduler.run()

      self.reloadPaymentMethodsCards.assertValues([[], []])
      XCTAssertEqual(self.reloadPaymentSheetPaymentMethodsCards.values.count, 2)
      XCTAssertTrue(
        self.reloadPaymentSheetPaymentMethodsCards.values[0].isEmpty
      )
      XCTAssertTrue(
        self.reloadPaymentSheetPaymentMethodsCards.values[1].isEmpty
      )
      self.reloadPaymentMethodsAvailableCardTypes.assertValues([[], []])
      self.reloadPaymentMethodsIsSelected.assertValues([[], []])
      self.reloadPaymentMethodsProjectCountry.assertValues([[], []])
      self.reloadPaymentMethodsSelectedCardId.assertValues([nil, nil], "No card to select")
      self.reloadPaymentMethodsShouldReload.assertValues([true, true])

      guard let paymentMethod = STPPaymentMethod.visaStripePaymentMethod else {
        XCTFail("Should've created payment method.")

        return
      }
      let paymentOption = STPPaymentMethod.sampleStringPaymentOption(paymentMethod)
      let paymentOptionsDisplayData = STPPaymentMethod.samplePaymentOptionsDisplayData(paymentOption)

      self.scheduler.advance(by: .seconds(1))

      self.vm.inputs
        .paymentSheetDidAdd(
          clientSecret: "seti_1LVlHO4VvJ2PtfhK43R6p7FI_secret_MEDiGbxfYVnHGsQy8v8TbZJTQhlNKLZ",
          paymentMethod: "pm_fake"
        )

      self.scheduler.advance(by: .seconds(1))

      XCTAssertEqual(self.reloadPaymentSheetPaymentMethodsCards.values.count, 3)
      XCTAssertTrue(
        self.reloadPaymentSheetPaymentMethodsCards.values[0].isEmpty
      )
      XCTAssertTrue(
        self.reloadPaymentSheetPaymentMethodsCards.values[1].isEmpty
      )
      XCTAssertNotNil(self.reloadPaymentSheetPaymentMethodsCards.lastValue?.last?.card)
      XCTAssertEqual(
        self.reloadPaymentSheetPaymentMethodsCards.lastValue?.last?.card.lastFour,
        addPaymentSheetResponse.createPaymentSource.paymentSource.lastFour
      )
      self.reloadPaymentMethodsCards.assertValues([[], [], []])
      self.reloadPaymentMethodsAvailableCardTypes.assertValues([[], [], []])
      self.reloadPaymentMethodsIsSelected.assertValues([[], [], []])
      self.reloadPaymentMethodsProjectCountry.assertValues([[], [], []])
      self.reloadPaymentMethodsSelectedCardId
        .assertValues([nil, nil, addPaymentSheetResponse.createPaymentSource.paymentSource.id])
      self.reloadPaymentMethodsShouldReload.assertValues([true, true, true])
    }
  }

  func testReloadPaymentMethods_NewPaymentSheetCardAdded_WithExistingStoredCard_Success() {
    let userTemplate = GraphUser.template |> \.storedCards .~ UserCreditCards.withCards([
      UserCreditCards.masterCard
    ])
    let response = UserEnvelope<GraphUser>(me: userTemplate)
    let addPaymentSheetResponse = CreatePaymentSourceEnvelope.paymentSourceSuccessTemplateWithId("999")
    let mockService = MockService(
      addPaymentSheetPaymentSourceResult: .success(addPaymentSheetResponse),
      fetchGraphUserResult: .success(response)
    )

    withEnvironment(apiService: mockService, currentUser: User.template) {
      self.reloadPaymentMethodsCards.assertDidNotEmitValue()
      self.reloadPaymentSheetPaymentMethodsCards.assertDidNotEmitValue()
      self.reloadPaymentMethodsSelectedCardId.assertDidNotEmitValue()
      self.reloadPaymentMethodsShouldReload.assertDidNotEmitValue()
      self.reloadPaymentMethodsIsLoading.assertDidNotEmitValue()

      self.vm.inputs
        .configure(with: (
          User.template,
          Project.template,
          "checkoutID",
          Reward.template,
          .pledge,
          .discovery
        ))
      self.vm.inputs.viewDidLoad()

      self.scheduler.run()

      self.reloadPaymentMethodsCards.assertValues([[], [UserCreditCards.masterCard]])
      self.reloadPaymentSheetPaymentMethodsCards.assertValueCount(2)
      XCTAssertEqual(self.reloadPaymentSheetPaymentMethodsCards.values.first?.count, 0)
      XCTAssertEqual(self.reloadPaymentSheetPaymentMethodsCards.values.last?.count, 0)
      self.reloadPaymentMethodsSelectedCardId
        .assertValues(
          [nil, UserCreditCards.masterCard.id],
          "Previous card selected before new payment sheet card added."
        )
      self.reloadPaymentMethodsShouldReload.assertValues([true, true])
      self.reloadPaymentMethodsIsLoading.assertValues([true, false])

      guard let paymentMethod = STPPaymentMethod.visaStripePaymentMethod else {
        XCTFail("Should've created payment method.")

        return
      }
      let paymentOption = STPPaymentMethod.sampleStringPaymentOption(paymentMethod)
      let paymentOptionsDisplayData = STPPaymentMethod.samplePaymentOptionsDisplayData(paymentOption)

      let expectedPaymentSheetPaymentMethodCard = PledgePaymentMethodCellData(
        card: addPaymentSheetResponse.createPaymentSource.paymentSource,
        isEnabled: true,
        isSelected: true,
        projectCountry: "US",
        isErroredPaymentMethod: false
      )

      self.vm.inputs
        .paymentSheetDidAdd(
          clientSecret: "seti_1LVlHO4VvJ2PtfhK43R6p7FI_secret_MEDiGbxfYVnHGsQy8v8TbZJTQhlNKLZ",
          paymentMethod: "pm_fake"
        )

      self.scheduler.advance(by: 1)

      self.reloadPaymentMethodsCards
        .assertValues(
          [[], [UserCreditCards.masterCard], [UserCreditCards.masterCard]],
          "Previous non payment sheet cards still emit."
        )
      self.reloadPaymentSheetPaymentMethodsCards.assertValueCount(3)
      XCTAssertNotNil(self.reloadPaymentSheetPaymentMethodsCards.lastValue?.last?.card)
      XCTAssertEqual(
        self.reloadPaymentSheetPaymentMethodsCards.lastValue?.last?.card.lastFour,
        expectedPaymentSheetPaymentMethodCard.card.lastFour
      )
      XCTAssertEqual(
        self.reloadPaymentSheetPaymentMethodsCards.lastValue?.last?.isSelected,
        expectedPaymentSheetPaymentMethodCard.isSelected
      )
      XCTAssertEqual(
        self.reloadPaymentSheetPaymentMethodsCards.lastValue?.last?.isEnabled,
        expectedPaymentSheetPaymentMethodCard.isEnabled
      )
      self.reloadPaymentMethodsSelectedCardId
        .assertValues(
          [nil, UserCreditCards.masterCard.id, expectedPaymentSheetPaymentMethodCard.card.id]
        )
      self.reloadPaymentMethodsShouldReload.assertValues([true, true, true])
      self.reloadPaymentMethodsIsLoading.assertValues([true, false, false])
    }
  }

  func testReloadPaymentMethods_NewPaymentSheetCardAdded_WithExistingStoredCard_ErroredBacking_Success() {
    let userTemplate = GraphUser.template |> \.storedCards .~ UserCreditCards.withCards([
      UserCreditCards.masterCard
    ])
    let projectWithErroredBacking = Project.template
      |> \.personalization.backing .~ Backing.errored

    let response = UserEnvelope<GraphUser>(me: userTemplate)
    let addPaymentSheetResponse = CreatePaymentSourceEnvelope.paymentSourceSuccessTemplateWithId("999")
    let mockService = MockService(
      addPaymentSheetPaymentSourceResult: .success(addPaymentSheetResponse),
      fetchGraphUserResult: .success(response)
    )

    withEnvironment(apiService: mockService, currentUser: User.template) {
      self.reloadPaymentMethodsCards.assertDidNotEmitValue()
      self.reloadPaymentSheetPaymentMethodsCards.assertDidNotEmitValue()
      self.reloadPaymentMethodsSelectedCardId.assertDidNotEmitValue()
      self.reloadPaymentMethodsShouldReload.assertDidNotEmitValue()
      self.reloadPaymentMethodsIsLoading.assertDidNotEmitValue()

      self.vm.inputs
        .configure(with: (
          User.template,
          projectWithErroredBacking,
          "checkoutID",
          Reward.template,
          .pledge,
          .discovery
        ))
      self.vm.inputs.viewDidLoad()

      self.scheduler.run()

      self.reloadPaymentMethodsCards.assertValues([[], [UserCreditCards.masterCard]])
      self.reloadPaymentSheetPaymentMethodsCards.assertValueCount(2)
      XCTAssertEqual(self.reloadPaymentSheetPaymentMethodsCards.values.first?.count, 0)
      XCTAssertEqual(self.reloadPaymentSheetPaymentMethodsCards.values.last?.count, 0)
      self.reloadPaymentMethodsSelectedCardId
        .assertValues([nil, nil], "No selected card due to backing error.")
      self.reloadPaymentMethodsShouldReload.assertValues([true, true])
      self.reloadPaymentMethodsIsLoading.assertValues([true, false])

      guard let paymentMethod = STPPaymentMethod.visaStripePaymentMethod else {
        XCTFail("Should've created payment method.")

        return
      }
      let paymentOption = STPPaymentMethod.sampleStringPaymentOption(paymentMethod)
      let paymentOptionsDisplayData = STPPaymentMethod.samplePaymentOptionsDisplayData(paymentOption)

      let expectedPaymentSheetPaymentMethodCard = PledgePaymentMethodCellData(
        card: addPaymentSheetResponse.createPaymentSource.paymentSource,
        isEnabled: true,
        isSelected: true,
        projectCountry: "US",
        isErroredPaymentMethod: false
      )

      self.vm.inputs
        .paymentSheetDidAdd(
          clientSecret: "seti_1LVlHO4VvJ2PtfhK43R6p7FI_secret_MEDiGbxfYVnHGsQy8v8TbZJTQhlNKLZ",
          paymentMethod: "pm_fake"
        )

      self.scheduler.advance(by: 1)

      self.reloadPaymentMethodsCards
        .assertValues(
          [[], [UserCreditCards.masterCard], [UserCreditCards.masterCard]],
          "Previous non payment sheet cards still emit."
        )
      self.reloadPaymentSheetPaymentMethodsCards.assertValueCount(3)
      XCTAssertNotNil(self.reloadPaymentSheetPaymentMethodsCards.lastValue?.last?.card)
      XCTAssertEqual(
        self.reloadPaymentSheetPaymentMethodsCards.lastValue?.last?.card.lastFour,
        expectedPaymentSheetPaymentMethodCard.card.lastFour
      )
      XCTAssertEqual(
        self.reloadPaymentSheetPaymentMethodsCards.lastValue?.last?.isSelected,
        expectedPaymentSheetPaymentMethodCard.isSelected
      )
      XCTAssertEqual(
        self.reloadPaymentSheetPaymentMethodsCards.lastValue?.last?.isEnabled,
        expectedPaymentSheetPaymentMethodCard.isEnabled
      )
      self.reloadPaymentMethodsSelectedCardId
        .assertValues(
          [nil, nil, expectedPaymentSheetPaymentMethodCard.card.id],
          "Newly added payment sheet card still selected even on errored backing."
        )
      self.reloadPaymentMethodsShouldReload.assertValues([true, true, true])
      self.reloadPaymentMethodsIsLoading.assertValues([true, false, false])
    }
  }

  func testSelectNewPaymentSheetCard_ViceVersa_AfterNewPaymentSheetCardsAdded_Success() {
    let userTemplate = GraphUser.template |> \.storedCards .~ UserCreditCards.withCards([
      UserCreditCards.masterCard
    ])
    let response = UserEnvelope<GraphUser>(me: userTemplate)
    let addPaymentSheetResponse = CreatePaymentSourceEnvelope.paymentSourceSuccessTemplateWithId("999")
    let mockService = MockService(
      addPaymentSheetPaymentSourceResult: .success(addPaymentSheetResponse),
      fetchGraphUserResult: .success(response)
    )

    withEnvironment(apiService: mockService, currentUser: User.template) {
      self.reloadPaymentMethodsCards.assertDidNotEmitValue()
      self.reloadPaymentSheetPaymentMethodsCards.assertDidNotEmitValue()
      self.reloadPaymentMethodsSelectedCardId.assertDidNotEmitValue()

      self.vm.inputs
        .configure(with: (
          User.template,
          Project.template,
          "checkoutID",
          Reward.template,
          .pledge,
          .discovery
        ))
      self.vm.inputs.viewDidLoad()

      self.scheduler.run()

      self.reloadPaymentMethodsSelectedCardId
        .assertValues(
          [nil, UserCreditCards.masterCard.id],
          "Previous card selected before new payment sheet card added."
        )

      guard let paymentMethod = STPPaymentMethod.visaStripePaymentMethod else {
        XCTFail("Should've created payment method.")

        return
      }
      let paymentOption = STPPaymentMethod.sampleStringPaymentOption(paymentMethod)
      let paymentOptionsDisplayData = STPPaymentMethod.samplePaymentOptionsDisplayData(paymentOption)

      self.vm.inputs
        .paymentSheetDidAdd(
          clientSecret: "seti_1LVlHO4VvJ2PtfhK43R6p7FI_secret_MEDiGbxfYVnHGsQy8v8TbZJTQhlNKLZ",
          paymentMethod: "pm_fake"
        )

      self.scheduler.advance(by: 1)

      self.reloadPaymentMethodsSelectedCardId
        .assertValues(
          [nil, UserCreditCards.masterCard.id, addPaymentSheetResponse.createPaymentSource.paymentSource.id]
        )

      let indexPath = IndexPath(row: 1, section: 0)

      self.vm.inputs.didSelectRowAtIndexPath(indexPath)
      self.reloadPaymentMethodsSelectedCardId
        .assertValues(
          [
            nil,
            UserCreditCards.masterCard.id,
            addPaymentSheetResponse.createPaymentSource.paymentSource.id,
            UserCreditCards.masterCard.id
          ]
        )

      let indexPath2 = IndexPath(row: 0, section: 0)

      self.vm.inputs.didSelectRowAtIndexPath(indexPath2)
      self.reloadPaymentMethodsSelectedCardId
        .assertValues(
          [
            nil,
            UserCreditCards.masterCard.id,
            addPaymentSheetResponse.createPaymentSource.paymentSource.id,
            UserCreditCards.masterCard.id,
            addPaymentSheetResponse.createPaymentSource.paymentSource.id
          ],
          "No card to select after payment sheet card added."
        )
    }
  }

  func testReloadPaymentMethods_FirstCardUnavailable_UnavailableCardOrderedLast() {
    let cards = UserCreditCards.withCards([
      UserCreditCards.discover,
      UserCreditCards.visa,
      UserCreditCards.amex
    ])

    let graphUser = GraphUser.template |> \.storedCards .~ cards
    let response = UserEnvelope<GraphUser>(me: graphUser)
    let mockService = MockService(fetchGraphUserResult: .success(response))
    let project = Project.template
      |> \.availableCardTypes .~ ["AMEX", "VISA", "MASTERCARD"]

    withEnvironment(apiService: mockService, currentUser: User.template) {
      self.reloadPaymentMethodsCards.assertDidNotEmitValue()
      self.reloadPaymentMethodsAvailableCardTypes.assertDidNotEmitValue()
      self.reloadPaymentMethodsIsSelected.assertDidNotEmitValue()
      self.reloadPaymentMethodsProjectCountry.assertDidNotEmitValue()
      self.reloadPaymentMethodsSelectedCardId.assertDidNotEmitValue()
      self.reloadPaymentMethodsShouldReload.assertDidNotEmitValue()
      self.reloadPaymentMethodsIsLoading.assertDidNotEmitValue()

      self.vm.inputs
        .configure(with: (
          User.template,
          project,
          "checkoutID",
          Reward.template,
          .pledge,
          .discovery
        ))
      self.vm.inputs.viewDidLoad()

      self.scheduler.run()

      self.reloadPaymentMethodsCards.assertValues([
        [],
        [
          UserCreditCards.visa,
          UserCreditCards.amex,
          UserCreditCards.discover
        ]
      ])
      self.reloadPaymentMethodsAvailableCardTypes.assertValues([[], [true, true, false]])
      self.reloadPaymentMethodsIsSelected.assertValues([[], [true, false, false]])
      self.reloadPaymentMethodsProjectCountry.assertValues([
        [],
        ["Brooklyn, NY", "Brooklyn, NY", "Brooklyn, NY"]
      ])
      self.reloadPaymentMethodsSelectedCardId.assertValues([nil, UserCreditCards.visa.id])
      self.reloadPaymentMethodsShouldReload.assertValues([true, true])
    }
  }

  func testReloadPaymentMethods_LoggedOut() {
    let response = UserEnvelope<GraphUser>(me: GraphUser.template)
    let mockService = MockService(fetchGraphUserResult: .success(response))

    withEnvironment(apiService: mockService, currentUser: nil) {
      self.vm.inputs.viewDidLoad()

      self.reloadPaymentMethodsCards.assertDidNotEmitValue()
      self.reloadPaymentMethodsAvailableCardTypes.assertDidNotEmitValue()
      self.reloadPaymentMethodsIsSelected.assertDidNotEmitValue()
      self.reloadPaymentMethodsProjectCountry.assertDidNotEmitValue()
      self.reloadPaymentMethodsSelectedCardId.assertDidNotEmitValue()
      self.reloadPaymentMethodsShouldReload.assertDidNotEmitValue()
      self.reloadPaymentMethodsIsLoading.assertDidNotEmitValue()
      self.notifyDelegateLoadPaymentMethodsError.assertDidNotEmitValue()

      self.scheduler.run()

      self.reloadPaymentMethodsCards.assertDidNotEmitValue()
      self.reloadPaymentMethodsAvailableCardTypes.assertDidNotEmitValue()
      self.reloadPaymentMethodsIsSelected.assertDidNotEmitValue()
      self.reloadPaymentMethodsProjectCountry.assertDidNotEmitValue()
      self.reloadPaymentMethodsSelectedCardId.assertDidNotEmitValue()
      self.reloadPaymentMethodsShouldReload.assertDidNotEmitValue()
      self.reloadPaymentMethodsIsLoading.assertDidNotEmitValue()
      self.notifyDelegateLoadPaymentMethodsError.assertDidNotEmitValue()
    }
  }

  func testCreditCardSelected() {
    let response = UserEnvelope<GraphUser>(me: userTemplate)
    let mockService = MockService(fetchGraphUserResult: .success(response))

    withEnvironment(apiService: mockService, currentUser: User.template) {
      self.vm.inputs
        .configure(with: (
          User.template,
          Project.template,
          "checkoutID",
          Reward.template,
          .pledge,
          .discovery
        ))
      self.vm.inputs.viewDidLoad()

      self.scheduler.run()

      self.notifyDelegateCreditCardSelected.assertValues(
        [PaymentSourceSelected.savedCreditCard(UserCreditCards.amex.id, "pm_fake_amex")],
        "First card selected by default"
      )

      let discoverIndexPath = IndexPath(
        row: 5,
        section: PaymentMethodsTableViewSection.paymentMethods.rawValue
      )

      self.vm.inputs.didSelectRowAtIndexPath(discoverIndexPath)

      self.notifyDelegateCreditCardSelected.assertValues([
        PaymentSourceSelected.savedCreditCard(UserCreditCards.amex.id, "pm_fake_amex"),
        PaymentSourceSelected.savedCreditCard(UserCreditCards.discover.id, "pm_fake_discover")
      ])
    }
  }

  func testPaymentSheetCardSetupIntent_UsedToNotifyDelegate_WhenPaymentSheetCardAdded_Success() {
    let userTemplateWithCards = self.userTemplate
      |> \.storedCards .~ UserCreditCards.withCards([UserCreditCards.visa])
    let response = UserEnvelope<GraphUser>(me: userTemplateWithCards)
    let addPaymentSheetResponse = CreatePaymentSourceEnvelope.paymentSourceSuccessTemplateWithId(
      "999",
      stripeCardId: nil
    )
    let mockService = MockService(
      addPaymentSheetPaymentSourceResult: .success(addPaymentSheetResponse),
      fetchGraphUserResult: .success(response)
    )

    withEnvironment(apiService: mockService, currentUser: User.template) {
      self.vm.inputs
        .configure(with: (
          User.template,
          Project.template,
          "checkoutID",
          Reward.template,
          .pledge,
          .discovery
        ))
      self.vm.inputs.viewDidLoad()

      self.scheduler.run()

      self.notifyDelegateCreditCardSelected.assertValues(
        [PaymentSourceSelected.savedCreditCard(UserCreditCards.visa.id, "pm_fake_visa")],
        "First card selected by default"
      )

      guard let paymentMethod = STPPaymentMethod.visaStripePaymentMethod else {
        XCTFail("Should've created payment method.")

        return
      }
      let paymentOption = STPPaymentMethod.sampleStringPaymentOption(paymentMethod)
      let paymentOptionsDisplayData = STPPaymentMethod.samplePaymentOptionsDisplayData(paymentOption)

      self.vm.inputs
        .paymentSheetDidAdd(
          clientSecret: "seti_1LVlHO4VvJ2PtfhK43R6p7FI_secret_MEDiGbxfYVnHGsQy8v8TbZJTQhlNKLZ",
          paymentMethod: "pm_fake_from_viewmodel"
        )

      self.scheduler.advance(by: 1)

      self.notifyDelegateCreditCardSelected.assertValues([
        PaymentSourceSelected.savedCreditCard(UserCreditCards.visa.id, "pm_fake_visa"),
        PaymentSourceSelected
          .savedCreditCard(
            addPaymentSheetResponse.createPaymentSource.paymentSource.id,
            "pm_fake_from_viewmodel"
          )
      ])
    }
  }

  func testPaymentSheetCardPaymentIntent_UsedToNotifyDelegate_WhenPaymentSheetCardAdded_Success() {
    let userTemplateWithCards = self.userTemplate
      |> \.storedCards .~ UserCreditCards.withCards([UserCreditCards.visa])
    let response = UserEnvelope<GraphUser>(me: userTemplateWithCards)
    let addPaymentSheetResponse = CreatePaymentSourceEnvelope.paymentSourceSuccessTemplateWithId(
      "999",
      stripeCardId: "pm_fake_from_response"
    )
    let mockService = MockService(
      addPaymentSheetPaymentSourceResult: .success(addPaymentSheetResponse),
      fetchGraphUserResult: .success(response)
    )

    withEnvironment(apiService: mockService, currentUser: User.template) {
      self.vm.inputs
        .configure(with: (
          User.template,
          Project.template,
          "checkoutID",
          Reward.template,
          .latePledge,
          .discovery
        ))
      self.vm.inputs.viewDidLoad()

      self.scheduler.run()

      self.notifyDelegateCreditCardSelected.assertValues(
        [PaymentSourceSelected.savedCreditCard(UserCreditCards.visa.id, "pm_fake_visa")],
        "First card selected by default"
      )

      guard let paymentMethod = STPPaymentMethod.visaStripePaymentMethod else {
        XCTFail("Should've created payment method.")

        return
      }

      let paymentOption = STPPaymentMethod.sampleStringPaymentOption(paymentMethod)

      self.vm.inputs
        .paymentSheetDidAdd(
          clientSecret: "fake_payment_intent",
          paymentMethod: "pm_fake_from_response"
        )

      self.scheduler.advance(by: 1)

      self.notifyDelegateCreditCardSelected.assertValues([
        PaymentSourceSelected.savedCreditCard(UserCreditCards.visa.id, "pm_fake_visa"),
        PaymentSourceSelected
          .savedCreditCard(
            addPaymentSheetResponse.createPaymentSource.paymentSource.id,
            "pm_fake_from_response"
          )
      ])
    }
  }

  func testCantSelectUnavailableCards() {
    let cards = UserCreditCards.withCards([
      UserCreditCards.visa,
      UserCreditCards.discover,
      UserCreditCards.amex
    ])
    let graphUser = GraphUser.template |> \.storedCards .~ cards
    let response = UserEnvelope<GraphUser>(me: graphUser)
    let mockService = MockService(fetchGraphUserResult: .success(response))
    let project = Project.template
      |> \.availableCardTypes .~ ["AMEX", "VISA", "MASTERCARD"]

    withEnvironment(apiService: mockService, currentUser: User.template) {
      self.vm.inputs
        .configure(with: (
          User.template,
          project,
          "checkoutID",
          Reward.template,
          .pledge,
          .discovery
        ))
      self.vm.inputs.viewDidLoad()

      self.scheduler.run()

      self.reloadPaymentMethodsCards.assertValues([
        [],
        [
          UserCreditCards.visa,
          UserCreditCards.amex,
          UserCreditCards.discover
        ]
      ], "Discover unavailable and ordered last")

      let discoverIndexPath = IndexPath(
        row: 2,
        section: PaymentMethodsTableViewSection.paymentMethods.rawValue
      )
      XCTAssertNil(self.vm.inputs.willSelectRowAtIndexPath(discoverIndexPath))

      let amexIndexPath = IndexPath(
        row: 1,
        section: PaymentMethodsTableViewSection.paymentMethods.rawValue
      )
      XCTAssertEqual(self.vm.inputs.willSelectRowAtIndexPath(amexIndexPath), amexIndexPath)

      let outOfBoundsIndexPath = IndexPath(
        row: 1, section: PaymentMethodsTableViewSection.loading.rawValue
      )
      XCTAssertNil(self.vm.inputs.willSelectRowAtIndexPath(outOfBoundsIndexPath))
    }
  }

  func testGoToAddNewCard_PledgeContext_Failure() {
    let project = Project.template
    let envelope = ClientSecretEnvelope(clientSecret: "test")
    let mockService = MockService(createStripeSetupIntentResult: .success(envelope))

    withEnvironment(
      apiService: mockService,
      currentUser: User.template
    ) {
      self.vm.inputs.viewDidLoad()
      self.vm.inputs
        .configure(with: (
          User.template,
          project,
          "checkoutID",
          Reward.template,
          .pledge,
          .discovery
        ))

      let addNewCardIndexPath = IndexPath(
        row: 0,
        section: PaymentMethodsTableViewSection.addNewCard.rawValue
      )
      self.vm.inputs.didSelectRowAtIndexPath(addNewCardIndexPath)

      self.goToAddStripeCardIntent.assertDidNotEmitValue()

      self.scheduler.run()

      XCTAssertEqual(self.goToAddStripeCardIntent.values.count, 1)
      XCTAssertEqual(self.mockStripeIntentService.setupIntentRequests, 1)
      XCTAssertEqual(self.mockStripeIntentService.paymentIntentRequests, 0)
    }
  }

  func testGoToAddNewCard_UpdatePledgeContext_Failure() {
    let project = Project.template
    let envelope = ClientSecretEnvelope(clientSecret: "test")
    let mockService = MockService(createStripeSetupIntentResult: .success(envelope))

    withEnvironment(
      apiService: mockService,
      currentUser: User.template
    ) {
      self.vm.inputs.viewDidLoad()
      self.vm.inputs
        .configure(with: (
          User.template,
          project,
          "checkoutID",
          Reward.template,
          .update,
          .discovery
        ))

      let addNewCardIndexPath = IndexPath(
        row: 0,
        section: PaymentMethodsTableViewSection.addNewCard.rawValue
      )
      self.vm.inputs.didSelectRowAtIndexPath(addNewCardIndexPath)

      self.goToAddStripeCardIntent.assertDidNotEmitValue()

      self.scheduler.run()

      XCTAssertEqual(self.goToAddStripeCardIntent.values.count, 1)
      XCTAssertEqual(self.mockStripeIntentService.setupIntentRequests, 1)
      XCTAssertEqual(self.mockStripeIntentService.paymentIntentRequests, 0)
    }
  }

  func testGoToAddNewCard_UpdateRewardContexts_Failure() {
    let project = Project.template
    let envelope = ClientSecretEnvelope(clientSecret: "test")
    let mockService = MockService(createStripeSetupIntentResult: .success(envelope))

    withEnvironment(
      apiService: mockService,
      currentUser: User.template
    ) {
      self.vm.inputs.viewDidLoad()
      self.vm.inputs
        .configure(with: (
          User.template,
          project,
          "checkoutID",
          Reward.template,
          .updateReward,
          .discovery
        ))

      let addNewCardIndexPath = IndexPath(
        row: 0,
        section: PaymentMethodsTableViewSection.addNewCard.rawValue
      )
      self.vm.inputs.didSelectRowAtIndexPath(addNewCardIndexPath)

      self.goToAddStripeCardIntent.assertDidNotEmitValue()

      self.scheduler.run()

      XCTAssertEqual(self.goToAddStripeCardIntent.values.count, 1)
      XCTAssertEqual(self.mockStripeIntentService.setupIntentRequests, 1)
      XCTAssertEqual(self.mockStripeIntentService.paymentIntentRequests, 0)
    }
  }

  func testGoToAddNewCard_ChangePaymentMethodContext_Failure() {
    let project = Project.template
    let envelope = ClientSecretEnvelope(clientSecret: "test")
    let mockService = MockService(createStripeSetupIntentResult: .success(envelope))

    withEnvironment(
      apiService: mockService,
      currentUser: User.template
    ) {
      self.vm.inputs.viewDidLoad()
      self.vm.inputs
        .configure(with: (
          User.template,
          project,
          "checkoutID",
          Reward.template,
          .changePaymentMethod,
          .discovery
        ))

      let addNewCardIndexPath = IndexPath(
        row: 0,
        section: PaymentMethodsTableViewSection.addNewCard.rawValue
      )
      self.vm.inputs.didSelectRowAtIndexPath(addNewCardIndexPath)

      self.goToAddStripeCardIntent.assertDidNotEmitValue()

      self.scheduler.run()

      XCTAssertEqual(self.goToAddStripeCardIntent.values.count, 1)
      XCTAssertEqual(self.mockStripeIntentService.setupIntentRequests, 1)
      XCTAssertEqual(self.mockStripeIntentService.paymentIntentRequests, 0)
    }
  }

  func testGoToAddNewCard_FixPaymentMethodContext_Failure() {
    let project = Project.template
    let envelope = ClientSecretEnvelope(clientSecret: "test")
    let mockService = MockService(createStripeSetupIntentResult: .success(envelope))

    withEnvironment(
      apiService: mockService,
      currentUser: User.template
    ) {
      self.vm.inputs.viewDidLoad()
      self.vm.inputs
        .configure(with: (
          User.template,
          project,
          "checkoutID",
          Reward.template,
          .fixPaymentMethod,
          .discovery
        ))

      let addNewCardIndexPath = IndexPath(
        row: 0,
        section: PaymentMethodsTableViewSection.addNewCard.rawValue
      )
      self.vm.inputs.didSelectRowAtIndexPath(addNewCardIndexPath)

      XCTAssertEqual(self.goToAddStripeCardIntent.values.count, 0)

      self.scheduler.run()

      XCTAssertEqual(self.goToAddStripeCardIntent.values.count, 1)
      XCTAssertEqual(self.mockStripeIntentService.setupIntentRequests, 1)
      XCTAssertEqual(self.mockStripeIntentService.paymentIntentRequests, 0)
    }
  }

  func testGoToAddNewStripeCard_NoStoredCards_Success() {
    let project = Project.template
    let graphUser = GraphUser.template |> \.storedCards .~ UserCreditCards.withCards([])
    let response = UserEnvelope<GraphUser>(me: graphUser)
    let addPaymentSheetResponse = CreatePaymentSourceEnvelope.paymentSourceSuccessTemplateWithId("999")
    let mockService = MockService(
      addPaymentSheetPaymentSourceResult: .success(addPaymentSheetResponse),
      fetchGraphUserResult: .success(response)
    )

    withEnvironment(
      apiService: mockService,
      currentUser: User.template
    ) {
      self.vm.inputs.viewDidLoad()
      self.vm.inputs
        .configure(with: (
          User.template,
          project,
          "checkoutID",
          Reward.template,
          .pledge,
          .discovery
        ))

      guard let paymentMethod = STPPaymentMethod.visaStripePaymentMethod else {
        XCTFail("Should've created payment method.")

        return
      }
      let paymentOption = STPPaymentMethod.sampleStringPaymentOption(paymentMethod)
      let paymentOptionsDisplayData = STPPaymentMethod.samplePaymentOptionsDisplayData(paymentOption)

      self.scheduler.advance(by: .seconds(1))

      self.vm.inputs
        .paymentSheetDidAdd(
          clientSecret: "seti_1LVlHO4VvJ2PtfhK43R6p7FI_secret_MEDiGbxfYVnHGsQy8v8TbZJTQhlNKLZ",
          paymentMethod: "pm_fake"
        )

      self.scheduler.advance(by: 1)

      XCTAssertEqual(self.reloadPaymentMethodsCards.lastValue, [])
      XCTAssertNotNil(self.reloadPaymentSheetPaymentMethodsCards.lastValue?.last?.card)
      XCTAssertEqual(
        self.reloadPaymentSheetPaymentMethodsCards.lastValue?.last?.card.id,
        addPaymentSheetResponse.createPaymentSource.paymentSource.id
      )
    }
  }

  func testGoToAddNewStripeCard_NoStoredCards_NewCardIsUnavailable_AddsButIsNotSelected() {
    let project = Project.template
      |> \.availableCardTypes .~ []

    let graphUser = GraphUser.template |> \.storedCards .~ UserCreditCards.withCards([])
    let response = UserEnvelope<GraphUser>(me: graphUser)
    let addPaymentSheetResponse = CreatePaymentSourceEnvelope.paymentSourceSuccessTemplateWithId("999")
    let mockService = MockService(
      addPaymentSheetPaymentSourceResult: .success(addPaymentSheetResponse),
      fetchGraphUserResult: .success(response)
    )

    withEnvironment(
      apiService: mockService,
      currentUser: User.template
    ) {
      self.vm.inputs.viewDidLoad()
      self.vm.inputs
        .configure(with: (
          User.template,
          project,
          "checkoutID",
          Reward.template,
          .pledge,
          .discovery
        ))

      guard let paymentMethod = STPPaymentMethod.visaStripePaymentMethod else {
        XCTFail("Should've created payment method.")

        return
      }
      let paymentOption = STPPaymentMethod.sampleStringPaymentOption(paymentMethod)
      let paymentOptionsDisplayData = STPPaymentMethod.samplePaymentOptionsDisplayData(paymentOption)

      self.scheduler.advance(by: .seconds(1))

      self.vm.inputs
        .paymentSheetDidAdd(
          clientSecret: "seti_1LVlHO4VvJ2PtfhK43R6p7FI_secret_MEDiGbxfYVnHGsQy8v8TbZJTQhlNKLZ",
          paymentMethod: "pm_fake"
        )

      self.scheduler.advance(by: 1)

      XCTAssertEqual(self.reloadPaymentMethodsCards.lastValue, [])
      let paymentSheetCard = self.reloadPaymentSheetPaymentMethodsCards.lastValue?.last

      XCTAssertNotNil(paymentSheetCard?.card)
      XCTAssertEqual(
        paymentSheetCard?.card.id,
        addPaymentSheetResponse.createPaymentSource.paymentSource.id
      )
      XCTAssertFalse(paymentSheetCard?.isEnabled ?? false)
      XCTAssertFalse(paymentSheetCard?.isSelected ?? false)

      self.reloadPaymentMethodsSelectedCardId
        .assertValues([nil, nil, nil])
    }
  }

  func testGoToAddNewStripeCard_WithStoredCards_NewCardIsUnavailable_AddsButIsNotSelected() {
    let project = Project.template
      |> \.availableCardTypes .~ [CreditCardType.amex.rawValue]

    let graphUser = GraphUser.template |> \.storedCards .~ UserCreditCards.withCards([UserCreditCards.amex])
    let response = UserEnvelope<GraphUser>(me: graphUser)
    let addPaymentSheetResponse = CreatePaymentSourceEnvelope.paymentSourceSuccessTemplateWithId("999")
    let mockService = MockService(
      addPaymentSheetPaymentSourceResult: .success(addPaymentSheetResponse),
      fetchGraphUserResult: .success(response)
    )

    withEnvironment(
      apiService: mockService,
      currentUser: User.template
    ) {
      self.vm.inputs.viewDidLoad()
      self.vm.inputs
        .configure(with: (
          User.template,
          project,
          "checkoutID",
          Reward.template,
          .pledge,
          .discovery
        ))

      guard let paymentMethod = STPPaymentMethod.visaStripePaymentMethod else {
        XCTFail("Should've created payment method.")

        return
      }
      let paymentOption = STPPaymentMethod.sampleStringPaymentOption(paymentMethod)
      let paymentOptionsDisplayData = STPPaymentMethod.samplePaymentOptionsDisplayData(paymentOption)

      self.scheduler.advance(by: .seconds(1))

      self.vm.inputs
        .paymentSheetDidAdd(
          clientSecret: "seti_1LVlHO4VvJ2PtfhK43R6p7FI_secret_MEDiGbxfYVnHGsQy8v8TbZJTQhlNKLZ",
          paymentMethod: "pm_fake"
        )

      self.scheduler.advance(by: 1)

      XCTAssertEqual(self.reloadPaymentMethodsCards.lastValue?.last?.id, UserCreditCards.amex.id)

      let paymentSheetCard = self.reloadPaymentSheetPaymentMethodsCards.lastValue?.last

      XCTAssertNotNil(paymentSheetCard?.card)
      XCTAssertEqual(
        paymentSheetCard?.card.id,
        addPaymentSheetResponse.createPaymentSource.paymentSource.id
      )
      XCTAssertFalse(paymentSheetCard?.isEnabled ?? false)
      XCTAssertFalse(paymentSheetCard?.isSelected ?? false)

      self.reloadPaymentMethodsSelectedCardId
        .assertValues([nil, UserCreditCards.amex.id, UserCreditCards.amex.id])
    }
  }

  func testGoToAddNewStripeCard_WithStoredCards_Sucess() {
    let project = Project.template
    let graphUser = GraphUser.template |> \.storedCards .~ UserCreditCards.withCards([UserCreditCards.visa])
    let response = UserEnvelope<GraphUser>(me: graphUser)
    let addPaymentSheetResponse = CreatePaymentSourceEnvelope.paymentSourceSuccessTemplateWithId("999")
    let mockService = MockService(
      addPaymentSheetPaymentSourceResult: .success(addPaymentSheetResponse),
      fetchGraphUserResult: .success(response)
    )

    withEnvironment(
      apiService: mockService,
      currentUser: User.template
    ) {
      self.vm.inputs.viewDidLoad()
      self.vm.inputs
        .configure(with: (
          User.template,
          project,
          "checkoutID",
          Reward.template,
          .pledge,
          .discovery
        ))

      guard let paymentMethod = STPPaymentMethod.amexStripePaymentMethod else {
        XCTFail("Should've created payment method.")

        return
      }

      let paymentOption = STPPaymentMethod.sampleStringPaymentOption(paymentMethod)
      let paymentOptionsDisplayData = STPPaymentMethod.samplePaymentOptionsDisplayData(paymentOption)

      self.scheduler.advance(by: .seconds(1))

      self.vm.inputs
        .paymentSheetDidAdd(
          clientSecret: "seti_1LVlHO4VvJ2PtfhK43R6p7FI_secret_MEDiGbxfYVnHGsQy8v8TbZJTQhlNKLZ",
          paymentMethod: "pm_fake"
        )

      self.scheduler.advance(by: 1)

      XCTAssertEqual(self.reloadPaymentMethodsCards.lastValue, [UserCreditCards.visa])
      XCTAssertNotNil(self.reloadPaymentSheetPaymentMethodsCards.lastValue?.last?.card.lastFour)
      XCTAssertEqual(
        self.reloadPaymentSheetPaymentMethodsCards.lastValue?.last?.card.id,
        addPaymentSheetResponse.createPaymentSource.paymentSource.id
      )
    }
  }

  func testLoadingStateAddNewCard_ShowAndHide_Success() {
    let project = Project.template
    let addNewCardIndexPath = IndexPath(
      row: 0,
      section: PaymentMethodsTableViewSection.addNewCard.rawValue
    )

    let mockService = MockService(createStripeSetupIntentResult: .failure(.couldNotParseErrorEnvelopeJSON))

    withEnvironment(
      apiService: mockService,
      currentUser: User.template
    ) {
      self.vm.inputs.viewDidLoad()
      self.vm.inputs
        .configure(with: (
          User.template,
          project,
          "checkoutID",
          Reward.template,
          .pledge,
          .discovery
        ))
      self.vm.inputs.didSelectRowAtIndexPath(addNewCardIndexPath)

      self.scheduler.run()

      self.addNewCardLoadingState.assertValues([true, false])

      XCTAssertEqual(self.mockStripeIntentService.setupIntentRequests, 1)
      XCTAssertEqual(self.mockStripeIntentService.paymentIntentRequests, 0)
    }
  }

  func testLoadingStateAddNewCard_ShowAndHide_NonCardSelectionNonAddNewCardContext_Success() {
    let project = Project.template

    let mockService = MockService(createStripeSetupIntentResult: .failure(.couldNotParseErrorEnvelopeJSON))

    withEnvironment(
      apiService: mockService,
      currentUser: User.template
    ) {
      self.vm.inputs.viewDidLoad()
      self.vm.inputs
        .configure(with: (
          User.template,
          project,
          "checkoutID",
          Reward.template,
          .pledge,
          .discovery
        ))
      self.vm.inputs.shouldCancelPaymentSheetAppearance(state: true)
      self.vm.inputs.shouldCancelPaymentSheetAppearance(state: false)
      self.vm.inputs.shouldCancelPaymentSheetAppearance(state: false)
      self.vm.inputs.shouldCancelPaymentSheetAppearance(state: false)

      self.scheduler.run()

      self.addNewCardLoadingState.assertValues([false, true, true, true])

      XCTAssertEqual(self.mockStripeIntentService.setupIntentRequests, 0)
      XCTAssertEqual(self.mockStripeIntentService.paymentIntentRequests, 0)
    }
  }

  func testLoadingStateAddNewCard_ShowAndHide_CardSelectionContext_Success() {
    let cards = UserCreditCards.withCards([
      UserCreditCards.visa,
      UserCreditCards.masterCard,
      UserCreditCards.amex
    ])
    let graphUser = GraphUser.template |> \.storedCards .~ cards
    let response = UserEnvelope<GraphUser>(me: graphUser)
    let mockService = MockService(fetchGraphUserResult: .success(response))
    let project = Project.template
      |> \.availableCardTypes .~ ["AMEX", "VISA", "MASTERCARD"]
    let paymentMethodSelectionIndexPath = IndexPath(
      row: 1,
      section: PaymentMethodsTableViewSection.paymentMethods.rawValue
    )

    withEnvironment(
      apiService: mockService,
      currentUser: User.template
    ) {
      self.vm.inputs.viewDidLoad()
      self.vm.inputs
        .configure(with: (
          User.template,
          project,
          "checkoutID",
          Reward.template,
          .pledge,
          .discovery
        ))
      self.vm.inputs.shouldCancelPaymentSheetAppearance(state: false)

      self.scheduler.advance(by: .seconds(1))
      self.vm.inputs.didSelectRowAtIndexPath(paymentMethodSelectionIndexPath)

      self.scheduler.run()

      self.addNewCardLoadingState.assertValues([true, false])
    }
  }

  func testGoToAddNewStripeCardScreen_PledgeContext_Success() {
    let project = Project.template
    let addNewCardIndexPath = IndexPath(
      row: 0,
      section: PaymentMethodsTableViewSection.addNewCard.rawValue
    )
    let envelope = ClientSecretEnvelope(clientSecret: "test")
    let mockService = MockService(createStripeSetupIntentResult: .success(envelope))
    var configuration = PaymentSheet.Configuration()
    configuration.merchantDisplayName = Strings.general_accessibility_kickstarter()
    configuration.allowsDelayedPaymentMethods = true

    withEnvironment(
      apiService: mockService,
      currentUser: User.template
    ) {
      self.vm.inputs.viewDidLoad()
      self.vm.inputs
        .configure(with: (
          User.template,
          project,
          "checkoutID",
          Reward.template,
          .pledge,
          .discovery
        ))
      self.vm.inputs.didSelectRowAtIndexPath(addNewCardIndexPath)

      self.scheduler.run()

      XCTAssertEqual(self.goToAddStripeCardIntent.values.count, 1)
      XCTAssertEqual(self.goToAddStripeCardIntent.lastValue?.clientSecret, "test")
      XCTAssertEqual(
        self.goToAddStripeCardIntent.lastValue?.configuration.merchantDisplayName,
        Strings.general_accessibility_kickstarter()
      )

      guard let allowedDelayedPaymentMethods = self.goToAddStripeCardIntent.lastValue?.configuration
        .allowsDelayedPaymentMethods else {
        XCTFail()

        return
      }

      XCTAssertTrue(allowedDelayedPaymentMethods)
      XCTAssertEqual(self.mockStripeIntentService.setupIntentRequests, 1)
      XCTAssertEqual(self.mockStripeIntentService.paymentIntentRequests, 0)
    }
  }

  func testGoToAddNewStripeCardScreen_LatePledgeContext_Success() {
    let project = Project.template
    let addNewCardIndexPath = IndexPath(
      row: 0,
      section: PaymentMethodsTableViewSection.addNewCard.rawValue
    )
    let envelope = ClientSecretEnvelope(clientSecret: "test")
    let mockService = MockService(createStripeSetupIntentResult: .success(envelope))
    var configuration = PaymentSheet.Configuration()
    configuration.merchantDisplayName = Strings.general_accessibility_kickstarter()
    configuration.allowsDelayedPaymentMethods = true

    withEnvironment(
      apiService: mockService,
      currentUser: User.template
    ) {
      self.vm.inputs.viewDidLoad()
      self.vm.inputs
        .configure(with: (
          User.template,
          project,
          "checkoutID",
          Reward.template,
          .latePledge,
          .discovery
        ))
      self.vm.inputs.didSelectRowAtIndexPath(addNewCardIndexPath)

      self.scheduler.run()

      XCTAssertEqual(self.goToAddStripeCardIntent.values.count, 1)
      XCTAssertEqual(self.goToAddStripeCardIntent.lastValue?.clientSecret, "test")
      XCTAssertEqual(
        self.goToAddStripeCardIntent.lastValue?.configuration.merchantDisplayName,
        Strings.general_accessibility_kickstarter()
      )

      guard let allowedDelayedPaymentMethods = self.goToAddStripeCardIntent.lastValue?.configuration
        .allowsDelayedPaymentMethods else {
        XCTFail()

        return
      }

      XCTAssertTrue(allowedDelayedPaymentMethods)
    }
  }
}
