import Foundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import XCTest

final class PledgePaymentMethodsViewModelTests: TestCase {
  private let vm: PledgePaymentMethodsViewModelType = PledgePaymentMethodsViewModel()

  private let goToAddCardIntent = TestObserver<AddNewCardIntent, Never>()
  private let goToProject = TestObserver<Project, Never>()
  private let notifyDelegateCreditCardSelected = TestObserver<String, Never>()
  private let notifyDelegateLoadPaymentMethodsError = TestObserver<String, Never>()

  private let reloadPaymentMethodsCards = TestObserver<[GraphUserCreditCard.CreditCard], Never>()
  private let reloadPaymentMethodsAvailableCardTypes = TestObserver<[Bool], Never>()
  private let reloadPaymentMethodsIsLoading = TestObserver<Bool, Never>()
  private let reloadPaymentMethodsIsSelected = TestObserver<[Bool], Never>()
  private let reloadPaymentMethodsProjectCountry = TestObserver<[String], Never>()
  private let reloadPaymentMethodsSelectedCard = TestObserver<GraphUserCreditCard.CreditCard?, Never>()
  private let reloadPaymentMethodsShouldReload = TestObserver<Bool, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.goToAddCardScreen.map(first).observe(self.goToAddCardIntent.observer)
    self.vm.outputs.goToAddCardScreen.map(second).observe(self.goToProject.observer)
    self.vm.outputs.notifyDelegateCreditCardSelected
      .observe(self.notifyDelegateCreditCardSelected.observer)
    self.vm.outputs.notifyDelegateLoadPaymentMethodsError
      .observe(self.notifyDelegateLoadPaymentMethodsError.observer)

    // swiftlint:disable line_length
    self.vm.outputs.reloadPaymentMethods.map { $0.0 }.map { $0.map { $0.card } }
      .observe(self.reloadPaymentMethodsCards.observer)
    self.vm.outputs.reloadPaymentMethods.map { $0.0 }.map { $0.map { $0.isEnabled } }
      .observe(self.reloadPaymentMethodsAvailableCardTypes.observer)
    self.vm.outputs.reloadPaymentMethods.map { $0.0 }.map { $0.map { $0.isSelected } }
      .observe(self.reloadPaymentMethodsIsSelected.observer)
    self.vm.outputs.reloadPaymentMethods.map { $0.0 }.map { $0.map { $0.projectCountry } }
      .observe(self.reloadPaymentMethodsProjectCountry.observer)
    self.vm.outputs.reloadPaymentMethods.map { $0.1 }.observe(self.reloadPaymentMethodsSelectedCard.observer)
    self.vm.outputs.reloadPaymentMethods.map { $0.2 }.observe(self.reloadPaymentMethodsShouldReload.observer)
    self.vm.outputs.reloadPaymentMethods.map { $0.3 }.observe(self.reloadPaymentMethodsIsLoading.observer)
    // swiftlint:enable line_length
  }

  // MARK: - New card added

  func testReloadPaymentMethods_NewCardAdded_UnavailableIsLast() {
    let response = UserEnvelope<GraphUserCreditCard>(me: GraphUserCreditCard.template)
    let mockService = MockService(fetchGraphCreditCardsResponse: response)
    let userCreditCard = GraphUserCreditCard.visa |> \.id .~ "10"

    withEnvironment(apiService: mockService, currentUser: User.template) {
      self.reloadPaymentMethodsCards.assertDidNotEmitValue()
      self.reloadPaymentMethodsAvailableCardTypes.assertDidNotEmitValue()
      self.reloadPaymentMethodsIsSelected.assertDidNotEmitValue()
      self.reloadPaymentMethodsProjectCountry.assertDidNotEmitValue()
      self.reloadPaymentMethodsSelectedCard.assertDidNotEmitValue()
      self.reloadPaymentMethodsShouldReload.assertDidNotEmitValue()
      self.reloadPaymentMethodsIsLoading.assertDidNotEmitValue()

      self.vm.inputs.configure(with: (User.template, Project.template, Reward.template, .pledge, .discovery))
      self.vm.inputs.viewDidLoad()

      self.scheduler.run()

      self.reloadPaymentMethodsCards.assertValues([[], response.me.storedCards.nodes])
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
        (0...response.me.storedCards.nodes.count - 1).map { _ in "Brooklyn, NY" }
      ], "One card is unavailable")
      self.reloadPaymentMethodsSelectedCard.assertValues([nil, response.me.storedCards.nodes.first])
      self.reloadPaymentMethodsShouldReload.assertValues([true, true])
      self.reloadPaymentMethodsIsLoading.assertValues([true, false])

      self.vm.inputs.addNewCardViewControllerDidAdd(newCard: userCreditCard)

      self.reloadPaymentMethodsCards.assertValues(
        [
          [],
          [
            GraphUserCreditCard.amex,
            GraphUserCreditCard.masterCard,
            GraphUserCreditCard.visa,
            GraphUserCreditCard.diners,
            GraphUserCreditCard.jcb,
            GraphUserCreditCard.discover,
            GraphUserCreditCard.unionPay,
            GraphUserCreditCard.generic
          ], [
            userCreditCard,
            GraphUserCreditCard.amex,
            GraphUserCreditCard.masterCard,
            GraphUserCreditCard.visa,
            GraphUserCreditCard.diners,
            GraphUserCreditCard.jcb,
            GraphUserCreditCard.discover,
            GraphUserCreditCard.unionPay,
            GraphUserCreditCard.generic
          ]
        ]
      )
      self.reloadPaymentMethodsAvailableCardTypes.assertValues([
        [],
        [true, true, true, true, true, true, true, false],
        [true, true, true, true, true, true, true, true, false]
      ])
      self.reloadPaymentMethodsIsSelected.assertValues([
        [],
        [true, false, false, false, false, false, false, false],
        [true, false, false, false, false, false, false, false, false]
      ], "First card is selected")
      self.reloadPaymentMethodsProjectCountry.assertValues([
        [],
        (0...response.me.storedCards.nodes.count - 1).map { _ in "Brooklyn, NY" },
        (0...response.me.storedCards.nodes.count).map { _ in "Brooklyn, NY" }
      ], "New and available card added")
      self.reloadPaymentMethodsSelectedCard.assertValues([
        nil,
        response.me.storedCards.nodes.first,
        userCreditCard
      ])
      self.reloadPaymentMethodsShouldReload.assertValues([true, true, true])
    }
  }

  func testReloadPaymentMethods_NewCardAdded_ProjectHasBacking() {
    let cards = GraphUserCreditCard.withCards([
      GraphUserCreditCard.amex,
      GraphUserCreditCard.visa,
      GraphUserCreditCard.masterCard,
      GraphUserCreditCard.diners,
      GraphUserCreditCard.generic
    ])
    let response = UserEnvelope<GraphUserCreditCard>(me: cards)
    let mockService = MockService(fetchGraphCreditCardsResponse: response)

    self.reloadPaymentMethodsCards.assertDidNotEmitValue()
    self.reloadPaymentMethodsAvailableCardTypes.assertDidNotEmitValue()
    self.reloadPaymentMethodsIsSelected.assertDidNotEmitValue()
    self.reloadPaymentMethodsProjectCountry.assertDidNotEmitValue()
    self.reloadPaymentMethodsSelectedCard.assertDidNotEmitValue()
    self.reloadPaymentMethodsShouldReload.assertDidNotEmitValue()
    self.reloadPaymentMethodsIsLoading.assertDidNotEmitValue()

    withEnvironment(apiService: mockService, currentUser: User.template) {
      let paymentSource = Backing.PaymentSource.template
        |> \.id .~ "2" // Matches GraphUserCreditCard.visa template id

      let project = Project.template
        |> Project.lens.personalization.backing .~ (
          Backing.template
            |> Backing.lens.paymentSource .~ paymentSource
        )

      self.vm.inputs.configure(with: (User.template, project, .template, .pledge, .discovery))
      self.vm.inputs.viewDidLoad()

      self.scheduler.run()

      self.reloadPaymentMethodsCards.assertValues([
        [],
        [
          GraphUserCreditCard.visa,
          GraphUserCreditCard.amex,
          GraphUserCreditCard.masterCard,
          GraphUserCreditCard.diners,
          GraphUserCreditCard.generic
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
        (0...response.me.storedCards.nodes.count - 1).map { _ in "Brooklyn, NY" }
      ], "One card is unavailable")
      self.reloadPaymentMethodsSelectedCard.assertValues(
        [nil, GraphUserCreditCard.visa],
        "Card used for backing is selected"
      )
      self.reloadPaymentMethodsShouldReload.assertValues([true, true])

      let newCard = GraphUserCreditCard.visa
        |> \.id .~ "123"
        |> \.lastFour .~ "1234"

      self.vm.inputs.addNewCardViewControllerDidAdd(newCard: newCard)

      self.reloadPaymentMethodsCards.assertValues([
        [],
        [
          GraphUserCreditCard.visa,
          GraphUserCreditCard.amex,
          GraphUserCreditCard.masterCard,
          GraphUserCreditCard.diners,
          GraphUserCreditCard.generic
        ],
        [
          newCard,
          GraphUserCreditCard.visa,
          GraphUserCreditCard.amex,
          GraphUserCreditCard.masterCard,
          GraphUserCreditCard.diners,
          GraphUserCreditCard.generic
        ]
      ], "New card added is first")
      self.reloadPaymentMethodsAvailableCardTypes.assertValues([
        [],
        [true, true, true, true, false],
        [true, true, true, true, true, false]
      ])
      self.reloadPaymentMethodsIsSelected.assertValues([
        [],
        [true, false, false, false, false],
        [true, false, false, false, false, false]
      ], "First card is selected")
      self.reloadPaymentMethodsProjectCountry.assertValues([
        [],
        (0...response.me.storedCards.nodes.count - 1).map { _ in "Brooklyn, NY" },
        (0...response.me.storedCards.nodes.count).map { _ in "Brooklyn, NY" }
      ], "One card is unavailable")
      self.reloadPaymentMethodsSelectedCard.assertValues(
        [
          nil,
          GraphUserCreditCard.visa,
          newCard
        ],
        "Newly added card is selected"
      )
      self.reloadPaymentMethodsShouldReload.assertValues([true, true, true])
    }
  }

  func testReloadPaymentMethods_NewCardAdded_NoStoredCards() {
    let response = UserEnvelope<GraphUserCreditCard>(me: GraphUserCreditCard.emptyTemplate)
    let mockService = MockService(fetchGraphCreditCardsResponse: response)

    withEnvironment(apiService: mockService, currentUser: User.template) {
      self.reloadPaymentMethodsCards.assertDidNotEmitValue()
      self.reloadPaymentMethodsAvailableCardTypes.assertDidNotEmitValue()
      self.reloadPaymentMethodsIsSelected.assertDidNotEmitValue()
      self.reloadPaymentMethodsProjectCountry.assertDidNotEmitValue()
      self.reloadPaymentMethodsSelectedCard.assertDidNotEmitValue()
      self.reloadPaymentMethodsShouldReload.assertDidNotEmitValue()
      self.reloadPaymentMethodsIsLoading.assertDidNotEmitValue()

      self.vm.inputs.configure(with: (User.template, Project.template, Reward.template, .pledge, .discovery))
      self.vm.inputs.viewDidLoad()

      self.scheduler.run()

      self.reloadPaymentMethodsCards.assertValues([[], []])
      self.reloadPaymentMethodsAvailableCardTypes.assertValues([[], []])
      self.reloadPaymentMethodsIsSelected.assertValues([[], []])
      self.reloadPaymentMethodsProjectCountry.assertValues([[], []])
      self.reloadPaymentMethodsSelectedCard.assertValues([nil, nil], "No card to select")
      self.reloadPaymentMethodsShouldReload.assertValues([true, true])

      self.vm.inputs.addNewCardViewControllerDidAdd(newCard: GraphUserCreditCard.visa)

      self.reloadPaymentMethodsCards.assertValues([[], [], [GraphUserCreditCard.visa]])
      self.reloadPaymentMethodsAvailableCardTypes.assertValues([[], [], [true]])
      self.reloadPaymentMethodsIsSelected.assertValues([[], [], [true]])
      self.reloadPaymentMethodsProjectCountry.assertValues([[], [], ["Brooklyn, NY"]])
      self.reloadPaymentMethodsSelectedCard
        .assertValues([nil, nil, GraphUserCreditCard.visa], "Added card is selected")
      self.reloadPaymentMethodsShouldReload.assertValues([true, true, true])
    }
  }

  func testReloadPaymentMethods_FirstCardUnavailable_UnavailableCardOrderedLast() {
    let cards = GraphUserCreditCard.withCards([
      GraphUserCreditCard.discover,
      GraphUserCreditCard.visa,
      GraphUserCreditCard.amex
    ])
    let response = UserEnvelope<GraphUserCreditCard>(me: cards)
    let mockService = MockService(fetchGraphCreditCardsResponse: response)
    let project = Project.template
      |> \.availableCardTypes .~ ["AMEX", "VISA", "MASTERCARD"]

    withEnvironment(apiService: mockService, currentUser: User.template) {
      self.reloadPaymentMethodsCards.assertDidNotEmitValue()
      self.reloadPaymentMethodsAvailableCardTypes.assertDidNotEmitValue()
      self.reloadPaymentMethodsIsSelected.assertDidNotEmitValue()
      self.reloadPaymentMethodsProjectCountry.assertDidNotEmitValue()
      self.reloadPaymentMethodsSelectedCard.assertDidNotEmitValue()
      self.reloadPaymentMethodsShouldReload.assertDidNotEmitValue()
      self.reloadPaymentMethodsIsLoading.assertDidNotEmitValue()

      self.vm.inputs.configure(with: (User.template, project, Reward.template, .pledge, .discovery))
      self.vm.inputs.viewDidLoad()

      self.scheduler.run()

      self.reloadPaymentMethodsCards.assertValues([
        [],
        [
          GraphUserCreditCard.visa,
          GraphUserCreditCard.amex,
          GraphUserCreditCard.discover
        ]
      ])
      self.reloadPaymentMethodsAvailableCardTypes.assertValues([[], [true, true, false]])
      self.reloadPaymentMethodsIsSelected.assertValues([[], [true, false, false]])
      self.reloadPaymentMethodsProjectCountry.assertValues([
        [],
        ["Brooklyn, NY", "Brooklyn, NY", "Brooklyn, NY"]
      ])
      self.reloadPaymentMethodsSelectedCard.assertValues([nil, GraphUserCreditCard.visa])
      self.reloadPaymentMethodsShouldReload.assertValues([true, true])
    }
  }

  func testReloadPaymentMethods_LoggedOut() {
    let response = UserEnvelope<GraphUserCreditCard>(me: GraphUserCreditCard.template)
    let mockService = MockService(fetchGraphCreditCardsResponse: response)

    withEnvironment(apiService: mockService, currentUser: nil) {
      self.vm.inputs.viewDidLoad()

      self.reloadPaymentMethodsCards.assertDidNotEmitValue()
      self.reloadPaymentMethodsAvailableCardTypes.assertDidNotEmitValue()
      self.reloadPaymentMethodsIsSelected.assertDidNotEmitValue()
      self.reloadPaymentMethodsProjectCountry.assertDidNotEmitValue()
      self.reloadPaymentMethodsSelectedCard.assertDidNotEmitValue()
      self.reloadPaymentMethodsShouldReload.assertDidNotEmitValue()
      self.reloadPaymentMethodsIsLoading.assertDidNotEmitValue()
      self.notifyDelegateLoadPaymentMethodsError.assertDidNotEmitValue()

      self.scheduler.run()

      self.reloadPaymentMethodsCards.assertDidNotEmitValue()
      self.reloadPaymentMethodsAvailableCardTypes.assertDidNotEmitValue()
      self.reloadPaymentMethodsIsSelected.assertDidNotEmitValue()
      self.reloadPaymentMethodsProjectCountry.assertDidNotEmitValue()
      self.reloadPaymentMethodsSelectedCard.assertDidNotEmitValue()
      self.reloadPaymentMethodsShouldReload.assertDidNotEmitValue()
      self.reloadPaymentMethodsIsLoading.assertDidNotEmitValue()
      self.notifyDelegateLoadPaymentMethodsError.assertDidNotEmitValue()
    }
  }

  func testCreditCardSelected() {
    let response = UserEnvelope<GraphUserCreditCard>(me: GraphUserCreditCard.template)
    let mockService = MockService(fetchGraphCreditCardsResponse: response)

    withEnvironment(apiService: mockService, currentUser: User.template) {
      self.vm.inputs.configure(with: (User.template, Project.template, Reward.template, .pledge, .discovery))
      self.vm.inputs.viewDidLoad()

      self.scheduler.run()

      self.notifyDelegateCreditCardSelected.assertValues(
        [GraphUserCreditCard.amex.id], "First card selected by default"
      )

      let discoverIndexPath = IndexPath(
        row: 5,
        section: PaymentMethodsTableViewSection.paymentMethods.rawValue
      )

      self.vm.inputs.didSelectRowAtIndexPath(discoverIndexPath)

      self.notifyDelegateCreditCardSelected.assertValues([
        GraphUserCreditCard.amex.id, GraphUserCreditCard.discover.id
      ])
    }
  }

  func testCantSelectUnavailableCards() {
    let cards = GraphUserCreditCard.withCards([
      GraphUserCreditCard.visa,
      GraphUserCreditCard.discover,
      GraphUserCreditCard.amex
    ])
    let response = UserEnvelope<GraphUserCreditCard>(me: cards)
    let mockService = MockService(fetchGraphCreditCardsResponse: response)
    let project = Project.template
      |> \.availableCardTypes .~ ["AMEX", "VISA", "MASTERCARD"]

    withEnvironment(apiService: mockService, currentUser: User.template) {
      self.vm.inputs.configure(with: (User.template, project, Reward.template, .pledge, .discovery))
      self.vm.inputs.viewDidLoad()

      self.scheduler.run()

      self.reloadPaymentMethodsCards.assertValues([
        [],
        [
          GraphUserCreditCard.visa,
          GraphUserCreditCard.amex,
          GraphUserCreditCard.discover
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

  func testGoToAddNewCard() {
    let project = Project.template

    self.vm.inputs.viewDidLoad()
    self.vm.inputs.configure(with: (User.template, project, Reward.template, .pledge, .discovery))

    let addNewCardIndexPath = IndexPath(
      row: 0,
      section: PaymentMethodsTableViewSection.addNewCard.rawValue
    )

    self.vm.inputs.didSelectRowAtIndexPath(addNewCardIndexPath)
    self.goToAddCardIntent.assertValues([.pledge])
    self.goToProject.assertValues([project])
  }

  func testGoToAddNewCard_NoStoredCards() {
    let project = Project.template
    let cards = GraphUserCreditCard.withCards([])
    let response = UserEnvelope<GraphUserCreditCard>(me: cards)
    let mockService = MockService(fetchGraphCreditCardsResponse: response)

    withEnvironment(apiService: mockService, currentUser: User.template) {
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.configure(with: (User.template, project, Reward.template, .pledge, .discovery))

      let addNewCardIndexPath = IndexPath(
        row: 0,
        section: PaymentMethodsTableViewSection.addNewCard.rawValue
      )

      self.vm.inputs.didSelectRowAtIndexPath(addNewCardIndexPath)
      self.goToAddCardIntent.assertValues([.pledge])
      self.goToProject.assertValues([project])
    }
  }

  func testTrackingEvents_PledgeContext() {
    let project = Project.template

    self.vm.inputs.viewDidLoad()
    self.vm.inputs.configure(with: (User.template, project, Reward.template, .pledge, .discovery))

    XCTAssertEqual([], self.trackingClient.events)

    let addNewCardIndexPath = IndexPath(
      row: 0,
      section: PaymentMethodsTableViewSection.addNewCard.rawValue
    )

    self.vm.inputs.didSelectRowAtIndexPath(addNewCardIndexPath)

    XCTAssertEqual(["Add New Card Button Clicked"], self.trackingClient.events)

    XCTAssertEqual(["new_pledge"], self.trackingClient.properties(forKey: "context_pledge_flow"))
    XCTAssertEqual(["discovery"], self.trackingClient.properties(forKey: "session_ref_tag"))
  }

  func testTrackingEvents_UpdateContext() {
    let project = Project.template

    self.vm.inputs.viewDidLoad()
    self.vm.inputs.configure(with: (User.template, project, Reward.template, .update, .discovery))

    XCTAssertEqual([], self.trackingClient.events)

    let addNewCardIndexPath = IndexPath(
      row: 0,
      section: PaymentMethodsTableViewSection.addNewCard.rawValue
    )

    self.vm.inputs.didSelectRowAtIndexPath(addNewCardIndexPath)

    XCTAssertEqual(["Add New Card Button Clicked"], self.trackingClient.events)

    XCTAssertEqual(["manage_reward"], self.trackingClient.properties(forKey: "context_pledge_flow"))
    XCTAssertEqual(["discovery"], self.trackingClient.properties(forKey: "session_ref_tag"))
  }
}
