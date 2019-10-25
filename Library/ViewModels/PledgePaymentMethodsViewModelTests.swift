import Foundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers

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
  private let reloadPaymentMethodsProjectCountry = TestObserver<String, Never>()
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

    self.vm.outputs.reloadPaymentMethods.map { $0.cardAndIsAvailableCardType.map { $0.card } }
      .observe(self.reloadPaymentMethodsCards.observer)
    self.vm.outputs.reloadPaymentMethods.map { $0.cardAndIsAvailableCardType.map { $0.cardTypeIsAvailable } }
      .observe(self.reloadPaymentMethodsAvailableCardTypes.observer)
    self.vm.outputs.reloadPaymentMethods.map { $0.projectCountry }
      .observe(self.reloadPaymentMethodsProjectCountry.observer)

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
      self.reloadPaymentMethodsProjectCountry.assertValues(["Brooklyn, NY"])
      self.vm.inputs.addNewCardViewControllerDidAdd(newCard: userCreditCard)

      self.reloadPaymentMethodsCards.assertValues(
        [response.me.storedCards.nodes, [userCreditCard] + response.me.storedCards.nodes]
      )
      self.reloadPaymentMethodsAvailableCardTypes.assertValues([
        [true, true, true, true, true, true, false, true],
        [true, true, true, true, true, true, true, false, true]
      ])
      self.reloadPaymentMethodsProjectCountry.assertValues(["Brooklyn, NY", "Brooklyn, NY"])
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

      self.vm.inputs.configureWith((User.template, Project.template, false))
      self.vm.inputs.viewDidLoad()

      self.scheduler.run()

      self.reloadPaymentMethodsCards.assertValue(response.me.storedCards.nodes)
      self.reloadPaymentMethodsAvailableCardTypes.assertValues([
        [true, true, true, true, true, true, false, true]
      ])
      self.reloadPaymentMethodsProjectCountry.assertValues(["Brooklyn, NY"])
      self.vm.inputs.addNewCardViewControllerDidAdd(newCard: userCreditCard)

      self.reloadPaymentMethodsCards.assertValues(
        [response.me.storedCards.nodes, [userCreditCard] + response.me.storedCards.nodes]
      )
      self.reloadPaymentMethodsAvailableCardTypes.assertValues([
        [true, true, true, true, true, true, false, true],
        [true, true, true, true, true, true, true, false, true]
      ])
      self.reloadPaymentMethodsProjectCountry.assertValues(["Brooklyn, NY", "Brooklyn, NY"])

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

      self.vm.inputs.configureWith((User.template, Project.template, false))
      self.vm.inputs.viewDidLoad()

      self.scheduler.run()

      self.applePayButtonHidden.assertValues([true])
      self.reloadPaymentMethodsCards.assertValue(response.me.storedCards.nodes)
      self.reloadPaymentMethodsAvailableCardTypes.assertValues([
        [true, true, true, true, true, true, false, true]
      ])
      self.reloadPaymentMethodsProjectCountry.assertValues(["Brooklyn, NY"])
    }
  }

  func testReloadPaymentMethods_LoggedIn_ApplePayCapable_isTrue() {
    let response = UserEnvelope<GraphUserCreditCard>(me: GraphUserCreditCard.template)
    let mockService = MockService(fetchGraphCreditCardsResponse: response)

    withEnvironment(apiService: mockService, currentUser: User.template) {
      self.reloadPaymentMethodsCards.assertDidNotEmitValue()
      self.reloadPaymentMethodsAvailableCardTypes.assertDidNotEmitValue()
      self.reloadPaymentMethodsProjectCountry.assertDidNotEmitValue()
      self.applePayButtonHidden.assertDidNotEmitValue()

      self.vm.inputs.configureWith((User.template, Project.template, true))
      self.vm.inputs.viewDidLoad()

      self.scheduler.run()

      self.applePayButtonHidden.assertValues([false])
      self.reloadPaymentMethodsCards.assertValue(response.me.storedCards.nodes)
      self.reloadPaymentMethodsAvailableCardTypes.assertValues([
        [true, true, true, true, true, true, false, true]
      ])
      self.reloadPaymentMethodsProjectCountry.assertValues(["Brooklyn, NY"])
    }
  }

  func testReloadPaymentMethods_Error_LoggedIn_ApplePayCapable_isFalse() {
    let error = GraphResponseError(message: "Something went wrong")
    let apiService = MockService(fetchGraphCreditCardsError: GraphError.decodeError(error))

    withEnvironment(apiService: apiService, currentUser: User.template) {
      self.reloadPaymentMethodsCards.assertDidNotEmitValue()
      self.reloadPaymentMethodsAvailableCardTypes.assertDidNotEmitValue()
      self.reloadPaymentMethodsProjectCountry.assertDidNotEmitValue()
      self.applePayButtonHidden.assertDidNotEmitValue()

      self.vm.inputs.configureWith((User.template, Project.template, false))
      self.vm.inputs.viewDidLoad()

      self.reloadPaymentMethodsCards.assertDidNotEmitValue()
      self.reloadPaymentMethodsAvailableCardTypes.assertDidNotEmitValue()
      self.reloadPaymentMethodsProjectCountry.assertDidNotEmitValue()
      self.notifyDelegateLoadPaymentMethodsError.assertDidNotEmitValue()

      self.scheduler.run()

      self.applePayButtonHidden.assertValues([true])
      self.reloadPaymentMethodsCards.assertDidNotEmitValue()
      self.reloadPaymentMethodsAvailableCardTypes.assertDidNotEmitValue()
      self.reloadPaymentMethodsProjectCountry.assertDidNotEmitValue()
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
      self.applePayButtonHidden.assertDidNotEmitValue()

      self.vm.inputs.configureWith((User.template, Project.template, true))
      self.vm.inputs.viewDidLoad()

      self.reloadPaymentMethodsCards.assertDidNotEmitValue()
      self.reloadPaymentMethodsAvailableCardTypes.assertDidNotEmitValue()
      self.reloadPaymentMethodsProjectCountry.assertDidNotEmitValue()
      self.notifyDelegateLoadPaymentMethodsError.assertDidNotEmitValue()

      self.scheduler.run()

      self.applePayButtonHidden.assertValues([false])
      self.reloadPaymentMethodsCards.assertDidNotEmitValue()
      self.reloadPaymentMethodsAvailableCardTypes.assertDidNotEmitValue()
      self.reloadPaymentMethodsProjectCountry.assertDidNotEmitValue()
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
      self.applePayButtonHidden.assertDidNotEmitValue()

      self.scheduler.run()

      self.applePayButtonHidden.assertDidNotEmitValue()
      self.reloadPaymentMethodsCards.assertDidNotEmitValue()
      self.reloadPaymentMethodsAvailableCardTypes.assertDidNotEmitValue()
      self.reloadPaymentMethodsProjectCountry.assertDidNotEmitValue()
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
}
