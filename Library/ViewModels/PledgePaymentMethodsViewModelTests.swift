import Foundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers

final class PledgePaymentMethodsViewModelTests: TestCase {
  private let vm: PledgePaymentMethodsViewModelType = PledgePaymentMethodsViewModel()

  private let applePayButtonHidden = TestObserver<Bool, Never>()
  private let notifyDelegateApplePayButtonTapped = TestObserver<Void, Never>()
  private let notifyDelegateCreditCardSelected = TestObserver<String, Never>()
  private let notifyDelegateLoadPaymentMethodsError = TestObserver<String, Never>()
  private let pledgeButtonEnabled = TestObserver<Bool, Never>()
  private let reloadPaymentMethods = TestObserver<[GraphUserCreditCard.CreditCard], Never>()
  private let updateSelectedCreditCard = TestObserver<GraphUserCreditCard.CreditCard, Never>()

  override func setUp() {
    super.setUp()
    self.vm.outputs.applePayButtonHidden.observe(self.applePayButtonHidden.observer)
    self.vm.outputs.notifyDelegateApplePayButtonTapped
      .observe(self.notifyDelegateApplePayButtonTapped.observer)
    self.vm.outputs.notifyDelegateCreditCardSelected
      .observe(self.notifyDelegateCreditCardSelected.observer)
    self.vm.outputs.notifyDelegateLoadPaymentMethodsError
      .observe(self.notifyDelegateLoadPaymentMethodsError.observer)
    self.vm.outputs.pledgeButtonEnabled.observe(self.pledgeButtonEnabled.observer)
    self.vm.outputs.reloadPaymentMethods.observe(self.reloadPaymentMethods.observer)
    self.vm.outputs.updateSelectedCreditCard.observe(self.updateSelectedCreditCard.observer)
  }

  func testNewCardAdded() {
    let response = UserEnvelope<GraphUserCreditCard>(me: GraphUserCreditCard.template)
    let mockService = MockService(fetchGraphCreditCardsResponse: response)
    let userCreditCard = GraphUserCreditCard.amex

    withEnvironment(apiService: mockService, currentUser: User.template) {
      self.reloadPaymentMethods.assertDidNotEmitValue()

      self.vm.inputs.configureWith((User.template, Project.template, false))
      self.vm.inputs.viewDidLoad()

      self.scheduler.run()

      self.reloadPaymentMethods.assertValue(response.me.storedCards.nodes)
      self.vm.inputs.addNewCardViewControllerDidAdd(newCard: userCreditCard)

      self.reloadPaymentMethods.assertValues(
        [response.me.storedCards.nodes, [userCreditCard] + response.me.storedCards.nodes]
      )
    }
  }

  func testUpdateSelectedCreditCard() {
    self.updateSelectedCreditCard.assertDidNotEmitValue()

    let response = UserEnvelope<GraphUserCreditCard>(me: GraphUserCreditCard.template)
    let mockService = MockService(fetchGraphCreditCardsResponse: response)
    let userCreditCard = GraphUserCreditCard.amex

    withEnvironment(apiService: mockService, currentUser: User.template) {
      self.reloadPaymentMethods.assertDidNotEmitValue()

      self.vm.inputs.configureWith((User.template, Project.template, false))
      self.vm.inputs.viewDidLoad()

      self.scheduler.run()

      self.reloadPaymentMethods.assertValue(response.me.storedCards.nodes)
      self.vm.inputs.addNewCardViewControllerDidAdd(newCard: userCreditCard)

      self.reloadPaymentMethods.assertValues(
        [response.me.storedCards.nodes, [userCreditCard] + response.me.storedCards.nodes]
      )

      self.vm.inputs.creditCardSelected(paymentSourceId: userCreditCard.id)

      self.updateSelectedCreditCard.assertValues([userCreditCard])
    }
  }

  func testReloadPaymentMethods_LoggedIn_ApplePayCapable_isFalse() {
    let response = UserEnvelope<GraphUserCreditCard>(me: GraphUserCreditCard.template)
    let mockService = MockService(fetchGraphCreditCardsResponse: response)

    withEnvironment(apiService: mockService, currentUser: User.template) {
      self.reloadPaymentMethods.assertDidNotEmitValue()
      self.applePayButtonHidden.assertDidNotEmitValue()

      self.vm.inputs.configureWith((User.template, Project.template, false))
      self.vm.inputs.viewDidLoad()

      self.scheduler.run()

      self.applePayButtonHidden.assertValues([true])
      self.reloadPaymentMethods.assertValue(response.me.storedCards.nodes)
    }
  }

  func testReloadPaymentMethods_LoggedIn_ApplePayCapable_isTrue() {
    let response = UserEnvelope<GraphUserCreditCard>(me: GraphUserCreditCard.template)
    let mockService = MockService(fetchGraphCreditCardsResponse: response)

    withEnvironment(apiService: mockService, currentUser: User.template) {
      self.reloadPaymentMethods.assertDidNotEmitValue()
      self.applePayButtonHidden.assertDidNotEmitValue()

      self.vm.inputs.configureWith((User.template, Project.template, true))
      self.vm.inputs.viewDidLoad()

      self.scheduler.run()

      self.applePayButtonHidden.assertValues([false])
      self.reloadPaymentMethods.assertValue(response.me.storedCards.nodes)
    }
  }

  func testReloadPaymentMethods_Error_LoggedIn_ApplePayCapable_isFalse() {
    let error = GraphResponseError(message: "Something went wrong")
    let apiService = MockService(fetchGraphCreditCardsError: GraphError.decodeError(error))

    withEnvironment(apiService: apiService, currentUser: User.template) {
      self.reloadPaymentMethods.assertDidNotEmitValue()
      self.applePayButtonHidden.assertDidNotEmitValue()

      self.vm.inputs.configureWith((User.template, Project.template, false))
      self.vm.inputs.viewDidLoad()

      self.reloadPaymentMethods.assertDidNotEmitValue()
      self.notifyDelegateLoadPaymentMethodsError.assertDidNotEmitValue()

      self.scheduler.run()

      self.applePayButtonHidden.assertValues([true])
      self.reloadPaymentMethods.assertDidNotEmitValue()
      self.notifyDelegateLoadPaymentMethodsError.assertValue("Something went wrong")
    }
  }

  func testReloadPaymentMethods_Error_LoggedIn_ApplePayCapable_isTrue() {
    let error = GraphResponseError(message: "Something went wrong")
    let apiService = MockService(fetchGraphCreditCardsError: GraphError.decodeError(error))

    withEnvironment(apiService: apiService, currentUser: User.template) {
      self.reloadPaymentMethods.assertDidNotEmitValue()
      self.applePayButtonHidden.assertDidNotEmitValue()

      self.vm.inputs.configureWith((User.template, Project.template, true))
      self.vm.inputs.viewDidLoad()

      self.reloadPaymentMethods.assertDidNotEmitValue()
      self.notifyDelegateLoadPaymentMethodsError.assertDidNotEmitValue()

      self.scheduler.run()

      self.applePayButtonHidden.assertValues([false])
      self.reloadPaymentMethods.assertDidNotEmitValue()
      self.notifyDelegateLoadPaymentMethodsError.assertValue("Something went wrong")
    }
  }

  func testReloadPaymentMethods_LoggedOut() {
    let response = UserEnvelope<GraphUserCreditCard>(me: GraphUserCreditCard.template)
    let mockService = MockService(fetchGraphCreditCardsResponse: response)

    withEnvironment(apiService: mockService, currentUser: nil) {
      self.vm.inputs.viewDidLoad()

      self.reloadPaymentMethods.assertDidNotEmitValue()
      self.applePayButtonHidden.assertDidNotEmitValue()

      self.scheduler.run()

      self.applePayButtonHidden.assertDidNotEmitValue()
      self.reloadPaymentMethods.assertDidNotEmitValue()
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

  func testPledgeButtonEnabled() {
    self.vm.inputs.configureWith((User.template, Project.template, true))
    self.vm.inputs.viewDidLoad()

    self.pledgeButtonEnabled.assertValues([false], "Defaults to false")

    self.vm.inputs.updatePledgeButtonEnabled(isEnabled: true)

    self.pledgeButtonEnabled.assertValues([false, true])

    self.vm.inputs.updatePledgeButtonEnabled(isEnabled: true)

    self.pledgeButtonEnabled.assertValues([false, true], "Skips repeats")

    self.vm.inputs.updatePledgeButtonEnabled(isEnabled: false)

    self.pledgeButtonEnabled.assertValues([false, true, false])
  }
}
