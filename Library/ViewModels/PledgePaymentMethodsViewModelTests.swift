import Foundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import XCTest

final class PledgePaymentMethodsViewModelTests: TestCase {
  private let vm: PledgePaymentMethodsViewModelType = PledgePaymentMethodsViewModel()

  private let applePayStackViewHidden = TestObserver<Bool, Never>()
  private let goToAddCardIntent = TestObserver<AddNewCardIntent, Never>()
  private let goToProject = TestObserver<Project, Never>()
  private let notifyDelegateApplePayButtonTapped = TestObserver<Void, Never>()
  private let notifyDelegateCreditCardSelected = TestObserver<String, Never>()
  private let notifyDelegateLoadPaymentMethodsError = TestObserver<String, Never>()

  private let reloadPaymentMethodsCards = TestObserver<[GraphUserCreditCard.CreditCard], Never>()
  private let reloadPaymentMethodsAvailableCardTypes = TestObserver<[Bool], Never>()
  private let reloadPaymentMethodsProjectCountry = TestObserver<[String], Never>()
  private let reloadPaymentMethodsSelectedCard = TestObserver<GraphUserCreditCard.CreditCard?, Never>()
  private let updateSelectedCreditCard = TestObserver<GraphUserCreditCard.CreditCard, Never>()

  override func setUp() {
    super.setUp()
    self.vm.outputs.applePayStackViewHidden.observe(self.applePayStackViewHidden.observer)
    self.vm.outputs.goToAddCardScreen.map(first).observe(self.goToAddCardIntent.observer)
    self.vm.outputs.goToAddCardScreen.map(second).observe(self.goToProject.observer)
    self.vm.outputs.notifyDelegateApplePayButtonTapped
      .observe(self.notifyDelegateApplePayButtonTapped.observer)
    self.vm.outputs.notifyDelegateCreditCardSelected
      .observe(self.notifyDelegateCreditCardSelected.observer)
    self.vm.outputs.notifyDelegateLoadPaymentMethodsError
      .observe(self.notifyDelegateLoadPaymentMethodsError.observer)

    self.vm.outputs.reloadPaymentMethodsAndSelectCard.map(first).map { $0.map { $0.card } }
      .observe(self.reloadPaymentMethodsCards.observer)
    self.vm.outputs.reloadPaymentMethodsAndSelectCard.map(first).map { $0.map { $0.isEnabled } }
      .observe(self.reloadPaymentMethodsAvailableCardTypes.observer)
    self.vm.outputs.reloadPaymentMethodsAndSelectCard.map(first).map { $0.map { $0.projectCountry } }
      .observe(self.reloadPaymentMethodsProjectCountry.observer)
    self.vm.outputs.reloadPaymentMethodsAndSelectCard.map(second)
      .observe(self.reloadPaymentMethodsSelectedCard.observer)
    self.vm.outputs.updateSelectedCreditCard.observe(self.updateSelectedCreditCard.observer)
  }

  // MARK: - New card added

  func testReloadPaymentMethods_NewCardAdded() {
    let response = UserEnvelope<GraphUserCreditCard>(me: GraphUserCreditCard.template)
    let mockService = MockService(fetchGraphCreditCardsResponse: response)
    let userCreditCard = GraphUserCreditCard.visa |> \.id .~ "10"

    withEnvironment(apiService: mockService, currentUser: User.template) {
      self.reloadPaymentMethodsCards.assertDidNotEmitValue()
      self.reloadPaymentMethodsAvailableCardTypes.assertDidNotEmitValue()
      self.reloadPaymentMethodsProjectCountry.assertDidNotEmitValue()

      self.vm.inputs.configure(with: (User.template, Project.template, Reward.template))
      self.vm.inputs.viewDidLoad()

      self.scheduler.run()

      self.reloadPaymentMethodsCards.assertValue(response.me.storedCards.nodes)
      self.reloadPaymentMethodsAvailableCardTypes.assertValues([
        [true, true, true, true, true, true, false, true]
      ])
      self.reloadPaymentMethodsProjectCountry.assertValues([
        (0...response.me.storedCards.nodes.count - 1).map { _ in "Brooklyn, NY" }
      ], "One card is unavailable")
      self.reloadPaymentMethodsSelectedCard.assertValues([response.me.storedCards.nodes.first])

      self.vm.inputs.addNewCardViewControllerDidAdd(newCard: userCreditCard)

      self.reloadPaymentMethodsCards.assertValues(
        [
          [
            GraphUserCreditCard.amex,
            GraphUserCreditCard.masterCard,
            GraphUserCreditCard.visa,
            GraphUserCreditCard.diners,
            GraphUserCreditCard.jcb,
            GraphUserCreditCard.discover,
            GraphUserCreditCard.generic,
            GraphUserCreditCard.unionPay
          ], [
            userCreditCard,
            GraphUserCreditCard.amex,
            GraphUserCreditCard.masterCard,
            GraphUserCreditCard.visa,
            GraphUserCreditCard.diners,
            GraphUserCreditCard.jcb,
            GraphUserCreditCard.discover,
            GraphUserCreditCard.generic,
            GraphUserCreditCard.unionPay
          ]
        ]
      )
      self.reloadPaymentMethodsAvailableCardTypes.assertValues([
        [true, true, true, true, true, true, false, true],
        [true, true, true, true, true, true, true, false, true]
      ])
      self.reloadPaymentMethodsProjectCountry.assertValues([
        (0...response.me.storedCards.nodes.count - 1).map { _ in "Brooklyn, NY" },
        (0...response.me.storedCards.nodes.count).map { _ in "Brooklyn, NY" }
      ], "New and available card added")
      self.reloadPaymentMethodsSelectedCard.assertValues([
        response.me.storedCards.nodes.first,
        userCreditCard
      ])
    }
  }

  func testReloadPaymentMethods_NewCardAdded_ProjectHasBacking() {
    let response = UserEnvelope<GraphUserCreditCard>(me: GraphUserCreditCard.template)
    let mockService = MockService(fetchGraphCreditCardsResponse: response)

    withEnvironment(apiService: mockService, currentUser: User.template) {
      let paymentSource = Backing.PaymentSource.template
        |> \.id .~ "2" // Matches GraphUserCreditCard.visa template id

      let project = Project.template
        |> Project.lens.personalization.backing .~ (
          Backing.template
            |> Backing.lens.paymentSource .~ paymentSource
        )

      self.reloadPaymentMethodsSelectedCard.assertDidNotEmitValue()

      self.vm.inputs.configure(with: (User.template, project, .template))
      self.vm.inputs.viewDidLoad()

      self.scheduler.run()

      self.reloadPaymentMethodsCards.assertValues([
        [
          GraphUserCreditCard.visa,
          GraphUserCreditCard.amex,
          GraphUserCreditCard.masterCard,
          GraphUserCreditCard.diners,
          GraphUserCreditCard.jcb,
          GraphUserCreditCard.discover,
          GraphUserCreditCard.generic,
          GraphUserCreditCard.unionPay
        ]
      ], "Card used for backing is first")
      self.reloadPaymentMethodsAvailableCardTypes.assertValues([
        [true, true, true, true, true, true, false, true]
      ])
      self.reloadPaymentMethodsProjectCountry.assertValues([
        (0...response.me.storedCards.nodes.count - 1).map { _ in "Brooklyn, NY" }
      ], "One card is unavailable")
      self.reloadPaymentMethodsSelectedCard.assertValues(
        [GraphUserCreditCard.visa],
        "Card used for backing is selected"
      )

      let newCard = GraphUserCreditCard.visa
        |> \.id .~ "123"
        |> \.lastFour .~ "1234"

      self.vm.inputs.addNewCardViewControllerDidAdd(newCard: newCard)

      self.reloadPaymentMethodsCards.assertValues([
        [
          GraphUserCreditCard.visa,
          GraphUserCreditCard.amex,
          GraphUserCreditCard.masterCard,
          GraphUserCreditCard.diners,
          GraphUserCreditCard.jcb,
          GraphUserCreditCard.discover,
          GraphUserCreditCard.generic,
          GraphUserCreditCard.unionPay
        ],
        [
          newCard,
          GraphUserCreditCard.visa,
          GraphUserCreditCard.amex,
          GraphUserCreditCard.masterCard,
          GraphUserCreditCard.diners,
          GraphUserCreditCard.jcb,
          GraphUserCreditCard.discover,
          GraphUserCreditCard.generic,
          GraphUserCreditCard.unionPay
        ]
      ], "New card added is first")
      self.reloadPaymentMethodsAvailableCardTypes.assertValues([
        [true, true, true, true, true, true, false, true],
        [true, true, true, true, true, true, true, false, true]
      ])
      self.reloadPaymentMethodsProjectCountry.assertValues([
        (0...response.me.storedCards.nodes.count - 1).map { _ in "Brooklyn, NY" },
        (0...response.me.storedCards.nodes.count).map { _ in "Brooklyn, NY" }
      ], "One card is unavailable")
      self.reloadPaymentMethodsSelectedCard.assertValues(
        [
          GraphUserCreditCard.visa,
          newCard
        ],
        "Newly added card is selected"
      )
    }
  }

  func testReloadPaymentMethods_NewCardAdded_NoStoredCards() {
    let response = UserEnvelope<GraphUserCreditCard>(me: GraphUserCreditCard.emptyTemplate)
    let mockService = MockService(fetchGraphCreditCardsResponse: response)

    withEnvironment(apiService: mockService, currentUser: User.template) {
      self.reloadPaymentMethodsCards.assertDidNotEmitValue()
      self.reloadPaymentMethodsAvailableCardTypes.assertDidNotEmitValue()
      self.reloadPaymentMethodsProjectCountry.assertDidNotEmitValue()
      self.applePayStackViewHidden.assertDidNotEmitValue()
      self.reloadPaymentMethodsSelectedCard.assertDidNotEmitValue()

      self.vm.inputs.configure(with: (User.template, Project.template, Reward.template))
      self.vm.inputs.viewDidLoad()

      self.scheduler.run()

      self.reloadPaymentMethodsCards.assertValues([[]])
      self.reloadPaymentMethodsAvailableCardTypes.assertValues([[]])
      self.reloadPaymentMethodsProjectCountry.assertValues([[]])
      self.reloadPaymentMethodsSelectedCard.assertValues([nil], "No card to select")

      self.vm.inputs.addNewCardViewControllerDidAdd(newCard: GraphUserCreditCard.visa)

      self.reloadPaymentMethodsCards.assertValues([[], [GraphUserCreditCard.visa]])
      self.reloadPaymentMethodsAvailableCardTypes.assertValues([[], [true]])
      self.reloadPaymentMethodsProjectCountry.assertValues([[], ["Brooklyn, NY"]])
      self.reloadPaymentMethodsSelectedCard
        .assertValues([nil, GraphUserCreditCard.visa], "Added card is selected")
    }
  }

  func testUpdateSelectedCreditCard() {
    self.updateSelectedCreditCard.assertDidNotEmitValue()

    let response = UserEnvelope<GraphUserCreditCard>(me: GraphUserCreditCard.template)
    let mockService = MockService(fetchGraphCreditCardsResponse: response)
    let userCreditCard = GraphUserCreditCard.amex

    withEnvironment(apiService: mockService, currentUser: User.template) {
      self.reloadPaymentMethodsCards.assertDidNotEmitValue()
      self.reloadPaymentMethodsAvailableCardTypes.assertDidNotEmitValue()
      self.reloadPaymentMethodsProjectCountry.assertDidNotEmitValue()
      self.reloadPaymentMethodsSelectedCard.assertDidNotEmitValue()

      self.vm.inputs.configure(with: (User.template, Project.template, Reward.template))
      self.vm.inputs.viewDidLoad()

      self.scheduler.run()

      self.reloadPaymentMethodsCards.assertValue(response.me.storedCards.nodes)
      self.reloadPaymentMethodsAvailableCardTypes.assertValues([
        [true, true, true, true, true, true, false, true]
      ])
      self.reloadPaymentMethodsProjectCountry.assertValues([
        (0...response.me.storedCards.nodes.count - 1).map { _ in "Brooklyn, NY" }
      ], "One card is unavailable")
      self.reloadPaymentMethodsSelectedCard.assertValues([
        response.me.storedCards.nodes.first
      ], "First card is selected")

      self.vm.inputs.addNewCardViewControllerDidAdd(newCard: userCreditCard)

      self.reloadPaymentMethodsCards.assertValues(
        [response.me.storedCards.nodes, [userCreditCard] + response.me.storedCards.nodes]
      )
      self.reloadPaymentMethodsAvailableCardTypes.assertValues([
        [true, true, true, true, true, true, false, true],
        [true, true, true, true, true, true, true, false, true]
      ])
      self.reloadPaymentMethodsProjectCountry.assertValues([
        (0...response.me.storedCards.nodes.count - 1).map { _ in "Brooklyn, NY" },
        (0...response.me.storedCards.nodes.count).map { _ in "Brooklyn, NY" }
      ], "New and available card added")
      self.reloadPaymentMethodsSelectedCard.assertValues([
        response.me.storedCards.nodes.first,
        userCreditCard
      ], "Newly added card is selected")

      self.vm.inputs.creditCardSelected(paymentSourceId: userCreditCard.id)

      self.updateSelectedCreditCard.assertValues([userCreditCard])
    }
  }

  func testUpdateSelectedCard_NewCardAdded() {
    let cards = GraphUserCreditCard.withCards([GraphUserCreditCard.amex, GraphUserCreditCard.masterCard])
    let response = UserEnvelope<GraphUserCreditCard>(me: cards)
    let mockService = MockService(fetchGraphCreditCardsResponse: response)
    let userCreditCard = GraphUserCreditCard.visa
      |> \.id .~ "10"

    withEnvironment(apiService: mockService, currentUser: User.template) {
      self.vm.inputs.configure(with: (User.template, Project.template, Reward.template))
      self.vm.inputs.viewDidLoad()

      self.scheduler.run()

      self.updateSelectedCreditCard.assertDidNotEmitValue()
      self.reloadPaymentMethodsSelectedCard
        .assertValues([GraphUserCreditCard.amex], "First card is selected")

      self.vm.inputs.addNewCardViewControllerDidAdd(newCard: userCreditCard)

      self.reloadPaymentMethodsSelectedCard
        .assertValues([GraphUserCreditCard.amex, userCreditCard], "New card selected")
      self.updateSelectedCreditCard.assertDidNotEmitValue()

      self.vm.inputs.creditCardSelected(paymentSourceId: "1") // Mastercard selected

      self.updateSelectedCreditCard.assertValues(
        [GraphUserCreditCard.masterCard],
        "Correct card is selected"
      )

      self.vm.inputs.creditCardSelected(paymentSourceId: userCreditCard.id)

      self.updateSelectedCreditCard.assertValues(
        [GraphUserCreditCard.masterCard, userCreditCard],
        "Correct card is selected"
      )
    }
  }

  func testReloadPaymentMethods_NoStoredCards() {
    let response = UserEnvelope<GraphUserCreditCard>(me: GraphUserCreditCard.emptyTemplate)
    let mockService = MockService(fetchGraphCreditCardsResponse: response)

    withEnvironment(apiService: mockService, currentUser: User.template) {
      self.reloadPaymentMethodsCards.assertDidNotEmitValue()
      self.reloadPaymentMethodsAvailableCardTypes.assertDidNotEmitValue()
      self.reloadPaymentMethodsProjectCountry.assertDidNotEmitValue()
      self.applePayStackViewHidden.assertDidNotEmitValue()
      self.reloadPaymentMethodsSelectedCard.assertDidNotEmitValue()

      self.vm.inputs.configure(with: (User.template, Project.template, Reward.template))
      self.vm.inputs.viewDidLoad()

      self.scheduler.run()

      self.reloadPaymentMethodsCards.assertValues([[]])
      self.reloadPaymentMethodsAvailableCardTypes.assertValues([[]])
      self.reloadPaymentMethodsProjectCountry.assertValues([[]])
      self.reloadPaymentMethodsSelectedCard.assertValues([nil], "No card to select")
    }
  }

  func testReloadPaymentMethods_FirstCardUnavailable() {
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
      self.reloadPaymentMethodsSelectedCard.assertDidNotEmitValue()

      self.vm.inputs.configure(with: (User.template, project, Reward.template))
      self.vm.inputs.viewDidLoad()

      self.scheduler.run()

      self.reloadPaymentMethodsCards.assertValues([
        [
          GraphUserCreditCard.discover,
          GraphUserCreditCard.visa,
          GraphUserCreditCard.amex
        ]
      ])
      self.reloadPaymentMethodsAvailableCardTypes.assertValues([[false, true, true]])
      self.reloadPaymentMethodsSelectedCard.assertValues([nil], "No card to select")
    }
  }

  func testReloadPaymentMethods_LoggedIn_DeviceIsApplePayCapable_isFalse() {
    let response = UserEnvelope<GraphUserCreditCard>(me: GraphUserCreditCard.template)
    let mockService = MockService(fetchGraphCreditCardsResponse: response)
    let mockApplePayCapabilities = MockApplePayCapabilities()
      |> \.isApplePayDevice .~ false

    withEnvironment(apiService: mockService,
                    applePayCapabilities: mockApplePayCapabilities,
                    currentUser: User.template) {
      self.reloadPaymentMethodsCards.assertDidNotEmitValue()
      self.reloadPaymentMethodsAvailableCardTypes.assertDidNotEmitValue()
      self.reloadPaymentMethodsProjectCountry.assertDidNotEmitValue()
      self.applePayStackViewHidden.assertDidNotEmitValue()
      self.reloadPaymentMethodsSelectedCard.assertDidNotEmitValue()

      self.vm.inputs.configure(with: (User.template, Project.template, Reward.template))
      self.vm.inputs.viewDidLoad()

      self.scheduler.run()

      self.applePayStackViewHidden.assertValues([true])
      self.reloadPaymentMethodsCards.assertValue(response.me.storedCards.nodes)
      self.reloadPaymentMethodsAvailableCardTypes.assertValues([
        [true, true, true, true, true, true, false, true]
      ])
      self.reloadPaymentMethodsProjectCountry.assertValues([
        (0...response.me.storedCards.nodes.count - 1).map { _ in "Brooklyn, NY" }
      ], "One card is unavailable")
      self.reloadPaymentMethodsSelectedCard.assertValues([
        response.me.storedCards.nodes.first
      ], "First card is selected")
    }
  }

  func testReloadPaymentMethods_LoggedIn_DeviceIsApplePayCapable_isTrue() {
    let response = UserEnvelope<GraphUserCreditCard>(me: GraphUserCreditCard.template)
    let mockService = MockService(fetchGraphCreditCardsResponse: response)
    let mockApplePayCapabilities = MockApplePayCapabilities()
      |> \.isApplePayDevice .~ true

    withEnvironment(apiService: mockService,
                    applePayCapabilities: mockApplePayCapabilities,
                    currentUser: User.template) {
      self.reloadPaymentMethodsCards.assertDidNotEmitValue()
      self.reloadPaymentMethodsAvailableCardTypes.assertDidNotEmitValue()
      self.reloadPaymentMethodsProjectCountry.assertDidNotEmitValue()
      self.reloadPaymentMethodsSelectedCard.assertDidNotEmitValue()
      self.applePayStackViewHidden.assertDidNotEmitValue()

      self.vm.inputs.configure(with: (User.template, Project.template, Reward.template))
      self.vm.inputs.viewDidLoad()

      self.scheduler.run()

      self.applePayStackViewHidden.assertValues([false])
      self.reloadPaymentMethodsCards.assertValue(response.me.storedCards.nodes)
      self.reloadPaymentMethodsAvailableCardTypes.assertValues([
        [true, true, true, true, true, true, false, true]
      ])
      self.reloadPaymentMethodsProjectCountry.assertValues([
        (0...response.me.storedCards.nodes.count - 1).map { _ in "Brooklyn, NY" }
      ], "One card is unavailable")
      self.reloadPaymentMethodsSelectedCard.assertValues([
        response.me.storedCards.nodes.first
      ], "First card is selected")
    }
  }

  func testReloadPaymentMethods_LoggedIn_DeviceIsApplePayCapable_isTrue_BackedCardRemoved() {
    let filteredCards = GraphUserCreditCard.template.storedCards.nodes
      .filter { $0.id != GraphUserCreditCard.visa.id }

    let filteredTemplate = GraphUserCreditCard(
      storedCards: GraphUserCreditCard.CreditCardConnection(nodes: filteredCards)
    )

    let response = UserEnvelope<GraphUserCreditCard>(me: filteredTemplate)
    let mockService = MockService(fetchGraphCreditCardsResponse: response)

    let project = Project.cosmicSurgery
      |> Project.lens.state .~ .live
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.paymentSource .~ Backing.PaymentSource.visa
          |> Backing.lens.status .~ .pledged
          |> Backing.lens.reward .~ Reward.postcards
          |> Backing.lens.rewardId .~ Reward.postcards.id
          |> Backing.lens.shippingAmount .~ 10
          |> Backing.lens.amount .~ 700
      )

    withEnvironment(apiService: mockService, currentUser: User.template) {
      self.reloadPaymentMethodsCards.assertDidNotEmitValue()
      self.reloadPaymentMethodsAvailableCardTypes.assertDidNotEmitValue()
      self.reloadPaymentMethodsProjectCountry.assertDidNotEmitValue()
      self.reloadPaymentMethodsSelectedCard.assertDidNotEmitValue()
      self.applePayStackViewHidden.assertDidNotEmitValue()

      self.vm.inputs.configure(with: (User.template, project, Reward.template))
      self.vm.inputs.viewDidLoad()

      self.scheduler.run()

      self.applePayStackViewHidden.assertValues([false])
      self.reloadPaymentMethodsCards.assertValue(response.me.storedCards.nodes)
      self.reloadPaymentMethodsAvailableCardTypes.assertValues([
        [true, true, true, true, true, false, true]
      ])
      self.reloadPaymentMethodsProjectCountry.assertValues([
        (0...response.me.storedCards.nodes.count - 1).map { _ in "Hastings, UK" }
      ], "One card is unavailable")
      self.reloadPaymentMethodsSelectedCard.assertValues([nil], "No card selected")
    }
  }

  func testReloadPaymentMethods_Error_LoggedIn_DeviceIsApplePayCapable_isFalse() {
    let error = GraphResponseError(message: "Something went wrong")
    let apiService = MockService(fetchGraphCreditCardsError: GraphError.decodeError(error))
    let mockApplePayCapabilities = MockApplePayCapabilities()
      |> \.isApplePayDevice .~ false

    withEnvironment(apiService: apiService,
                    applePayCapabilities: mockApplePayCapabilities,
                    currentUser: User.template) {
      self.reloadPaymentMethodsCards.assertDidNotEmitValue()
      self.reloadPaymentMethodsAvailableCardTypes.assertDidNotEmitValue()
      self.reloadPaymentMethodsProjectCountry.assertDidNotEmitValue()
      self.reloadPaymentMethodsSelectedCard.assertDidNotEmitValue()
      self.applePayStackViewHidden.assertDidNotEmitValue()

      self.vm.inputs.configure(with: (User.template, Project.template, Reward.template))
      self.vm.inputs.viewDidLoad()

      self.reloadPaymentMethodsCards.assertDidNotEmitValue()
      self.reloadPaymentMethodsAvailableCardTypes.assertDidNotEmitValue()
      self.reloadPaymentMethodsProjectCountry.assertDidNotEmitValue()
      self.notifyDelegateLoadPaymentMethodsError.assertDidNotEmitValue()
      self.reloadPaymentMethodsSelectedCard.assertDidNotEmitValue()
      self.applePayStackViewHidden.assertValues([true])

      self.scheduler.run()

      self.applePayStackViewHidden.assertValues([true])
      self.reloadPaymentMethodsCards.assertDidNotEmitValue()
      self.reloadPaymentMethodsAvailableCardTypes.assertDidNotEmitValue()
      self.reloadPaymentMethodsProjectCountry.assertDidNotEmitValue()
      self.reloadPaymentMethodsSelectedCard.assertDidNotEmitValue()
      self.notifyDelegateLoadPaymentMethodsError.assertValue("Something went wrong")
    }
  }

  func testReloadPaymentMethods_Error_LoggedIn_DeviceIsApplePayCapable_isTrue() {
    let error = GraphResponseError(message: "Something went wrong")
    let apiService = MockService(fetchGraphCreditCardsError: GraphError.decodeError(error))
    let mockApplePayCapabilities = MockApplePayCapabilities()
      |> \.isApplePayDevice .~ true

    withEnvironment(apiService: apiService,
                    applePayCapabilities: mockApplePayCapabilities,
                    currentUser: User.template) {
      self.reloadPaymentMethodsCards.assertDidNotEmitValue()
      self.reloadPaymentMethodsAvailableCardTypes.assertDidNotEmitValue()
      self.reloadPaymentMethodsProjectCountry.assertDidNotEmitValue()
      self.reloadPaymentMethodsSelectedCard.assertDidNotEmitValue()
      self.applePayStackViewHidden.assertDidNotEmitValue()

      self.vm.inputs.configure(with: (User.template, Project.template, Reward.template))
      self.vm.inputs.viewDidLoad()

      self.reloadPaymentMethodsCards.assertDidNotEmitValue()
      self.reloadPaymentMethodsAvailableCardTypes.assertDidNotEmitValue()
      self.reloadPaymentMethodsProjectCountry.assertDidNotEmitValue()
      self.reloadPaymentMethodsSelectedCard.assertDidNotEmitValue()
      self.notifyDelegateLoadPaymentMethodsError.assertDidNotEmitValue()

      self.scheduler.run()

      self.applePayStackViewHidden.assertValues([false])
      self.reloadPaymentMethodsCards.assertDidNotEmitValue()
      self.reloadPaymentMethodsAvailableCardTypes.assertDidNotEmitValue()
      self.reloadPaymentMethodsProjectCountry.assertDidNotEmitValue()
      self.reloadPaymentMethodsSelectedCard.assertDidNotEmitValue()
      self.notifyDelegateLoadPaymentMethodsError.assertValue("Something went wrong")
    }
  }

  func testReloadPaymentMethods_LoggedOut() {
    let response = UserEnvelope<GraphUserCreditCard>(me: GraphUserCreditCard.template)
    let mockService = MockService(fetchGraphCreditCardsResponse: response)

    withEnvironment(apiService: mockService, currentUser: nil) {
      self.vm.inputs.viewDidLoad()

      self.reloadPaymentMethodsCards.assertDidNotEmitValue()
      self.reloadPaymentMethodsAvailableCardTypes.assertDidNotEmitValue()
      self.reloadPaymentMethodsProjectCountry.assertDidNotEmitValue()
      self.reloadPaymentMethodsSelectedCard.assertDidNotEmitValue()
      self.applePayStackViewHidden.assertDidNotEmitValue()

      self.scheduler.run()

      self.applePayStackViewHidden.assertDidNotEmitValue()
      self.reloadPaymentMethodsCards.assertDidNotEmitValue()
      self.reloadPaymentMethodsAvailableCardTypes.assertDidNotEmitValue()
      self.reloadPaymentMethodsProjectCountry.assertDidNotEmitValue()
      self.reloadPaymentMethodsSelectedCard.assertDidNotEmitValue()
      self.notifyDelegateLoadPaymentMethodsError.assertDidNotEmitValue()
    }
  }

  func testApplePayButtonTapped() {
    withEnvironment(currentUser: .template) {
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.configure(with: (user: .template, project: .template, Reward.template))

      self.notifyDelegateApplePayButtonTapped.assertDidNotEmitValue()

      self.vm.inputs.applePayButtonTapped()

      self.notifyDelegateApplePayButtonTapped.assertValueCount(1)
    }
  }

  func testApplePayStackViewHidden_isHidden_DeviceIsApplePayCapable_UnsupportedProjectCountry() {
    let mockConfig = Config.template
      |> \.applePayCountries .~ [Project.Country.us.countryCode]
    let project = Project.template
      |> \.country .~ .gb
    let mockApplePayCapabilities = MockApplePayCapabilities()
      |> \.isApplePayDevice .~ true

    withEnvironment(applePayCapabilities: mockApplePayCapabilities, config: mockConfig) {
      self.vm.inputs.configure(with: (User.template, project, Reward.template))
      self.vm.inputs.viewDidLoad()

      self.applePayStackViewHidden.assertValues([true])
    }
  }

  func testApplePayViewHidden_isNotHidden_DeviceIsApplePayCapable_SupportedProjectCountry() {
    let mockConfig = Config.template
      |> \.applePayCountries .~ [
        Project.Country.us.countryCode,
        Project.Country.gb.countryCode
      ]
    let project = Project.template
      |> \.country .~ .gb
    let mockApplePayCapabilities = MockApplePayCapabilities()
      |> \.isApplePayDevice .~ true

    withEnvironment(applePayCapabilities: mockApplePayCapabilities, config: mockConfig) {
      self.vm.inputs.configure(with: (User.template, project, Reward.template))
      self.vm.inputs.viewDidLoad()

      self.applePayStackViewHidden.assertValues([false])
    }
  }

  func testCreditCardSelected() {
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.configure(with: (User.template, Project.template, Reward.template))

    self.notifyDelegateCreditCardSelected.assertDidNotEmitValue()

    self.vm.inputs.creditCardSelected(paymentSourceId: "123")

    self.notifyDelegateCreditCardSelected.assertValues(["123"])

    self.vm.inputs.creditCardSelected(paymentSourceId: "abc")

    self.notifyDelegateCreditCardSelected.assertValues(["123", "abc"])
  }

  func testGoToAddNewCard() {
    let project = Project.template

    self.vm.inputs.viewDidLoad()
    self.vm.inputs.configure(with: (User.template, project, Reward.template))

    self.vm.inputs.addNewCardTapped(with: .pledge)
    self.goToAddCardIntent.assertValues([.pledge])
    self.goToProject.assertValues([project])
  }

  func testTrackingEvents() {
    let project = Project.template

    self.vm.inputs.viewDidLoad()
    self.vm.inputs.configure(with: (User.template, project, Reward.template))

    XCTAssertEqual([], self.trackingClient.events)

    self.vm.inputs.addNewCardTapped(with: .pledge)

    XCTAssertEqual(["Add New Card Button Clicked"], self.trackingClient.events)
  }
}
