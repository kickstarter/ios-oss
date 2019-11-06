import Foundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import XCTest

final class PledgePaymentMethodsViewModelTests: TestCase {
  private let vm: PledgePaymentMethodsViewModelType = PledgePaymentMethodsViewModel()

  private let applePayButtonHidden = TestObserver<Bool, Never>()
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
    self.vm.outputs.applePayButtonHidden.observe(self.applePayButtonHidden.observer)
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

  func testNewCardAdded() {
    let response = UserEnvelope<GraphUserCreditCard>(me: GraphUserCreditCard.template)
    let mockService = MockService(fetchGraphCreditCardsResponse: response)
    let userCreditCard = GraphUserCreditCard.amex

    withEnvironment(apiService: mockService, currentUser: User.template) {
      self.reloadPaymentMethodsCards.assertDidNotEmitValue()
      self.reloadPaymentMethodsAvailableCardTypes.assertDidNotEmitValue()
      self.reloadPaymentMethodsProjectCountry.assertDidNotEmitValue()

      self.vm.inputs.configureWith((User.template, Project.template, false))
      self.vm.inputs.viewDidLoad()

      self.scheduler.run()

      self.reloadPaymentMethodsCards.assertValue(response.me.storedCards.nodes)
      self.reloadPaymentMethodsAvailableCardTypes.assertValues([
        [true, true, true, true, true, true, false, true]
      ])
      self.reloadPaymentMethodsProjectCountry.assertValues([
        (0...response.me.storedCards.nodes.count - 1).map { _ in "Brooklyn, NY" }
      ], "One card is unavailable")
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

      self.vm.inputs.configureWith((User.template, Project.template, false))
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

  func testCardFromBackingIsSelectedFirst() {
    let response = UserEnvelope<GraphUserCreditCard>(me: GraphUserCreditCard.template)
    let mockService = MockService(fetchGraphCreditCardsResponse: response)
    let userCreditCard = GraphUserCreditCard.visa

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

      self.vm.inputs.configureWith((User.template, project, false))
      self.vm.inputs.viewDidLoad()

      self.scheduler.run()

      let visaFirstCards = response.me.storedCards.nodes.sorted {
        card1, _ in card1 == GraphUserCreditCard.visa
      }

      self.reloadPaymentMethodsCards.assertValues([visaFirstCards])
      self.reloadPaymentMethodsAvailableCardTypes.assertValues([
        [true, true, true, true, true, true, false, true]
      ])
      self.reloadPaymentMethodsProjectCountry.assertValues([
        (0...response.me.storedCards.nodes.count - 1).map { _ in "Hastings, UK" }
      ], "One card is unavailable")
      self.reloadPaymentMethodsSelectedCard.assertValues([
        GraphUserCreditCard.visa
      ], "First card is selected and matches that of the backing")

      self.vm.inputs.addNewCardViewControllerDidAdd(newCard: userCreditCard)

      self.reloadPaymentMethodsCards.assertValues([
        visaFirstCards,
        [userCreditCard] + visaFirstCards
      ], "Newly added card is ordered first")
      self.reloadPaymentMethodsAvailableCardTypes.assertValues([
        [true, true, true, true, true, true, false, true],
        [true, true, true, true, true, true, true, false, true]
      ])
      self.reloadPaymentMethodsProjectCountry.assertValues([
        (0...response.me.storedCards.nodes.count - 1).map { _ in "Hastings, UK" },
        (0...response.me.storedCards.nodes.count).map { _ in "Hastings, UK" }
      ], "New and available card added")
      self.reloadPaymentMethodsSelectedCard.assertValues([
        GraphUserCreditCard.visa,
        userCreditCard
      ], "Newly added card is selected")

      self.vm.inputs.creditCardSelected(paymentSourceId: userCreditCard.id)

      self.updateSelectedCreditCard.assertValues([userCreditCard])
    }
  }

  func testReloadPaymentMethods_LoggedIn_ApplePayCapable_isFalse() {
    let response = UserEnvelope<GraphUserCreditCard>(me: GraphUserCreditCard.template)
    let mockService = MockService(fetchGraphCreditCardsResponse: response)

    withEnvironment(apiService: mockService, currentUser: User.template) {
      self.reloadPaymentMethodsCards.assertDidNotEmitValue()
      self.reloadPaymentMethodsAvailableCardTypes.assertDidNotEmitValue()
      self.reloadPaymentMethodsProjectCountry.assertDidNotEmitValue()
      self.applePayButtonHidden.assertDidNotEmitValue()
      self.reloadPaymentMethodsSelectedCard.assertDidNotEmitValue()

      self.vm.inputs.configureWith((User.template, Project.template, false))
      self.vm.inputs.viewDidLoad()

      self.scheduler.run()

      self.applePayButtonHidden.assertValues([true])
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

  func testReloadPaymentMethods_LoggedIn_ApplePayCapable_isTrue() {
    let response = UserEnvelope<GraphUserCreditCard>(me: GraphUserCreditCard.template)
    let mockService = MockService(fetchGraphCreditCardsResponse: response)

    withEnvironment(apiService: mockService, currentUser: User.template) {
      self.reloadPaymentMethodsCards.assertDidNotEmitValue()
      self.reloadPaymentMethodsAvailableCardTypes.assertDidNotEmitValue()
      self.reloadPaymentMethodsProjectCountry.assertDidNotEmitValue()
      self.reloadPaymentMethodsSelectedCard.assertDidNotEmitValue()
      self.applePayButtonHidden.assertDidNotEmitValue()

      self.vm.inputs.configureWith((User.template, Project.template, true))
      self.vm.inputs.viewDidLoad()

      self.scheduler.run()

      self.applePayButtonHidden.assertValues([false])
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

  func testReloadPaymentMethods_LoggedIn_ApplePayCapable_isTrue_BackedCardRemoved() {
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
      self.applePayButtonHidden.assertDidNotEmitValue()

      self.vm.inputs.configureWith((User.template, project, true))
      self.vm.inputs.viewDidLoad()

      self.scheduler.run()

      self.applePayButtonHidden.assertValues([false])
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

  func testReloadPaymentMethods_Error_LoggedIn_ApplePayCapable_isFalse() {
    let error = GraphResponseError(message: "Something went wrong")
    let apiService = MockService(fetchGraphCreditCardsError: GraphError.decodeError(error))

    withEnvironment(apiService: apiService, currentUser: User.template) {
      self.reloadPaymentMethodsCards.assertDidNotEmitValue()
      self.reloadPaymentMethodsAvailableCardTypes.assertDidNotEmitValue()
      self.reloadPaymentMethodsProjectCountry.assertDidNotEmitValue()
      self.reloadPaymentMethodsSelectedCard.assertDidNotEmitValue()
      self.applePayButtonHidden.assertDidNotEmitValue()

      self.vm.inputs.configureWith((User.template, Project.template, false))
      self.vm.inputs.viewDidLoad()

      self.reloadPaymentMethodsCards.assertDidNotEmitValue()
      self.reloadPaymentMethodsAvailableCardTypes.assertDidNotEmitValue()
      self.reloadPaymentMethodsProjectCountry.assertDidNotEmitValue()
      self.notifyDelegateLoadPaymentMethodsError.assertDidNotEmitValue()
      self.reloadPaymentMethodsSelectedCard.assertDidNotEmitValue()
      self.applePayButtonHidden.assertValues([true])

      self.scheduler.run()

      self.applePayButtonHidden.assertValues([true])
      self.reloadPaymentMethodsCards.assertDidNotEmitValue()
      self.reloadPaymentMethodsAvailableCardTypes.assertDidNotEmitValue()
      self.reloadPaymentMethodsProjectCountry.assertDidNotEmitValue()
      self.reloadPaymentMethodsSelectedCard.assertDidNotEmitValue()
      self.notifyDelegateLoadPaymentMethodsError.assertValue("Something went wrong")
    }
  }

  func testReloadPaymentMethods_Error_LoggedIn_ApplePayCapable_isTrue() {
    let error = GraphResponseError(message: "Something went wrong")
    let apiService = MockService(fetchGraphCreditCardsError: GraphError.decodeError(error))

    withEnvironment(apiService: apiService, currentUser: User.template) {
      self.reloadPaymentMethodsCards.assertDidNotEmitValue()
      self.reloadPaymentMethodsAvailableCardTypes.assertDidNotEmitValue()
      self.reloadPaymentMethodsProjectCountry.assertDidNotEmitValue()
      self.reloadPaymentMethodsSelectedCard.assertDidNotEmitValue()
      self.applePayButtonHidden.assertDidNotEmitValue()

      self.vm.inputs.configureWith((User.template, Project.template, true))
      self.vm.inputs.viewDidLoad()

      self.reloadPaymentMethodsCards.assertDidNotEmitValue()
      self.reloadPaymentMethodsAvailableCardTypes.assertDidNotEmitValue()
      self.reloadPaymentMethodsProjectCountry.assertDidNotEmitValue()
      self.reloadPaymentMethodsSelectedCard.assertDidNotEmitValue()
      self.notifyDelegateLoadPaymentMethodsError.assertDidNotEmitValue()

      self.scheduler.run()

      self.applePayButtonHidden.assertValues([false])
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
      self.applePayButtonHidden.assertDidNotEmitValue()

      self.scheduler.run()

      self.applePayButtonHidden.assertDidNotEmitValue()
      self.reloadPaymentMethodsCards.assertDidNotEmitValue()
      self.reloadPaymentMethodsAvailableCardTypes.assertDidNotEmitValue()
      self.reloadPaymentMethodsProjectCountry.assertDidNotEmitValue()
      self.reloadPaymentMethodsSelectedCard.assertDidNotEmitValue()
      self.notifyDelegateLoadPaymentMethodsError.assertDidNotEmitValue()
    }
  }

  func testApplePayButtonTapped() {
    withEnvironment(currentUser: .template) {
      self.vm.inputs.configureWith((user: .template, project: .template, true))
      self.vm.inputs.viewDidLoad()

      self.notifyDelegateApplePayButtonTapped.assertDidNotEmitValue()

      self.vm.inputs.applePayButtonTapped()

      self.notifyDelegateApplePayButtonTapped.assertValueCount(1)
    }
  }

  func testApplePayButton_isHidden_applePayCapable_unsupportedProjectCountry() {
    let mockConfig = Config.template
      |> \.applePayCountries .~ [Project.Country.us.countryCode]
    let project = Project.template
      |> \.country .~ .gb

    withEnvironment(config: mockConfig) {
      self.vm.inputs.configureWith((User.template, project, true))
      self.vm.inputs.viewDidLoad()

      self.applePayButtonHidden.assertValues([true])
    }
  }

  func testApplePayButton_isNotHidden_applePayCapable_supportedProjectCountry() {
    let mockConfig = Config.template
      |> \.applePayCountries .~ [
        Project.Country.us.countryCode,
        Project.Country.gb.countryCode
      ]
    let project = Project.template
      |> \.country .~ .gb

    withEnvironment(config: mockConfig) {
      self.vm.inputs.configureWith((User.template, project, true))
      self.vm.inputs.viewDidLoad()

      self.applePayButtonHidden.assertValues([false])
    }
  }

  func testCreditCardSelected() {
    self.vm.inputs.configureWith((User.template, Project.template, true))
    self.vm.inputs.viewDidLoad()

    self.notifyDelegateCreditCardSelected.assertDidNotEmitValue()

    self.vm.inputs.creditCardSelected(paymentSourceId: "123")

    self.notifyDelegateCreditCardSelected.assertValues(["123"])

    self.vm.inputs.creditCardSelected(paymentSourceId: "abc")

    self.notifyDelegateCreditCardSelected.assertValues(["123", "abc"])
  }

  func testGoToAddNewCard() {
    let project = Project.template

    self.vm.inputs.configureWith((User.template, project, true))
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.addNewCardTapped(with: .pledge)
    self.goToAddCardIntent.assertValues([.pledge])
    self.goToProject.assertValues([project])
  }

  func testTrackingEvents() {
    let project = Project.template

    self.vm.inputs.configureWith((User.template, project, true))
    self.vm.inputs.viewDidLoad()

    XCTAssertEqual([], self.trackingClient.events)

    self.vm.inputs.addNewCardTapped(with: .pledge)

    XCTAssertEqual(["Add New Card Button Clicked"], self.trackingClient.events)
  }
}
